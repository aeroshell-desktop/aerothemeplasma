#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <iostream>
#include <KWindowSystem/KWindowSystem>
#include <KWindowSystem/KWindowEffects>
#include <QRegion>
#include <QWindow>

/*
 * Border color: #b6b6b6e6
 * Lower bound color: #808080b3
 * Upper bound color: #888888b3
 */

float constrain(float n, float low, float high)
{
    return std::max(std::min(n, high), low);
}
float map(float value, float start1, float stop1, float start2, float stop2, bool withinBounds = false)
{
    float m = start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
    if(!withinBounds) return m;
    if(start2 < stop2)
        return constrain(value, start2, stop2);
    else
        return constrain(value, stop2, start2);
}
QColor mixColor(QColor col, double percentage)
{
    if(percentage > 1.0 || percentage < 0.0) return QColor(0,0,0);
    QColor base = QColor(216, 216, 216);
    double base_percentage = 1.0 - percentage;
    unsigned int r1 = (int)((double)base.red() * base_percentage);
    unsigned int g1 = (int)((double)base.green() * base_percentage);
    unsigned int b1 = (int)((double)base.blue() * base_percentage);

    unsigned int r2 = (int)((double)col.red() * percentage);
    unsigned int g2 = (int)((double)col.green() * percentage);
    unsigned int b2 = (int)((double)col.blue() * percentage);

    return QColor(r1+r2, g1+g2, b1+b2);
}

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    /* Loading config file, if it exists. Otherwise use default values */
    settings["transparency"] = 1;
    settings["red"] = 116;
    settings["green"] = 184;
    settings["blue"] = 252;
    settings["alpha"] = 107;
    settings["color"] = 1;
    loadConfig();
    paths << QDir::homePath() + "/.local/share/plasma/desktoptheme/Seven-Black/widgets/panel-background.svg";
    paths << QDir::homePath() + "/.local/share/plasma/desktoptheme/Seven-Black/widgets/tooltip.svg";
    paths << QDir::homePath() + "/.local/share/plasma/desktoptheme/Seven-Black/dialogs/background.svg";
    paths << QDir::homePath() + "/.local/share/plasma/desktoptheme/Seven-Black/solid/dialogs/background.svg";
    paths << QDir::homePath() + "/.emerald/theme/theme.ini";

    style = "QSlider::groove:horizontal {"
            "background-color: GRADIENT_HERE;"
            "height: 5px;"
            "position: absolute;"
        "}"

        "QSlider::handle:horizontal {"
        "    height: 3px;"
        "    width: 10px;"
        "    background: #fafafa;"
        "    border: 1px solid #46aaab;"
        "    margin: -6px 1px;"
        "}"

        "QSlider::handle:horizontal:hover { "
        "    background: #dadaff;"
        "}";
    ui->setupUi(this);
    this->setAttribute(Qt::WA_TranslucentBackground, true);
    this->setAttribute(Qt::WA_NoSystemBackground, true);
    KWindowEffects::enableBlurBehind(QWindow::fromWinId(this->winId()), true, QRegion(0,0, this->width(), this->height()));

    plasmaThemeExists = true;
    for(int i = 0; i < paths.length()-1; i++)
    {
        plasmaThemeExists = QFile::exists(paths[i]);
    }
    emeraldThemeExists = QFile::exists(paths[paths.length()-1]);
    if(!plasmaThemeExists && emeraldThemeExists)
    {
        QMessageBox::critical(this, "Plasma theme not found", "Could not find the Plasma theme on your system. This theme will only be applied to the Emerald theme.");
    }
    else if(plasmaThemeExists && !emeraldThemeExists)
    {
        QMessageBox::warning(this, "Emerald theme not found", "Could not find the Emerald theme on your system. This theme will only be applied to the Plasma theme.");
    }
    else if(!plasmaThemeExists && !emeraldThemeExists)
    {
        QMessageBox::critical(this, "Theme not found", "Could not find the Plasma and Emerald theme on your system. This program will now close.");
        this->close();
    }

    /* Setting up more UI stuff */
    ui->colorMixerGroupBox->setVisible(false);
    hue_gradient = "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #FF0000, stop: 0.167 #FFFF00, stop: 0.33 #00FF00, stop: 0.5 #00FFFF, stop: 0.667 #0000FF, stop: 0.833 #FF00FF, stop: 1 #FF0000)";
    ui->hue_Slider->setStyleSheet(QString(style).replace("GRADIENT_HERE", hue_gradient));
    saturation_gradient = "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #FFFFFF, stop: 1 " + QColor::fromHsl(ui->hue_Slider->value(), 255, 128).name(QColor::HexRgb) + ")";
    brightness_gradient = "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #000000, stop: 1 " + QColor::fromHsl(ui->hue_Slider->value(), 255, 128).name(QColor::HexRgb) +  ")";
    ui->saturation_Slider->setStyleSheet(QString(style).replace("GRADIENT_HERE", saturation_gradient));
    ui->Lightness_Slider->setStyleSheet(QString(style).replace("GRADIENT_HERE", brightness_gradient));
    ui->hue_label->setText(QString::number(ui->hue_Slider->value()));
    ui->alpha_label->setText(QString::number(ui->alpha_slider->value()));
    ui->saturation_label->setText(QString::number(ui->saturation_Slider->value()));
    ui->brightness_label->setText(QString::number(ui->Lightness_Slider->value()));
    QStringList values = { "6b74b8fc-Custom",
                           "6b74b8fc-Sky",
                           "a80046ad-Twilight",
                           "8032cdcd-Sea",
                           "6614a600-Leaf",
                           "6697d937-Lime",
                           "54fadc0e-Sun",
                           "80ff9c00-Pumpkin",
                           "a8ce0f0f-Ruby",
                           "66ff0099-Fuchsia",
                           "70fcc7f8-Blush ",
                           "856e3ba1-Violet",
                           "528d5a94-Lavander",
                           "6698844c-Taupe",
                           "a84f1b1b-Chocolate",
                           "80555555-Slate",
                           "54fcfcfc-Frost"};
    for(int i = 0; i < values.size(); i++)
    {
        QStringList temp = values[i].split("-");
        predefined_colors.push_back(ColorWindow(temp[1], QColor("#" + temp[0]), ui->groupBox, i));
    }
    selected_color = 1;
    colorLayout = new FlowLayout(ui->groupBox);
    colorLayout->setContentsMargins(10, 25, 25, 25);

    for(unsigned int i = 0; i < predefined_colors.size(); i++)
    {
        colorLayout->addWidget(predefined_colors[i].getFrame());
        connect(predefined_colors[i].getButton(), SIGNAL(clicked()), this, SLOT(on_colorWindow_Clicked()));
    }
    colorLayout->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);

    ui->enableTransparency_CheckBox->setChecked(settings["transparency"]);
    QColor tempColor(settings["red"], settings["green"], settings["blue"], settings["alpha"]);
    predefined_colors[0].setColor(tempColor);
    selected_color = -1;
    ui->hue_Slider->setValue(predefined_colors[0].getColor().hslHue());
    ui->saturation_Slider->setValue(predefined_colors[0].getColor().hsvSaturation());
    ui->Lightness_Slider->setValue(predefined_colors[0].getColor().value());
    selected_color = 0;
    selected_color = settings["color"];
    changeColor(selected_color);
    changeBackground();

}

