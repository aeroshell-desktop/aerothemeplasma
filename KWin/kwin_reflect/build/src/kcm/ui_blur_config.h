/********************************************************************************
** Form generated from reading UI file 'blur_config.ui'
**
** Created by: Qt User Interface Compiler version 5.15.10
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_BLUR_CONFIG_H
#define UI_BLUR_CONFIG_H

#include <QtCore/QVariant>
#include <QtGui/QIcon>
#include <QtWidgets/QApplication>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QFrame>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QPlainTextEdit>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_BlurEffectConfig
{
public:
    QVBoxLayout *verticalLayout;
    QLabel *labelConstantBlurDescription;
    QVBoxLayout *verticalLayout_2;
    QCheckBox *kcfg_TranslateTexture;
    QCheckBox *kcfg_EnableColorization;
    QLabel *showAccentColor_label;
    QSpinBox *kcfg_AccentColorName;
    QPlainTextEdit *kcfg_AccentColor;
    QPlainTextEdit *kcfg_CustomColor;
    QCheckBox *kcfg_EnableTransparency;
    QLabel *labelConstantNoiseDescription;
    QHBoxLayout *horizontalLayout_2;
    QLineEdit *kcfg_TextureLocation;
    QPushButton *browse_pushButton;
    QPushButton *clear_pushButton;
    QSpacerItem *verticalSpacer_2;
    QFrame *line;
    QLabel *label;
    QPlainTextEdit *kcfg_ExcludedWindows;
    QLabel *label_2;
    QPlainTextEdit *kcfg_ExcludedColorization;
    QSpacerItem *verticalSpacer;

    void setupUi(QWidget *BlurEffectConfig)
    {
        if (BlurEffectConfig->objectName().isEmpty())
            BlurEffectConfig->setObjectName(QString::fromUtf8("BlurEffectConfig"));
        BlurEffectConfig->resize(456, 450);
        QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(BlurEffectConfig->sizePolicy().hasHeightForWidth());
        BlurEffectConfig->setSizePolicy(sizePolicy);
        BlurEffectConfig->setMinimumSize(QSize(444, 450));
        BlurEffectConfig->setBaseSize(QSize(444, 450));
        verticalLayout = new QVBoxLayout(BlurEffectConfig);
        verticalLayout->setObjectName(QString::fromUtf8("verticalLayout"));
        labelConstantBlurDescription = new QLabel(BlurEffectConfig);
        labelConstantBlurDescription->setObjectName(QString::fromUtf8("labelConstantBlurDescription"));

        verticalLayout->addWidget(labelConstantBlurDescription);

        verticalLayout_2 = new QVBoxLayout();
        verticalLayout_2->setObjectName(QString::fromUtf8("verticalLayout_2"));
        kcfg_TranslateTexture = new QCheckBox(BlurEffectConfig);
        kcfg_TranslateTexture->setObjectName(QString::fromUtf8("kcfg_TranslateTexture"));
        kcfg_TranslateTexture->setChecked(true);

        verticalLayout_2->addWidget(kcfg_TranslateTexture);

        kcfg_EnableColorization = new QCheckBox(BlurEffectConfig);
        kcfg_EnableColorization->setObjectName(QString::fromUtf8("kcfg_EnableColorization"));
        kcfg_EnableColorization->setChecked(true);

        verticalLayout_2->addWidget(kcfg_EnableColorization);

        showAccentColor_label = new QLabel(BlurEffectConfig);
        showAccentColor_label->setObjectName(QString::fromUtf8("showAccentColor_label"));
        showAccentColor_label->setCursor(QCursor(Qt::PointingHandCursor));
        showAccentColor_label->setMouseTracking(true);
        showAccentColor_label->setTextFormat(Qt::RichText);

        verticalLayout_2->addWidget(showAccentColor_label);

        kcfg_AccentColorName = new QSpinBox(BlurEffectConfig);
        kcfg_AccentColorName->setObjectName(QString::fromUtf8("kcfg_AccentColorName"));
        QSizePolicy sizePolicy1(QSizePolicy::Minimum, QSizePolicy::Ignored);
        sizePolicy1.setHorizontalStretch(0);
        sizePolicy1.setVerticalStretch(0);
        sizePolicy1.setHeightForWidth(kcfg_AccentColorName->sizePolicy().hasHeightForWidth());
        kcfg_AccentColorName->setSizePolicy(sizePolicy1);

        verticalLayout_2->addWidget(kcfg_AccentColorName);

        kcfg_AccentColor = new QPlainTextEdit(BlurEffectConfig);
        kcfg_AccentColor->setObjectName(QString::fromUtf8("kcfg_AccentColor"));
        QSizePolicy sizePolicy2(QSizePolicy::Expanding, QSizePolicy::Ignored);
        sizePolicy2.setHorizontalStretch(0);
        sizePolicy2.setVerticalStretch(0);
        sizePolicy2.setHeightForWidth(kcfg_AccentColor->sizePolicy().hasHeightForWidth());
        kcfg_AccentColor->setSizePolicy(sizePolicy2);

        verticalLayout_2->addWidget(kcfg_AccentColor);

        kcfg_CustomColor = new QPlainTextEdit(BlurEffectConfig);
        kcfg_CustomColor->setObjectName(QString::fromUtf8("kcfg_CustomColor"));
        sizePolicy2.setHeightForWidth(kcfg_CustomColor->sizePolicy().hasHeightForWidth());
        kcfg_CustomColor->setSizePolicy(sizePolicy2);

        verticalLayout_2->addWidget(kcfg_CustomColor);

        kcfg_EnableTransparency = new QCheckBox(BlurEffectConfig);
        kcfg_EnableTransparency->setObjectName(QString::fromUtf8("kcfg_EnableTransparency"));
        sizePolicy1.setHeightForWidth(kcfg_EnableTransparency->sizePolicy().hasHeightForWidth());
        kcfg_EnableTransparency->setSizePolicy(sizePolicy1);
        kcfg_EnableTransparency->setChecked(true);

        verticalLayout_2->addWidget(kcfg_EnableTransparency);


        verticalLayout->addLayout(verticalLayout_2);

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
        QIcon icon;
        QString iconThemeName = QString::fromUtf8("document-open");
        if (QIcon::hasThemeIcon(iconThemeName)) {
            icon = QIcon::fromTheme(iconThemeName);
        } else {
            icon.addFile(QString::fromUtf8("."), QSize(), QIcon::Normal, QIcon::Off);
        }
        browse_pushButton->setIcon(icon);

        horizontalLayout_2->addWidget(browse_pushButton);

        clear_pushButton = new QPushButton(BlurEffectConfig);
        clear_pushButton->setObjectName(QString::fromUtf8("clear_pushButton"));
        QIcon icon1;
        iconThemeName = QString::fromUtf8("edit-delete");
        if (QIcon::hasThemeIcon(iconThemeName)) {
            icon1 = QIcon::fromTheme(iconThemeName);
        } else {
            icon1.addFile(QString::fromUtf8("."), QSize(), QIcon::Normal, QIcon::Off);
        }
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

        kcfg_ExcludedWindows = new QPlainTextEdit(BlurEffectConfig);
        kcfg_ExcludedWindows->setObjectName(QString::fromUtf8("kcfg_ExcludedWindows"));
        QSizePolicy sizePolicy3(QSizePolicy::Expanding, QSizePolicy::Fixed);
        sizePolicy3.setHorizontalStretch(0);
        sizePolicy3.setVerticalStretch(0);
        sizePolicy3.setHeightForWidth(kcfg_ExcludedWindows->sizePolicy().hasHeightForWidth());
        kcfg_ExcludedWindows->setSizePolicy(sizePolicy3);
        kcfg_ExcludedWindows->setMaximumSize(QSize(16777215, 100));
        kcfg_ExcludedWindows->setBaseSize(QSize(0, 100));

        verticalLayout->addWidget(kcfg_ExcludedWindows);

        label_2 = new QLabel(BlurEffectConfig);
        label_2->setObjectName(QString::fromUtf8("label_2"));

        verticalLayout->addWidget(label_2);

        kcfg_ExcludedColorization = new QPlainTextEdit(BlurEffectConfig);
        kcfg_ExcludedColorization->setObjectName(QString::fromUtf8("kcfg_ExcludedColorization"));
        sizePolicy3.setHeightForWidth(kcfg_ExcludedColorization->sizePolicy().hasHeightForWidth());
        kcfg_ExcludedColorization->setSizePolicy(sizePolicy3);
        kcfg_ExcludedColorization->setMaximumSize(QSize(16777215, 100));
        kcfg_ExcludedColorization->setBaseSize(QSize(0, 100));

        verticalLayout->addWidget(kcfg_ExcludedColorization);

        verticalSpacer = new QSpacerItem(0, 0, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout->addItem(verticalSpacer);


        retranslateUi(BlurEffectConfig);

        QMetaObject::connectSlotsByName(BlurEffectConfig);
    } // setupUi

    void retranslateUi(QWidget *BlurEffectConfig)
    {
        labelConstantBlurDescription->setText(QCoreApplication::translate("BlurEffectConfig", "General:", nullptr));
        kcfg_TranslateTexture->setText(QCoreApplication::translate("BlurEffectConfig", "Dynamically move the texture horizontally", nullptr));
        kcfg_EnableColorization->setText(QCoreApplication::translate("BlurEffectConfig", "Enable colorization", nullptr));
        showAccentColor_label->setText(QCoreApplication::translate("BlurEffectConfig", "<a href=\"no\">Change accent color</a>", nullptr));
        kcfg_EnableTransparency->setText(QCoreApplication::translate("BlurEffectConfig", "CheckBox", nullptr));
        labelConstantNoiseDescription->setText(QCoreApplication::translate("BlurEffectConfig", "Reflection texture:", nullptr));
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
        label->setText(QCoreApplication::translate("BlurEffectConfig", "Windows excluded from reflections:", nullptr));
        kcfg_ExcludedWindows->setPlaceholderText(QString());
        label_2->setText(QCoreApplication::translate("BlurEffectConfig", "Windows excluded from colorization:", nullptr));
        (void)BlurEffectConfig;
    } // retranslateUi

};

namespace Ui {
    class BlurEffectConfig: public Ui_BlurEffectConfig {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_BLUR_CONFIG_H
