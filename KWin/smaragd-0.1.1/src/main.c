/*
 * Copyright © 2006 Novell, Inc.
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

#define NEED_BUTTON_BISTATES
#define NEED_BUTTON_STATE_FLAGS
#define NEED_BUTTON_ACTIONS
#define NEED_BUTTON_FILE_NAMES
#include <emerald.h>
#include <engine.h>

extern gboolean load_engine(gchar *, window_settings *);
extern void load_engine_settings(GKeyFile *, window_settings *);
extern int update_shadow(frame_settings *);

#define C(name) { 0, XC_ ## name }
#define BUTTON_NOT_VISIBLE(ddd, xxx) \
    ((ddd)->tobj_item_state[(xxx)] == 3 || !((ddd)->actions & button_actions[(xxx)]))

//static gboolean enable_tooltips = TRUE;

static gint get_b_offset(gint b)
{
    int boffset[B_COUNT+1];
    gint i, b_t = 0;

    for (i = 0; i < B_COUNT; i++)
    {
        boffset[i] = b_t;
        if (btbistate[b_t])
        {
            boffset[i+1] = b_t;
            i++;
        }
        b_t++;
    }
    return boffset[b];
}

static gint get_b_t_offset(gint b_t)
{
    int btoffset[B_T_COUNT];
    gint i, b = 0;

    for (i = 0; i < B_T_COUNT; i++)
    {
        btoffset[i] = b;
        b++;
        if (btbistate[i])
            b++;
    }
    return btoffset[b_t];
}
#if 0 /* ************************ */
//window_settings *global_ws;
static gint get_real_pos(window_settings * ws, gint tobj, decor_t * d)
{
    switch (d->tobj_item_state[tobj])
    {
        case 1:
            return ((d->width + ws->left_space - ws->right_space +
                     d->tobj_size[0] - d->tobj_size[1] - d->tobj_size[2]) / 2 +
                    d->tobj_item_pos[tobj]);
        case 2:
            return (d->width - ws->right_space - d->tobj_size[2] +
                    d->tobj_item_pos[tobj]);
        case 3:
            return -1;
        default:
            return (ws->left_space + d->tobj_item_pos[tobj]);
    }
}
#endif
static void update_window_extents(window_settings * ws)
{
    //where 4 is v_corn_rad (8 is 2*4), 6 is...?
    // 0,       0,          L_EXT+4,    TT_H+4,     0,0,0,0
    // L_EXT+4  0,          -8,         T_EXT+2,    0,0,1,0
    // L_EXT-4, 0,          R_EXT+4,    TT_H+4,     1,0,0,0
    // 0,       T_EXT+6,    L_EXT,      TT_H-6,     0,0,0,1
    // L_EXT,   T_EXT+2,    0,          TT_H-2,     0,0,1,0
    // L_EXT,   T_EXT+6,    R_EXT,      TT_H-6,     1,0,0,1
    // 0,       TT_H,       L_EXT+4,    B_EXT+4,    0,1,0,0
    // L_EXT+4, TT_H+4,     -8,         B_EXT,      0,1,1,0
    // L_EXT-4, TT_H,       R_EXT+4,    B_EXT+4,    1,1,0,0
    gint l_ext = ws->win_extents.left;
    gint r_ext = ws->win_extents.right;
    gint t_ext = ws->win_extents.top;
    gint b_ext = ws->win_extents.bottom;
    gint tt_h = ws->titlebar_height;

    /*pos_t newpos[3][3] = {
      {
      {  0,  0, 10, 21,   0, 0, 0, 0 },
      { 10,  0, -8,  6,   0, 0, 1, 0 },
      {  2,  0, 10, 21,   1, 0, 0, 0 }
      }, {
      {  0, 10,  6, 11,   0, 0, 0, 1 },
      {  6,  6,  0, 15,   0, 0, 1, 0 },
      {  6, 10,  6, 11,   1, 0, 0, 1 }
      }, {
      {  0, 17, 10, 10,   0, 1, 0, 0 },
      { 10, 21, -8,  6,   0, 1, 1, 0 },
      {  2, 17, 10, 10,   1, 1, 0, 0 }
      }
      }; */
    pos_t newpos[3][3] = { {
        {0, 0, l_ext + 4, tt_h + 4, 0, 0, 0, 0},
            {l_ext + 4, 0, -8, t_ext + 2, 0, 0, 1, 0},
            {l_ext - 4, 0, r_ext + 4, tt_h + 4, 1, 0, 0, 0}
    }, {
        {0, t_ext + 6, l_ext, tt_h - 6, 0, 0, 0, 1},
            {l_ext, t_ext + 2, 0, tt_h - 2, 0, 0, 1, 0},
            {l_ext, t_ext + 6, r_ext, tt_h - 6, 1, 0, 0, 1}
    }, {
        {0, tt_h, l_ext + 4, b_ext + 4, 0, 1, 0,
            0},
            {l_ext + 4, tt_h + 4, -8, b_ext, 0, 1, 1,
                0},
            {l_ext - 4, tt_h, r_ext + 4, b_ext + 4, 1,
                1, 0, 0}
    }
    };
    memcpy(ws->pos, newpos, sizeof(pos_t) * 9);
}
#if 0
static void
gdk_cairo_set_source_color_alpha(cairo_t * cr, GdkColor * color, double alpha)
{
    cairo_set_source_rgba(cr,
                          color->red / 65535.0,
                          color->green / 65535.0,
                          color->blue / 65535.0, alpha);
}

static void draw_shadow_background(decor_t * d, cairo_t * cr)
{
    cairo_matrix_t matrix;
    double w, h, x2, y2;
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
    h = d->height - top - bottom;

    x2 = d->width - right;
    y2 = d->height - bottom;

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
    cairo_fill(cr);

    /* left */
    if (h > 0)
    {
        cairo_matrix_init_translate(&matrix, 0.0, top);
        cairo_matrix_scale(&matrix, 1.0, 1.0 / h);
        cairo_matrix_translate(&matrix, 0.0, -top);
        cairo_pattern_set_matrix(ws->shadow_pattern, &matrix);
        cairo_set_source(cr, ws->shadow_pattern);
        cairo_rectangle(cr, 0.0, top, left, h);
        cairo_fill(cr);
    }

    /* right */
    if (h > 0)
    {
        cairo_matrix_init_translate(&matrix, width - right - x2, top);
        cairo_matrix_scale(&matrix, 1.0, 1.0 / h);
        cairo_matrix_translate(&matrix, 0.0, -top);
        cairo_pattern_set_matrix(ws->shadow_pattern, &matrix);
        cairo_set_source(cr, ws->shadow_pattern);
        cairo_rectangle(cr, x2, top, right, h);
        cairo_fill(cr);
    }

    /* bottom left */
    cairo_matrix_init_translate(&matrix, 0.0, height - bottom - y2);
    cairo_pattern_set_matrix(ws->shadow_pattern, &matrix);
    cairo_set_source(cr, ws->shadow_pattern);
    cairo_rectangle(cr, 0.0, y2, left, bottom);
    cairo_fill(cr);

    /* bottom */
    if (w > 0)
    {
        cairo_matrix_init_translate(&matrix, left, height - bottom - y2);
        cairo_matrix_scale(&matrix, 1.0 / w, 1.0);
        cairo_matrix_translate(&matrix, -left, 0.0);
        cairo_pattern_set_matrix(ws->shadow_pattern, &matrix);
        cairo_set_source(cr, ws->shadow_pattern);
        cairo_rectangle(cr, left, y2, w, bottom);
        cairo_fill(cr);
    }

    /* bottom right */
    cairo_matrix_init_translate(&matrix, width - right - x2,
                                height - bottom - y2);
    cairo_pattern_set_matrix(ws->shadow_pattern, &matrix);
    cairo_set_source(cr, ws->shadow_pattern);
    cairo_rectangle(cr, x2, y2, right, bottom);
    cairo_fill(cr);
}
#endif

static void draw_help_button(decor_t * d, cairo_t * cr, double s)
{
    cairo_rel_move_to(cr, 0.0, 6.0);
    cairo_rel_line_to(cr, 0.0, 3.0);
    cairo_rel_line_to(cr, 4.5, 0.0);
    cairo_rel_line_to(cr, 0.0, 4.5);
    cairo_rel_line_to(cr, 3.0, 0.0);
    cairo_rel_line_to(cr, 0.0, -4.5);

    cairo_rel_line_to(cr, 4.5, 0.0);

    cairo_rel_line_to(cr, 0.0, -3.0);
    cairo_rel_line_to(cr, -4.5, 0.0);
    cairo_rel_line_to(cr, 0.0, -4.5);
    cairo_rel_line_to(cr, -3.0, 0.0);
    cairo_rel_line_to(cr, 0.0, 4.5);

    cairo_close_path(cr);
}
static void draw_close_button(decor_t * d, cairo_t * cr, double s)
{
    cairo_rel_move_to(cr, 0.0, s);

    cairo_rel_line_to(cr, s, -s);
    cairo_rel_line_to(cr, s, s);
    cairo_rel_line_to(cr, s, -s);
    cairo_rel_line_to(cr, s, s);

    cairo_rel_line_to(cr, -s, s);
    cairo_rel_line_to(cr, s, s);
    cairo_rel_line_to(cr, -s, s);
    cairo_rel_line_to(cr, -s, -s);

    cairo_rel_line_to(cr, -s, s);
    cairo_rel_line_to(cr, -s, -s);
    cairo_rel_line_to(cr, s, -s);

    cairo_close_path(cr);
}

