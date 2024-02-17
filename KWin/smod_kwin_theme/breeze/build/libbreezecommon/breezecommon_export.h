
#ifndef BREEZECOMMON_EXPORT_H
#define BREEZECOMMON_EXPORT_H

#ifdef BREEZECOMMON_STATIC_DEFINE
#  define BREEZECOMMON_EXPORT
#  define BREEZECOMMON_NO_EXPORT
#else
#  ifndef BREEZECOMMON_EXPORT
#    ifdef breezecommon5_EXPORTS
        /* We are building this library */
#      define BREEZECOMMON_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define BREEZECOMMON_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef BREEZECOMMON_NO_EXPORT
#    define BREEZECOMMON_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef BREEZECOMMON_DEPRECATED
#  define BREEZECOMMON_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef BREEZECOMMON_DEPRECATED_EXPORT
#  define BREEZECOMMON_DEPRECATED_EXPORT BREEZECOMMON_EXPORT BREEZECOMMON_DEPRECATED
#endif

#ifndef BREEZECOMMON_DEPRECATED_NO_EXPORT
#  define BREEZECOMMON_DEPRECATED_NO_EXPORT BREEZECOMMON_NO_EXPORT BREEZECOMMON_DEPRECATED
#endif

#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef BREEZECOMMON_NO_DEPRECATED
#    define BREEZECOMMON_NO_DEPRECATED
#  endif
#endif

#endif /* BREEZECOMMON_EXPORT_H */
