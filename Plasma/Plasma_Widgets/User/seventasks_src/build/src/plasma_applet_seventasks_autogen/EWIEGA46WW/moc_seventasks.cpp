/****************************************************************************
** Meta object code from reading C++ file 'seventasks.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.10)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../src/seventasks.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'seventasks.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.10. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_SevenTasks_t {
    QByteArrayData data[13];
    char stringdata0[129];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_SevenTasks_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_SevenTasks_t qt_meta_stringdata_SevenTasks = {
    {
QT_MOC_LITERAL(0, 0, 10), // "SevenTasks"
QT_MOC_LITERAL(1, 11, 18), // "mouseEventDetected"
QT_MOC_LITERAL(2, 30, 0), // ""
QT_MOC_LITERAL(3, 31, 16), // "getDominantColor"
QT_MOC_LITERAL(4, 48, 3), // "src"
QT_MOC_LITERAL(5, 52, 14), // "isActiveWindow"
QT_MOC_LITERAL(6, 67, 3), // "wid"
QT_MOC_LITERAL(7, 71, 17), // "disableBlurBehind"
QT_MOC_LITERAL(8, 89, 8), // "QWindow*"
QT_MOC_LITERAL(9, 98, 1), // "w"
QT_MOC_LITERAL(10, 100, 12), // "setMouseGrab"
QT_MOC_LITERAL(11, 113, 3), // "arg"
QT_MOC_LITERAL(12, 117, 11) // "getPosition"

    },
    "SevenTasks\0mouseEventDetected\0\0"
    "getDominantColor\0src\0isActiveWindow\0"
    "wid\0disableBlurBehind\0QWindow*\0w\0"
    "setMouseGrab\0arg\0getPosition"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_SevenTasks[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   44,    2, 0x06 /* Public */,

 // methods: name, argc, parameters, tag, flags
       3,    1,   45,    2, 0x02 /* Public */,
       5,    1,   48,    2, 0x02 /* Public */,
       7,    1,   51,    2, 0x02 /* Public */,
      10,    2,   54,    2, 0x02 /* Public */,
      12,    1,   59,    2, 0x02 /* Public */,

 // signals: parameters
    QMetaType::Void,

 // methods: parameters
    QMetaType::QColor, QMetaType::QVariant,    4,
    QMetaType::Bool, QMetaType::Int,    6,
    QMetaType::Void, 0x80000000 | 8,    9,
    QMetaType::Void, QMetaType::Bool, 0x80000000 | 8,   11,    9,
    QMetaType::QPoint, 0x80000000 | 8,    9,

       0        // eod
};

void SevenTasks::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<SevenTasks *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->mouseEventDetected(); break;
        case 1: { QColor _r = _t->getDominantColor((*reinterpret_cast< QVariant(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QColor*>(_a[0]) = std::move(_r); }  break;
        case 2: { bool _r = _t->isActiveWindow((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 3: _t->disableBlurBehind((*reinterpret_cast< QWindow*(*)>(_a[1]))); break;
        case 4: _t->setMouseGrab((*reinterpret_cast< bool(*)>(_a[1])),(*reinterpret_cast< QWindow*(*)>(_a[2]))); break;
        case 5: { QPoint _r = _t->getPosition((*reinterpret_cast< QWindow*(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QPoint*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 3:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QWindow* >(); break;
            }
            break;
        case 4:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 1:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QWindow* >(); break;
            }
            break;
        case 5:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QWindow* >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (SevenTasks::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&SevenTasks::mouseEventDetected)) {
                *result = 0;
                return;
            }
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject SevenTasks::staticMetaObject = { {
    QMetaObject::SuperData::link<Plasma::Applet::staticMetaObject>(),
    qt_meta_stringdata_SevenTasks.data,
    qt_meta_data_SevenTasks,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *SevenTasks::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SevenTasks::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_SevenTasks.stringdata0))
        return static_cast<void*>(this);
    return Plasma::Applet::qt_metacast(_clname);
}

int SevenTasks::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = Plasma::Applet::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    }
    return _id;
}

// SIGNAL 0
void SevenTasks::mouseEventDetected()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
