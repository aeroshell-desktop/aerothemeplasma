#ifndef EMERALD_ENGINE_H
#define EMERALD_ENGINE_H
#include <emerald.h>
#include <libengine.h>
typedef void (*init_engine_proc)(window_settings *);        // init_engine
typedef void (*load_settings_proc)(GKeyFile * f, window_settings * ws);           // load_engine_settings
typedef void (*fini_engine_proc)(window_settings *);                     // fini_engine
typedef void (*draw_frame_proc)(decor_t * d, cairo_t * cr); // engine_draw_frame
typedef void (*layout_settings_proc)(GtkWidget * vbox); // layout_engine_settings
typedef void (*get_meta_info_proc)(EngineMetaInfo * d); // get meta info
#endif
