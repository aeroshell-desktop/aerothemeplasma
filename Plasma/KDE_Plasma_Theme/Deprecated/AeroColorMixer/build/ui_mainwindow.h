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
#include <QtWidgets/QHBoxLayout>
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
    QGridLayout *gridLayout_3;
    QLabel *alpha_label;
    QSpacerItem *horizontalSpacer_3;
    QLabel *label;
    QSpacerItem *horizontalSpacer_5;
    QCheckBox *enableTransparency_CheckBox;
    QFrame *frame;
    QGridLayout *gridLayout;
    QSpacerItem *horizontalSpacer;
    QLabel *colorMixerLabel;
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
    QSpacerItem *horizontalSpacer_4;
    QSpacerItem *verticalSpacer;
    QSlider *alpha_slider;
    QSpacerItem *verticalSpacer_3;
    QLabel *color_name_label;
    QGroupBox *groupBox;
    QWidget *widget;
    QHBoxLayout *horizontalLayout;
    QSpacerItem *horizontalSpacer_6;
    QPushButton *apply_Button;
    QPushButton *saveChanges_Button;
    QPushButton *cancel_Button;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName(QString::fromUtf8("MainWindow"));
        MainWindow->resize(759, 585);
        MainWindow->setMinimumSize(QSize(759, 585));
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
        gridLayout_3 = new QGridLayout(centralwidget);
        gridLayout_3->setObjectName(QString::fromUtf8("gridLayout_3"));
        alpha_label = new QLabel(centralwidget);
        alpha_label->setObjectName(QString::fromUtf8("alpha_label"));
        alpha_label->setMinimumSize(QSize(40, 0));
        alpha_label->setMaximumSize(QSize(40, 16777215));

        gridLayout_3->addWidget(alpha_label, 4, 3, 1, 1);

        horizontalSpacer_3 = new QSpacerItem(40, 20, QSizePolicy::MinimumExpanding, QSizePolicy::Minimum);

        gridLayout_3->addItem(horizontalSpacer_3, 4, 4, 1, 1);

        label = new QLabel(centralwidget);
        label->setObjectName(QString::fromUtf8("label"));
        QSizePolicy sizePolicy(QSizePolicy::Maximum, QSizePolicy::Preferred);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(label->sizePolicy().hasHeightForWidth());
        label->setSizePolicy(sizePolicy);
        label->setMinimumSize(QSize(0, 0));
        label->setMaximumSize(QSize(16777215, 20));
        label->setAlignment(Qt::AlignHCenter|Qt::AlignTop);

        gridLayout_3->addWidget(label, 4, 1, 1, 1);

        horizontalSpacer_5 = new QSpacerItem(40, 20, QSizePolicy::Preferred, QSizePolicy::Minimum);

        gridLayout_3->addItem(horizontalSpacer_5, 4, 5, 1, 1);

        enableTransparency_CheckBox = new QCheckBox(centralwidget);
        enableTransparency_CheckBox->setObjectName(QString::fromUtf8("enableTransparency_CheckBox"));
        enableTransparency_CheckBox->setMaximumSize(QSize(16777215, 16777215));
        enableTransparency_CheckBox->setChecked(true);

        gridLayout_3->addWidget(enableTransparency_CheckBox, 2, 1, 1, 2);

        frame = new QFrame(centralwidget);
        frame->setObjectName(QString::fromUtf8("frame"));
        QSizePolicy sizePolicy1(QSizePolicy::Preferred, QSizePolicy::MinimumExpanding);
        sizePolicy1.setHorizontalStretch(0);
        sizePolicy1.setVerticalStretch(0);
        sizePolicy1.setHeightForWidth(frame->sizePolicy().hasHeightForWidth());
        frame->setSizePolicy(sizePolicy1);
        frame->setMaximumSize(QSize(16777215, 50));
        frame->setFrameShape(QFrame::NoFrame);
        frame->setFrameShadow(QFrame::Raised);
        gridLayout = new QGridLayout(frame);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        horizontalSpacer = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout->addItem(horizontalSpacer, 1, 0, 1, 1);


        gridLayout_3->addWidget(frame, 8, 1, 1, 2);

        colorMixerLabel = new QLabel(centralwidget);
        colorMixerLabel->setObjectName(QString::fromUtf8("colorMixerLabel"));
        QSizePolicy sizePolicy2(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy2.setHorizontalStretch(0);
        sizePolicy2.setVerticalStretch(0);
        sizePolicy2.setHeightForWidth(colorMixerLabel->sizePolicy().hasHeightForWidth());
        colorMixerLabel->setSizePolicy(sizePolicy2);
        colorMixerLabel->setCursor(QCursor(Qt::PointingHandCursor));
        colorMixerLabel->setTextFormat(Qt::RichText);
        colorMixerLabel->setOpenExternalLinks(false);
        colorMixerLabel->setTextInteractionFlags(Qt::LinksAccessibleByMouse);

        gridLayout_3->addWidget(colorMixerLabel, 5, 1, 1, 2);

        colorMixerGroupBox = new QGroupBox(centralwidget);
        colorMixerGroupBox->setObjectName(QString::fromUtf8("colorMixerGroupBox"));
        colorMixerGroupBox->setMinimumSize(QSize(0, 150));
        colorMixerGroupBox->setFlat(true);
        gridLayout_2 = new QGridLayout(colorMixerGroupBox);
        gridLayout_2->setObjectName(QString::fromUtf8("gridLayout_2"));
        gridLayout_2->setContentsMargins(0, 0, -1, -1);
        horizontalSpacer_2 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout_2->addItem(horizontalSpacer_2, 1, 4, 3, 1);

        hue_Slider = new QSlider(colorMixerGroupBox);
        hue_Slider->setObjectName(QString::fromUtf8("hue_Slider"));
        QSizePolicy sizePolicy3(QSizePolicy::Fixed, QSizePolicy::Fixed);
        sizePolicy3.setHorizontalStretch(0);
        sizePolicy3.setVerticalStretch(0);
        sizePolicy3.setHeightForWidth(hue_Slider->sizePolicy().hasHeightForWidth());
        hue_Slider->setSizePolicy(sizePolicy3);
        hue_Slider->setMinimumSize(QSize(259, 25));
        hue_Slider->setMaximumSize(QSize(259, 16777215));
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
        QSizePolicy sizePolicy4(QSizePolicy::Minimum, QSizePolicy::Preferred);
        sizePolicy4.setHorizontalStretch(0);
        sizePolicy4.setVerticalStretch(0);
        sizePolicy4.setHeightForWidth(label_3->sizePolicy().hasHeightForWidth());
        label_3->setSizePolicy(sizePolicy4);
        label_3->setMinimumSize(QSize(72, 0));
        label_3->setMaximumSize(QSize(72, 16777215));
        label_3->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignVCenter);
        label_3->setMargin(0);

        gridLayout_2->addWidget(label_3, 2, 0, 1, 1);

        label_2 = new QLabel(colorMixerGroupBox);
        label_2->setObjectName(QString::fromUtf8("label_2"));
        sizePolicy4.setHeightForWidth(label_2->sizePolicy().hasHeightForWidth());
        label_2->setSizePolicy(sizePolicy4);
        label_2->setMinimumSize(QSize(72, 0));
        label_2->setMaximumSize(QSize(72, 16777215));
        label_2->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignVCenter);
        label_2->setMargin(0);

        gridLayout_2->addWidget(label_2, 1, 0, 1, 1);

        saturation_Slider = new QSlider(colorMixerGroupBox);
        saturation_Slider->setObjectName(QString::fromUtf8("saturation_Slider"));
        sizePolicy3.setHeightForWidth(saturation_Slider->sizePolicy().hasHeightForWidth());
        saturation_Slider->setSizePolicy(sizePolicy3);
        saturation_Slider->setMinimumSize(QSize(259, 25));
        saturation_Slider->setMaximumSize(QSize(259, 16777215));
        saturation_Slider->setMaximum(255);
        saturation_Slider->setOrientation(Qt::Horizontal);

        gridLayout_2->addWidget(saturation_Slider, 2, 2, 1, 1);

        label_4 = new QLabel(colorMixerGroupBox);
        label_4->setObjectName(QString::fromUtf8("label_4"));
        sizePolicy4.setHeightForWidth(label_4->sizePolicy().hasHeightForWidth());
        label_4->setSizePolicy(sizePolicy4);
        label_4->setMinimumSize(QSize(72, 0));
        label_4->setMaximumSize(QSize(72, 16777215));
        label_4->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignVCenter);
        label_4->setMargin(0);

        gridLayout_2->addWidget(label_4, 3, 0, 1, 1);

        Lightness_Slider = new QSlider(colorMixerGroupBox);
        Lightness_Slider->setObjectName(QString::fromUtf8("Lightness_Slider"));
        sizePolicy3.setHeightForWidth(Lightness_Slider->sizePolicy().hasHeightForWidth());
        Lightness_Slider->setSizePolicy(sizePolicy3);
        Lightness_Slider->setMinimumSize(QSize(259, 25));
        Lightness_Slider->setMaximumSize(QSize(259, 16777215));
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


        gridLayout_3->addWidget(colorMixerGroupBox, 6, 1, 1, 4);

        horizontalSpacer_4 = new QSpacerItem(40, 20, QSizePolicy::Preferred, QSizePolicy::Minimum);

        gridLayout_3->addItem(horizontalSpacer_4, 1, 0, 1, 1);

        verticalSpacer = new QSpacerItem(20, 10, QSizePolicy::Minimum, QSizePolicy::MinimumExpanding);

        gridLayout_3->addItem(verticalSpacer, 7, 1, 1, 1);

        alpha_slider = new QSlider(centralwidget);
        alpha_slider->setObjectName(QString::fromUtf8("alpha_slider"));
        QSizePolicy sizePolicy5(QSizePolicy::MinimumExpanding, QSizePolicy::Preferred);
        sizePolicy5.setHorizontalStretch(1);
        sizePolicy5.setVerticalStretch(0);
        sizePolicy5.setHeightForWidth(alpha_slider->sizePolicy().hasHeightForWidth());
        alpha_slider->setSizePolicy(sizePolicy5);
        alpha_slider->setMinimumSize(QSize(259, 0));
        alpha_slider->setMaximumSize(QSize(250, 16777215));
        alpha_slider->setMaximum(255);
        alpha_slider->setOrientation(Qt::Horizontal);

        gridLayout_3->addWidget(alpha_slider, 4, 2, 1, 1);

        verticalSpacer_3 = new QSpacerItem(20, 10, QSizePolicy::Minimum, QSizePolicy::Fixed);

        gridLayout_3->addItem(verticalSpacer_3, 3, 1, 1, 1);

        color_name_label = new QLabel(centralwidget);
        color_name_label->setObjectName(QString::fromUtf8("color_name_label"));

        gridLayout_3->addWidget(color_name_label, 1, 1, 1, 2);

        groupBox = new QGroupBox(centralwidget);
        groupBox->setObjectName(QString::fromUtf8("groupBox"));
        QSizePolicy sizePolicy6(QSizePolicy::Preferred, QSizePolicy::Maximum);
        sizePolicy6.setHorizontalStretch(0);
        sizePolicy6.setVerticalStretch(0);
        sizePolicy6.setHeightForWidth(groupBox->sizePolicy().hasHeightForWidth());
        groupBox->setSizePolicy(sizePolicy6);
        groupBox->setMaximumSize(QSize(16777215, 16777215));
        QFont font;
        font.setPointSize(12);
        font.setBold(false);
        font.setItalic(false);
        groupBox->setFont(font);
        groupBox->setAlignment(Qt::AlignCenter);

        gridLayout_3->addWidget(groupBox, 0, 1, 1, 4);

        widget = new QWidget(centralwidget);
        widget->setObjectName(QString::fromUtf8("widget"));
        sizePolicy2.setHeightForWidth(widget->sizePolicy().hasHeightForWidth());
        widget->setSizePolicy(sizePolicy2);
        widget->setMinimumSize(QSize(290, 0));
        widget->setStyleSheet(QString::fromUtf8(""));
        horizontalLayout = new QHBoxLayout(widget);
        horizontalLayout->setObjectName(QString::fromUtf8("horizontalLayout"));
        horizontalSpacer_6 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        horizontalLayout->addItem(horizontalSpacer_6);

        apply_Button = new QPushButton(widget);
        apply_Button->setObjectName(QString::fromUtf8("apply_Button"));
        sizePolicy3.setHeightForWidth(apply_Button->sizePolicy().hasHeightForWidth());
        apply_Button->setSizePolicy(sizePolicy3);
        apply_Button->setMinimumSize(QSize(0, 21));
        apply_Button->setMaximumSize(QSize(16777215, 21));

        horizontalLayout->addWidget(apply_Button);

        saveChanges_Button = new QPushButton(widget);
        saveChanges_Button->setObjectName(QString::fromUtf8("saveChanges_Button"));
        sizePolicy3.setHeightForWidth(saveChanges_Button->sizePolicy().hasHeightForWidth());
        saveChanges_Button->setSizePolicy(sizePolicy3);
        saveChanges_Button->setMinimumSize(QSize(100, 21));
        saveChanges_Button->setMaximumSize(QSize(100, 21));

        horizontalLayout->addWidget(saveChanges_Button);

        cancel_Button = new QPushButton(widget);
        cancel_Button->setObjectName(QString::fromUtf8("cancel_Button"));
        sizePolicy3.setHeightForWidth(cancel_Button->sizePolicy().hasHeightForWidth());
        cancel_Button->setSizePolicy(sizePolicy3);
        cancel_Button->setMinimumSize(QSize(0, 21));
        cancel_Button->setMaximumSize(QSize(16777215, 21));

        horizontalLayout->addWidget(cancel_Button);


        gridLayout_3->addWidget(widget, 8, 3, 1, 3);

        MainWindow->setCentralWidget(centralwidget);

        retranslateUi(MainWindow);

        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QCoreApplication::translate("MainWindow", "Change the accent color of your theme", nullptr));
        alpha_label->setText(QCoreApplication::translate("MainWindow", "TextLabel", nullptr));
        label->setText(QCoreApplication::translate("MainWindow", "Color intensity:", nullptr));
