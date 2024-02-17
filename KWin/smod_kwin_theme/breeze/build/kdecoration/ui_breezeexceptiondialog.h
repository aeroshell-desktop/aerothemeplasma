#include <klocalizedstring.h>

/********************************************************************************
** Form generated from reading UI file 'breezeexceptiondialog.ui'
**
** Created by: Qt User Interface Compiler version 5.15.11
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_BREEZEEXCEPTIONDIALOG_H
#define UI_BREEZEEXCEPTIONDIALOG_H

#include <QtCore/QVariant>
#include <QtWidgets/QApplication>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QComboBox>
#include <QtWidgets/QDialog>
#include <QtWidgets/QDialogButtonBox>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QVBoxLayout>

QT_BEGIN_NAMESPACE

class Ui_BreezeExceptionDialog
{
public:
    QVBoxLayout *verticalLayout;
    QGroupBox *groupBox;
    QGridLayout *gridLayout_2;
    QLabel *label;
    QLabel *label_2;
    QPushButton *detectDialogButton;
    QLineEdit *exceptionEditor;
    QComboBox *exceptionType;
    QGroupBox *groupBox_2;
    QGridLayout *gridLayout_3;
    QCheckBox *borderSizeCheckBox;
    QCheckBox *hideTitleBar;
    QComboBox *borderSizeComboBox;
    QCheckBox *hideIcon;
    QCheckBox *hideCaption;
    QCheckBox *hideInnerBorder;
    QSpacerItem *verticalSpacer;
    QDialogButtonBox *buttonBox;

    void setupUi(QDialog *BreezeExceptionDialog)
    {
        if (BreezeExceptionDialog->objectName().isEmpty())
            BreezeExceptionDialog->setObjectName(QString::fromUtf8("BreezeExceptionDialog"));
        BreezeExceptionDialog->resize(362, 321);
        verticalLayout = new QVBoxLayout(BreezeExceptionDialog);
        verticalLayout->setObjectName(QString::fromUtf8("verticalLayout"));
        groupBox = new QGroupBox(BreezeExceptionDialog);
        groupBox->setObjectName(QString::fromUtf8("groupBox"));
        gridLayout_2 = new QGridLayout(groupBox);
        gridLayout_2->setObjectName(QString::fromUtf8("gridLayout_2"));
        label = new QLabel(groupBox);
        label->setObjectName(QString::fromUtf8("label"));
        label->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);

        gridLayout_2->addWidget(label, 0, 0, 1, 1);

        label_2 = new QLabel(groupBox);
        label_2->setObjectName(QString::fromUtf8("label_2"));
        label_2->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);

        gridLayout_2->addWidget(label_2, 1, 0, 1, 1);

        detectDialogButton = new QPushButton(groupBox);
        detectDialogButton->setObjectName(QString::fromUtf8("detectDialogButton"));

        gridLayout_2->addWidget(detectDialogButton, 2, 2, 1, 1);

        exceptionEditor = new QLineEdit(groupBox);
        exceptionEditor->setObjectName(QString::fromUtf8("exceptionEditor"));
        exceptionEditor->setProperty("showClearButton", QVariant(true));

        gridLayout_2->addWidget(exceptionEditor, 1, 1, 1, 2);

        exceptionType = new QComboBox(groupBox);
        exceptionType->addItem(QString());
        exceptionType->addItem(QString());
        exceptionType->setObjectName(QString::fromUtf8("exceptionType"));

        gridLayout_2->addWidget(exceptionType, 0, 1, 1, 2);


        verticalLayout->addWidget(groupBox);

        groupBox_2 = new QGroupBox(BreezeExceptionDialog);
        groupBox_2->setObjectName(QString::fromUtf8("groupBox_2"));
        gridLayout_3 = new QGridLayout(groupBox_2);
        gridLayout_3->setObjectName(QString::fromUtf8("gridLayout_3"));
        borderSizeCheckBox = new QCheckBox(groupBox_2);
        borderSizeCheckBox->setObjectName(QString::fromUtf8("borderSizeCheckBox"));

        gridLayout_3->addWidget(borderSizeCheckBox, 0, 0, 1, 1);

        hideTitleBar = new QCheckBox(groupBox_2);
        hideTitleBar->setObjectName(QString::fromUtf8("hideTitleBar"));

        gridLayout_3->addWidget(hideTitleBar, 2, 0, 1, 2);

        borderSizeComboBox = new QComboBox(groupBox_2);
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->addItem(QString());
        borderSizeComboBox->setObjectName(QString::fromUtf8("borderSizeComboBox"));
        borderSizeComboBox->setEnabled(false);

        gridLayout_3->addWidget(borderSizeComboBox, 0, 1, 1, 1);

        hideIcon = new QCheckBox(groupBox_2);
        hideIcon->setObjectName(QString::fromUtf8("hideIcon"));

        gridLayout_3->addWidget(hideIcon, 3, 0, 1, 2);

        hideCaption = new QCheckBox(groupBox_2);
        hideCaption->setObjectName(QString::fromUtf8("hideCaption"));

        gridLayout_3->addWidget(hideCaption, 4, 0, 1, 2);

        hideInnerBorder = new QCheckBox(groupBox_2);
        hideInnerBorder->setObjectName(QString::fromUtf8("hideInnerBorder"));

        gridLayout_3->addWidget(hideInnerBorder, 5, 0, 1, 2);

        verticalSpacer = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);

        gridLayout_3->addItem(verticalSpacer, 6, 0, 1, 2);


        verticalLayout->addWidget(groupBox_2);

        buttonBox = new QDialogButtonBox(BreezeExceptionDialog);
        buttonBox->setObjectName(QString::fromUtf8("buttonBox"));
        buttonBox->setOrientation(Qt::Horizontal);
        buttonBox->setStandardButtons(QDialogButtonBox::Cancel|QDialogButtonBox::Ok);

        verticalLayout->addWidget(buttonBox);

#if QT_CONFIG(shortcut)
        label->setBuddy(exceptionType);
        label_2->setBuddy(exceptionEditor);
#endif // QT_CONFIG(shortcut)

        retranslateUi(BreezeExceptionDialog);
        QObject::connect(buttonBox, SIGNAL(accepted()), BreezeExceptionDialog, SLOT(accept()));
        QObject::connect(buttonBox, SIGNAL(rejected()), BreezeExceptionDialog, SLOT(reject()));
        QObject::connect(borderSizeCheckBox, SIGNAL(toggled(bool)), borderSizeComboBox, SLOT(setEnabled(bool)));

        QMetaObject::connectSlotsByName(BreezeExceptionDialog);
    } // setupUi

    void retranslateUi(QDialog *BreezeExceptionDialog)
    {
        BreezeExceptionDialog->setWindowTitle(tr2i18n("Dialog", nullptr));
        groupBox->setTitle(tr2i18n("Window Identification", nullptr));
        label->setText(tr2i18n("&Matching window property: ", nullptr));
        label_2->setText(tr2i18n("Regular expression &to match: ", nullptr));
        detectDialogButton->setText(tr2i18n("Detect Window Properties\342\200\246", nullptr));
        exceptionType->setItemText(0, tr2i18n("Window Class Name", nullptr));
        exceptionType->setItemText(1, tr2i18n("Window Title", nullptr));

        groupBox_2->setTitle(tr2i18n("Decoration Options", nullptr));
        borderSizeCheckBox->setText(tr2i18n("Border size:", nullptr));
        hideTitleBar->setText(tr2i18n("Hide window title bar", nullptr));
        borderSizeComboBox->setItemText(0, tr2i18n("No Border", "@item:inlistbox Border size:"));
        borderSizeComboBox->setItemText(1, tr2i18n("No Side Borders", "@item:inlistbox Border size:"));
        borderSizeComboBox->setItemText(2, tr2i18n("Tiny", "@item:inlistbox Border size:"));
        borderSizeComboBox->setItemText(3, tr2i18n("Normal", "@item:inlistbox Border size:"));
        borderSizeComboBox->setItemText(4, tr2i18n("Large", "@item:inlistbox Border size:"));
        borderSizeComboBox->setItemText(5, tr2i18n("Very Large", "@item:inlistbox Border size:"));
        borderSizeComboBox->setItemText(6, tr2i18n("Huge", "@item:inlistbox Border size:"));
        borderSizeComboBox->setItemText(7, tr2i18n("Very Huge", "@item:inlistbox Border size:"));
        borderSizeComboBox->setItemText(8, tr2i18n("Oversized", "@item:inlistbox Border size:"));

        hideIcon->setText(tr2i18n("Hide window icon", nullptr));
        hideCaption->setText(tr2i18n("Hide window caption", nullptr));
        hideInnerBorder->setText(tr2i18n("Hide window inner border", nullptr));
    } // retranslateUi

};

namespace Ui {
    class BreezeExceptionDialog: public Ui_BreezeExceptionDialog {};
} // namespace Ui

QT_END_NAMESPACE

#endif // BREEZEEXCEPTIONDIALOG_H

