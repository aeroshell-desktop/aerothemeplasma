/*
 * vrunner theme engine
 *
 * vrunner.c
 *
 * Copyright (C) 2006 Quinn Storm <livinglatexkali@gmail.com> (original legacy theme engine)
 * Copyright (C) 2006 Varun <varunratnakar@gmail.com>
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
 */

//vrunner engine
#include <emerald.h>
#include <engine.h>
#include "vrunner_engine.h"

#define SECT "vrunner_settings"

#define FLTS(flt) \
    load_float_setting(f,&((private_fs *)ws->fs_act->engine_fs)->flt,"active_" #flt ,SECT);\
    load_float_setting(f,&((private_fs *)ws->fs_inact->engine_fs)->flt,"inactive_" #flt ,SECT);

/*
 * settings structs
 */
typedef struct _private_fs
{
    alpha_color title_left;
    alpha_color title_left_lower;
    alpha_color title_middle;
    alpha_color title_middle_lower;
    alpha_color title_right;
    alpha_color title_right_lower;
    alpha_color window_halo;
    alpha_color window_highlight;
    alpha_color window_shadow;
    alpha_color separator_line;
    alpha_color contents_highlight;
    alpha_color contents_shadow;
    alpha_color contents_halo;
    double	title_notch_position;
    double	curve_offset;
    double	frame_notch_position;
    double	color_contrast;
    double	alpha_contrast;
    double	glow_radius;
    alpha_color glow_inner;
    gboolean	use_glow;
} private_fs;

typedef struct _private_ws
{
    gboolean round_top_left;
    gboolean round_top_right;
    gboolean round_bottom_left;
    gboolean round_bottom_right;
    double	corner_radius;
} private_ws;

void get_meta_info (EngineMetaInfo * emi)
{
    emi->version = g_strdup("0.2");
    emi->description = g_strdup(_("Multiple gradients with somewhat glassy features too"));
    emi->last_compat = g_strdup("0.0"); // old themes marked still compatible for now
    emi->icon = gdk_pixbuf_new_from_inline(-1, my_pixbuf, TRUE, NULL);
}

void
draw_closed_curve (cairo_t *cr,
        double  x,
        double  y,
        double  w,
        double  h,
        double ch,
        gboolean tophalf)
{
    cairo_move_to (cr, x, y);
    if(tophalf || ch == 0) 
       cairo_line_to (cr, x + w, y);
    else 
       cairo_curve_to (cr, x, y, x + w/2, y + ch, x + w, y);

    cairo_line_to (cr, x + w, y + h);

    if(tophalf && ch != 0)
       cairo_curve_to (cr, x + w, y + h, x + w/2, y + h + ch, x, y + h);
    else
       cairo_line_to (cr, x, y + h);

    cairo_line_to (cr, x, y);
}

void
draw_filled_closed_curve (cairo_t *cr,
        double        x,
        double        y,
        double        w,
        double        h,
        double        ch,
        gboolean      tophalf,
        alpha_color * c0,
        alpha_color * c1,
        alpha_color * c2)
{
    cairo_pattern_t *pattern;

    draw_closed_curve (cr, x, y, w, h, ch, tophalf);

    pattern = cairo_pattern_create_linear (x, y, x + w, y + h);
    cairo_pattern_add_color_stop_rgba (pattern, 0.0, c0->color.r, c0->color.g,
            c0->color.b,c0->alpha);
    cairo_pattern_add_color_stop_rgba (pattern, 0.5, c1->color.r, c1->color.g,
            c1->color.b,c1->alpha);
    cairo_pattern_add_color_stop_rgba (pattern, 1.0, c2->color.r, c2->color.g,
            c2->color.b,c2->alpha);
    //cairo_pattern_set_extend (pattern, CAIRO_EXTEND_PAD);
    cairo_set_source (cr, pattern);
    cairo_fill (cr);
    cairo_pattern_destroy (pattern);
}

void create_glow(decor_t *d, cairo_t *cr,
                 double x, double y, double w, double h, 
                 alpha_color * c0, double p)
{
       double r = 0.0;
       double wp = p;
       double hp = p;
       //cairo_rectangle(cr, x1, y1, w, h);
       frame_settings * fs = d->fs;
       // private_fs * pfs = fs->engine_fs;
       window_settings * ws = fs->ws;
       if(wp*2 > w) wp = w/2;
       if(hp*2 > h) hp = h/2;

       x = x+wp;
       y = y+hp;
       wp = wp*2;
       hp = hp*2;
       w = w-wp;
       h = h-hp;

       alpha_color c1;
       c1.color = c0->color;
       c1.alpha = 0;
       cairo_set_operator (cr, CAIRO_OPERATOR_OVER);

       fill_rounded_rectangle (cr,
            x-wp, y-hp, wp, hp, CORNER_TOPLEFT, 
	     c0, &c1, (SHADE_LEFT | SHADE_TOP ), ws, r);
       fill_rounded_rectangle (cr,
            x, y-hp, w, hp, 0, 
	    c0, &c1, SHADE_TOP, ws, r);
       fill_rounded_rectangle (cr,
            x+w, y-hp, wp, hp, CORNER_TOPRIGHT, 
	     c0, &c1, (SHADE_RIGHT | SHADE_TOP ), ws, r);
       fill_rounded_rectangle (cr,
            x-wp, y, wp, h, 0, 
	    c0, &c1, SHADE_LEFT, ws, r);
       fill_rounded_rectangle (cr,
            x+w, y, wp, h, 0, 
	    c0, &c1, SHADE_RIGHT, ws, r);
       fill_rounded_rectangle (cr,
            x-wp, y+h, wp, hp, CORNER_BOTTOMLEFT, 
	     c0, &c1, (SHADE_LEFT | SHADE_BOTTOM ), ws, r);
       fill_rounded_rectangle (cr,
            x, y+h, w, hp, 0, 
	    c0, &c1, SHADE_BOTTOM, ws, r);
       fill_rounded_rectangle (cr,
            x+w, y+h, wp, hp, CORNER_BOTTOMRIGHT, 
	     c0, &c1, (SHADE_RIGHT | SHADE_BOTTOM ), ws, r);

       cairo_rectangle (cr, x, y, w, h);
       cairo_set_source_alpha_color (cr, c0);
       cairo_fill (cr);
}
                                        
static gint get_real_pos(window_settings * ws, gint tobj, decor_t * d)
{
    gint width = d->width;
    gint base = ws->left_space;
    switch(d->tobj_item_state[tobj])
    {
        case 1:
            base = (width - ws->left_space - ws->right_space - d->tobj_size[0] - d->tobj_size[2]) / 2
                 - d->tobj_size[1]/2 + ws->left_space + d->tobj_size[0];
            break;
        case 2:
            base = width - ws->right_space - d->tobj_size[2];
            break;
        case 3:
            return -1;
        default:
            break;
    }
    return base + d->tobj_item_pos[tobj];
}

void engine_draw_frame (decor_t * d, cairo_t * cr)
{
    double        x1, y1, x2, y2, h, 
                  top_title_height, bottom_title_height, 
                  top_left, top_right;
    int           top, title_width = 0, title_height = 0, title_pos;
    // double        curve_offset;
    frame_settings * fs = d->fs;
    private_fs * pfs = fs->engine_fs;
    window_settings * ws = fs->ws;
    private_ws * pws = ws->engine_ws;
    gdouble pleft;
    gdouble ptop;
    gdouble pwidth;
    gdouble pheight;
    top = ws->win_extents.top + ws->titlebar_height;

    x1 = ws->left_space - ws->win_extents.left;
    y1 = ws->top_space - ws->win_extents.top;
    x2 = d->width - ws->right_space + ws->win_extents.right;
    y2 = d->height - ws->bottom_space + ws->win_extents.bottom;
    pleft   = x1 + ws->win_extents.left - 0.5;
    ptop    = y1 + top - 0.5;
    pwidth  = x2 - x1 - ws->win_extents.left - ws->win_extents.right + 1;
    pheight = y2 - y1 - top-ws->win_extents.bottom + 1;

    h = d->height - ws->top_space - ws->titlebar_height - ws->bottom_space;

    int corners = 
        ((pws->round_top_left)     ? CORNER_TOPLEFT     : 0) |
        ((pws->round_top_right)    ? CORNER_TOPRIGHT    : 0) |
        ((pws->round_bottom_left)  ? CORNER_BOTTOMLEFT  : 0) |
        ((pws->round_bottom_right) ? CORNER_BOTTOMRIGHT : 0);
    
	// maximize work-a-round
	if (d->state & (WNCK_WINDOW_STATE_MAXIMIZED_HORIZONTALLY |
                WNCK_WINDOW_STATE_MAXIMIZED_VERTICALLY))
        corners = 0;

    cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE);
    cairo_set_line_width (cr, 0.0);

    top_title_height    = (top - 0.5)*pfs->title_notch_position + 1;
    bottom_title_height = (top - 0.5)*(1-pfs->title_notch_position) + 1;

    top_left = ws->win_extents.left;
    top_right = ws->win_extents.right;
    if((top_left < pws->corner_radius) && (corners & CORNER_TOPLEFT))
		top_left = pws->corner_radius;
    if((top_right < pws->corner_radius) && (corners & CORNER_TOPRIGHT))
		top_right = pws->corner_radius;

    // Main Top Titlebar
    rounded_rectangle (cr,
            x1 + 0.5,
            y1 + 0.5,
            x2 - x1 - 1,
            top + 1,
            (CORNER_TOPLEFT | CORNER_TOPRIGHT) & corners, ws,
            pws->corner_radius);
    cairo_clip(cr);

    draw_filled_closed_curve(cr,
            x1 + 0.5,
            y1 + 0.5,
            x2 - x1 - 1,
            top_title_height + 1,
            pfs->curve_offset,
            TRUE,
            &pfs->title_left,
            &pfs->title_middle,
            &pfs->title_right);

    draw_filled_closed_curve(cr,
            x1 + 0.5,
            y1 + top_title_height - 1,
            x2 - x1 - 1,
            bottom_title_height + 2,
            pfs->curve_offset,
            FALSE,
            &pfs->title_left_lower,
            &pfs->title_middle_lower,
            &pfs->title_right_lower);

    cairo_reset_clip(cr);

    // Left and Right
    fill_rounded_rectangle (cr,
            x1+0.5,
            y1 + top - 0.5,
            ws->win_extents.left,
            h + 0.5,
            0,
            &pfs->title_left_lower,&pfs->title_left_lower,
            SHADE_BOTTOM, ws,
            pws->corner_radius);

    fill_rounded_rectangle (cr,
            x2 - ws->win_extents.right-0.5,
            y1 + top - 0.5,
            ws->win_extents.right,
            h + 0.5,
            0,
            &pfs->title_right_lower,&pfs->title_right_lower,
            SHADE_BOTTOM, ws,
            pws->corner_radius);

    // Bottom Frame
    rounded_rectangle (cr,
            x1 + 0.5,
            y2 - ws->win_extents.bottom,
            x2 - x1 - 1,
            ws->win_extents.bottom,
            (CORNER_BOTTOMLEFT | CORNER_BOTTOMRIGHT) & corners, ws,
            pws->corner_radius);

    cairo_clip(cr);

    draw_filled_closed_curve(cr,
            x1 + 0.5,
            y2 - ws->win_extents.bottom,
            x2 - x1 - 1,
            ws->win_extents.bottom,
            0,
            TRUE,
            &pfs->title_left_lower,
            &pfs->title_middle_lower,
            &pfs->title_right_lower);

    cairo_reset_clip(cr);

    // Title Glow
    if(pfs->use_glow) {
       cairo_set_operator (cr, CAIRO_OPERATOR_ATOP);

       if(PANGO_IS_LAYOUT(d->layout))
          pango_layout_get_pixel_size(d->layout, &title_width, &title_height);
       title_pos = get_real_pos(ws, TBT_TITLE, d);
       create_glow (d, cr, title_pos, y1 + top/2.0 - title_height/2.0,
                           title_width, title_height,
                           &pfs->glow_inner, pfs->glow_radius);
    }


	// ======= NEW LAYER ======
    cairo_set_operator (cr, CAIRO_OPERATOR_OVER);
    cairo_set_line_width (cr, 1.0);

    // Titlebar Separator
    if(pfs->separator_line.alpha > 0) {
       cairo_set_source_alpha_color(cr, &pfs->separator_line);
       cairo_move_to (cr, x1 + 0.5, y1 + top - 0.5);
       cairo_rel_line_to (cr, x2 - x1 - 1, 0.0);
       cairo_stroke (cr);
    }

    // Frame Clip
    rounded_rectangle (cr,
            x1 + 0.5, y1 + 0.5,
            x2 - x1 - 1.0, y2 - y1 - 1.0,
            (CORNER_TOPLEFT | CORNER_TOPRIGHT | CORNER_BOTTOMLEFT |
             CORNER_BOTTOMRIGHT) & corners, ws,
            pws->corner_radius);
    cairo_clip (cr);

	cairo_translate (cr, 1.0, 1.0);

	// highlight
    rounded_rectangle (cr,
            x1 + 0.5, y1 + 0.5,
            x2 - x1 - 1.0, y2 - y1 - 1.0,
            (CORNER_TOPLEFT | CORNER_TOPRIGHT | CORNER_BOTTOMLEFT |
             CORNER_BOTTOMRIGHT) & corners, ws,
            pws->corner_radius);

    cairo_set_source_alpha_color (cr, &pfs->window_highlight);
    cairo_stroke (cr);

    cairo_translate (cr, -2.0, -2.0);

	// shadow
    rounded_rectangle (cr,
            x1 + 0.5, y1 + 0.5,
            x2 - x1 - 1.0, y2 - y1 - 1.0,
            (CORNER_TOPLEFT | CORNER_TOPRIGHT | CORNER_BOTTOMLEFT |
             CORNER_BOTTOMRIGHT) & corners, ws,
            pws->corner_radius);

    cairo_set_source_alpha_color (cr, &pfs->window_shadow);
    cairo_stroke (cr);

    cairo_translate (cr, 1.0, 1.0);

    cairo_reset_clip (cr);
	
	// halo
    rounded_rectangle (cr,
            x1 + 0.5, y1 + 0.5,
            x2 - x1 - 1.0, y2 - y1 - 1.0,
            (CORNER_TOPLEFT | CORNER_TOPRIGHT | CORNER_BOTTOMLEFT |
             CORNER_BOTTOMRIGHT) & corners, ws,
            pws->corner_radius);

    cairo_set_source_alpha_color (cr, &pfs->window_halo);
    cairo_stroke (cr);

    // inner border
    //TODO - make this a bit more pixel-perfect...but it works for now

    cairo_set_line_width (cr, 1.0);

    cairo_move_to (cr, pleft + pwidth + 1.5, ptop - 1);
    cairo_rel_line_to (cr, -pwidth - 2.5, 0);
    cairo_rel_line_to (cr, 0, pheight + 2.5);
    cairo_set_source_alpha_color (cr, &pfs->contents_shadow);
    cairo_stroke (cr);

    cairo_move_to (cr, pleft + pwidth + 1, ptop - 1.5);
    cairo_rel_line_to (cr, 0, pheight + 2.5);
    cairo_rel_line_to (cr, -pwidth - 2.5, 0);
    cairo_set_source_alpha_color (cr, &pfs->contents_highlight);
    cairo_stroke (cr);

    cairo_move_to (cr, pleft, ptop);
    cairo_rel_line_to (cr, pwidth, 0);
    cairo_rel_line_to (cr, 0, pheight);
    cairo_rel_line_to (cr, -pwidth, 0);
    cairo_rel_line_to (cr, 0, -pheight);
    cairo_set_source_alpha_color (cr, &pfs->contents_halo);
    cairo_stroke(cr);
}

void load_engine_settings(GKeyFile * f, window_settings * ws)
{
    private_ws * pws = ws->engine_ws;

	// color settings
    PFACS(title_left);
    PFACS(title_middle);
    PFACS(title_right);
    PFACS(window_halo);
    PFACS(window_highlight);
    PFACS(window_shadow);
    PFACS(separator_line);
    PFACS(contents_shadow);
    PFACS(contents_highlight);
    PFACS(contents_halo);
    PFACS(glow_inner);
    FLTS(color_contrast);
    FLTS(glow_radius);
    FLTS(alpha_contrast);
    FLTS(curve_offset);
    FLTS(title_notch_position);

    private_fs * pfs = ws->fs_act->engine_fs;
    CCOLOR(title_left_lower, title_left);
    CCOLOR(title_middle_lower, title_middle);
    CCOLOR(title_right_lower, title_right);
    load_bool_setting(f, &pfs->use_glow, "active_use_glow", SECT);

    pfs = ws->fs_inact->engine_fs;
    CCOLOR(title_left_lower, title_left);
    CCOLOR(title_middle_lower, title_middle);
    CCOLOR(title_right_lower, title_right);
    load_bool_setting(f, &pfs->use_glow, "inactive_use_glow", SECT);

    load_bool_setting(f, &pws->round_top_left, "round_top_left", SECT);
    load_bool_setting(f, &pws->round_top_right, "round_top_right", SECT);
    load_bool_setting(f, &pws->round_bottom_left, "round_bottom_left", SECT);
    load_bool_setting(f, &pws->round_bottom_right, "round_bottom_right", SECT);
    load_float_setting(f, &pws->corner_radius, "radius", SECT);
}

void init_engine(window_settings * ws)
{
    private_fs * pfs;
    private_ws * pws;

    pws = malloc(sizeof(private_ws));
    ws->engine_ws = pws;
    bzero(pws, sizeof(private_ws));
    pws->round_top_left = TRUE;
    pws->round_top_right = TRUE;
    pws->round_bottom_left = TRUE;
    pws->round_bottom_right = TRUE;
    pws->corner_radius = 5.0;

    pfs = malloc(sizeof(private_fs));
    ws->fs_act->engine_fs = pfs;
    bzero(pfs, sizeof(private_fs));
    pfs->title_notch_position = 0.5;
    pfs->curve_offset = 0.0;
    pfs->color_contrast = 0.9;
    pfs->use_glow = FALSE;
    pfs->alpha_contrast = 0.9;
    pfs->glow_radius = 7.0;
    ACOLOR(title_left, 0.8, 0.8, 0.8, 0.8);
    CCOLOR(title_left_lower,title_left);
    ACOLOR(title_middle, 0.8, 0.8, 0.8, 0.8);
    CCOLOR(title_middle_lower, title_middle);
    ACOLOR(title_right, 0.8, 0.8, 0.8, 0.8);
    CCOLOR(title_right_lower, title_right);
    ACOLOR(window_highlight, 1.0, 1.0, 1.0, 0.8);
    ACOLOR(window_shadow, 0.6, 0.6, 0.6, 0.8);
    ACOLOR(window_halo, 0.8, 0.8, 0.8, 0.8);
    ACOLOR(separator_line, 0.0, 0.0, 0.0, 0.0);
    ACOLOR(contents_highlight, 1.0, 1.0, 1.0, 0.8);
    ACOLOR(contents_shadow, 0.6, 0.6, 0.6, 0.8);
    ACOLOR(contents_halo, 0.8, 0.8, 0.8, 0.8);
    ACOLOR(glow_inner, 0.9, 0.9, 0.9, 0.9);

    pfs = malloc(sizeof(private_fs));
    bzero(pfs, sizeof(private_fs));
    ws->fs_inact->engine_fs = pfs;
    pfs->title_notch_position = 0.5;
    pfs->curve_offset = 0.0;
    pfs->color_contrast = 0.9;
    pfs->alpha_contrast = 0.9;
    pfs->use_glow = FALSE;
    pfs->glow_radius = 7.0;
    ACOLOR(title_left, 0.8, 0.8, 0.8,0.6);
    CCOLOR(title_left_lower, title_left);
    ACOLOR(title_middle, 0.8, 0.8, 0.8, 0.6);
    CCOLOR(title_middle_lower, title_middle);
    ACOLOR(title_right, 0.8, 0.8, 0.8, 0.6);
    CCOLOR(title_right_lower, title_right);
    ACOLOR(window_highlight,1.0, 1.0, 1.0, 0.7);
    ACOLOR(window_shadow, 0.6, 0.6, 0.6, 0.7);
    ACOLOR(window_halo, 0.8, 0.8, 0.8, 0.7);
    ACOLOR(separator_line, 0.0, 0.0, 0.0, 0.0);
    ACOLOR(contents_highlight, 1.0, 1.0, 1.0, 0.8);
    ACOLOR(contents_shadow, 0.6, 0.6, 0.6, 0.8);
    ACOLOR(contents_halo, 0.8, 0.8, 0.8, 0.8);
    ACOLOR(glow_inner, 0.9, 0.9, 0.9, 0.9);
}

void fini_engine(window_settings * ws)
{
    free(ws->fs_act->engine_fs);
    free(ws->fs_inact->engine_fs);
}
#if 0
void layout_corners_frame(GtkWidget * vbox)
{
    GtkWidget * hbox;
    GtkWidget * junk;

    junk = gtk_check_button_new_with_label(_("Round Top Left Corner"));
    gtk_box_pack_startC(vbox, junk, FALSE, FALSE, 0);
    register_setting(junk, ST_BOOL, SECT, "round_top_left");

    junk = gtk_check_button_new_with_label(_("Round Top Right Corner"));
    gtk_box_pack_startC(vbox, junk, FALSE, FALSE, 0);
    register_setting(junk, ST_BOOL, SECT, "round_top_right");

    junk = gtk_check_button_new_with_label(_("Round Bottom Left Corner"));
    gtk_box_pack_startC(vbox, junk, FALSE, FALSE, 0);
    register_setting(junk, ST_BOOL, SECT, "round_bottom_left");

    junk = gtk_check_button_new_with_label(_("Round Bottom Right Corner"));
    gtk_box_pack_startC(vbox, junk, FALSE, FALSE, 0);
    register_setting(junk, ST_BOOL, SECT, "round_bottom_right");

    hbox = gtk_hbox_new(FALSE, 2);
    gtk_box_pack_startC(vbox, hbox, FALSE, FALSE, 0);
    
    gtk_box_pack_startC(hbox, gtk_label_new(_("Rounding Radius")), FALSE, FALSE, 0);

    junk = scaler_new(0, 20, 0.5);
    gtk_box_pack_startC(hbox, junk, TRUE, TRUE, 0);
    register_setting(junk, ST_FLOAT, SECT, "radius");

}
void my_engine_settings(GtkWidget * hbox,  gboolean active)
{
    GtkWidget * vbox;
    GtkWidget * junk;
    GtkWidget * scroller;

    vbox = gtk_vbox_new(FALSE, 2);
    gtk_box_pack_startC(hbox, vbox, TRUE, TRUE, 0);
    gtk_box_pack_startC(vbox, gtk_label_new(active ? "Active Window" : "Inactive Window"), FALSE, FALSE, 0);
    gtk_box_pack_startC(vbox, gtk_hseparator_new(), FALSE, FALSE, 0);
    scroller = gtk_scrolled_window_new(NULL, NULL);
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scroller), 
            GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC);
    gtk_box_pack_startC(vbox, scroller, TRUE, TRUE, 0);
    
    table_new(3, FALSE, FALSE);

    gtk_scrolled_window_add_with_viewport(GTK_SCROLLED_WINDOW(scroller), GTK_WIDGET(get_current_table()));
    
    make_labels(_("Colors"));
    table_append_separator();
    ACAV(_("Left Blend"), "title_left", SECT);
    ACAV(_("Middle Blend"), "title_middle", SECT);
    ACAV(_("Right Blend"), "title_right", SECT);

    table_append_separator();
    junk = gtk_label_new(_("Contrast"));
    table_append(junk,  FALSE);
    junk = gtk_label_new(_("(Color)"));
    table_append(junk,  FALSE);
    junk = scaler_new(0, 1, 0.01);
    table_append(junk,  FALSE);
    if(active)
		register_setting(junk, ST_FLOAT, SECT, "active_color_contrast");
    else
		register_setting(junk, ST_FLOAT, SECT, "inactive_color_contrast");

    junk = gtk_label_new(_("Contrast"));
    table_append(junk, FALSE);
    junk = gtk_label_new(_("(Alpha)"));
    table_append(junk, FALSE);
    junk = scaler_new(0, 1, 0.01);
    table_append(junk, FALSE);
    if(active)
		register_setting(junk, ST_FLOAT, SECT, "active_alpha_contrast");
    else
		register_setting(junk, ST_FLOAT, SECT, "inactive_alpha_contrast");

    junk = gtk_label_new(_("Notch"));
    table_append(junk, FALSE);
    junk = gtk_label_new(_("Position"));
    table_append(junk, FALSE);
    junk = scaler_new(0, 1, 0.01);
    gtk_range_set_value(GTK_RANGE(junk), 0.5);
    table_append(junk, FALSE);
    if(active)
		register_setting(junk, ST_FLOAT, SECT, "active_title_notch_position");
    else
		register_setting(junk, ST_FLOAT, SECT, "inactive_title_notch_position");

    junk = gtk_label_new(_("Curve"));
    table_append(junk, FALSE);
    junk = gtk_label_new(_("Offset"));
    table_append(junk, FALSE);
    junk = scaler_new(-100, 100, 0.1);
    gtk_range_set_value(GTK_RANGE(junk), 0);
    table_append(junk, FALSE);
    if(active)
		register_setting(junk, ST_FLOAT, SECT, "active_curve_offset");
    else
		register_setting(junk, ST_FLOAT, SECT, "inactive_curve_offset");

    table_append_separator();

    junk = gtk_check_button_new_with_label(_("Use Glow"));
    gtk_box_pack_startC(vbox, junk, FALSE, FALSE, 0);
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(junk), FALSE);
    if(active)
		register_setting(junk, ST_BOOL, SECT, "active_use_glow");
    else
		register_setting(junk, ST_BOOL, SECT, "inactive_use_glow");

    ACAV(_("Title Glow"), "glow_inner", SECT);
    junk = gtk_label_new("Glow");
    table_append(junk, FALSE);
    junk = gtk_label_new(_("Radius"));
    table_append(junk, FALSE);
    junk = scaler_new(0, 25, 0.1);
    gtk_range_set_value(GTK_RANGE(junk), 7.0);
    table_append(junk, FALSE);
    if(active)
		register_setting(junk, ST_FLOAT, SECT, "active_glow_radius");
    else
		register_setting(junk, ST_FLOAT, SECT, "inactive_glow_radius");

    table_append_separator();
    ACAV(_("Titlebar Separator"), "separator_line", SECT);

    table_append_separator();
    ACAV(_("Frame Outline"), "window_halo", SECT);
    ACAV(_("Frame Highlight"), "window_highlight", SECT);
    ACAV("Frame Shadow", "window_shadow", SECT);

    table_append_separator();
    ACAV(_("Contents Outline"), "contents_halo", SECT);
    ACAV(_("Contents Highlight"), "contents_highlight", SECT);
    ACAV("Contents Shadow", "contents_shadow", SECT);
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
    layout_corners_frame(build_notebook_page(_("Frame"), note));
}
#endif
