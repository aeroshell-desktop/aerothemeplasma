#include <klocalizedstring.h>

/********************************************************************************
** Form generated from reading UI file 'breezeexceptionlistwidget.ui'
**
** Created by: Qt User Interface Compiler version 5.15.11
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_BREEZEEXCEPTIONLISTWIDGET_H
#define UI_BREEZEEXCEPTIONLISTWIDGET_H

#include <QtCore/QVariant>
#include <QtWidgets/QApplication>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QTreeView>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_BreezeExceptionListWidget
{
public:
    QGridLayout *gridLayout;
    QTreeView *exceptionListView;
    QSpacerItem *verticalSpacer;
    QPushButton *moveUpButton;
    QPushButton *moveDownButton;
    QPushButton *addButton;
    QPushButton *removeButton;
    QPushButton *editButton;

    void setupUi(QWidget *BreezeExceptionListWidget)
    {
        if (BreezeExceptionListWidget->objectName().isEmpty())
            BreezeExceptionListWidget->setObjectName(QString::fromUtf8("BreezeExceptionListWidget"));
        BreezeExceptionListWidget->resize(473, 182);
        QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(BreezeExceptionListWidget->sizePolicy().hasHeightForWidth());
        BreezeExceptionListWidget->setSizePolicy(sizePolicy);
        BreezeExceptionListWidget->setMinimumSize(QSize(0, 0));
        gridLayout = new QGridLayout(BreezeExceptionListWidget);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        gridLayout->setContentsMargins(0, 0, 0, 0);
        exceptionListView = new QTreeView(BreezeExceptionListWidget);
        exceptionListView->setObjectName(QString::fromUtf8("exceptionListView"));
        QSizePolicy sizePolicy1(QSizePolicy::Expanding, QSizePolicy::Maximum);
        sizePolicy1.setHorizontalStretch(0);
        sizePolicy1.setVerticalStretch(0);
        sizePolicy1.setHeightForWidth(exceptionListView->sizePolicy().hasHeightForWidth());
        exceptionListView->setSizePolicy(sizePolicy1);
        exceptionListView->setMinimumSize(QSize(100, 100));

        gridLayout->addWidget(exceptionListView, 0, 0, 6, 1);

        verticalSpacer = new QSpacerItem(20, 1, QSizePolicy::Minimum, QSizePolicy::Expanding);

        gridLayout->addItem(verticalSpacer, 5, 1, 1, 1);

        moveUpButton = new QPushButton(BreezeExceptionListWidget);
        moveUpButton->setObjectName(QString::fromUtf8("moveUpButton"));

        gridLayout->addWidget(moveUpButton, 0, 1, 1, 1);

        moveDownButton = new QPushButton(BreezeExceptionListWidget);
        moveDownButton->setObjectName(QString::fromUtf8("moveDownButton"));

        gridLayout->addWidget(moveDownButton, 1, 1, 1, 1);

        addButton = new QPushButton(BreezeExceptionListWidget);
        addButton->setObjectName(QString::fromUtf8("addButton"));

        gridLayout->addWidget(addButton, 2, 1, 1, 1);

        removeButton = new QPushButton(BreezeExceptionListWidget);
        removeButton->setObjectName(QString::fromUtf8("removeButton"));

        gridLayout->addWidget(removeButton, 3, 1, 1, 1);

        editButton = new QPushButton(BreezeExceptionListWidget);
        editButton->setObjectName(QString::fromUtf8("editButton"));

        gridLayout->addWidget(editButton, 4, 1, 1, 1);

        QWidget::setTabOrder(exceptionListView, moveUpButton);
        QWidget::setTabOrder(moveUpButton, moveDownButton);
        QWidget::setTabOrder(moveDownButton, addButton);
        QWidget::setTabOrder(addButton, removeButton);
        QWidget::setTabOrder(removeButton, editButton);

        retranslateUi(BreezeExceptionListWidget);

        QMetaObject::connectSlotsByName(BreezeExceptionListWidget);
    } // setupUi

    void retranslateUi(QWidget *BreezeExceptionListWidget)
    {
        moveUpButton->setText(tr2i18n("Move Up", nullptr));
        moveDownButton->setText(tr2i18n("Move Down", nullptr));
        addButton->setText(tr2i18n("Add", nullptr));
        removeButton->setText(tr2i18n("Remove", nullptr));
        editButton->setText(tr2i18n("Edit", nullptr));
        (void)BreezeExceptionListWidget;
    } // retranslateUi

};

namespace Ui {
    class BreezeExceptionListWidget: public Ui_BreezeExceptionListWidget {};
} // namespace Ui

QT_END_NAMESPACE

#endif // BREEZEEXCEPTIONLISTWIDGET_H

