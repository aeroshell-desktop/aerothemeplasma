#ifndef EMERALD_LIBENGINE_H
#define EMERALD_LIBENGINE_H
#include <emerald.h>
void copy_from_defaults_if_needed();
void load_color_setting(GKeyFile * f, decor_color_t * color, const gchar * key, const gchar * sect);
void load_shadow_color_setting(GKeyFile * f, gint sc[3], const gchar * key, const gchar * sect);
void load_float_setting(GKeyFile * f, gdouble * d, const gchar * key, const gchar * sect);
void load_int_setting(GKeyFile * f, gint * i, const gchar * key, const gchar * sect);
void load_bool_setting(GKeyFile * f, gboolean * b, const gchar * key, const gchar * sect);
void load_font_setting(GKeyFile * f, PangoFontDescription ** fd, const gchar * key, const gchar * sect);
void load_string_setting(GKeyFile * f, gchar ** s, const gchar * key, const gchar * sect);
void cairo_set_source_alpha_color(cairo_t * cr, alpha_color * c);
#define PFACS(zc) \
    load_color_setting(f,&((private_fs *)ws->fs_act->engine_fs)->zc.color,"active_" #zc ,SECT);\
    load_color_setting(f,&((private_fs *)ws->fs_inact->engine_fs)->zc.color,"inactive_" #zc ,SECT);\
    load_float_setting(f,&((private_fs *)ws->fs_act->engine_fs)->zc.alpha,"active_" #zc "_alpha",SECT);\
    load_float_setting(f,&((private_fs *)ws->fs_inact->engine_fs)->zc.alpha,"inactive_" #zc "_alpha",SECT);

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
        double        radius);
void
rounded_rectangle (cairo_t *cr,
        double  x,
        double  y,
        double  w,
        double  h,
        int	   corner,
        window_settings * ws,
        double  radius);

//////////////////////////////////////////////////////
//themer stuff
typedef struct _EngineMetaInfo
{
    gchar * description;
    gchar * version;
    gchar * last_compat;
    GdkPixbuf * icon;
} EngineMetaInfo;
typedef enum _SettingType
{
    ST_BOOL,
    ST_INT,
    ST_FLOAT,
    ST_COLOR,
    ST_FONT,
    ST_META_STRING,
    ST_IMG_FILE,
    ST_STRING_COMBO,
    ST_SFILE_INT_COMBO,
    ST_ENGINE_COMBO,
    ST_SFILE_BOOL,
    ST_SFILE_INT,
    ST_NUM
} SettingType;
typedef struct _SettingItem
{
    SettingType type;
    gchar * key;
    gchar * section;
    GtkWidget * widget;
    
    gchar * fvalue;
    GtkImage * image;
    GtkImage * preview;
} SettingItem;

#include <titlebar.h>

#define gtk_box_pack_startC(a,b,c,d,e) gtk_box_pack_start(GTK_BOX(a),GTK_WIDGET(b),c,d,e)
#define gtk_box_pack_endC(a,b,c,d,e) gtk_box_pack_end(GTK_BOX(a),b,c,d,e)
#define gtk_container_addC(a,b) gtk_container_add(GTK_CONTAINER(a),b)
#define gtk_container_set_border_widthC(a,b) gtk_container_set_border_width(GTK_CONTAINER(a),b)

#define ACAV(caption,basekey,sect) add_color_alpha_value(caption,basekey,sect,active)

gboolean get_engine_meta_info(const gchar * engine, EngineMetaInfo * inf); // returns FALSE if couldn't find engine

GtkWidget * scaler_new(gdouble low, gdouble high, gdouble prec);
void add_color_alpha_value(gchar * caption, gchar * basekey, gchar * sect, gboolean active);

void make_labels(gchar * header);
GtkWidget * build_frame(GtkWidget * vbox, gchar * title, gboolean is_hbox);
SettingItem * register_setting(GtkWidget * widget, SettingType type, gchar * section, gchar * key);
SettingItem * register_img_file_setting(GtkWidget * widget, gchar * section, gchar * key, GtkImage * image);
void table_new(gint width, gboolean same, gboolean labels);
void table_append(GtkWidget * child,gboolean stretch);
void table_append_separator();
GtkTable * get_current_table();

void send_reload_signal();
void apply_settings();
void cb_apply_setting(GtkWidget * w, gpointer p);
#ifdef USE_DBUS
void setup_dbus();
#endif
void write_setting(SettingItem * item, gpointer p);
void write_setting_file();
gboolean get_bool(SettingItem * item);
gdouble get_float(SettingItem * item);
gint get_int(SettingItem * item);
const gchar * get_float_str(SettingItem * item);
const gchar * get_color(SettingItem * item);
const gchar * get_font(SettingItem * item);
const gchar * get_string(SettingItem * item);
void check_file(SettingItem * item,gchar * f);
const gchar * get_file(SettingItem * item);
const gchar * get_string_combo(SettingItem * item);
gint get_sf_int_combo(SettingItem * item);
void update_preview(GtkFileChooser * fc, gchar * filename, GtkImage * img);
void update_preview_cb(GtkFileChooser * file_chooser, gpointer data);
void set_file(SettingItem * item,gchar * f);
void set_bool(SettingItem * item, gboolean b);
void set_float(SettingItem * item, gdouble f);
void set_int(SettingItem * item, gint i);
void set_float_str(SettingItem * item, gchar * s);
void set_color(SettingItem * item, gchar * s);
void set_font(SettingItem * item, gchar * f);
void set_string(SettingItem * item, gchar * s);
void set_string_combo(SettingItem * item, gchar * s);
void set_sf_int_combo(SettingItem * item, gint i);
void read_setting(SettingItem * item, gpointer * p);
void init_settings();
void set_changed(gboolean schanged);
void set_apply(gboolean sapply);
void cb_clear_file(GtkWidget * button, gpointer p);
void init_key_files();
GSList * get_setting_list();
const gchar * get_engine_combo(SettingItem * item);
void do_engine(const gchar * nam);
GtkWidget * build_notebook_page(gchar * title, GtkWidget * notebook);
gchar * make_filename(const gchar * sect, const gchar * key, const gchar * ext);
void layout_engine_list(GtkWidget * vbox);
void init_engine_list();
#endif
