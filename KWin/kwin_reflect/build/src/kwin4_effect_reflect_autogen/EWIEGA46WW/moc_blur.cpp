/****************************************************************************
** Meta object code from reading C++ file 'blur.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.11)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../src/blur.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'blur.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.11. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_KWin__BlurEffect_t {
    QByteArrayData data[11];
    char stringdata0[165];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_KWin__BlurEffect_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_KWin__BlurEffect_t qt_meta_stringdata_KWin__BlurEffect = {
    {
QT_MOC_LITERAL(0, 0, 16), // "KWin::BlurEffect"
QT_MOC_LITERAL(1, 17, 15), // "slotWindowAdded"
QT_MOC_LITERAL(2, 33, 0), // ""
QT_MOC_LITERAL(3, 34, 19), // "KWin::EffectWindow*"
QT_MOC_LITERAL(4, 54, 1), // "w"
QT_MOC_LITERAL(5, 56, 17), // "slotWindowDeleted"
QT_MOC_LITERAL(6, 74, 18), // "slotPropertyNotify"
QT_MOC_LITERAL(7, 93, 4), // "atom"
QT_MOC_LITERAL(8, 98, 25), // "slotScreenGeometryChanged"
QT_MOC_LITERAL(9, 124, 26), // "setupDecorationConnections"
QT_MOC_LITERAL(10, 151, 13) // "EffectWindow*"

    },
    "KWin::BlurEffect\0slotWindowAdded\0\0"
    "KWin::EffectWindow*\0w\0slotWindowDeleted\0"
    "slotPropertyNotify\0atom\0"
    "slotScreenGeometryChanged\0"
    "setupDecorationConnections\0EffectWindow*"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_KWin__BlurEffect[] = {

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
       1,    1,   39,    2, 0x0a /* Public */,
       5,    1,   42,    2, 0x0a /* Public */,
       6,    2,   45,    2, 0x0a /* Public */,
       8,    0,   50,    2, 0x0a /* Public */,
       9,    1,   51,    2, 0x0a /* Public */,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3, QMetaType::Long,    4,    7,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 10,    4,

       0        // eod
};

void KWin::BlurEffect::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<BlurEffect *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->slotWindowAdded((*reinterpret_cast< KWin::EffectWindow*(*)>(_a[1]))); break;
        case 1: _t->slotWindowDeleted((*reinterpret_cast< KWin::EffectWindow*(*)>(_a[1]))); break;
        case 2: _t->slotPropertyNotify((*reinterpret_cast< KWin::EffectWindow*(*)>(_a[1])),(*reinterpret_cast< long(*)>(_a[2]))); break;
        case 3: _t->slotScreenGeometryChanged(); break;
        case 4: _t->setupDecorationConnections((*reinterpret_cast< EffectWindow*(*)>(_a[1]))); break;
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
        case 4:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< EffectWindow* >(); break;
            }
            break;
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject KWin::BlurEffect::staticMetaObject = { {
    QMetaObject::SuperData::link<KWin::Effect::staticMetaObject>(),
    qt_meta_stringdata_KWin__BlurEffect.data,
    qt_meta_data_KWin__BlurEffect,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *KWin::BlurEffect::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *KWin::BlurEffect::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_KWin__BlurEffect.stringdata0))
        return static_cast<void*>(this);
    return KWin::Effect::qt_metacast(_clname);
}

int KWin::BlurEffect::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = KWin::Effect::qt_metacall(_c, _id, _a);
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