static void draw_max_button(decor_t * d, cairo_t * cr, double s)
{
    cairo_set_fill_rule(cr, CAIRO_FILL_RULE_EVEN_ODD);

    cairo_rel_line_to(cr, 12.0, 0.0);
    cairo_rel_line_to(cr, 0.0, 12.0);
    cairo_rel_line_to(cr, -12.0, 0.0);

    cairo_close_path(cr);

    cairo_rel_move_to(cr, 2.0, s);

    cairo_rel_line_to(cr, 8.0, 0.0);
    cairo_rel_line_to(cr, 0.0, 10.0 - s);
    cairo_rel_line_to(cr, -8.0, 0.0);

    cairo_close_path(cr);
}

static void draw_unmax_button(decor_t * d, cairo_t * cr, double s)
{
    cairo_set_fill_rule(cr, CAIRO_FILL_RULE_EVEN_ODD);

    cairo_rel_move_to(cr, 1.0, 1.0);

    cairo_rel_line_to(cr, 10.0, 0.0);
    cairo_rel_line_to(cr, 0.0, 10.0);
    cairo_rel_line_to(cr, -10.0, 0.0);

    cairo_close_path(cr);

    cairo_rel_move_to(cr, 2.0, s);

    cairo_rel_line_to(cr, 6.0, 0.0);
    cairo_rel_line_to(cr, 0.0, 8.0 - s);
    cairo_rel_line_to(cr, -6.0, 0.0);

    cairo_close_path(cr);
}

static void draw_min_button(decor_t * d, cairo_t * cr, double s)
{
    cairo_rel_move_to(cr, 0.0, 8.0);

    cairo_rel_line_to(cr, 12.0, 0.0);
    cairo_rel_line_to(cr, 0.0, s);
    cairo_rel_line_to(cr, -12.0, 0.0);

    cairo_close_path(cr);
}
#if 0
typedef void (*draw_proc) (cairo_t * cr);
static void
get_button_pos(window_settings * ws, gint b_t,
               decor_t * d, gdouble y1, gdouble * rx, gdouble * ry)
{
    //y1 - 4.0 + ws->titlebar_height / 2,
    *ry = y1 + ws->button_offset;
    *rx = get_real_pos(ws, b_t, d);
}
#endif
static void
button_state_paint(cairo_t * cr,
                   alpha_color * color, alpha_color * color_2, guint state)
{
    double alpha;

    if (state & IN_EVENT_WINDOW)
        alpha = 1.0;
    else
        alpha = color->alpha;

    if ((state & (PRESSED_EVENT_WINDOW | IN_EVENT_WINDOW))
        == (PRESSED_EVENT_WINDOW | IN_EVENT_WINDOW))
    {
        cairo_set_source_rgba(cr, color->color.r, color->color.g,
                              color->color.b, alpha);

        cairo_fill_preserve(cr);

        cairo_set_source_alpha_color(cr, color_2);

        cairo_set_line_width(cr, 1.0);
        cairo_stroke(cr);
        cairo_set_line_width(cr, 2.0);
    }
    else
    {
        cairo_set_source_alpha_color(cr, color_2);
        cairo_stroke_preserve(cr);

        cairo_set_source_rgba(cr, color->color.r, color->color.g,
                              color->color.b, alpha);

        cairo_fill(cr);
    }
}
static int get_b_state(decor_t * d, int button)
{
    int ret = d->active ? 0 : 3;

    if (d->button_states[button] & IN_EVENT_WINDOW)
    {
        ret++;
        if (d->button_states[button] & PRESSED_EVENT_WINDOW)
            ret++;
    }
    return ret;
}
static void
draw_pixbuf(GdkPixbuf * pixbuf, cairo_t * cr,
            gdouble x, gdouble y, gdouble x2, gdouble y2, gdouble alpha)
{
#if 0
    cairo_save(cr);
    cairo_rectangle(cr, x, y, x2-x, y2-y);
    cairo_clip(cr);
    gdk_cairo_set_source_pixbuf(cr, pixbuf, x, y);
    cairo_paint_with_alpha(cr, alpha);
    cairo_restore(cr);
#endif
}
void
draw_button_with_glow_alpha_bstate(gint b_t, decor_t * d, cairo_t * cr,
                                   gint y1, gdouble button_alpha,
                                   gdouble glow_alpha, int b_state)
{
    gint b = b_t;
    gdouble x, y;
    gdouble x2, y2;
    gdouble glow_x, glow_y;             // glow top left coordinates
    gdouble glow_x2, glow_y2;   // glow bottom right coordinates
    window_settings *ws = d->fs->ws;

#if 0
    if (b_state < 0)
        b_state = get_b_state(d, b_t);

    b = get_b_t_offset(b_t);

    if (btbistate[b_t])
        if (d->state & btstateflag[b_t])
            b++;

    if (BUTTON_NOT_VISIBLE(d, b_t))
        return;
#endif
    button_region_t *button_region =
        (d->active ? &d->button_region[b_t] : &d->
         button_region_inact[b_t]);
    x = button_region->base_x1;
    y = button_region->base_y1;

    if (ws->use_pixmap_buttons)
    {
        x2 = button_region->base_x2;
        y2 = button_region->base_y2;
        draw_pixbuf(ws->ButtonPix[b_state + b * S_COUNT], cr, x, y, x2, y2,
                    button_alpha);

        if (glow_alpha > 1e-5)  // i.e. glow is on
        {
            glow_x = button_region->glow_x1;
            glow_y = button_region->glow_y1;
            glow_x2 = button_region->glow_x2;
            glow_y2 = button_region->glow_y2;
            if (d->active)
            {                                   // Draw glow
                draw_pixbuf(ws->ButtonGlowPix[b], cr, glow_x, glow_y, glow_x2,
                            glow_y2, glow_alpha);
            }
            else                                // assume this function won't be called with glow_alpha>0
            {                                   // if ws->use_inactive_glow is false
                // Draw inactive glow
                draw_pixbuf(ws->ButtonInactiveGlowPix[b], cr, glow_x, glow_y,
                            glow_x2, glow_y2, glow_alpha);
            }
        }
    }
    else
    {
        y += 3;
        x += 1;
        cairo_set_line_width(cr, 2.0);
        cairo_move_to(cr, x, y);
        switch (b)
        {
            case B_CLOSE:
                draw_close_button(d, cr, 3.1);
                break;
            case B_MAXIMIZE:
                draw_max_button(d, cr, 4.0);
                break;
            case B_RESTORE:
                draw_unmax_button(d, cr, 4.0);
                break;
            case B_MINIMIZE:
                draw_min_button(d, cr, 4.0);
                break;
            case B_HELP:
                cairo_move_to(cr, x, y);
                draw_help_button(d, cr, 3.1);
                break;
            default:
                //FIXME - do something here
                break;
        }
        button_state_paint(cr, &d->fs->button, &d->fs->button_halo,
                           b_state);
    }
}
#if 0
static void
draw_button_with_glow(gint b_t, decor_t * d, cairo_t * cr, gint y1,
                      gboolean with_glow)
{
    draw_button_with_glow_alpha_bstate(b_t, d, cr, y1, 1.0,
                                       (with_glow ? 1.0 : 0.0), -1);
}
static void draw_button(gint b_t, decor_t * d, cairo_t * cr, gint y1)
{
    draw_button_with_glow_alpha_bstate(b_t, d, cr, y1, 1.0, 0.0, -1);
}
static void reset_buttons_bg_and_fade(decor_t * d)
{
    d->draw_only_buttons_region = FALSE;
    d->button_fade_info.cr = NULL;
    d->button_fade_info.timer = -1;
    int b_t;

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        d->button_fade_info.counters[b_t] = 0;
        d->button_fade_info.pulsating[b_t] = 0;
        d->button_region[b_t].base_x1 = -100;
        d->button_region[b_t].glow_x1 = -100;
        if (d->button_region[b_t].bg_pixmap)
            g_object_unref (G_OBJECT (d->button_region[b_t].bg_pixmap));
        d->button_region[b_t].bg_pixmap = NULL;
        d->button_region_inact[b_t].base_x1 = -100;
        d->button_region_inact[b_t].glow_x1 = -100;
        if (d->button_region_inact[b_t].bg_pixmap)
            g_object_unref (G_OBJECT (d->button_region_inact[b_t].bg_pixmap));
        d->button_region_inact[b_t].bg_pixmap = NULL;
        d->button_last_drawn_state[b_t] = 0;
    }
}
static void stop_button_fade(decor_t * d)
{
    int j;

    if (d->button_fade_info.cr)
    {
        cairo_destroy(d->button_fade_info.cr);
        d->button_fade_info.cr = NULL;
    }
    if (d->button_fade_info.timer >= 0)
    {
        g_source_remove(d->button_fade_info.timer);
        d->button_fade_info.timer = -1;
    }
    for (j = 0; j < B_T_COUNT; j++)
        d->button_fade_info.counters[j] = 0;
}
static void draw_button_backgrounds(decor_t * d, int *necessary_update_type)
{
    int b_t;
    window_settings *ws = d->fs->ws;

    // Draw button backgrounds
    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        if (BUTTON_NOT_VISIBLE(d, b_t))
            continue;
        button_region_t *button_region = (d->active ? &d->button_region[b_t] :
                                          &d->button_region_inact[b_t]);
        gint src_x = 0, src_y = 0, w = 0, h = 0, dest_x = 0, dest_y = 0;

        if (necessary_update_type[b_t] == 1)
        {
            w = button_region->base_x2 - button_region->base_x1;
            h = button_region->base_y2 - button_region->base_y1;
            if (ws->use_pixmap_buttons)
            {
                dest_x = button_region->base_x1;
                dest_y = button_region->base_y1;
                if ((ws->use_button_glow && d->active) ||
                    (ws->use_button_inactive_glow && !d->active))
                {
                    src_x = button_region->base_x1 - button_region->glow_x1;
                    src_y = button_region->base_y1 - button_region->glow_y1;
                }
            }
            else
            {
                dest_x = button_region->base_x1 - 2;
                dest_y = button_region->base_y1 + 1;
            }
        }
        else if (necessary_update_type[b_t] == 2)
        {
            dest_x = button_region->glow_x1;
            dest_y = button_region->glow_y1;
            w = button_region->glow_x2 - button_region->glow_x1;
            h = button_region->glow_y2 - button_region->glow_y1;
        }
        else
            return;
        if (button_region->bg_pixmap)
            gdk_draw_drawable(IS_VALID(d->buffer_pixmap) ? d->buffer_pixmap :
                                                           d->pixmap,
                              d->gc, button_region->bg_pixmap, src_x, src_y,
                              dest_x, dest_y, w, h);
        d->min_drawn_buttons_region.x1 =
            MIN(d->min_drawn_buttons_region.x1, dest_x);
        d->min_drawn_buttons_region.y1 =
            MIN(d->min_drawn_buttons_region.y1, dest_y);
        d->min_drawn_buttons_region.x2 =
            MAX(d->min_drawn_buttons_region.x2, dest_x + w);
        d->min_drawn_buttons_region.y2 =
            MAX(d->min_drawn_buttons_region.y2, dest_y + h);
    }
}

