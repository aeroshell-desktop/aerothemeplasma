/********************************************************************************
** Form generated from reading UI file 'mainwindow.ui'
**
** Created by: Qt User Interface Compiler version 5.15.5
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAINWINDOW_H
#define UI_MAINWINDOW_H

#include <QtCore/QVariant>
#include <QtGui/QIcon>
#include <QtWidgets/QApplication>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QFrame>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QLabel>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSlider>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_MainWindow
{
public:
    QWidget *centralwidget;
    QGridLayout *gridLayout_4;
    QSpacerItem *verticalSpacer_3;
    QSpacerItem *verticalSpacer;
    QSpacerItem *horizontalSpacer_4;
    QSlider *alpha_slider;
    QGroupBox *groupBox;
    QSpacerItem *verticalSpacer_2;
    QFrame *frame;
    QGridLayout *gridLayout;
    QPushButton *saveChanges_Button;
    QPushButton *apply_Button;
    QPushButton *cancel_Button;
    QSpacerItem *horizontalSpacer;
    QCheckBox *enableTransparency_CheckBox;
    QLabel *color_name_label;
    QGroupBox *colorMixerGroupBox;
    QGridLayout *gridLayout_2;
    QSpacerItem *horizontalSpacer_2;
    QSlider *hue_Slider;
    QLabel *label_3;
    QLabel *label_2;
    QSlider *saturation_Slider;
    QLabel *label_4;
    QSlider *Lightness_Slider;
    QLabel *hue_label;
    QLabel *saturation_label;
    QLabel *brightness_label;
    QLabel *alpha_label;
    QSpacerItem *horizontalSpacer_3;
    QLabel *colorMixerLabel;
    QLabel *label;
    QSpacerItem *horizontalSpacer_5;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName(QString::fromUtf8("MainWindow"));
        MainWindow->resize(900, 600);
        MainWindow->setMinimumSize(QSize(776, 585));
        QIcon icon;
        QString iconThemeName = QString::fromUtf8("style");
        if (QIcon::hasThemeIcon(iconThemeName)) {
            icon = QIcon::fromTheme(iconThemeName);
        } else {
            icon.addFile(QString::fromUtf8("."), QSize(), QIcon::Normal, QIcon::Off);
        }
        MainWindow->setWindowIcon(icon);
        MainWindow->setStyleSheet(QString::fromUtf8(""));
        centralwidget = new QWidget(MainWindow);
        centralwidget->setObjectName(QString::fromUtf8("centralwidget"));
        centralwidget->setStyleSheet(QString::fromUtf8(""));
        gridLayout_4 = new QGridLayout(centralwidget);
        gridLayout_4->setObjectName(QString::fromUtf8("gridLayout_4"));
        verticalSpacer_3 = new QSpacerItem(20, 10, QSizePolicy::Minimum, QSizePolicy::Maximum);

        gridLayout_4->addItem(verticalSpacer_3, 3, 1, 1, 1);

        verticalSpacer = new QSpacerItem(20, 10, QSizePolicy::Minimum, QSizePolicy::Expanding);

        gridLayout_4->addItem(verticalSpacer, 8, 1, 1, 1);

        horizontalSpacer_4 = new QSpacerItem(40, 20, QSizePolicy::Preferred, QSizePolicy::Minimum);

        gridLayout_4->addItem(horizontalSpacer_4, 1, 0, 1, 1);

        alpha_slider = new QSlider(centralwidget);
        alpha_slider->setObjectName(QString::fromUtf8("alpha_slider"));
        QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(alpha_slider->sizePolicy().hasHeightForWidth());
        alpha_slider->setSizePolicy(sizePolicy);
        alpha_slider->setMinimumSize(QSize(350, 0));
        alpha_slider->setMaximumSize(QSize(16777215, 16777215));
        alpha_slider->setMaximum(255);
        alpha_slider->setOrientation(Qt::Horizontal);

        gridLayout_4->addWidget(alpha_slider, 4, 2, 1, 1);

        groupBox = new QGroupBox(centralwidget);
        groupBox->setObjectName(QString::fromUtf8("groupBox"));
        QSizePolicy sizePolicy1(QSizePolicy::Preferred, QSizePolicy::Maximum);
        sizePolicy1.setHorizontalStretch(0);
        sizePolicy1.setVerticalStretch(0);
        sizePolicy1.setHeightForWidth(groupBox->sizePolicy().hasHeightForWidth());
        groupBox->setSizePolicy(sizePolicy1);
        groupBox->setMaximumSize(QSize(16777215, 16777215));
        QFont font;
        font.setPointSize(12);
        font.setBold(false);
        font.setItalic(false);
        groupBox->setFont(font);
        groupBox->setAlignment(Qt::AlignCenter);

        gridLayout_4->addWidget(groupBox, 0, 1, 1, 4);

        verticalSpacer_2 = new QSpacerItem(20, 20, QSizePolicy::Minimum, QSizePolicy::Maximum);

        gridLayout_4->addItem(verticalSpacer_2, 5, 1, 1, 1);

        frame = new QFrame(centralwidget);
        frame->setObjectName(QString::fromUtf8("frame"));
        QSizePolicy sizePolicy2(QSizePolicy::Preferred, QSizePolicy::MinimumExpanding);
        sizePolicy2.setHorizontalStretch(0);
        sizePolicy2.setVerticalStretch(0);
        sizePolicy2.setHeightForWidth(frame->sizePolicy().hasHeightForWidth());
        frame->setSizePolicy(sizePolicy2);
        frame->setMaximumSize(QSize(16777215, 50));
        frame->setFrameShape(QFrame::NoFrame);
        frame->setFrameShadow(QFrame::Raised);
        gridLayout = new QGridLayout(frame);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        saveChanges_Button = new QPushButton(frame);
        saveChanges_Button->setObjectName(QString::fromUtf8("saveChanges_Button"));
        saveChanges_Button->setMinimumSize(QSize(100, 0));
        saveChanges_Button->setMaximumSize(QSize(100, 25));

        gridLayout->addWidget(saveChanges_Button, 1, 2, 1, 1);

        apply_Button = new QPushButton(frame);
        apply_Button->setObjectName(QString::fromUtf8("apply_Button"));

        gridLayout->addWidget(apply_Button, 1, 1, 1, 1);

        cancel_Button = new QPushButton(frame);
        cancel_Button->setObjectName(QString::fromUtf8("cancel_Button"));

        gridLayout->addWidget(cancel_Button, 1, 3, 1, 1);

        horizontalSpacer = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout->addItem(horizontalSpacer, 1, 0, 1, 1);


        gridLayout_4->addWidget(frame, 9, 1, 1, 4);

        enableTransparency_CheckBox = new QCheckBox(centralwidget);
        enableTransparency_CheckBox->setObjectName(QString::fromUtf8("enableTransparency_CheckBox"));
        enableTransparency_CheckBox->setChecked(true);

        gridLayout_4->addWidget(enableTransparency_CheckBox, 2, 1, 1, 1);

        color_name_label = new QLabel(centralwidget);
        color_name_label->setObjectName(QString::fromUtf8("color_name_label"));

        gridLayout_4->addWidget(color_name_label, 1, 1, 1, 1);

        colorMixerGroupBox = new QGroupBox(centralwidget);
        colorMixerGroupBox->setObjectName(QString::fromUtf8("colorMixerGroupBox"));
        colorMixerGroupBox->setMinimumSize(QSize(0, 150));
        gridLayout_2 = new QGridLayout(colorMixerGroupBox);
        gridLayout_2->setObjectName(QString::fromUtf8("gridLayout_2"));
        horizontalSpacer_2 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout_2->addItem(horizontalSpacer_2, 1, 4, 3, 1);

        hue_Slider = new QSlider(colorMixerGroupBox);
        hue_Slider->setObjectName(QString::fromUtf8("hue_Slider"));
        hue_Slider->setMinimumSize(QSize(0, 25));
        hue_Slider->setMaximumSize(QSize(16777215, 16777215));
        hue_Slider->setStyleSheet(QString::fromUtf8("QSlider::groove:horizontal {\n"
"	background-color: qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #FF0000, stop: 0.167 #FFFF00, stop: 0.33 #00FF00, stop: 0.5 #00FFFF, stop: 0.667 #0000FF, stop: 0.833 #FF00FF, stop: 1 #FF0000);\n"
"	height: 5px;\n"
"	position: absolute;\n"
"}\n"
"\n"
"QSlider::handle:horizontal {\n"
"	height: 3px;\n"
"	width: 10px;\n"
"    background: #fafafa;\n"
"    border: 1px solid #46aaab;\n"
"	margin: -6px 1px;\n"
"    /* expand outside the groove */\n"
"\n"
"}\n"
"\n"
"QSlider::handle:horizontal:hover { \n"
"	background: #dadaff;\n"
"}"));
        hue_Slider->setMaximum(359);
        hue_Slider->setValue(0);
        hue_Slider->setOrientation(Qt::Horizontal);

        gridLayout_2->addWidget(hue_Slider, 1, 2, 1, 1);

        label_3 = new QLabel(colorMixerGroupBox);
        label_3->setObjectName(QString::fromUtf8("label_3"));

        gridLayout_2->addWidget(label_3, 2, 0, 1, 1);

        label_2 = new QLabel(colorMixerGroupBox);
        label_2->setObjectName(QString::fromUtf8("label_2"));

        gridLayout_2->addWidget(label_2, 1, 0, 1, 1);

        saturation_Slider = new QSlider(colorMixerGroupBox);
        saturation_Slider->setObjectName(QString::fromUtf8("saturation_Slider"));
        saturation_Slider->setMinimumSize(QSize(0, 25));
        saturation_Slider->setMaximumSize(QSize(16777215, 16777215));
        saturation_Slider->setMaximum(255);
        saturation_Slider->setOrientation(Qt::Horizontal);

        gridLayout_2->addWidget(saturation_Slider, 2, 2, 1, 1);

        label_4 = new QLabel(colorMixerGroupBox);
        label_4->setObjectName(QString::fromUtf8("label_4"));

        gridLayout_2->addWidget(label_4, 3, 0, 1, 1);

        Lightness_Slider = new QSlider(colorMixerGroupBox);
        Lightness_Slider->setObjectName(QString::fromUtf8("Lightness_Slider"));
        Lightness_Slider->setMinimumSize(QSize(0, 25));
        Lightness_Slider->setMaximum(255);
        Lightness_Slider->setOrientation(Qt::Horizontal);

        gridLayout_2->addWidget(Lightness_Slider, 3, 2, 1, 1);

        hue_label = new QLabel(colorMixerGroupBox);
        hue_label->setObjectName(QString::fromUtf8("hue_label"));
        hue_label->setMinimumSize(QSize(40, 0));
        hue_label->setMaximumSize(QSize(40, 16777215));

        gridLayout_2->addWidget(hue_label, 1, 3, 1, 1);

        saturation_label = new QLabel(colorMixerGroupBox);
        saturation_label->setObjectName(QString::fromUtf8("saturation_label"));
        saturation_label->setMinimumSize(QSize(40, 0));
        saturation_label->setMaximumSize(QSize(40, 16777215));

        gridLayout_2->addWidget(saturation_label, 2, 3, 1, 1);

        brightness_label = new QLabel(colorMixerGroupBox);
        brightness_label->setObjectName(QString::fromUtf8("brightness_label"));
        brightness_label->setMinimumSize(QSize(40, 0));
        brightness_label->setMaximumSize(QSize(40, 16777215));

        gridLayout_2->addWidget(brightness_label, 3, 3, 1, 1);


        gridLayout_4->addWidget(colorMixerGroupBox, 7, 1, 1, 4);

        alpha_label = new QLabel(centralwidget);
        alpha_label->setObjectName(QString::fromUtf8("alpha_label"));
        alpha_label->setMinimumSize(QSize(40, 0));
        alpha_label->setMaximumSize(QSize(40, 16777215));

        gridLayout_4->addWidget(alpha_label, 4, 3, 1, 1);

        horizontalSpacer_3 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout_4->addItem(horizontalSpacer_3, 4, 4, 1, 1);

        colorMixerLabel = new QLabel(centralwidget);
        colorMixerLabel->setObjectName(QString::fromUtf8("colorMixerLabel"));
        colorMixerLabel->setCursor(QCursor(Qt::PointingHandCursor));
        colorMixerLabel->setTextFormat(Qt::RichText);
        colorMixerLabel->setOpenExternalLinks(false);
        colorMixerLabel->setTextInteractionFlags(Qt::LinksAccessibleByMouse);

        gridLayout_4->addWidget(colorMixerLabel, 6, 1, 1, 1);

        label = new QLabel(centralwidget);
        label->setObjectName(QString::fromUtf8("label"));

        gridLayout_4->addWidget(label, 4, 1, 1, 1);

        horizontalSpacer_5 = new QSpacerItem(40, 20, QSizePolicy::Preferred, QSizePolicy::Minimum);

        gridLayout_4->addItem(horizontalSpacer_5, 4, 5, 1, 1);

        MainWindow->setCentralWidget(centralwidget);

        retranslateUi(MainWindow);

        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QCoreApplication::translate("MainWindow", "Change the colours of your theme", nullptr));
        groupBox->setTitle(QCoreApplication::translate("MainWindow", "Set the colour of window decorations, panels, tooltips and taskbar", nullptr));
        saveChanges_Button->setText(QCoreApplication::translate("MainWindow", "Save Changes", nullptr));
        apply_Button->setText(QCoreApplication::translate("MainWindow", "Apply", nullptr));
        cancel_Button->setText(QCoreApplication::translate("MainWindow", "Cancel", nullptr));
