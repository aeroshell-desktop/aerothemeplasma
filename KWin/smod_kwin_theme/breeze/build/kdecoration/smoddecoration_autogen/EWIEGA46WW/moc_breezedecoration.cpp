/****************************************************************************
** Meta object code from reading C++ file 'breezedecoration.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.11)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../kdecoration/breezedecoration.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'breezedecoration.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.11. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_Breeze__Decoration_t {
    QByteArrayData data[17];
    char stringdata0[251];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Breeze__Decoration_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Breeze__Decoration_t qt_meta_stringdata_Breeze__Decoration = {
    {
QT_MOC_LITERAL(0, 0, 18), // "Breeze::Decoration"
QT_MOC_LITERAL(1, 19, 17), // "buttonHoverStatus"
QT_MOC_LITERAL(2, 37, 0), // ""
QT_MOC_LITERAL(3, 38, 34), // "KDecoration2::DecorationButto..."
QT_MOC_LITERAL(4, 73, 6), // "button"
QT_MOC_LITERAL(5, 80, 7), // "hovered"
QT_MOC_LITERAL(6, 88, 3), // "pos"
QT_MOC_LITERAL(7, 92, 4), // "init"
QT_MOC_LITERAL(8, 97, 11), // "reconfigure"
QT_MOC_LITERAL(9, 109, 18), // "recalculateBorders"
QT_MOC_LITERAL(10, 128, 21), // "updateButtonsGeometry"
QT_MOC_LITERAL(11, 150, 28), // "updateButtonsGeometryDelayed"
QT_MOC_LITERAL(12, 179, 14), // "updateTitleBar"
QT_MOC_LITERAL(13, 194, 20), // "updateAnimationState"
QT_MOC_LITERAL(14, 215, 10), // "updateBlur"
QT_MOC_LITERAL(15, 226, 19), // "onTabletModeChanged"
QT_MOC_LITERAL(16, 246, 4) // "mode"

    },
    "Breeze::Decoration\0buttonHoverStatus\0"
    "\0KDecoration2::DecorationButtonType\0"
    "button\0hovered\0pos\0init\0reconfigure\0"
    "recalculateBorders\0updateButtonsGeometry\0"
    "updateButtonsGeometryDelayed\0"
    "updateTitleBar\0updateAnimationState\0"
    "updateBlur\0onTabletModeChanged\0mode"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Breeze__Decoration[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      10,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    3,   64,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       7,    0,   71,    2, 0x0a /* Public */,
       8,    0,   72,    2, 0x08 /* Private */,
       9,    0,   73,    2, 0x08 /* Private */,
      10,    0,   74,    2, 0x08 /* Private */,
      11,    0,   75,    2, 0x08 /* Private */,
      12,    0,   76,    2, 0x08 /* Private */,
      13,    0,   77,    2, 0x08 /* Private */,
      14,    0,   78,    2, 0x08 /* Private */,
      15,    1,   79,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void, 0x80000000 | 3, QMetaType::Bool, QMetaType::QPoint,    4,    5,    6,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Bool,   16,

       0        // eod
};

void Breeze::Decoration::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<Decoration *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->buttonHoverStatus((*reinterpret_cast< KDecoration2::DecorationButtonType(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2])),(*reinterpret_cast< QPoint(*)>(_a[3]))); break;
        case 1: _t->init(); break;
        case 2: _t->reconfigure(); break;
        case 3: _t->recalculateBorders(); break;
        case 4: _t->updateButtonsGeometry(); break;
        case 5: _t->updateButtonsGeometryDelayed(); break;
        case 6: _t->updateTitleBar(); break;
        case 7: _t->updateAnimationState(); break;
        case 8: _t->updateBlur(); break;
        case 9: _t->onTabletModeChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 0:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< KDecoration2::DecorationButtonType >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (Decoration::*)(KDecoration2::DecorationButtonType , bool , QPoint );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Decoration::buttonHoverStatus)) {
                *result = 0;
                return;
            }
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject Breeze::Decoration::staticMetaObject = { {
    QMetaObject::SuperData::link<KDecoration2::Decoration::staticMetaObject>(),
    qt_meta_stringdata_Breeze__Decoration.data,
    qt_meta_data_Breeze__Decoration,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *Breeze::Decoration::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Breeze::Decoration::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_Breeze__Decoration.stringdata0))
        return static_cast<void*>(this);
    return KDecoration2::Decoration::qt_metacast(_clname);
}

int Breeze::Decoration::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = KDecoration2::Decoration::qt_metacall(_c, _id, _a);
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

// SIGNAL 0
void Breeze::Decoration::buttonHoverStatus(KDecoration2::DecorationButtonType _t1, bool _t2, QPoint _t3)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t3))) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