gint draw_buttons_timer_func(gpointer data)
{
    button_fade_info_t *fade_info = (button_fade_info_t *) data;
    decor_t *d = (decor_t *) (fade_info->d);
    window_settings *ws = d->fs->ws;
    int num_steps = ws->button_fade_num_steps;

    /* decorations no longer available? */
    if (!d->buffer_pixmap && !d->pixmap)
    {
        stop_button_fade(d);
        return FALSE;
    }

    d->min_drawn_buttons_region.x1 = 10000;
    d->min_drawn_buttons_region.y1 = 10000;
    d->min_drawn_buttons_region.x2 = -100;
    d->min_drawn_buttons_region.y2 = -100;

    if (!fade_info->cr)
    {
        fade_info->cr =
            gdk_cairo_create(GDK_DRAWABLE
                             (IS_VALID(d->buffer_pixmap) ? d->buffer_pixmap :
                                                           d->pixmap));
        cairo_set_operator(fade_info->cr, CAIRO_OPERATOR_OVER);
    }

    // Determine necessary updates
    int b_t;
    int necessary_update_type[B_T_COUNT];       // 0: none, 1: only base, 2: base+glow

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
        necessary_update_type[b_t] = (ws->use_button_glow && d->active) ||
            (ws->use_button_inactive_glow && !d->active) ? 2:1;
    draw_button_backgrounds(d, necessary_update_type);

    // Draw the buttons that are in "non-hovered" or pressed state
    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        if (BUTTON_NOT_VISIBLE(d, b_t) || fade_info->counters[b_t] ||
            necessary_update_type[b_t] == 0)
            continue;
        int b_state = get_b_state(d, b_t);
        int toBeDrawnState =
            (d->
             active ? (b_state == S_ACTIVE_PRESS ? 2 : 0) : (b_state ==
                                                             S_INACTIVE_PRESS
                                                             ? 5 : 3));
        draw_button_with_glow_alpha_bstate(b_t, d, fade_info->cr, fade_info->y1, 1.0, 0.0, toBeDrawnState);     // no glow here
    }

    // Draw the buttons that are in "hovered" state (fading in/out or at max fade)
    double button_alphas[B_T_COUNT];

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        button_alphas[b_t] = 0;
        if (BUTTON_NOT_VISIBLE(d, b_t) ||
            (!fade_info->pulsating[b_t] && !fade_info->counters[b_t]))
            continue;

        if (ws->button_fade_pulse_len_steps > 0 && fade_info->counters[b_t] &&
            fade_info->pulsating[b_t])
        {
            // If it is time, reverse the fade
            if (fade_info->counters[b_t] ==
                -num_steps + ws->button_fade_pulse_len_steps)
                fade_info->counters[b_t] = 1 - fade_info->counters[b_t];
            if (fade_info->counters[b_t] ==
                num_steps + 1 + ws->button_fade_pulse_wait_steps)
                fade_info->counters[b_t] =
                    1 - MIN(fade_info->counters[b_t], num_steps + 1);
        }
        if (ws->button_fade_pulse_len_steps > 0 &&
            fade_info->counters[b_t] == num_steps)
            fade_info->pulsating[b_t] = TRUE;   // start pulse

        if (fade_info->counters[b_t] != num_steps + 1 ||        // unless fade is at max
            (ws->button_fade_pulse_len_steps > 0 &&     // or at pulse max
             fade_info->counters[b_t] !=
             num_steps + 1 + ws->button_fade_pulse_wait_steps))
        {
            fade_info->counters[b_t]++; // increment fade counter
        }
        d->button_last_drawn_state[b_t] = fade_info->counters[b_t];

        gdouble alpha;

        if (fade_info->counters[b_t] > 0)
            alpha = (MIN(fade_info->counters[b_t], num_steps + 1) -
                     1) / (gdouble) num_steps;
        else
            alpha = -fade_info->counters[b_t] / (gdouble) num_steps;

        if (fade_info->counters[b_t] < num_steps + 1)   // not at max fade
        {
            // Draw button's non-hovered version (with 1-alpha)
            draw_button_with_glow_alpha_bstate(b_t, d, fade_info->cr,
                                               fade_info->y1, pow(1 - alpha,
                                                                  0.4), 0.0,
                                               d->active ? 0 : 3);
        }
        button_alphas[b_t] = alpha;
    }
    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        if (button_alphas[b_t] > 1e-4)
        {
            gdouble glow_alpha = 0.0;

            if ((ws->use_button_glow && d->active) ||
                (ws->use_button_inactive_glow && !d->active))
                glow_alpha = button_alphas[b_t];

            // Draw button's hovered version (with alpha)
            draw_button_with_glow_alpha_bstate(b_t, d, fade_info->cr,
                                               fade_info->y1,
                                               button_alphas[b_t], glow_alpha,
                                               d->active ? 1 : 4);
        }
    }

    // Check if the fade has come to an end
    gboolean any_active_buttons = FALSE;

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
        if (!BUTTON_NOT_VISIBLE(d, b_t) &&
            ((fade_info->counters[b_t] &&
              fade_info->counters[b_t] < num_steps + 1) ||
             fade_info->pulsating[b_t]))
        {
            any_active_buttons = TRUE;
            break;
        }

    if (IS_VALID(d->buffer_pixmap) && !d->button_fade_info.first_draw &&
        d->min_drawn_buttons_region.x1 < 10000)
    {
        // if region is updated at least once
        gdk_draw_drawable(d->pixmap,
                          d->gc,
                          d->buffer_pixmap,
                          d->min_drawn_buttons_region.x1,
                          d->min_drawn_buttons_region.y1,
                          d->min_drawn_buttons_region.x1,
                          d->min_drawn_buttons_region.y1,
                          d->min_drawn_buttons_region.x2 -
                          d->min_drawn_buttons_region.x1,
                          d->min_drawn_buttons_region.y2 -
                          d->min_drawn_buttons_region.y1);
    }
    fade_info->first_draw = FALSE;
    if (!any_active_buttons)
    {
        cairo_destroy(fade_info->cr);
        fade_info->cr = NULL;
        if (fade_info->timer >= 0)
        {
            g_source_remove(fade_info->timer);
            fade_info->timer = -1;
        }
        return FALSE;
    }
    return TRUE;
}
static void draw_buttons_with_fade(decor_t * d, cairo_t * cr, double y1)
{
    window_settings *ws = d->fs->ws;
    int b_t;

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        if (BUTTON_NOT_VISIBLE(d, b_t))
            continue;
        if (!(d->active ? d->button_region[b_t] : d->button_region_inact[b_t]).bg_pixmap)       // don't draw if bg_pixmaps are not valid
            return;
    }
    button_fade_info_t *fade_info = &(d->button_fade_info);
    gboolean button_pressed = FALSE;

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        if (BUTTON_NOT_VISIBLE(d, b_t))
            continue;
        int b_state = get_b_state(d, b_t);

        if (fade_info->counters[b_t] != 0 &&
            (b_state == S_ACTIVE_PRESS || b_state == S_INACTIVE_PRESS))
        {
            // Button pressed, stop fade
            fade_info->counters[b_t] = 0;
            button_pressed = TRUE;
        }
        else if (fade_info->counters[b_t] > 0 && (b_state == S_ACTIVE || b_state == S_INACTIVE))        // moved out
        {
            // Change fade in -> out and proceed 1 step
            fade_info->counters[b_t] =
                1 - MIN(fade_info->counters[b_t],
                        ws->button_fade_num_steps + 1);
        }
        else if (fade_info->counters[b_t] < 0 &&
                 (b_state == S_ACTIVE_HOVER || b_state == S_INACTIVE_HOVER))
        {
            // Change fade out -> in and proceed 1 step
            fade_info->counters[b_t] = 1 - fade_info->counters[b_t];
        }
        else if (fade_info->counters[b_t] == 0 &&
                 (b_state == S_ACTIVE_HOVER || b_state == S_INACTIVE_HOVER))
        {
            // Start fade in
            fade_info->counters[b_t] = 1;
        }
        if (fade_info->pulsating[b_t] &&
            b_state != S_ACTIVE_HOVER && b_state != S_INACTIVE_HOVER)
        {
            // Stop pulse
            fade_info->pulsating[b_t] = FALSE;
        }
    }

    if (fade_info->timer == -1 || button_pressed)
        // button_pressed is needed because sometimes after a button is pressed,
        // this function is called twice, first with S_(IN)ACTIVE, then with S_(IN)ACTIVE_PRESS
        // where it should have been only once with S_(IN)ACTIVE_PRESS
    {
        fade_info->d = (gpointer) d;
        fade_info->y1 = y1;
        if (draw_buttons_timer_func((gpointer) fade_info) == TRUE)      // call once now
        {
            // and start a new timer for the next step
            fade_info->timer =
                g_timeout_add(ws->button_fade_step_duration,
                              draw_buttons_timer_func,
                              (gpointer) fade_info);
        }
    }
}
static void draw_buttons_without_fade(decor_t * d, cairo_t * cr, double y1)
{
    window_settings *ws = d->fs->ws;

    d->min_drawn_buttons_region.x1 = 10000;
    d->min_drawn_buttons_region.y1 = 10000;
    d->min_drawn_buttons_region.x2 = -100;
    d->min_drawn_buttons_region.y2 = -100;

    int b_t;
    int necessary_update_type[B_T_COUNT];       // 0: none, 1: only base, 2: base+glow

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
        necessary_update_type[b_t] = (ws->use_button_glow && d->active) ||
            (ws->use_button_inactive_glow && !d->active) ? 2:1;
    //necessary_update_type[b_t] = 2;

    draw_button_backgrounds(d, necessary_update_type);

    // Draw buttons
    gint button_hovered_on = -1;

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        if (necessary_update_type[b_t] == 0)
            continue;
        int b_state = get_b_state(d, b_t);

        if (ws->use_pixmap_buttons &&
            ((ws->use_button_glow && b_state == S_ACTIVE_HOVER) ||
             (ws->use_button_inactive_glow && b_state == S_INACTIVE_HOVER)))
        {
            // skip the one being hovered on, if any
            button_hovered_on = b_t;
        }
        else
            draw_button(b_t, d, cr, y1);
    }
    if (button_hovered_on >= 0)
    {
        // Draw the button and the glow for the button hovered on
        draw_button_with_glow(button_hovered_on, d, cr, y1, TRUE);
    }
}
static void update_button_regions(decor_t * d)
{
    window_settings *ws = d->fs->ws;
    gint y1 = ws->top_space - ws->win_extents.top;

    gint b_t, b_t2;
    gdouble x, y;
    gdouble glow_x, glow_y;             // glow top left coordinates

    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        if (BUTTON_NOT_VISIBLE(d, b_t))
            continue;
        button_region_t *button_region = &(d->button_region[b_t]);

        if (button_region->bg_pixmap)
        {
            g_object_unref (G_OBJECT (button_region->bg_pixmap));
            button_region->bg_pixmap = NULL;
        }
        if (d->button_region_inact[b_t].bg_pixmap)
        {
            g_object_unref (G_OBJECT (d->button_region_inact[b_t].bg_pixmap));
            d->button_region_inact[b_t].bg_pixmap = NULL;
        }
        // Reset overlaps
        for (b_t2 = 0; b_t2 < b_t; b_t2++)
            if (!BUTTON_NOT_VISIBLE(d, b_t2))
                d->button_region[b_t].overlap_buttons[b_t2] = FALSE;
        for (b_t2 = 0; b_t2 < b_t; b_t2++)
            if (!BUTTON_NOT_VISIBLE(d, b_t2))
                d->button_region_inact[b_t].overlap_buttons[b_t2] = FALSE;
    }
    d->button_fade_info.first_draw = TRUE;

    if (ws->use_pixmap_buttons)
    {
        if ((d->active && ws->use_button_glow) ||
            (!d->active && ws->use_button_inactive_glow))
        {
            for (b_t = 0; b_t < B_T_COUNT; b_t++)
            {
                if (BUTTON_NOT_VISIBLE(d, b_t))
                    continue;
                get_button_pos(ws, b_t, d, y1, &x, &y);
                button_region_t *button_region = &(d->button_region[b_t]);

                glow_x = x - (ws->c_glow_size.w - ws->c_icon_size[b_t].w) / 2;
                glow_y = y - (ws->c_glow_size.h - ws->c_icon_size[b_t].h) / 2;

                button_region->base_x1 = x;
                button_region->base_y1 = y;
                button_region->base_x2 = x + ws->c_icon_size[b_t].w;
                button_region->base_y2 = MIN(y + ws->c_icon_size[b_t].h,
                                             ws->top_space +
                                             ws->titlebar_height);

                button_region->glow_x1 = glow_x;
                button_region->glow_y1 = glow_y;
                button_region->glow_x2 = glow_x + ws->c_glow_size.w;
                button_region->glow_y2 = MIN(glow_y + ws->c_glow_size.h,
                                             ws->top_space +
                                             ws->titlebar_height);

                // Update glow overlaps of each pair

                for (b_t2 = 0; b_t2 < b_t; b_t2++)
                {                               // coordinates for these b_t2's will be ready for this b_t here
                    if (BUTTON_NOT_VISIBLE(d, b_t2))
                        continue;
                    if ((button_region->base_x1 > d->button_region[b_t2].base_x1 &&     //right of b_t2
                         button_region->glow_x1 <= d->button_region[b_t2].base_x2) || (button_region->base_x1 < d->button_region[b_t2].base_x1 &&       //left of b_t2
                                                                                       button_region->
                                                                                       glow_x2
                                                                                       >=
                                                                                       d->
                                                                                       button_region
                                                                                       [b_t2].
                                                                                       base_x1))
                    {
                        button_region->overlap_buttons[b_t2] = TRUE;
                    }
                    else
                        button_region->overlap_buttons[b_t2] = FALSE;

                    // buttons' protruding glow length might be asymmetric
                    if ((d->button_region[b_t2].base_x1 > button_region->base_x1 &&     //left of b_t2
                         d->button_region[b_t2].glow_x1 <= button_region->base_x2) || (d->button_region[b_t2].base_x1 < button_region->base_x1 &&       //right of b_t2
                                                                                       d->
                                                                                       button_region
                                                                                       [b_t2].
                                                                                       glow_x2
                                                                                       >=
                                                                                       button_region->
                                                                                       base_x1))
                    {
                        d->button_region[b_t2].overlap_buttons[b_t] = TRUE;
                    }
                    else
                        d->button_region[b_t2].overlap_buttons[b_t] = FALSE;
                }
            }
        }
        else
        {
            for (b_t = 0; b_t < B_T_COUNT; b_t++)
            {
                if (BUTTON_NOT_VISIBLE(d, b_t))
                    continue;
                get_button_pos(ws, b_t, d, y1, &x, &y);
                button_region_t *button_region = &(d->button_region[b_t]);

                button_region->base_x1 = x;
                button_region->base_y1 = y;
                button_region->base_x2 = x + ws->c_icon_size[b_t].w;
                button_region->base_y2 = MIN(y + ws->c_icon_size[b_t].h,
                                             ws->top_space +
                                             ws->titlebar_height);
            }
        }
    }
    else
    {
        for (b_t = 0; b_t < B_T_COUNT; b_t++)
        {
            if (BUTTON_NOT_VISIBLE(d, b_t))
                continue;
            get_button_pos(ws, b_t, d, y1, &x, &y);
            button_region_t *button_region = &(d->button_region[b_t]);

            button_region->base_x1 = x;
            button_region->base_y1 = y;
            button_region->base_x2 = x + 16;
            button_region->base_y2 = y + 16;
        }
    }
    for (b_t = 0; b_t < B_T_COUNT; b_t++)
    {
        button_region_t *button_region = &(d->button_region[b_t]);
        button_region_t *button_region_inact = &(d->button_region_inact[b_t]);

        memcpy(button_region_inact, button_region, sizeof(button_region_t));
    }
}
static void draw_window_decoration_real(decor_t * d, gboolean shadow_time)
{
    cairo_t *cr;
    double x1, y1, x2, y2, h;
    int top;
    frame_settings *fs = d->fs;
    window_settings *ws = fs->ws;

    if (!d->pixmap)
        return;

    top = ws->win_extents.top + ws->titlebar_height;

    x1 = ws->left_space - ws->win_extents.left;
    y1 = ws->top_space - ws->win_extents.top;
    x2 = d->width - ws->right_space + ws->win_extents.right;
    y2 = d->height - ws->bottom_space + ws->win_extents.bottom;

    h = d->height - ws->top_space - ws->titlebar_height - ws->bottom_space;

    if (!d->draw_only_buttons_region)   // if not only drawing buttons
    {
        cr = gdk_cairo_create(GDK_DRAWABLE
                              (IS_VALID(d->buffer_pixmap) ? d->buffer_pixmap :
                                                            d->pixmap));
        cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
        cairo_set_line_width(cr, 1.0);
        cairo_save(cr);
        draw_shadow_background(d, cr);
        engine_draw_frame(d, cr);
        cairo_restore(cr);
        cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
        cairo_set_line_width(cr, 2.0);

        /*color.r = 1;
          color.g = 1;
          color.b = 1; */

        // the buttons were previously drawn here, so we need to save the cairo state here
        cairo_save(cr);

        if (d->layout && d->tobj_item_state[TBT_TITLE] != 3)
        {
            pango_layout_set_alignment(d->layout, ws->title_text_align);
            cairo_move_to(cr,
                          get_real_pos(ws, TBT_TITLE, d),
                          y1 + 2.0 + (ws->titlebar_height -
                                      ws->text_height) / 2.0);

            /* ===================active text colors */
            cairo_set_source_alpha_color(cr, &fs->text_halo);
            pango_cairo_layout_path(cr, d->layout);
            cairo_stroke(cr);

            cairo_set_source_alpha_color(cr, &fs->text);

            cairo_move_to(cr,
                          get_real_pos(ws, TBT_TITLE, d),
                          y1 + 2.0 + (ws->titlebar_height -
                                      ws->text_height) / 2.0);

            pango_cairo_show_layout(cr, d->layout);
        }
        if (d->icon && d->tobj_item_state[TBT_ICON] != 3)
        {
            cairo_translate(cr, get_real_pos(ws, TBT_ICON, d),
                            y1 - 5.0 + ws->titlebar_height / 2);

            cairo_set_source(cr, d->icon);
            cairo_rectangle(cr, 0.0, 0.0, 16.0, 16.0);
            cairo_clip(cr);
            cairo_paint(cr);
        }
        // Copy button region backgrounds to buffers
        // for fast drawing of buttons from now on
        // when drawing is done for buttons
        gboolean bg_pixmaps_update_needed = FALSE;
        int b_t;

        for (b_t = 0; b_t < B_T_COUNT; b_t++)
        {
            button_region_t *button_region =
                (d->active ? &d->button_region[b_t] : &d->
                 button_region_inact[b_t]);
            if (BUTTON_NOT_VISIBLE(d, b_t))
                continue;
            if (!button_region->bg_pixmap && button_region->base_x1 >= 0)       // if region is valid
            {
                bg_pixmaps_update_needed = TRUE;
                break;
            }
        }
        if (bg_pixmaps_update_needed && !shadow_time)
        {
            for (b_t = 0; b_t < B_T_COUNT; b_t++)
            {
                if (BUTTON_NOT_VISIBLE(d, b_t))
                    continue;

                button_region_t *button_region =
                    (d->active ? &d->button_region[b_t] : &d->
                     button_region_inact[b_t]);
                gint rx, ry, rw, rh;

                if (ws->use_pixmap_buttons &&
                    ((ws->use_button_glow && d->active) ||
                     (ws->use_button_inactive_glow && !d->active)))
                {
                    if (button_region->glow_x1 == -100) // skip uninitialized regions
                        continue;
                    rx = button_region->glow_x1;
                    ry = button_region->glow_y1;
                    rw = button_region->glow_x2 - button_region->glow_x1;
                    rh = button_region->glow_y2 - button_region->glow_y1;
                }
                else
                {
                    if (button_region->base_x1 == -100) // skip uninitialized regions
                        continue;
                    rx = button_region->base_x1;
                    ry = button_region->base_y1;
                    if (!ws->use_pixmap_buttons)        // offset: (-2,1)
                    {
                        rx -= 2;
                        ry++;
                    }
                    rw = button_region->base_x2 - button_region->base_x1;
                    rh = button_region->base_y2 - button_region->base_y1;
                }
                if (!button_region->bg_pixmap)
                    button_region->bg_pixmap = create_pixmap(rw, rh);
                if (!button_region->bg_pixmap)
                {
                    fprintf(stderr,
                            "%s: Error allocating buffer.\n", program_name);
                }
                else
                {
                    gdk_draw_drawable(button_region->bg_pixmap, d->gc,
                                      IS_VALID(d->buffer_pixmap) ?
                                      d->buffer_pixmap : d->pixmap,
                                      rx, ry, 0, 0,
                                      rw, rh);
                }
            }
        }
        cairo_restore(cr);              // and restore the state for button drawing
        /*if (!shadow_time)
          {
        //workaround for slowness, will grab and rotate the two side-pieces
        gint w, h;
        cairo_surface_t * csur;
        cairo_pattern_t * sr;
        cairo_matrix_t cm;
        cairo_destroy(cr);
        gint topspace = ws->top_space + ws->titlebar_height;
        cr = gdk_cairo_create (GDK_DRAWABLE (d->buffer_pixmap ? d->buffer_pixmap : d->pixmap));
        cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);

        gdk_drawable_get_size(pbuff,&w,&h);
        csur = cairo_xlib_surface_create(
        GDK_DISPLAY_XDISPLAY (gdk_display_get_default ()),
        GDK_PIXMAP_XID(pbuff),
        GDK_VISUAL_XVISUAL(gdk_drawable_get_visual(pbuff)),
        w,h);

        cairo_set_source_surface(cr, csur, 0, 0);
        sr = cairo_get_source(cr);
        cairo_pattern_get_matrix(sr, &cm);

        //draw all four quads from the old one to the new one
        //first top quad
        cairo_save(cr);
        cairo_rectangle(cr, 0, 0, d->width, topspace);
        cairo_clip(cr);
        cairo_pattern_set_matrix(sr, &cm);
        cairo_paint(cr);
        cairo_restore(cr);

        //then bottom, easiest this way
        cairo_save(cr);
        cairo_rectangle(cr, 0, topspace, d->width, ws->bottom_space);
        cairo_clip(cr);
        cm.y0 = d->height - (top_space + ws->bottom_space);
        cm.x0 = 0;
        cairo_pattern_set_matrix(sr,&cm);
        cairo_paint(cr);
        cairo_restore(cr);

        //now left
        cairo_save(cr);
        cairo_rectangle(cr, 0, topspace + ws->bottom_space,
        d->height-(topspace + ws->bottom_space), ws->left_space);
        cairo_clip(cr);
        cm.xx=0;
        cm.xy=1;
        cm.yx=1;
        cm.yy=0;
        cm.x0 = - topspace - ws->bottom_space;
        cm.y0 = topspace;
        cairo_pattern_set_matrix(sr,&cm);
        cairo_paint(cr);
        cairo_restore(cr);

        //now right
        cairo_save(cr);
        cairo_rectangle(cr, 0, topspace + ws->bottom_space + ws->left_space,
        d->height-(topspace + ws->bottom_space), ws->right_space);
        cairo_clip(cr);
        cm.y0 = topspace;
        cm.x0 = d->width-
        (topspace + ws->bottom_space + ws->left_space + ws->right_space);
        cairo_pattern_set_matrix(sr,&cm);
        cairo_paint(cr);
        cairo_restore(cr);


        cairo_destroy(cr);
        g_object_unref (G_OBJECT (pbuff));
        cairo_surface_destroy(csur);
    }
    */
    }
    // Draw buttons

    cr = gdk_cairo_create(GDK_DRAWABLE (IS_VALID(d->buffer_pixmap) ?
                                        d->buffer_pixmap : d->pixmap));

    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);

    if (ws->use_button_fade && ws->use_pixmap_buttons)
        draw_buttons_with_fade(d, cr, y1);
    else
        draw_buttons_without_fade(d, cr, y1);

    cairo_destroy(cr);

    if (IS_VALID(d->buffer_pixmap))
    {
        /*if (d->draw_only_buttons_region && d->min_drawn_buttons_region.x1 < 10000)    // if region is updated at least once
          {
          gdk_draw_drawable(d->pixmap,
          d->gc,
          d->buffer_pixmap,
          d->min_drawn_buttons_region.x1,
          d->min_drawn_buttons_region.y1,
          d->min_drawn_buttons_region.x1,
          d->min_drawn_buttons_region.y1,
          d->min_drawn_buttons_region.x2 -
          d->min_drawn_buttons_region.x1,
          d->min_drawn_buttons_region.y2 -
          d->min_drawn_buttons_region.y1);
          }
          else*/
        {
            gdk_draw_drawable(d->pixmap,
                              d->gc,
                              d->buffer_pixmap,
                              0,
                              0,
                              0,
                              0,
                              d->width,
                              d->height);
            //ws->top_space + ws->bottom_space +
            //ws->titlebar_height + 2);
        }
    }
}

