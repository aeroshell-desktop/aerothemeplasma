#ifndef EMERALD_TITLEBAR_H
#define EMERALD_TITLEBAR_H

#define IN_EVENT_WINDOW      (1 << 0)
#define PRESSED_EVENT_WINDOW (1 << 1)
enum buttons
{
    B_CLOSE,
    B_MAXIMIZE,
    B_RESTORE,
    B_MINIMIZE,
    B_HELP,
    B_MENU,
    B_SHADE,
    B_UNSHADE,
    B_ABOVE,
    B_UNABOVE,
    B_STICK,
    B_UNSTICK,
    B_COUNT
};
enum states
{
    S_ACTIVE,
    S_ACTIVE_HOVER,
    S_ACTIVE_PRESS,
    S_INACTIVE,
    S_INACTIVE_HOVER,
    S_INACTIVE_PRESS,
    S_COUNT
};
enum btypes
{
    B_T_CLOSE,
    B_T_MAXIMIZE,
    B_T_MINIMIZE,
    B_T_HELP,
    B_T_MENU,
    B_T_SHADE,
    B_T_ABOVE,
    B_T_STICKY,
    B_T_COUNT
};
#ifdef NEED_BUTTON_BISTATES
static const gboolean btbistate[B_T_COUNT]={
    FALSE,
    TRUE,
    FALSE,
    FALSE,
    FALSE,
    TRUE,
    TRUE,
    TRUE,
};
#endif
#ifdef NEED_BUTTON_STATE_FLAGS
static const int btstateflag[B_T_COUNT] =
{
    0,
    WNCK_WINDOW_STATE_MAXIMIZED_HORIZONTALLY | WNCK_WINDOW_STATE_MAXIMIZED_VERTICALLY,
    0,
    0,
    0,
    WNCK_WINDOW_STATE_SHADED,
    WNCK_WINDOW_STATE_ABOVE,
    WNCK_WINDOW_STATE_STICKY,
};
#endif
enum tbtypes
{
    TBT_CLOSE=B_T_CLOSE,
    TBT_MAXIMIZE=B_T_MAXIMIZE,
    TBT_MINIMIZE=B_T_MINIMIZE,
    TBT_HELP=B_T_HELP,
    TBT_MENU=B_T_MENU,
    TBT_SHADE=B_T_SHADE,
    TBT_ONTOP=B_T_ABOVE,
    TBT_STICKY=B_T_STICKY,
    TBT_TITLE=B_T_COUNT,
    TBT_ICON,
    TBT_ONBOTTOM,
    TBT_COUNT,
};
#define BX_COUNT B_COUNT+2
#ifdef NEED_BUTTON_ACTIONS
static const guint button_actions[B_T_COUNT] = {
    WNCK_WINDOW_ACTION_CLOSE,
    WNCK_WINDOW_ACTION_MAXIMIZE,
    WNCK_WINDOW_ACTION_MINIMIZE,
    FAKE_WINDOW_ACTION_HELP,
    0xFFFFFFFF, // any action should match
    WNCK_WINDOW_ACTION_SHADE,
    0xFFFFFFFF,//WNCK_WINDOW_ACTION_ABOVE,
    WNCK_WINDOW_ACTION_STICK,
};
#endif
#ifdef NEED_BUTTON_FILE_NAMES
static const gchar * const b_types[]=
{
    "close",
    "max",
    "restore",
    "min",
    "help",
    "menu",
    "shade",
    "unshade",
    "above",
    "unabove",
    "sticky",
    "unsticky",
    "glow",
    "inactive_glow"
};
#endif
#ifdef NEED_BUTTON_NAMES
static const gchar * const b_names[]={
    "Close",
    "Maximize",
    "Restore",
    "Minimize",
    "Help",
    "Menu",
    "Shade",
    "Un-Shade",
    "Set Above",
    "Un-Set Above",
    "Stick",
    "Un-Stick",
    "Glow(Halo)",
    "Inactive Glow"
};
#endif
enum {
    DOUBLE_CLICK_SHADE=0,
    DOUBLE_CLICK_MAXIMIZE,
    DOUBLE_CLICK_MINIMIZE,
    TITLEBAR_ACTION_COUNT
};
#ifdef NEED_TITLEBAR_ACTION_NAMES
static const gchar * const titlebar_action_name[TITLEBAR_ACTION_COUNT] =
{
    "Shade",
    "Maximize/Restore",
    "Minimize",
};
#endif


#endif
