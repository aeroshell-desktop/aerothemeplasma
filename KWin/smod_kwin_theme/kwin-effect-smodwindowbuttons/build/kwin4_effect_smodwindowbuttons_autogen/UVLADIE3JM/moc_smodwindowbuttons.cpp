/****************************************************************************
** Meta object code from reading C++ file 'smodwindowbuttons.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.11)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../src/smodwindowbuttons.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'smodwindowbuttons.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.11. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_KWin__GlowAnimationHandler_t {
    QByteArrayData data[2];
    char stringdata0[41];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_KWin__GlowAnimationHandler_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_KWin__GlowAnimationHandler_t qt_meta_stringdata_KWin__GlowAnimationHandler = {
    {
QT_MOC_LITERAL(0, 0, 26), // "KWin::GlowAnimationHandler"
QT_MOC_LITERAL(1, 27, 13) // "hoverProgress"

    },
    "KWin::GlowAnimationHandler\0hoverProgress"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_KWin__GlowAnimationHandler[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       1,   14, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // properties: name, type, flags
       1, QMetaType::QReal, 0x00095103,

       0        // eod
};

void KWin::GlowAnimationHandler::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{

#ifndef QT_NO_PROPERTIES
    if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<GlowAnimationHandler *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< qreal*>(_v) = _t->hoverProgress(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<GlowAnimationHandler *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setHoverProgress(*reinterpret_cast< qreal*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
    (void)_o;
    (void)_id;
    (void)_c;
    (void)_a;
}

QT_INIT_METAOBJECT const QMetaObject KWin::GlowAnimationHandler::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_KWin__GlowAnimationHandler.data,
    qt_meta_data_KWin__GlowAnimationHandler,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *KWin::GlowAnimationHandler::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *KWin::GlowAnimationHandler::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_KWin__GlowAnimationHandler.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int KWin::GlowAnimationHandler::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    
#ifndef QT_NO_PROPERTIES
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 1;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}
struct qt_meta_stringdata_KWin__GlowHandler_t {
    QByteArrayData data[1];
    char stringdata0[18];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_KWin__GlowHandler_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_KWin__GlowHandler_t qt_meta_stringdata_KWin__GlowHandler = {
    {
QT_MOC_LITERAL(0, 0, 17) // "KWin::GlowHandler"

    },
    "KWin::GlowHandler"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_KWin__GlowHandler[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

       0        // eod
};

void KWin::GlowHandler::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    (void)_o;
    (void)_id;
    (void)_c;
    (void)_a;
}

QT_INIT_METAOBJECT const QMetaObject KWin::GlowHandler::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_KWin__GlowHandler.data,
    qt_meta_data_KWin__GlowHandler,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *KWin::GlowHandler::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *KWin::GlowHandler::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_KWin__GlowHandler.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int KWin::GlowHandler::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    return _id;
}
struct qt_meta_stringdata_KWin__SmodWindowButtonsEffect_t {
    QByteArrayData data[11];
    char stringdata0[170];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_KWin__SmodWindowButtonsEffect_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_KWin__SmodWindowButtonsEffect_t qt_meta_stringdata_KWin__SmodWindowButtonsEffect = {
    {
QT_MOC_LITERAL(0, 0, 29), // "KWin::SmodWindowButtonsEffect"
QT_MOC_LITERAL(1, 30, 11), // "windowAdded"
QT_MOC_LITERAL(2, 42, 0), // ""
QT_MOC_LITERAL(3, 43, 19), // "KWin::EffectWindow*"
QT_MOC_LITERAL(4, 63, 1), // "w"
QT_MOC_LITERAL(5, 65, 12), // "windowClosed"
QT_MOC_LITERAL(6, 78, 27), // "windowMaximizedStateChanged"
QT_MOC_LITERAL(7, 106, 10), // "horizontal"
QT_MOC_LITERAL(8, 117, 8), // "vertical"
QT_MOC_LITERAL(9, 126, 15), // "windowMinimized"
QT_MOC_LITERAL(10, 142, 27) // "windowStartUserMovedResized"

    },
    "KWin::SmodWindowButtonsEffect\0windowAdded\0"
    "\0KWin::EffectWindow*\0w\0windowClosed\0"
    "windowMaximizedStateChanged\0horizontal\0"
    "vertical\0windowMinimized\0"
    "windowStartUserMovedResized"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_KWin__SmodWindowButtonsEffect[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   39,    2, 0x08 /* Private */,
       5,    1,   42,    2, 0x08 /* Private */,
       6,    3,   45,    2, 0x08 /* Private */,
       9,    1,   52,    2, 0x08 /* Private */,
      10,    1,   55,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3, QMetaType::Bool, QMetaType::Bool,    4,    7,    8,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,

       0        // eod
};

void KWin::SmodWindowButtonsEffect::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<SmodWindowButtonsEffect *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->windowAdded((*reinterpret_cast< KWin::EffectWindow*(*)>(_a[1]))); break;
        case 1: _t->windowClosed((*reinterpret_cast< KWin::EffectWindow*(*)>(_a[1]))); break;
        case 2: _t->windowMaximizedStateChanged((*reinterpret_cast< KWin::EffectWindow*(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 3: _t->windowMinimized((*reinterpret_cast< KWin::EffectWindow*(*)>(_a[1]))); break;
        case 4: _t->windowStartUserMovedResized((*reinterpret_cast< KWin::EffectWindow*(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 0:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< KWin::EffectWindow* >(); break;
            }
            break;
        case 1:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< KWin::EffectWindow* >(); break;
            }
            break;
        case 2:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< KWin::EffectWindow* >(); break;
            }
            break;
        case 3:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< KWin::EffectWindow* >(); break;
            }
            break;
        case 4:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< KWin::EffectWindow* >(); break;
            }
            break;
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject KWin::SmodWindowButtonsEffect::staticMetaObject = { {
    QMetaObject::SuperData::link<Effect::staticMetaObject>(),
    qt_meta_stringdata_KWin__SmodWindowButtonsEffect.data,
    qt_meta_data_KWin__SmodWindowButtonsEffect,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *KWin::SmodWindowButtonsEffect::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *KWin::SmodWindowButtonsEffect::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_KWin__SmodWindowButtonsEffect.stringdata0))
        return static_cast<void*>(this);
    return Effect::qt_metacast(_clname);
}

int KWin::SmodWindowButtonsEffect::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = Effect::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