static void draw_window_decoration(decor_t * d)
{
    if (d->active)
    {
        d->pixmap = d->p_active;
        d->buffer_pixmap = d->p_active_buffer;
    }
    else
    {
        d->pixmap = d->p_inactive;
        d->buffer_pixmap = d->p_inactive_buffer;
    }
    if (d->draw_only_buttons_region)
        draw_window_decoration_real(d, FALSE);
    if (!d->only_change_active)
    {
        gboolean save = d->active;
        frame_settings *fs = d->fs;

        d->active = TRUE;
        d->fs = d->fs->ws->fs_act;
        d->pixmap = d->p_active;
        d->buffer_pixmap = d->p_active_buffer;
        draw_window_decoration_real(d, FALSE);
        d->active = FALSE;
        d->fs = d->fs->ws->fs_inact;
        d->pixmap = d->p_inactive;
        d->buffer_pixmap = d->p_inactive_buffer;
        draw_window_decoration_real(d, FALSE);
        d->active = save;
        d->fs = fs;
    }
    else
    {
        d->only_change_active = FALSE;
    }
    if (d->active)
    {
        d->pixmap = d->p_active;
        d->buffer_pixmap = d->p_active_buffer;
    }
    else
    {
        d->pixmap = d->p_inactive;
        d->buffer_pixmap = d->p_inactive_buffer;
    }
    if (d->prop_xid)
    {
        decor_update_window_property(d);
        d->prop_xid = 0;
    }
    d->draw_only_buttons_region = FALSE;
}
static void draw_shadow_window(decor_t * d)
{
    draw_window_decoration_real(d, TRUE);
}

