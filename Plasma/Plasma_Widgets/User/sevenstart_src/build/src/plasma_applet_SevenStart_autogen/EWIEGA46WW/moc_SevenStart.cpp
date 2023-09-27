/****************************************************************************
** Meta object code from reading C++ file 'SevenStart.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.10)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../src/SevenStart.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'SevenStart.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.10. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_SevenStart_t {
    QByteArrayData data[17];
    char stringdata0[208];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_SevenStart_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_SevenStart_t qt_meta_stringdata_SevenStart = {
    {
QT_MOC_LITERAL(0, 0, 10), // "SevenStart"
QT_MOC_LITERAL(1, 11, 20), // "onCompositingChanged"
QT_MOC_LITERAL(2, 32, 0), // ""
QT_MOC_LITERAL(3, 33, 7), // "enabled"
QT_MOC_LITERAL(4, 41, 23), // "onShowingDesktopChanged"
QT_MOC_LITERAL(5, 65, 22), // "onStackingOrderChanged"
QT_MOC_LITERAL(6, 88, 13), // "setDashWindow"
QT_MOC_LITERAL(7, 102, 13), // "QQuickWindow*"
QT_MOC_LITERAL(8, 116, 1), // "w"
QT_MOC_LITERAL(9, 118, 6), // "setOrb"
QT_MOC_LITERAL(10, 125, 7), // "setMask"
QT_MOC_LITERAL(11, 133, 4), // "mask"
QT_MOC_LITERAL(12, 138, 12), // "overrideMask"
QT_MOC_LITERAL(13, 151, 11), // "setWinState"
QT_MOC_LITERAL(14, 163, 10), // "setWinType"
QT_MOC_LITERAL(15, 174, 20), // "setTransparentWindow"
QT_MOC_LITERAL(16, 195, 12) // "setActiveWin"

    },
    "SevenStart\0onCompositingChanged\0\0"
    "enabled\0onShowingDesktopChanged\0"
    "onStackingOrderChanged\0setDashWindow\0"
    "QQuickWindow*\0w\0setOrb\0setMask\0mask\0"
    "overrideMask\0setWinState\0setWinType\0"
    "setTransparentWindow\0setActiveWin"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_SevenStart[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      10,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   64,    2, 0x0a /* Public */,
       4,    1,   67,    2, 0x0a /* Public */,
       5,    0,   70,    2, 0x0a /* Public */,

 // methods: name, argc, parameters, tag, flags
       6,    1,   71,    2, 0x02 /* Public */,
       9,    1,   74,    2, 0x02 /* Public */,
      10,    2,   77,    2, 0x02 /* Public */,
      13,    1,   82,    2, 0x02 /* Public */,
      14,    1,   85,    2, 0x02 /* Public */,
      15,    0,   88,    2, 0x02 /* Public */,
      16,    1,   89,    2, 0x02 /* Public */,

 // slots: parameters
    QMetaType::Void, QMetaType::Bool,    3,
    QMetaType::Void, QMetaType::Bool,    3,
    QMetaType::Void,

 // methods: parameters
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void, QMetaType::QString, QMetaType::Bool,   11,   12,
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 7,    8,

       0        // eod
};

void SevenStart::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<SevenStart *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->onCompositingChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 1: _t->onShowingDesktopChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 2: _t->onStackingOrderChanged(); break;
        case 3: _t->setDashWindow((*reinterpret_cast< QQuickWindow*(*)>(_a[1]))); break;
        case 4: _t->setOrb((*reinterpret_cast< QQuickWindow*(*)>(_a[1]))); break;
        case 5: _t->setMask((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2]))); break;
        case 6: _t->setWinState((*reinterpret_cast< QQuickWindow*(*)>(_a[1]))); break;
        case 7: _t->setWinType((*reinterpret_cast< QQuickWindow*(*)>(_a[1]))); break;
        case 8: _t->setTransparentWindow(); break;
        case 9: _t->setActiveWin((*reinterpret_cast< QQuickWindow*(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 3:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QQuickWindow* >(); break;
            }
            break;
        case 4:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QQuickWindow* >(); break;
            }
            break;
        case 6:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QQuickWindow* >(); break;
            }
            break;
        case 7:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QQuickWindow* >(); break;
            }
            break;
        case 9:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QQuickWindow* >(); break;
            }
            break;
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject SevenStart::staticMetaObject = { {
    QMetaObject::SuperData::link<Plasma::Applet::staticMetaObject>(),
    qt_meta_stringdata_SevenStart.data,
    qt_meta_data_SevenStart,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *SevenStart::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SevenStart::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_SevenStart.stringdata0))
        return static_cast<void*>(this);
    return Plasma::Applet::qt_metacast(_clname);
}

int SevenStart::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = Plasma::Applet::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
