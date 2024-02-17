/*
 * Line theme engine
 *
 * line.c
 *
 * Copyright (C) 2006 Quinn Storm <livinglatexkali@gmail.com>
 * Copyright (C) 2007 Patrick Niklaus <patrick.niklaus@googlemail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

#include <emerald.h>
#include <engine.h>

#include "line_engine.h"

#define SECT "line_settings"

#define SHADOW_FIX

/*
 * color privates
 */
typedef struct _private_fs
{
    alpha_color border;
	alpha_color title_bar;
} private_fs;

/*
 * settings privates
 */
typedef struct _private_ws
{
} private_ws;

void get_meta_info (EngineMetaInfo * emi)
{
    emi->version = g_strdup("0.1");
    emi->description = g_strdup(_("Based on original legacy"));
    emi->last_compat = g_strdup("0.0"); // old themes still compatible
    emi->icon = gdk_pixbuf_new_from_inline(-1, my_pixbuf, TRUE, NULL);
}

#ifdef SHADOW_FIX
static void draw_shadow_background(decor_t * d, cairo_t * cr)
{
	cairo_matrix_t matrix;
	double w, x2;
	gint width, height;
	gint left, right, top, bottom;
	window_settings *ws = d->fs->ws;

	if (!ws->large_shadow_pixmap)
	{
		cairo_set_source_rgba(cr, 0.0, 0.0, 0.0, 0.0);
		cairo_paint(cr);

		return;
	}

	gdk_drawable_get_size(ws->large_shadow_pixmap, &width, &height);

	left = ws->left_space + ws->left_corner_space;
	right = ws->right_space + ws->right_corner_space;
	top = ws->top_space + ws->top_corner_space;
	bottom = ws->bottom_space + ws->bottom_corner_space;

	if (d->width - left - right < 0)
	{
		left = d->width / 2;
		right = d->width - left;
	}

	if (d->height - top - bottom < 0)
	{
		top = d->height / 2;
		bottom = d->height - top;
	}

	w = d->width - left - right;

	x2 = d->width - right;

	/* top left */
	cairo_matrix_init_identity(&matrix);
	cairo_pattern_set_matrix(ws->shadow_pattern, &matrix);
	cairo_set_source(cr, ws->shadow_pattern);
	cairo_rectangle(cr, 0.0, 0.0, left, top);
	cairo_fill(cr);

	/* top */
	if (w > 0)
	{
		cairo_matrix_init_translate(&matrix, left, 0.0);
		cairo_matrix_scale(&matrix, 1.0 / w, 1.0);
		cairo_matrix_translate(&matrix, -left, 0.0);
		cairo_pattern_set_matrix(ws->shadow_pattern, &matrix);
		cairo_set_source(cr, ws->shadow_pattern);
		cairo_rectangle(cr, left, 0.0, w, top);
		cairo_fill(cr);
	}

	
	/* top right */
	cairo_matrix_init_translate(&matrix, width - right - x2, 0.0);
	cairo_pattern_set_matrix(ws->shadow_pattern, &matrix);
	cairo_set_source(cr, ws->shadow_pattern);
	cairo_rectangle(cr, x2, 0.0, right, top);
	cairo_clip_preserve(cr);
	cairo_fill(cr);
}
#endif