MainWindow::~MainWindow()
{
    delete ui;
}

QColor MainWindow::exportColor()
{
    if(ui->enableTransparency_CheckBox->isChecked())
    {
        double alpha_dec = map(ui->alpha_slider->value(), 0, 255, 0.1f, 0.8f);
        QColor c = predefined_colors[selected_color].getColor();
        c.setAlphaF(alpha_dec);
        return c;
    }
    else
    {
        return mixColor(predefined_colors[selected_color].getColor(), ui->alpha_slider->value() / 255.0f);
    }
}

bool MainWindow::saveConfig()
{
    QString txt = "";
    txt = "transparency=" + QString::number(ui->enableTransparency_CheckBox->isChecked()) + "\n";
    txt += "red=" + QString::number(predefined_colors[0].getColor().red()) + "\n";
    txt += "green=" + QString::number(predefined_colors[0].getColor().green()) + "\n";
    txt += "blue=" + QString::number(predefined_colors[0].getColor().blue()) + "\n";
    txt += "alpha=" + QString::number(predefined_colors[0].getColor().alpha()) + "\n";
    txt += "color=" + QString::number(selected_color);
    QFile configFile(configPath);
    configFile.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&configFile);
    out << txt;
    configFile.close();
}
bool MainWindow::loadConfig()
{
    QFile f(configPath);
    f.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream reader(&f);
    QString line = "";
    while(!reader.atEnd())
    {
        line = reader.readLine();
        QStringList temp = line.split("=");
        if(settings.count(temp[0]) != 0)
        {
            settings[temp[0]] = temp[1].toInt();
        }
        else
        {
            std::cout << "Unknown property" << temp[0].toStdString() << std::endl;
        }
    }

}
void MainWindow::changeEvent(QEvent* e)
{
    if(e->type() == QEvent::ActivationChange)
    {
        changeBackground();
    }
}
void MainWindow::changeBackground()
{
    QColor theme_color = QWidget::palette().window().color();
    QColor current_color = exportColor();
    QColor inactive_col = current_color;
    if(ui->enableTransparency_CheckBox->isChecked())
    {
        inactive_col.setAlphaF(inactive_col.alphaF() / 2.0f);
    }
    else
    {
        inactive_col.setHslF(inactive_col.hslHueF(), inactive_col.hslSaturationF() / 2.0f, inactive_col.lightnessF());
    }
    if(!this->isActiveWindow()) current_color = inactive_col;
    QString temp = this->background_style;
    temp = temp.replace('$', "rgba("+ QString::number(current_color.red()) +","
                                                                                + QString::number(current_color.green()) +","
                                                                                + QString::number(current_color.blue()) +","
                                                                                + QString::number(current_color.alpha()) + ")")
                                                           .replace('!', "rgba("+ QString::number(theme_color.red()) +","
                                                                                + QString::number(theme_color.green()) +","
                                                                                + QString::number(theme_color.blue()) +","
                                                                                + "255)");


    ui->centralwidget->setStyleSheet(temp);

}
void MainWindow::changeColor(int index)
{
    ui->color_name_label->setText("Current color: " + predefined_colors[index].getName());
    selected_color = -1;
    ui->hue_Slider->setValue(predefined_colors[index].getColor().hslHue());
    ui->saturation_Slider->setValue(predefined_colors[index].getColor().hsvSaturation());
    ui->Lightness_Slider->setValue(predefined_colors[index].getColor().value());
    ui->alpha_slider->setValue(predefined_colors[index].getColor().alpha());
    selected_color = index;
    changeBackground();

}
void MainWindow::on_colorWindow_Clicked()
{
    int index = sender()->objectName().split("_")[1].toInt();
    changeColor(index);
}