#if QT_CONFIG(tooltip)
        enableTransparency_CheckBox->setToolTip(QCoreApplication::translate("MainWindow", "Enables/disables the transparency of the entire theme. \n"
"NOTE: This setting does NOT affect compositing settings.", nullptr));
#endif // QT_CONFIG(tooltip)
        enableTransparency_CheckBox->setText(QCoreApplication::translate("MainWindow", "Enable transparency", nullptr));
        color_name_label->setText(QCoreApplication::translate("MainWindow", "Current color: Custom", nullptr));
        colorMixerGroupBox->setTitle(QCoreApplication::translate("MainWindow", "Color mixer", nullptr));
        label_3->setText(QCoreApplication::translate("MainWindow", "Saturation:", nullptr));
        label_2->setText(QCoreApplication::translate("MainWindow", "Hue:", nullptr));
        label_4->setText(QCoreApplication::translate("MainWindow", "Brightness:", nullptr));
        hue_label->setText(QCoreApplication::translate("MainWindow", "TextLabel", nullptr));
        saturation_label->setText(QCoreApplication::translate("MainWindow", "TextLabel", nullptr));
        brightness_label->setText(QCoreApplication::translate("MainWindow", "TextLabel", nullptr));
        alpha_label->setText(QCoreApplication::translate("MainWindow", "TextLabel", nullptr));
        colorMixerLabel->setText(QCoreApplication::translate("MainWindow", "<a href=\"no\">Show color mixer</a>", nullptr));
        label->setText(QCoreApplication::translate("MainWindow", "Color intensity:", nullptr));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