void engine_draw_frame (decor_t * d, cairo_t * cr)
{
    frame_settings *fs = d->fs;
    private_fs *pfs = fs->engine_fs;
    window_settings *ws = fs->ws;

    double x1, y1, x2, y2;

    x1 = ws->left_space - ws->win_extents.left;
    y1 = ws->top_space - ws->win_extents.top;
    x2 = d->width  - ws->right_space  + ws->win_extents.right;
    y2 = d->height - ws->bottom_space + ws->win_extents.bottom;
	int top;
	top = ws->win_extents.top + ws->titlebar_height;

	double m1 = MIN(ws->win_extents.left, ws->win_extents.right);
	double m2 = MIN(ws->win_extents.top,  ws->win_extents.bottom);
	
	double border_width = MIN(m1, m2);
	double border_offset = border_width/2.0;

    cairo_set_line_width (cr, border_width);
	
	cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE);

    rounded_rectangle (cr,
            x1 + border_offset,
			y1 + top - border_offset,
            x2 - x1 - border_width,
			y2 - y1 - top,
            0, ws, 0);
	cairo_set_source_alpha_color(cr, &pfs->border);
	cairo_stroke (cr);

	// title bar
	if (pfs->title_bar.alpha != 0.0) {
		rounded_rectangle (cr,
				x1,
				y1,
				x2 - x1,
				top,
				0, ws, 0);
		cairo_set_source_alpha_color(cr, &pfs->title_bar);
		cairo_fill(cr);
	} else {
		cairo_save(cr);
		cairo_set_operator (cr, CAIRO_OPERATOR_CLEAR);
		cairo_rectangle (cr, 0.0, 0.0, d->width, top + y1 - border_width);
		cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
		cairo_fill(cr);
		cairo_restore(cr);

// FIXME => find a proper solution for this
#ifdef SHADOW_FIX
		cairo_rectangle (cr, 0.0, 0.0, d->width, top + y1 - border_width);
		cairo_clip(cr);
		cairo_translate(cr, 0.0, ws->top_space + ws->win_extents.top);
		draw_shadow_background(d, cr);
		cairo_translate(cr, 0.0, -ws->top_space - ws->win_extents.top);
#endif
	}
}

void load_engine_settings(GKeyFile * f, window_settings * ws)
{
    PFACS(border);
	PFACS(title_bar);
}

void init_engine(window_settings * ws)
{
    private_fs * pfs;
    private_ws * pws;

    pws = malloc(sizeof(private_ws));
    ws->engine_ws = pws;
    bzero(pws,sizeof(private_ws));

    pfs = malloc(sizeof(private_fs));
    ws->fs_act->engine_fs = pfs;
    bzero(pfs, sizeof(private_fs));
    ACOLOR(border, 0.0, 0.0, 0.0, 1.0);
	ACOLOR(title_bar, 0.0, 0.0, 0.0, 0.3);

	pfs = malloc(sizeof(private_fs));
    ws->fs_inact->engine_fs = pfs;
    bzero(pfs,sizeof(private_fs));
    ACOLOR(border, 0.0, 0.0, 0.0, 1.0);
	ACOLOR(title_bar, 0.0, 0.0, 0.0, 0.0);
}

void fini_engine(window_settings * ws)
{
    free(ws->fs_act->engine_fs);
    free(ws->fs_inact->engine_fs);
}
#if 0
void my_engine_settings(GtkWidget * hbox, gboolean active)
{
    GtkWidget * vbox;
    GtkWidget * scroller;
    vbox = gtk_vbox_new(FALSE,2);
    gtk_box_pack_startC(hbox, vbox, TRUE, TRUE, 0);
    gtk_box_pack_startC(vbox, gtk_label_new(active?"Active Window":"Inactive Window"), FALSE, FALSE, 0);
    gtk_box_pack_startC(vbox, gtk_hseparator_new(), FALSE, FALSE, 0);
    scroller = gtk_scrolled_window_new(NULL,NULL);
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scroller), GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC);
    gtk_box_pack_startC(vbox, scroller, TRUE, TRUE, 0);
    
    table_new(3, FALSE, FALSE);

    gtk_scrolled_window_add_with_viewport(GTK_SCROLLED_WINDOW(scroller), GTK_WIDGET(get_current_table()));
    
    make_labels(_("Colors"));
    table_append_separator();
    ACAV(_("Outer Frame Blend"), "border", SECT);
	ACAV(_("Title Bar"), "title_bar", SECT);
}

void layout_engine_colors(GtkWidget * vbox)
{
    GtkWidget * hbox;
    hbox = gtk_hbox_new(FALSE, 2);
    gtk_box_pack_startC(vbox, hbox, TRUE, TRUE, 0);
    my_engine_settings(hbox, TRUE);
    gtk_box_pack_startC(hbox, gtk_vseparator_new(), FALSE, FALSE, 0);
    my_engine_settings(hbox, FALSE);
}

void layout_engine_settings(GtkWidget * vbox)
{
    GtkWidget * note;
    note = gtk_notebook_new();
    gtk_box_pack_startC(vbox, note, TRUE, TRUE, 0);
    layout_engine_colors(build_notebook_page(_("Colors"), note));
}
#endif