void MainWindow::changeCustomColor()
{
    if(selected_color != -1)
    {
        selected_color = 0;
        ui->color_name_label->setText("Current color: Custom");
        QColor c;
        c.setHsv(ui->hue_Slider->value(), ui->saturation_Slider->value(), ui->Lightness_Slider->value(), ui->alpha_slider->value());
        predefined_colors[selected_color].setColor(c);
        changeBackground();
    }
}

void MainWindow::on_colorMixerLabel_linkActivated(const QString &link)
{
    ui->colorMixerGroupBox->setVisible(!ui->colorMixerGroupBox->isVisible());
    ui->colorMixerLabel->setText(ui->colorMixerGroupBox->isVisible() ? "<a href=\"no\">Hide color mixer</a>" : "<a href=\"no\">Show color mixer</a>" );
}

void MainWindow::on_hue_Slider_valueChanged(int value)
{
    ui->hue_label->setText(QString::number(ui->hue_Slider->value()));
    saturation_gradient = "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #FFFFFF, stop: 1 " + QColor::fromHsl(ui->hue_Slider->value(), 255, 128).name(QColor::HexRgb) + ")";
    brightness_gradient = "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #000000, stop: 1 " + QColor::fromHsl(ui->hue_Slider->value(), 255, 128).name(QColor::HexRgb) +  ")";
    ui->saturation_Slider->setStyleSheet(QString(style).replace("GRADIENT_HERE", saturation_gradient));
    ui->Lightness_Slider->setStyleSheet(QString(style).replace("GRADIENT_HERE", brightness_gradient));
    changeCustomColor();
}

void MainWindow::on_pushButton_3_clicked()
{
    this->close();
}

void MainWindow::on_saturation_Slider_valueChanged(int value)
{
    ui->saturation_label->setText(QString::number(ui->saturation_Slider->value()));
    changeCustomColor();
}

void MainWindow::on_Lightness_Slider_valueChanged(int value)
{
    ui->brightness_label->setText(QString::number(ui->Lightness_Slider->value()));
    changeCustomColor();
}

void MainWindow::on_alpha_slider_valueChanged(int value)
{
    ui->alpha_label->setText(QString::number(ui->alpha_slider->value()));
    changeCustomColor();
}