/* to save some memory, value is specific to current decorations */
#define CORNER_REDUCTION 3

static int update_shadow(frame_settings * fs)
{
#if 0
    Display *xdisplay = gdk_display;
    XRenderPictFormat *format;
    GdkPixmap *pixmap;
    Picture src, dst, tmp;
    XFixed *params;
    XFilters *filters;
    char *filter = NULL;
    int size, n_params = 0;
#endif
    cairo_t *cr;
    decor_t d;

    bzero(&d, sizeof(decor_t));
    window_settings *ws = fs->ws;
#if 0
    //    double        save_decoration_alpha;
    static XRenderColor color;
    static XRenderColor clear = { 0x0000, 0x0000, 0x0000, 0x0000 };
    static XRenderColor white = { 0xffff, 0xffff, 0xffff, 0xffff };

    color.red = ws->shadow_color[0];
    color.green = ws->shadow_color[1];
    color.blue = ws->shadow_color[2];
    color.alpha = 0xffff;

    /* compute a gaussian convolution kernel */
    params = create_gaussian_kernel(ws->shadow_radius, ws->shadow_radius / 2.0, // SIGMA
                                    ws->shadow_radius,  // ALPHA
                                    ws->shadow_opacity, &size);
    if (!params)
        ws->shadow_offset_x = ws->shadow_offset_y = size = 0;

    if (ws->shadow_radius <= 0.0 && ws->shadow_offset_x == 0 &&
        ws->shadow_offset_y == 0)
        size = 0;

    n_params = size + 2;
    size = size / 2;
#endif
    ws->left_space = ws->win_extents.left + size - ws->shadow_offset_x;
    ws->right_space = ws->win_extents.right + size + ws->shadow_offset_x;
    ws->top_space = ws->win_extents.top + size - ws->shadow_offset_y;
    ws->bottom_space = ws->win_extents.bottom + size + ws->shadow_offset_y;


    ws->left_space = MAX(ws->win_extents.left, ws->left_space);
    ws->right_space = MAX(ws->win_extents.right, ws->right_space);
    ws->top_space = MAX(ws->win_extents.top, ws->top_space);
    ws->bottom_space = MAX(ws->win_extents.bottom, ws->bottom_space);

    ws->shadow_left_space = MAX(0, size - ws->shadow_offset_x);
    ws->shadow_right_space = MAX(0, size + ws->shadow_offset_x);
    ws->shadow_top_space = MAX(0, size - ws->shadow_offset_y);
    ws->shadow_bottom_space = MAX(0, size + ws->shadow_offset_y);

    ws->shadow_left_corner_space = MAX(0, size + ws->shadow_offset_x);
    ws->shadow_right_corner_space = MAX(0, size - ws->shadow_offset_x);
    ws->shadow_top_corner_space = MAX(0, size + ws->shadow_offset_y);
    ws->shadow_bottom_corner_space = MAX(0, size - ws->shadow_offset_y);

    ws->left_corner_space =
        MAX(0, ws->shadow_left_corner_space - CORNER_REDUCTION);
    ws->right_corner_space =
        MAX(0, ws->shadow_right_corner_space - CORNER_REDUCTION);
    ws->top_corner_space =
        MAX(0, ws->shadow_top_corner_space - CORNER_REDUCTION);
    ws->bottom_corner_space =
        MAX(0, ws->shadow_bottom_corner_space - CORNER_REDUCTION);

    ws->normal_top_corner_space =
        MAX(0, ws->top_corner_space - ws->titlebar_height);
    ws->switcher_top_corner_space =
        MAX(0, ws->top_corner_space - SWITCHER_TOP_EXTRA);
    ws->switcher_bottom_corner_space =
        MAX(0, ws->bottom_corner_space - SWITCHER_SPACE);

    d.buffer_pixmap = NULL;
    d.layout = NULL;
    d.icon = NULL;
    d.state = 0;
    d.actions = 0;
    d.prop_xid = 0;
    d.draw = draw_shadow_window;
    d.active = TRUE;
    d.fs = fs;

    reset_buttons_bg_and_fade(&d);

    d.width =
        ws->left_space + ws->left_corner_space + 1 +
        ws->right_corner_space + ws->right_space;
    d.height =
        ws->top_space + ws->titlebar_height +
        ws->normal_top_corner_space + 2 + ws->bottom_corner_space +
        ws->bottom_space;
#if 0
    /* all pixmaps are ARGB32 */
    format = XRenderFindStandardFormat(xdisplay, PictStandardARGB32);

    /* shadow color */
    src = XRenderCreateSolidFill(xdisplay, &color);

    if (ws->large_shadow_pixmap)
    {
        g_object_unref (G_OBJECT (ws->large_shadow_pixmap));
        ws->large_shadow_pixmap = NULL;
    }

    if (ws->shadow_pattern)
    {
        cairo_pattern_destroy(ws->shadow_pattern);
        ws->shadow_pattern = NULL;
    }

    if (ws->shadow_pixmap)
    {
        g_object_unref (G_OBJECT (ws->shadow_pixmap));
        ws->shadow_pixmap = NULL;
    }

    /* no shadow */
    if (size <= 0)
    {
        if (params)
            g_free(params);

        return 1;
    }

    pixmap = create_pixmap(d.width, d.height);
    if (!pixmap)
    {
        g_free(params);
        return 0;
    }

    /* query server for convolution filter */
    filters = XRenderQueryFilters(xdisplay, GDK_PIXMAP_XID(pixmap));
    if (filters)
    {
        int i;

        for (i = 0; i < filters->nfilter; i++)
        {
            if (strcmp(filters->filter[i], FilterConvolution) == 0)
            {
                filter = FilterConvolution;
                break;
            }
        }

        XFree(filters);
    }

    if (!filter)
    {
        fprintf(stderr, "can't generate shadows, X server doesn't support "
                "convolution filters\n");

        g_free(params);
        g_object_unref (G_OBJECT (pixmap));
        return 1;
    }

    /* WINDOWS WITH DECORATION */

    d.pixmap = create_pixmap(d.width, d.height);
    if (!d.pixmap)
    {
        g_free(params);
        g_object_unref (G_OBJECT (pixmap));
        return 0;
    }

    /* draw decorations */
    (*d.draw) (&d);

    dst = XRenderCreatePicture(xdisplay, GDK_PIXMAP_XID(d.pixmap),
                               format, 0, NULL);
    tmp = XRenderCreatePicture(xdisplay, GDK_PIXMAP_XID(pixmap),
                               format, 0, NULL);

    /* first pass */
    params[0] = (n_params - 2) << 16;
    params[1] = 1 << 16;

    set_picture_transform(xdisplay, dst, ws->shadow_offset_x, 0);
    XRenderSetPictureFilter(xdisplay, dst, filter, params, n_params);
    XRenderComposite(xdisplay,
                     PictOpSrc,
                     src, dst, tmp, 0, 0, 0, 0, 0, 0, d.width, d.height);

    /* second pass */
    params[0] = 1 << 16;
    params[1] = (n_params - 2) << 16;

    set_picture_transform(xdisplay, tmp, 0, ws->shadow_offset_y);
    XRenderSetPictureFilter(xdisplay, tmp, filter, params, n_params);
    XRenderComposite(xdisplay,
                     PictOpSrc,
                     src, tmp, dst, 0, 0, 0, 0, 0, 0, d.width, d.height);

    XRenderFreePicture(xdisplay, tmp);
    XRenderFreePicture(xdisplay, dst);

    g_object_unref (G_OBJECT (pixmap));

    ws->large_shadow_pixmap = d.pixmap;

    cr = gdk_cairo_create(GDK_DRAWABLE(ws->large_shadow_pixmap));
    ws->shadow_pattern =
        cairo_pattern_create_for_surface(cairo_get_target(cr));
    cairo_pattern_set_filter(ws->shadow_pattern, CAIRO_FILTER_NEAREST);
    cairo_destroy(cr);


    /* WINDOWS WITHOUT DECORATIONS */

    d.width = ws->shadow_left_space + ws->shadow_left_corner_space + 1 +
        ws->shadow_right_space + ws->shadow_right_corner_space;
    d.height = ws->shadow_top_space + ws->shadow_top_corner_space + 1 +
        ws->shadow_bottom_space + ws->shadow_bottom_corner_space;

    pixmap = create_pixmap(d.width, d.height);
    if (!pixmap)
    {
        g_free(params);
        return 0;
    }

    d.pixmap = create_pixmap(d.width, d.height);
    if (!d.pixmap)
    {
        g_object_unref (G_OBJECT (pixmap));
        g_free(params);
        return 0;
    }

    dst = XRenderCreatePicture(xdisplay, GDK_PIXMAP_XID(d.pixmap),
                               format, 0, NULL);

    /* draw rectangle */
    XRenderFillRectangle(xdisplay, PictOpSrc, dst, &clear,
                         0, 0, d.width, d.height);
    XRenderFillRectangle(xdisplay, PictOpSrc, dst, &white,
                         ws->shadow_left_space,
                         ws->shadow_top_space,
                         d.width - ws->shadow_left_space -
                         ws->shadow_right_space,
                         d.height - ws->shadow_top_space -
                         ws->shadow_bottom_space);

    tmp = XRenderCreatePicture(xdisplay, GDK_PIXMAP_XID(pixmap),
                               format, 0, NULL);

    /* first pass */
    params[0] = (n_params - 2) << 16;
    params[1] = 1 << 16;

    set_picture_transform(xdisplay, dst, ws->shadow_offset_x, 0);
    XRenderSetPictureFilter(xdisplay, dst, filter, params, n_params);
    XRenderComposite(xdisplay,
                     PictOpSrc,
                     src, dst, tmp, 0, 0, 0, 0, 0, 0, d.width, d.height);

    /* second pass */
    params[0] = 1 << 16;
    params[1] = (n_params - 2) << 16;

    set_picture_transform(xdisplay, tmp, 0, ws->shadow_offset_y);
    XRenderSetPictureFilter(xdisplay, tmp, filter, params, n_params);
    XRenderComposite(xdisplay,
                     PictOpSrc,
                     src, tmp, dst, 0, 0, 0, 0, 0, 0, d.width, d.height);

    XRenderFreePicture(xdisplay, tmp);
    XRenderFreePicture(xdisplay, dst);
    XRenderFreePicture(xdisplay, src);

    g_object_unref (G_OBJECT (pixmap));

    g_free(params);

    ws->shadow_pixmap = d.pixmap;
#endif
    return 1;
}
#endif /* ************************ */
static void titlebar_font_changed(window_settings * ws)
{
#if 0
    PangoFontMetrics *metrics;
    PangoLanguage *lang;

    pango_context_set_font_description(ws->pango_context, ws->font_desc);
    lang = pango_context_get_language(ws->pango_context);
    metrics =
        pango_context_get_metrics(ws->pango_context, ws->font_desc, lang);

    ws->text_height = PANGO_PIXELS(pango_font_metrics_get_ascent(metrics) +
                                   pango_font_metrics_get_descent(metrics));
#endif
    ws->titlebar_height = ws->text_height;
    if (ws->titlebar_height < ws->min_titlebar_height)
        ws->titlebar_height = ws->min_titlebar_height;

//    pango_font_metrics_unref(metrics);

}

