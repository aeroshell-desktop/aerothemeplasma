/********************************************************************************
** Form generated from reading UI file 'blur_config.ui'
**
** Created by: Qt User Interface Compiler version 5.15.11
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_BLUR_CONFIG_H
#define UI_BLUR_CONFIG_H

#include <QtCore/QVariant>
#include <QtGui/QIcon>
#include <QtWidgets/QApplication>
#include <QtWidgets/QFrame>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QPlainTextEdit>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_BlurEffectConfig
{
public:
    QVBoxLayout *verticalLayout;
    QLabel *labelConstantBlurDescription;
    QLabel *labelConstantNoiseDescription;
    QHBoxLayout *horizontalLayout_2;
    QLineEdit *kcfg_TextureLocation;
    QPushButton *browse_pushButton;
    QPushButton *clear_pushButton;
    QSpacerItem *verticalSpacer_2;
    QFrame *line;
    QLabel *label;
    QPlainTextEdit *kcfg_IncludedWindows;
    QSpacerItem *verticalSpacer;

    void setupUi(QWidget *BlurEffectConfig)
    {
        if (BlurEffectConfig->objectName().isEmpty())
            BlurEffectConfig->setObjectName(QString::fromUtf8("BlurEffectConfig"));
        BlurEffectConfig->resize(456, 250);
        QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(BlurEffectConfig->sizePolicy().hasHeightForWidth());
        BlurEffectConfig->setSizePolicy(sizePolicy);
        BlurEffectConfig->setMinimumSize(QSize(444, 250));
        BlurEffectConfig->setBaseSize(QSize(444, 450));
        verticalLayout = new QVBoxLayout(BlurEffectConfig);
        verticalLayout->setObjectName(QString::fromUtf8("verticalLayout"));
        labelConstantBlurDescription = new QLabel(BlurEffectConfig);
        labelConstantBlurDescription->setObjectName(QString::fromUtf8("labelConstantBlurDescription"));

        verticalLayout->addWidget(labelConstantBlurDescription);

        labelConstantNoiseDescription = new QLabel(BlurEffectConfig);
        labelConstantNoiseDescription->setObjectName(QString::fromUtf8("labelConstantNoiseDescription"));

        verticalLayout->addWidget(labelConstantNoiseDescription);

        horizontalLayout_2 = new QHBoxLayout();
        horizontalLayout_2->setObjectName(QString::fromUtf8("horizontalLayout_2"));
        kcfg_TextureLocation = new QLineEdit(BlurEffectConfig);
        kcfg_TextureLocation->setObjectName(QString::fromUtf8("kcfg_TextureLocation"));
        kcfg_TextureLocation->setReadOnly(true);

        horizontalLayout_2->addWidget(kcfg_TextureLocation);

        browse_pushButton = new QPushButton(BlurEffectConfig);
        browse_pushButton->setObjectName(QString::fromUtf8("browse_pushButton"));
        QIcon icon(QIcon::fromTheme(QString::fromUtf8("document-open")));
        browse_pushButton->setIcon(icon);

        horizontalLayout_2->addWidget(browse_pushButton);

        clear_pushButton = new QPushButton(BlurEffectConfig);
        clear_pushButton->setObjectName(QString::fromUtf8("clear_pushButton"));
        QIcon icon1(QIcon::fromTheme(QString::fromUtf8("edit-delete")));
        clear_pushButton->setIcon(icon1);

        horizontalLayout_2->addWidget(clear_pushButton);


        verticalLayout->addLayout(horizontalLayout_2);

        verticalSpacer_2 = new QSpacerItem(10, 10, QSizePolicy::Minimum, QSizePolicy::Fixed);

        verticalLayout->addItem(verticalSpacer_2);

        line = new QFrame(BlurEffectConfig);
        line->setObjectName(QString::fromUtf8("line"));
        line->setFrameShape(QFrame::HLine);
        line->setFrameShadow(QFrame::Sunken);

        verticalLayout->addWidget(line);

        label = new QLabel(BlurEffectConfig);
        label->setObjectName(QString::fromUtf8("label"));

        verticalLayout->addWidget(label);

        kcfg_IncludedWindows = new QPlainTextEdit(BlurEffectConfig);
        kcfg_IncludedWindows->setObjectName(QString::fromUtf8("kcfg_IncludedWindows"));
        QSizePolicy sizePolicy1(QSizePolicy::Expanding, QSizePolicy::Fixed);
        sizePolicy1.setHorizontalStretch(0);
        sizePolicy1.setVerticalStretch(0);
        sizePolicy1.setHeightForWidth(kcfg_IncludedWindows->sizePolicy().hasHeightForWidth());
        kcfg_IncludedWindows->setSizePolicy(sizePolicy1);
        kcfg_IncludedWindows->setMaximumSize(QSize(16777215, 100));
        kcfg_IncludedWindows->setBaseSize(QSize(0, 100));

        verticalLayout->addWidget(kcfg_IncludedWindows);

        verticalSpacer = new QSpacerItem(0, 0, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout->addItem(verticalSpacer);


        retranslateUi(BlurEffectConfig);

        QMetaObject::connectSlotsByName(BlurEffectConfig);
    } // setupUi

    void retranslateUi(QWidget *BlurEffectConfig)
    {
        labelConstantBlurDescription->setText(QCoreApplication::translate("BlurEffectConfig", "General:", nullptr));
        labelConstantNoiseDescription->setText(QCoreApplication::translate("BlurEffectConfig", "Blur region mask:", nullptr));
#if QT_CONFIG(tooltip)
        browse_pushButton->setToolTip(QCoreApplication::translate("BlurEffectConfig", "Browse...", nullptr));
#endif // QT_CONFIG(tooltip)
        browse_pushButton->setText(QString());
#if QT_CONFIG(tooltip)
        clear_pushButton->setToolTip(QCoreApplication::translate("BlurEffectConfig", "Clear", nullptr));
#endif // QT_CONFIG(tooltip)
        clear_pushButton->setText(QString());
#if QT_CONFIG(whatsthis)
        label->setWhatsThis(QString());
#endif // QT_CONFIG(whatsthis)
        label->setText(QCoreApplication::translate("BlurEffectConfig", "Enable this effect for the following Firefox-based browsers:", nullptr));
        kcfg_IncludedWindows->setPlaceholderText(QString());
        (void)BlurEffectConfig;
    } // retranslateUi

};

namespace Ui {
    class BlurEffectConfig: public Ui_BlurEffectConfig {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_BLUR_CONFIG_H