QColor mixColor(QColor first)
{
    return QColor::fromHsv(first.hsvHue(), first.hsvSaturation() * 0.1f, first.value());
}
void MainWindow::applyChanges()
{
    QColor main_color = exportColor();
    QString alpha = QString::number(main_color.alphaF(), 'f');
    QString fillOpacityMatch 			  = R"(fill-opacity:(\d*\.?\d+;))";
    QString fillMatch 					  = R"(fill:#(?:[0-9a-fA-F]{3}){1,2};)";
    //Emerald
    QString active_color 			      = R"(^active_title_(left|right|middle)=#(?:[0-9a-fA-F]{3}){1,2})";
    QString active_alpha		  		  = R"(^active_title_(left|right|middle)_alpha=(\d*\.?\d+))";
    QString inactive_color 			      = R"(^inactive_title_(left|right|middle)=#(?:[0-9a-fA-F]{3}){1,2})";
    QString inactive_alpha		  		  = R"(^inactive_title_(left|right|middle)_alpha=(\d*\.?\d+))";
    QRegularExpression regex(fillOpacityMatch, QRegularExpression::MultilineOption | QRegularExpression::DotMatchesEverythingOption);
    int pos = 0;
    QStringList matches;
    auto getMatches = [&](QString pattern, QString input)
    {
        matches.clear();
        pos = 0;
        regex.setPattern(pattern);
        QRegularExpressionMatchIterator it = regex.globalMatch(input);
        while(it.hasNext())
        {
            QRegularExpressionMatch match = it.next();
            if(match.hasMatch())
            {
                matches << match.captured(0);
            }
        }

    };
    auto writeToPanel = [&](QString path)
    {
        if(!plasmaThemeExists) return;
          QFile f(path);
          f.open(QIODevice::ReadWrite | QIODevice::Text);
          QTextStream reader(&f);
          reader.setAutoDetectUnicode(true);
          QString rawData = "";
          QString line = "";
          while(!line.contains("</style>"))
          {
                line = reader.readLine();
                rawData += line + "\n";
          }
          getMatches(fillOpacityMatch, rawData);
          if(!ui->enableTransparency_CheckBox->isChecked())
          {
              rawData.replace(matches[0], "fill-opacity:1;");
          }
          else if(ui->enableTransparency_CheckBox->isChecked())
          {
              rawData.replace(matches[0], "fill-opacity:" + alpha + ";");
          }
          matches.clear();
          pos = 0;
          regex.setPattern(fillMatch);
          QString colorName = main_color.name(QColor::HexRgb);
          getMatches(fillMatch, rawData);
          rawData.replace(matches[0], "fill:" + colorName  + ";");
          //Writing to file
          f.seek(0);
          f.write(rawData.toStdString().c_str(), rawData.length());
          f.close();
    };


    auto writeToDecoration = [&](QString path)
    {
        if(!emeraldThemeExists) return;
        QFile f(path);
        f.open(QIODevice::ReadWrite | QIODevice::Text);
        QTextStream reader(&f);
        reader.setAutoDetectUnicode(true);
        QString rawData = "";
        bool foundSettings = false;
        QString line = "";
        while(!reader.atEnd())
        {
            line = reader.readLine();
            rawData += line + "\n";
        }
        QColor inactive_col = main_color;
        if(ui->enableTransparency_CheckBox->isChecked())
        {
            inactive_col.setAlphaF(inactive_col.alphaF() / 2.0f);
        }
        else
        {
            inactive_col.setHslF(inactive_col.hslHueF(), inactive_col.hslSaturationF() / 2.0f, inactive_col.lightnessF());
        }
        //Setting active colour alpha
        getMatches(active_alpha, rawData);
        for(int i = 0; i < matches.length(); i++)
        {
            QStringList temp = matches[i].split("=");
            rawData.replace(matches[i], temp[0] + "=" + QString::number(main_color.alphaF(), 'f'));
        }
        //Setting inactive colour alpha
        getMatches(inactive_alpha, rawData);
        for(int i = 0; i < matches.length(); i++)
        {
            QStringList temp = matches[i].split("=");
            rawData.replace(matches[i], temp[0] + "=" + QString::number(inactive_col.alphaF(), 'f'));
        }
        //Setting active colour data
        getMatches(active_color, rawData);
        for(int i = 0; i < matches.length(); i++)
        {
            QStringList temp = matches[i].split("=");
            rawData.replace(matches[i], temp[0] + "=" + main_color.name(QColor::HexRgb));
        }
        //Setting active colour data
        getMatches(inactive_color, rawData);
        for(int i = 0; i < matches.length(); i++)
        {
            QStringList temp = matches[i].split("=");
            rawData.replace(matches[i], temp[0] + "=" + inactive_col.name(QColor::HexRgb));
        }
        f.seek(0);
        f.write(rawData.toStdString().c_str(), rawData.length());
        f.close();
    };
    for(int i = 0; i < paths.length()-1; i++)
    {
        writeToPanel(paths[i]);
    }
    writeToDecoration(paths[paths.length()-1]);
    QProcess process;
    process.execute("plasma-apply-desktoptheme", QStringList() << "oxygen");
    process.waitForFinished();
    QThread::sleep(1);
    process.execute("plasma-apply-desktoptheme", QStringList() << "Seven-Black");
    process.waitForFinished();
    process.close();
    system("kwin_x11 --replace &");


}

void MainWindow::on_apply_Button_clicked()
{
    applyChanges();
    saveConfig();
}

void MainWindow::on_cancel_Button_clicked()
{
    this->close();
}


void MainWindow::on_saveChanges_Button_clicked()
{
    applyChanges();
    saveConfig();
    this->close();
}


void MainWindow::on_enableTransparency_CheckBox_stateChanged(int arg1)
{
    changeBackground();
}