#if QT_CONFIG(tooltip)
        enableTransparency_CheckBox->setToolTip(QCoreApplication::translate("MainWindow", "Enables/disables the transparency of the entire theme. \n"
"NOTE: This setting does NOT affect compositing settings.", nullptr));
#endif // QT_CONFIG(tooltip)
        enableTransparency_CheckBox->setText(QCoreApplication::translate("MainWindow", "Enable transparency", nullptr));
        colorMixerLabel->setText(QCoreApplication::translate("MainWindow", "<a href=\"no\">Show color mixer</a>", nullptr));
        colorMixerGroupBox->setTitle(QString());
        label_3->setText(QCoreApplication::translate("MainWindow", "Saturation:", nullptr));
        label_2->setText(QCoreApplication::translate("MainWindow", "Hue:", nullptr));
        label_4->setText(QCoreApplication::translate("MainWindow", "Brightness:", nullptr));
        hue_label->setText(QCoreApplication::translate("MainWindow", "TextLabel", nullptr));
        saturation_label->setText(QCoreApplication::translate("MainWindow", "TextLabel", nullptr));
        brightness_label->setText(QCoreApplication::translate("MainWindow", "TextLabel", nullptr));
        color_name_label->setText(QCoreApplication::translate("MainWindow", "Current color: Custom", nullptr));
        groupBox->setTitle(QCoreApplication::translate("MainWindow", "Set the color of window decorations, panels, tooltips and taskbar", nullptr));
        apply_Button->setText(QCoreApplication::translate("MainWindow", "Apply", nullptr));
        saveChanges_Button->setText(QCoreApplication::translate("MainWindow", "Save Changes", nullptr));
        cancel_Button->setText(QCoreApplication::translate("MainWindow", "Cancel", nullptr));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
