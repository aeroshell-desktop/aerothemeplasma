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

///////////////////////////////////////////////////
//emerald stuff
#include <engine.h>

#if 0
void copy_from_defaults_if_needed()
{
    gchar * opath = g_strdup_printf("%s/.emerald/theme",g_get_home_dir());
    gchar * fcont;
    gsize len=0;
    g_mkdir_with_parents(opath,0755);
    g_free(opath);
    opath = g_strdup_printf("%s/.emerald/settings.ini",g_get_home_dir());
    if (!g_file_test(opath,G_FILE_TEST_EXISTS))
    {
        if (g_file_get_contents(DEFSETTINGSFILE,&fcont,&len,NULL))
        {
            g_file_set_contents(opath,fcont,len,NULL);
            g_free(fcont);
        }
    }
    g_free(opath);
    opath = g_strdup_printf("%s/.emerald/theme/theme.ini",g_get_home_dir());
    if (!g_file_test(opath,G_FILE_TEST_EXISTS))
    {
        GDir * d;
        d = g_dir_open(DEFTHEMEDIR,0,NULL);
        if (d)
        {
            gchar * n;
            while(n=g_dir_read_name(d))
            {
                gchar * ipath = g_strdup_printf("%s/%s",DEFTHEMEDIR,n);
                gchar * npath = g_strdup_printf("%s/.emerald/theme/%s",g_get_home_dir(),n);
                if (g_file_get_contents(ipath,&fcont,&len,NULL))
                {
                    g_file_set_contents(npath,fcont,len,NULL);
                    g_free(fcont);
                }
                g_free(ipath);
                g_free(npath);
            }
            g_dir_close(d);
        }
    }
    g_free(opath);
}
#endif

gchar * make_filename(const gchar * sect, const gchar * key, const gchar * ext)
{
    return g_strdup_printf("%s/.emerald/theme/%s.%s.%s",g_get_home_dir(),sect,key,ext);
}
void cairo_set_source_alpha_color(cairo_t * cr, alpha_color * c)
{
    cairo_set_source_rgba(cr,c->color.r,c->color.g,c->color.b,c->alpha);
}
void load_color_setting(GKeyFile * f, decor_color_t * color, const gchar * key, const gchar * sect)
{
    GdkColor c;
    gchar * s = g_key_file_get_string(f,sect,key,NULL);
    if (s)
    {
        gdk_color_parse(s,&c);
        color->r = c.red/65536.0;
        color->g = c.green/65536.0;
        color->b = c.blue/65536.0;
        g_free(s);
    }
}
void load_shadow_color_setting(GKeyFile * f, gint sc[3], const gchar * key, const gchar * sect)
{
    GdkColor c;
    gchar * s = g_key_file_get_string(f,sect,key,NULL);
    if (s)
    {
        gdk_color_parse(s,&c);
        sc[0]=c.red;
        sc[1]=c.green;
        sc[2]=c.blue;
        g_free(s);
    }
}
void load_float_setting(GKeyFile * f, gdouble * d, const gchar * key, const gchar * sect)
{
    gchar * s = g_key_file_get_string(f,sect,key,NULL);
    if (s)
    {
        *d = g_ascii_strtod(s,NULL);
        g_free(s);
    }
}
void load_int_setting(GKeyFile * f, gint * i, const gchar * key, const gchar * sect)
{
    GError * e = NULL;
    gint ii = g_key_file_get_integer(f,sect,key,&e);
    if (!e)
        *i=ii;
}
void load_bool_setting(GKeyFile * f, gboolean * b, const gchar * key, const gchar * sect)
{
    GError * e = NULL;
    gboolean bb = g_key_file_get_boolean(f,sect,key,&e);
    if (!e)
        *b=bb;
}
void load_font_setting(GKeyFile * f, PangoFontDescription ** fd, const gchar * key, const gchar * sect)
{
    gchar * s = g_key_file_get_string(f,sect,key,NULL);
    if (s)
    {
#if 0
        if (*fd)
            pango_font_description_free(*fd);
        *fd = pango_font_description_from_string(s);
#endif
        g_free(s);
    }
}
void load_string_setting(GKeyFile * f, gchar ** s, const gchar * key, const gchar * sect)
{
    gchar * st = g_key_file_get_string(f,sect,key,NULL);
    if (st)
    {
        if (*s)
            g_free(*s);
        *s = st;
    }
}
void
rounded_rectangle (cairo_t *cr,
        double  x,
        double  y,
        double  w,
        double  h,
        int	   corner,
        window_settings * ws,
        double  radius)
{
    if (radius==0)
        corner=0;

    if (corner & CORNER_TOPLEFT)
        cairo_move_to (cr, x + radius, y);
    else
        cairo_move_to (cr, x, y);

    if (corner & CORNER_TOPRIGHT)
        cairo_arc (cr, x + w - radius, y + radius, radius,
                M_PI * 1.5, M_PI * 2.0);
    else
        cairo_line_to (cr, x + w, y);

    if (corner & CORNER_BOTTOMRIGHT)
        cairo_arc (cr, x + w - radius, y + h - radius, radius,
                0.0, M_PI * 0.5);
    else
        cairo_line_to (cr, x + w, y + h);

    if (corner & CORNER_BOTTOMLEFT)
        cairo_arc (cr, x + radius, y + h - radius, radius,
                M_PI * 0.5, M_PI);
    else
        cairo_line_to (cr, x, y + h);

    if (corner & CORNER_TOPLEFT)
        cairo_arc (cr, x + radius, y + radius, radius, M_PI, M_PI * 1.5);
    else
        cairo_line_to (cr, x, y);
}

void
fill_rounded_rectangle (cairo_t       *cr,
        double        x,
        double        y,
        double        w,
        double        h,
        int	      corner,
        alpha_color * c0,
        alpha_color * c1,
        int	      gravity,
        window_settings * ws,
        double    radius)
{
    cairo_pattern_t *pattern;

    rounded_rectangle (cr, x, y, w, h, corner,ws,radius);

    if (gravity & SHADE_RIGHT)
    {
        x = x + w;
        w = -w;
    }
    else if (!(gravity & SHADE_LEFT))
    {
        x = w = 0;
    }

    if (gravity & SHADE_BOTTOM)
    {
        y = y + h;
        h = -h;
    }
    else if (!(gravity & SHADE_TOP))
    {
        y = h = 0;
    }

    if (w && h)
    {
        cairo_matrix_t matrix;

        pattern = cairo_pattern_create_radial (0.0, 0.0, 0.0, 0.0, 0.0, w);

        cairo_matrix_init_scale (&matrix, 1.0, w / h);
        cairo_matrix_translate (&matrix, -(x + w), -(y + h));

        cairo_pattern_set_matrix (pattern, &matrix);
    }
    else
    {
        pattern = cairo_pattern_create_linear (x + w, y + h, x, y);
    }

    cairo_pattern_add_color_stop_rgba (pattern, 0.0, c0->color.r, c0->color.g,
            c0->color.b,c0->alpha);

    cairo_pattern_add_color_stop_rgba (pattern, 1.0, c1->color.r, c1->color.g,
            c1->color.b,c1->alpha);

    cairo_pattern_set_extend (pattern, CAIRO_EXTEND_PAD);

    cairo_set_source (cr, pattern);
    cairo_fill (cr);
    cairo_pattern_destroy (pattern);
}