static void load_buttons_image(window_settings * ws, gint y)
{
    gchar *file;
    int x, pix_width, pix_height, rel_button;

    rel_button = get_b_offset(y);



    if (ws->ButtonArray[y])
        g_object_unref(ws->ButtonArray[y]);
    file = make_filename("buttons", b_types[y], "png");
    if (!file || !(ws->ButtonArray[y] = gdk_pixbuf_new_from_file(file, NULL)))
        ws->ButtonArray[y] = gdk_pixbuf_new(GDK_COLORSPACE_RGB, TRUE, 8, 16 * S_COUNT, 16);     // create a blank pixbuf
    g_free(file);

    pix_width = gdk_pixbuf_get_width(ws->ButtonArray[y]) / S_COUNT;
    pix_height = gdk_pixbuf_get_height(ws->ButtonArray[y]);
    ws->c_icon_size[rel_button].w = pix_width;
    ws->c_icon_size[rel_button].h = pix_height;
    for (x = 0; x < S_COUNT; x++)
    {
        if (ws->ButtonPix[x + y * S_COUNT])
            g_object_unref(ws->ButtonPix[x + y * S_COUNT]);

        ws->ButtonPix[x + y * S_COUNT] =
            gdk_pixbuf_new_subpixbuf(ws->ButtonArray[y], x * pix_width, 0,
                                     pix_width, pix_height);
    }
}
static void load_buttons_glow_images(window_settings * ws)
{
    gchar *file1 = NULL;
    gchar *file2 = NULL;
    int x, pix_width, pix_height;
    int pix_width2, pix_height2;
    gboolean success1 = FALSE;
    gboolean success2 = FALSE;

    if (ws->use_button_glow)
    {
        if (ws->ButtonGlowArray)
            g_object_unref(ws->ButtonGlowArray);
        file1 = make_filename("buttons", "glow", "png");
        if (file1 &&
            (ws->ButtonGlowArray = gdk_pixbuf_new_from_file(file1, NULL)))
            success1 = TRUE;
    }
    if (ws->use_button_inactive_glow)
    {
        if (ws->ButtonInactiveGlowArray)
            g_object_unref(ws->ButtonInactiveGlowArray);
        file2 = make_filename("buttons", "inactive_glow", "png");
        if (file2 &&
            (ws->ButtonInactiveGlowArray =
             gdk_pixbuf_new_from_file(file2, NULL)))
            success2 = TRUE;
    }
    if (success1 && success2)
    {
        pix_width = gdk_pixbuf_get_width(ws->ButtonGlowArray) / B_COUNT;
        pix_height = gdk_pixbuf_get_height(ws->ButtonGlowArray);
        pix_width2 =
            gdk_pixbuf_get_width(ws->ButtonInactiveGlowArray) / B_COUNT;
        pix_height2 = gdk_pixbuf_get_height(ws->ButtonInactiveGlowArray);

        if (pix_width != pix_width2 || pix_height != pix_height2)
        {
            g_warning
                ("Choose same size glow images for active and inactive windows."
                 "\nInactive glow image is scaled for now.");
            // Scale the inactive one
            GdkPixbuf *tmp_pixbuf =
                gdk_pixbuf_new(gdk_pixbuf_get_colorspace
                               (ws->ButtonGlowArray),
                               TRUE,
                               gdk_pixbuf_get_bits_per_sample(ws->
                                                              ButtonGlowArray),
                               pix_width * B_COUNT,
                               pix_height);

            gdk_pixbuf_scale(ws->ButtonInactiveGlowArray, tmp_pixbuf,
                             0, 0,
                             pix_width * B_COUNT, pix_height,
                             0, 0,
                             pix_width / (double)pix_width2,
                             pix_height / (double)pix_height2,
                             GDK_INTERP_BILINEAR);
            g_object_unref(ws->ButtonInactiveGlowArray);
            ws->ButtonInactiveGlowArray = tmp_pixbuf;
        }
    }
    else
    {
        pix_width = 16;
        pix_height = 16;
        if (success1)
        {
            pix_width = gdk_pixbuf_get_width(ws->ButtonGlowArray) / B_COUNT;
            pix_height = gdk_pixbuf_get_height(ws->ButtonGlowArray);
        }
        else if (success2)
        {
            pix_width =
                gdk_pixbuf_get_width(ws->ButtonInactiveGlowArray) /
                B_COUNT;
            pix_height = gdk_pixbuf_get_height(ws->ButtonInactiveGlowArray);
        }
        if (!success1 && ws->use_button_glow)
            ws->ButtonGlowArray = gdk_pixbuf_new(GDK_COLORSPACE_RGB, TRUE, 8, pix_width * B_COUNT, pix_height); // create a blank pixbuf
        if (!success2 && ws->use_button_inactive_glow)
            ws->ButtonInactiveGlowArray = gdk_pixbuf_new(GDK_COLORSPACE_RGB, TRUE, 8, pix_width * B_COUNT, pix_height); // create a blank pixbuf
    }
    ws->c_glow_size.w = pix_width;
    ws->c_glow_size.h = pix_height;

    if (ws->use_button_glow)
    {
        g_free(file1);
        for (x = 0; x < B_COUNT; x++)
        {
            if (ws->ButtonGlowPix[x])
                g_object_unref(ws->ButtonGlowPix[x]);
            ws->ButtonGlowPix[x] =
                gdk_pixbuf_new_subpixbuf(ws->ButtonGlowArray,
                                         x * pix_width, 0, pix_width,
                                         pix_height);
        }
    }
    if (ws->use_button_inactive_glow)
    {
        g_free(file2);
        for (x = 0; x < B_COUNT; x++)
        {
            if (ws->ButtonInactiveGlowPix[x])
                g_object_unref(ws->ButtonInactiveGlowPix[x]);
            ws->ButtonInactiveGlowPix[x] =
                gdk_pixbuf_new_subpixbuf(ws->ButtonInactiveGlowArray,
                                         x * pix_width, 0, pix_width,
                                         pix_height);
        }
    }
}
void load_button_image_setting(window_settings * ws)
{
    gint i;

    for (i = 0; i < B_COUNT; i++)
        load_buttons_image(ws, i);

    // load active and inactive glow image
    if (ws->use_button_glow || ws->use_button_inactive_glow)
        load_buttons_glow_images(ws);
}
static void load_settings(window_settings * ws)
{
    gchar *engine = NULL;

    gchar *path =
        g_strjoin("/", g_get_home_dir(), ".emerald/settings.ini", NULL);
    GKeyFile *f = g_key_file_new();

//    copy_from_defaults_if_needed();

    //settings
    g_key_file_load_from_file(f, path, 0, NULL);
    g_free(path);
    load_int_setting(f, &ws->double_click_action, "double_click_action",
                     "titlebars");
    load_int_setting(f, &ws->button_hover_cursor, "hover_cursor", "buttons");
    load_bool_setting(f, &ws->use_decoration_cropping,
                      "use_decoration_cropping", "decorations");
    load_bool_setting(f, &ws->use_button_fade, "use_button_fade", "buttons");
    gint button_fade_step_duration = ws->button_fade_step_duration;

    load_int_setting(f, &button_fade_step_duration,
                     "button_fade_step_duration", "buttons");
    if (button_fade_step_duration > 0)
        ws->button_fade_step_duration = button_fade_step_duration;
    gint button_fade_total_duration = 250;

    load_int_setting(f, &button_fade_total_duration,
                     "button_fade_total_duration", "buttons");
    if (button_fade_total_duration > 0)
        ws->button_fade_num_steps =
            button_fade_total_duration / ws->button_fade_step_duration;
    if (ws->button_fade_num_steps == 0)
        ws->button_fade_num_steps = 1;
    gboolean use_button_fade_pulse = FALSE;

    load_bool_setting(f, &use_button_fade_pulse, "use_button_fade_pulse",
                      "buttons");

    ws->button_fade_pulse_wait_steps = 0;
    if (use_button_fade_pulse)
    {
        gint button_fade_pulse_min_opacity = 0;

        load_int_setting(f, &button_fade_pulse_min_opacity,
                         "button_fade_pulse_min_opacity", "buttons");
        ws->button_fade_pulse_len_steps =
            ws->button_fade_num_steps * (100 -
                                         button_fade_pulse_min_opacity) /
            100;
        gint button_fade_pulse_wait_duration = 0;

        load_int_setting(f, &button_fade_pulse_wait_duration,
                         "button_fade_pulse_wait_duration", "buttons");
        if (button_fade_pulse_wait_duration > 0)
            ws->button_fade_pulse_wait_steps =
                button_fade_pulse_wait_duration /
                ws->button_fade_step_duration;
    }
    else
        ws->button_fade_pulse_len_steps = 0;

//    load_bool_setting(f, &enable_tooltips, "enable_tooltips", "buttons");
    load_int_setting(f, &ws->blur_type,
                     "blur_type", "decorations");

    //theme
    path = g_strjoin("/", g_get_home_dir(), ".emerald/theme/theme.ini", NULL);
    g_key_file_load_from_file(f, path, 0, NULL);
    g_free(path);
    load_string_setting(f, &engine, "engine", "engine");

    if (!load_engine(engine, ws))
    {
        if (engine)
            g_free(engine);
        engine = g_strdup("legacy");
        load_engine(engine, ws);
    }
    LFACSS(text, titlebar);
    LFACSS(text_halo, titlebar);
    LFACSS(button, buttons);
    LFACSS(button_halo, buttons);
    load_engine_settings(f, ws);
    load_font_setting(f, &ws->font_desc, "titlebar_font", "titlebar");
    load_bool_setting(f, &ws->use_pixmap_buttons, "use_pixmap_buttons",
                      "buttons");
    load_bool_setting(f, &ws->use_button_glow, "use_button_glow", "buttons");
    load_bool_setting(f, &ws->use_button_inactive_glow,
                      "use_button_inactive_glow", "buttons");

    if (ws->use_pixmap_buttons)
        load_button_image_setting(ws);
    load_shadow_color_setting(f, ws->shadow_color, "shadow_color", "shadow");
    load_int_setting(f, &ws->shadow_offset_x, "shadow_offset_x", "shadow");
    load_int_setting(f, &ws->shadow_offset_y, "shadow_offset_y", "shadow");
    load_float_setting(f, &ws->shadow_radius, "shadow_radius", "shadow");
    load_float_setting(f, &ws->shadow_opacity, "shadow_opacity", "shadow");
    load_string_setting(f, &ws->tobj_layout, "title_object_layout",
                        "titlebar");
    load_int_setting(f, &ws->button_offset, "vertical_offset", "buttons");
    load_int_setting(f, &ws->button_hoffset, "horizontal_offset", "buttons");
    load_int_setting(f, &ws->win_extents.top, "top", "borders");
    load_int_setting(f, &ws->win_extents.left, "left", "borders");
    load_int_setting(f, &ws->win_extents.right, "right", "borders");
    load_int_setting(f, &ws->win_extents.bottom, "bottom", "borders");
    load_int_setting(f, &ws->min_titlebar_height, "min_titlebar_height",
                     "titlebar");
    g_key_file_free(f);
}
void update_settings(window_settings * ws)
{
#if 0
    //assumes ws is fully allocated

    GdkDisplay *gdkdisplay;

    // Display    *xdisplay;
    GdkScreen *gdkscreen;
    WnckScreen *screen = wnck_screen_get_default();
    GList *windows;
#endif

    load_settings(ws);

#if 0
    gdkdisplay = gdk_display_get_default();
    // xdisplay   = gdk_x11_display_get_xdisplay (gdkdisplay);
    gdkscreen = gdk_display_get_default_screen(gdkdisplay);
#endif

    titlebar_font_changed(ws);
    update_window_extents(ws);
    update_shadow(ws->fs_act);
#if 0
    update_default_decorations(gdkscreen, ws->fs_act, ws->fs_inact);

    windows = wnck_screen_get_windows(screen);
    while (windows)
    {
        decor_t *d = g_object_get_data(G_OBJECT(windows->data), "decor");

        if (d->decorated)
        {
            d->width = d->height = 0;
            update_window_decoration_size(WNCK_WINDOW(windows->data));
            update_event_windows(WNCK_WINDOW(windows->data));
        }
        windows = windows->next;
    }
#endif
}

