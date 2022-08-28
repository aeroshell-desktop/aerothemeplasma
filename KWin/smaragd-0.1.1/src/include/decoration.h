#include <glib.h>

/* --- PANGO --- */

#define PANGO_IS_LAYOUT(layout) (layout != 0)

typedef int PangoAlignment;

typedef void *PangoFontDescription;
typedef void *PangoContext;

typedef struct _PangoLayout {
    int bounding_width;
    int bounding_height;
} PangoLayout;

extern void pango_layout_get_pixel_size(PangoLayout *layout, int *pwidth, int *pheight);

/* --- GDK --- */

typedef struct _GdkGC GdkGC;
typedef struct _GdkPixbuf GdkPixbuf;

typedef struct _GdkPixmap {
    int width;
    int height;
} GdkPixmap;

typedef struct _GdkColor {
    unsigned short red;
    unsigned short green;
    unsigned short blue;
} GdkColor;

extern void gdk_color_parse(gchar *s, GdkColor *c);

#define gdk_pixbuf_new_from_inline(v, n, b, p) (0)

extern void g_object_unref(void *x);
extern int gdk_pixbuf_get_width(GdkPixbuf *pixbuf);
extern int gdk_pixbuf_get_height(GdkPixbuf *pixbuf);
extern int gdk_pixbuf_get_colorspace(GdkPixbuf *pixbuf);
extern int gdk_pixbuf_get_bits_per_sample(GdkPixbuf *pixbuf);

typedef enum {
    GDK_COLORSPACE_RGB
} GdkColorspace;

#define GDK_INTERP_BILINEAR (2)

extern GdkPixbuf *gdk_pixbuf_new(GdkColorspace colorspace, gboolean has_alpha, int bits_per_sample, int w, int h);
extern GdkPixbuf *gdk_pixbuf_new_from_file(gchar *file, GError **error);
extern GdkPixbuf *gdk_pixbuf_new_subpixbuf(GdkPixbuf *source, int x, int y, int w, int h);
extern void gdk_pixbuf_scale(GdkPixbuf *source, GdkPixbuf *dest, int x, int y, int w, int h, double source_x, double source_y, double scale_x, double scale_y, int interp);

extern void gdk_drawable_get_size(GdkPixmap *pixmap, int *width, int *height);

/* --- GTK --- */

typedef void *GtkWidget;
typedef void *GtkTable;
typedef void *GtkImage;
typedef void *GtkFileChooser;

typedef struct _decor_extents_t {
    int left, right, top, bottom;
} decor_extents_t;

/* --- WNCK --- */

typedef enum {
    WNCK_WINDOW_ACTION_MOVE                    = 1 << 0,
    WNCK_WINDOW_ACTION_RESIZE                  = 1 << 1,
    WNCK_WINDOW_ACTION_SHADE                   = 1 << 2,
    WNCK_WINDOW_ACTION_STICK                   = 1 << 3,
    WNCK_WINDOW_ACTION_MAXIMIZE_HORIZONTALLY   = 1 << 4,
    WNCK_WINDOW_ACTION_MAXIMIZE_VERTICALLY     = 1 << 5,
    WNCK_WINDOW_ACTION_CHANGE_WORKSPACE        = 1 << 6, /* includes pin/unpin */
    WNCK_WINDOW_ACTION_CLOSE                   = 1 << 7,
    WNCK_WINDOW_ACTION_UNMAXIMIZE_HORIZONTALLY = 1 << 8,
    WNCK_WINDOW_ACTION_UNMAXIMIZE_VERTICALLY   = 1 << 9,
    WNCK_WINDOW_ACTION_UNSHADE                 = 1 << 10,
    WNCK_WINDOW_ACTION_UNSTICK                 = 1 << 11,
    WNCK_WINDOW_ACTION_MINIMIZE                = 1 << 12,
    WNCK_WINDOW_ACTION_UNMINIMIZE              = 1 << 13,
    WNCK_WINDOW_ACTION_MAXIMIZE                = 1 << 14,
    WNCK_WINDOW_ACTION_UNMAXIMIZE              = 1 << 15,
    WNCK_WINDOW_ACTION_FULLSCREEN              = 1 << 16,
    WNCK_WINDOW_ACTION_ABOVE                   = 1 << 17,
    WNCK_WINDOW_ACTION_BELOW                   = 1 << 18
} WnckWindowActions;

typedef enum {
    WNCK_WINDOW_STATE_MINIMIZED              = 1 << 0,
    WNCK_WINDOW_STATE_MAXIMIZED_HORIZONTALLY = 1 << 1,
    WNCK_WINDOW_STATE_MAXIMIZED_VERTICALLY   = 1 << 2,
    WNCK_WINDOW_STATE_SHADED                 = 1 << 3,
    WNCK_WINDOW_STATE_SKIP_PAGER             = 1 << 4,
    WNCK_WINDOW_STATE_SKIP_TASKLIST          = 1 << 5,
    WNCK_WINDOW_STATE_STICKY                 = 1 << 6,
    WNCK_WINDOW_STATE_HIDDEN                 = 1 << 7,
    WNCK_WINDOW_STATE_FULLSCREEN             = 1 << 8,
    WNCK_WINDOW_STATE_DEMANDS_ATTENTION      = 1 << 9,
    WNCK_WINDOW_STATE_URGENT                 = 1 << 10,
    WNCK_WINDOW_STATE_ABOVE                  = 1 << 11,
    WNCK_WINDOW_STATE_BELOW                  = 1 << 12
} WnckWindowState;

