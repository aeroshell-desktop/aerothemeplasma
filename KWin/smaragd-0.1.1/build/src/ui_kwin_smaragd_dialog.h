#include <klocalizedstring.h>

/********************************************************************************
** Form generated from reading UI file 'kwin_smaragd_dialog.ui'
**
** Created by: Qt User Interface Compiler version 5.15.5
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_KWIN_SMARAGD_DIALOG_H
#define UI_KWIN_SMARAGD_DIALOG_H

#include <QtCore/QVariant>
#include <QtWidgets/QApplication>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QDoubleSpinBox>
#include <QtWidgets/QFormLayout>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QLabel>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QTabWidget>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>
#include "kcolorbutton.h"

QT_BEGIN_NAMESPACE

class Ui_KWinSmaragdDialog
{
public:
    QVBoxLayout *verticalLayout;
    QTabWidget *tabWidget;
    QWidget *tab;
    QFormLayout *formLayout_3;
    QLabel *label_9;
    QSpinBox *cm_HoverDuration;
    QCheckBox *cm_UseKWinTextColors;
    QCheckBox *cm_UseKWinShadows;
    QWidget *tab_2;
    QVBoxLayout *verticalLayout_2;
    QHBoxLayout *horizontalLayout;
    QFormLayout *formLayout;
    QLabel *label;
    KColorButton *cm_ShadowColor;
    QLabel *label_3;
    QSpinBox *cm_ShadowRadius;
    QLabel *label_4;
    QSpinBox *cm_ShadowOffsetX;
    QLabel *label_6;
    QDoubleSpinBox *cm_ShadowLinearDecay;
    QFormLayout *formLayout_2;
    QLabel *label_2;
    QSpinBox *cm_ShadowAlpha;
    QLabel *label_8;
    QSpinBox *cm_ShadowSize;
    QLabel *label_5;
    QSpinBox *cm_ShadowOffsetY;
    QLabel *label_7;
    QDoubleSpinBox *cm_ShadowExponentialDecay;
    QSpacerItem *horizontalSpacer;

    void setupUi(QWidget *KWinSmaragdDialog)
    {
        if (KWinSmaragdDialog->objectName().isEmpty())
            KWinSmaragdDialog->setObjectName(QString::fromUtf8("KWinSmaragdDialog"));
        KWinSmaragdDialog->resize(370, 169);
        verticalLayout = new QVBoxLayout(KWinSmaragdDialog);
        verticalLayout->setObjectName(QString::fromUtf8("verticalLayout"));
        tabWidget = new QTabWidget(KWinSmaragdDialog);
        tabWidget->setObjectName(QString::fromUtf8("tabWidget"));
        tab = new QWidget();
        tab->setObjectName(QString::fromUtf8("tab"));
        formLayout_3 = new QFormLayout(tab);
        formLayout_3->setObjectName(QString::fromUtf8("formLayout_3"));
        formLayout_3->setFieldGrowthPolicy(QFormLayout::ExpandingFieldsGrow);
        label_9 = new QLabel(tab);
        label_9->setObjectName(QString::fromUtf8("label_9"));

        formLayout_3->setWidget(1, QFormLayout::LabelRole, label_9);

        cm_HoverDuration = new QSpinBox(tab);
        cm_HoverDuration->setObjectName(QString::fromUtf8("cm_HoverDuration"));
        cm_HoverDuration->setMaximum(1990);
        cm_HoverDuration->setSingleStep(10);
        cm_HoverDuration->setValue(200);

        formLayout_3->setWidget(1, QFormLayout::FieldRole, cm_HoverDuration);

        cm_UseKWinTextColors = new QCheckBox(tab);
        cm_UseKWinTextColors->setObjectName(QString::fromUtf8("cm_UseKWinTextColors"));

        formLayout_3->setWidget(2, QFormLayout::SpanningRole, cm_UseKWinTextColors);

        cm_UseKWinShadows = new QCheckBox(tab);
        cm_UseKWinShadows->setObjectName(QString::fromUtf8("cm_UseKWinShadows"));

        formLayout_3->setWidget(3, QFormLayout::SpanningRole, cm_UseKWinShadows);

        tabWidget->addTab(tab, QString());
        tab_2 = new QWidget();
        tab_2->setObjectName(QString::fromUtf8("tab_2"));
        verticalLayout_2 = new QVBoxLayout(tab_2);
        verticalLayout_2->setObjectName(QString::fromUtf8("verticalLayout_2"));
        horizontalLayout = new QHBoxLayout();
        horizontalLayout->setObjectName(QString::fromUtf8("horizontalLayout"));
        formLayout = new QFormLayout();
        formLayout->setObjectName(QString::fromUtf8("formLayout"));
        label = new QLabel(tab_2);
        label->setObjectName(QString::fromUtf8("label"));

        formLayout->setWidget(0, QFormLayout::LabelRole, label);

        cm_ShadowColor = new KColorButton(tab_2);
        cm_ShadowColor->setObjectName(QString::fromUtf8("cm_ShadowColor"));
        cm_ShadowColor->setColor(QColor(0, 0, 0));
        cm_ShadowColor->setDefaultColor(QColor(0, 0, 0));

        formLayout->setWidget(0, QFormLayout::FieldRole, cm_ShadowColor);

        label_3 = new QLabel(tab_2);
        label_3->setObjectName(QString::fromUtf8("label_3"));

        formLayout->setWidget(1, QFormLayout::LabelRole, label_3);

        cm_ShadowRadius = new QSpinBox(tab_2);
        cm_ShadowRadius->setObjectName(QString::fromUtf8("cm_ShadowRadius"));
        cm_ShadowRadius->setValue(5);

        formLayout->setWidget(1, QFormLayout::FieldRole, cm_ShadowRadius);

        label_4 = new QLabel(tab_2);
        label_4->setObjectName(QString::fromUtf8("label_4"));

        formLayout->setWidget(2, QFormLayout::LabelRole, label_4);

        cm_ShadowOffsetX = new QSpinBox(tab_2);
        cm_ShadowOffsetX->setObjectName(QString::fromUtf8("cm_ShadowOffsetX"));
        cm_ShadowOffsetX->setMinimum(-99);

        formLayout->setWidget(2, QFormLayout::FieldRole, cm_ShadowOffsetX);

        label_6 = new QLabel(tab_2);
        label_6->setObjectName(QString::fromUtf8("label_6"));

        formLayout->setWidget(3, QFormLayout::LabelRole, label_6);

        cm_ShadowLinearDecay = new QDoubleSpinBox(tab_2);
        cm_ShadowLinearDecay->setObjectName(QString::fromUtf8("cm_ShadowLinearDecay"));
        cm_ShadowLinearDecay->setValue(1.000000000000000);

        formLayout->setWidget(3, QFormLayout::FieldRole, cm_ShadowLinearDecay);


        horizontalLayout->addLayout(formLayout);

        formLayout_2 = new QFormLayout();
        formLayout_2->setObjectName(QString::fromUtf8("formLayout_2"));
        formLayout_2->setFieldGrowthPolicy(QFormLayout::ExpandingFieldsGrow);
        label_2 = new QLabel(tab_2);
        label_2->setObjectName(QString::fromUtf8("label_2"));

        formLayout_2->setWidget(0, QFormLayout::LabelRole, label_2);

        cm_ShadowAlpha = new QSpinBox(tab_2);
        cm_ShadowAlpha->setObjectName(QString::fromUtf8("cm_ShadowAlpha"));
        cm_ShadowAlpha->setMaximum(255);
        cm_ShadowAlpha->setValue(180);

        formLayout_2->setWidget(0, QFormLayout::FieldRole, cm_ShadowAlpha);

        label_8 = new QLabel(tab_2);
        label_8->setObjectName(QString::fromUtf8("label_8"));

        formLayout_2->setWidget(1, QFormLayout::LabelRole, label_8);

        cm_ShadowSize = new QSpinBox(tab_2);
        cm_ShadowSize->setObjectName(QString::fromUtf8("cm_ShadowSize"));
        cm_ShadowSize->setMinimum(-99);
        cm_ShadowSize->setValue(-3);

        formLayout_2->setWidget(1, QFormLayout::FieldRole, cm_ShadowSize);

        label_5 = new QLabel(tab_2);
        label_5->setObjectName(QString::fromUtf8("label_5"));

        formLayout_2->setWidget(2, QFormLayout::LabelRole, label_5);

        cm_ShadowOffsetY = new QSpinBox(tab_2);
        cm_ShadowOffsetY->setObjectName(QString::fromUtf8("cm_ShadowOffsetY"));
        cm_ShadowOffsetY->setMinimum(-99);

        formLayout_2->setWidget(2, QFormLayout::FieldRole, cm_ShadowOffsetY);

        label_7 = new QLabel(tab_2);
        label_7->setObjectName(QString::fromUtf8("label_7"));

        formLayout_2->setWidget(3, QFormLayout::LabelRole, label_7);

        cm_ShadowExponentialDecay = new QDoubleSpinBox(tab_2);
        cm_ShadowExponentialDecay->setObjectName(QString::fromUtf8("cm_ShadowExponentialDecay"));
        cm_ShadowExponentialDecay->setDecimals(2);
        cm_ShadowExponentialDecay->setValue(6.000000000000000);

        formLayout_2->setWidget(3, QFormLayout::FieldRole, cm_ShadowExponentialDecay);


        horizontalLayout->addLayout(formLayout_2);

        horizontalSpacer = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        horizontalLayout->addItem(horizontalSpacer);


        verticalLayout_2->addLayout(horizontalLayout);

        tabWidget->addTab(tab_2, QString());

        verticalLayout->addWidget(tabWidget);


        retranslateUi(KWinSmaragdDialog);

        tabWidget->setCurrentIndex(0);


        QMetaObject::connectSlotsByName(KWinSmaragdDialog);
    } // setupUi

    void retranslateUi(QWidget *KWinSmaragdDialog)
    {
        label_9->setText(tr2i18n("Hover animation duration:", nullptr));
        cm_HoverDuration->setSuffix(tr2i18n(" ms", nullptr));
        cm_UseKWinTextColors->setText(tr2i18n("Use KWin colors for title text", nullptr));
        cm_UseKWinShadows->setText(tr2i18n("Use KWin shadow effect settings", nullptr));
        tabWidget->setTabText(tabWidget->indexOf(tab), tr2i18n("General", nullptr));
        label->setText(tr2i18n("Color:", nullptr));
        label_3->setText(tr2i18n("Radius:", nullptr));
        label_4->setText(tr2i18n("Offset X:", nullptr));
        label_6->setText(tr2i18n("Linear Decay:", nullptr));
        label_2->setText(tr2i18n("Intensity:", nullptr));
        label_8->setText(tr2i18n("Size:", nullptr));
        label_5->setText(tr2i18n("Offset Y:", nullptr));
        label_7->setText(tr2i18n("Exponential:", nullptr));
        tabWidget->setTabText(tabWidget->indexOf(tab_2), tr2i18n("Shadows", nullptr));
        (void)KWinSmaragdDialog;
    } // retranslateUi

};

namespace Ui {
    class KWinSmaragdDialog: public Ui_KWinSmaragdDialog {};
} // namespace Ui

QT_END_NAMESPACE

#endif // KWIN_SMARAGD_DIALOG_H