window_settings *create_settings()
{
    gchar *engine = NULL;
    int i;

    frame_settings *pfs;
    window_settings *ws;

    ws = malloc(sizeof(window_settings));
    bzero(ws, sizeof(window_settings));
#if 0
    global_ws = ws;
    setlocale(LC_ALL, "");
    bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
    textdomain(GETTEXT_PACKAGE);
#endif

    ws->win_extents.left = 6;
    ws->win_extents.top = 4;
    ws->win_extents.right = 6;
    ws->win_extents.bottom = 6;
    ws->corner_radius = 5;
    ws->shadow_radius = 15;
    ws->shadow_opacity = .8;
    ws->min_titlebar_height = 17;
    ws->double_click_action = DOUBLE_CLICK_SHADE;
    ws->button_hover_cursor = 1;
    ws->button_offset = 1;
    ws->button_hoffset = 1;
    ws->button_fade_step_duration = 50;
    ws->button_fade_num_steps = 5;
    ws->blur_type = BLUR_TYPE_NONE;

    ws->tobj_layout = g_strdup("IT::HNXC");     // DEFAULT TITLE OBJECT LAYOUT, does not use any odd buttons
    //ws->tobj_layout=g_strdup("CNX:IT:HM");

    pfs = malloc(sizeof(frame_settings));
    bzero(pfs, sizeof(frame_settings));
    pfs->ws = ws;
    ACOLOR(text, 1.0, 1.0, 1.0, 1.0);
    ACOLOR(text_halo, 0.0, 0.0, 0.0, 0.2);
    ACOLOR(button, 1.0, 1.0, 1.0, 0.8);
    ACOLOR(button_halo, 0.0, 0.0, 0.0, 0.2);
    ws->fs_act = pfs;

    pfs = malloc(sizeof(frame_settings));
    bzero(pfs, sizeof(frame_settings));
    pfs->ws = ws;
    ACOLOR(text, 0.8, 0.8, 0.8, 0.8);
    ACOLOR(text_halo, 0.0, 0.0, 0.0, 0.2);
    ACOLOR(button, 0.8, 0.8, 0.8, 0.8);
    ACOLOR(button_halo, 0.0, 0.0, 0.0, 0.2);
    ws->fs_inact = pfs;

    ws->round_top_left = TRUE;
    ws->round_top_right = TRUE;
    ws->round_bottom_left = TRUE;
    ws->round_bottom_right = TRUE;

    engine = g_strdup("legacy");
    load_engine(engine, ws);    // assumed to always return TRUE

//    program_name = argv[0];

    //ws->ButtonBase = NULL;
    for (i = 0; i < (S_COUNT * B_COUNT); i++)
    {
        ws->ButtonPix[i] = NULL;
    }
    return ws;
}

