#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <KWindowEffects>
#include <KWindowSystem>
#include <QRegion>
#include <QScreen>
#include <QWindow>
#include <iostream>

#include "blur_config.h"

// Clamps the value n into the interval [low, high].
float constrain(float n, float low, float high) {
  return std::max(std::min(n, high), low);
}

// Linearly maps a value from the expected interval [start1, stop1] to [start2,
// stop2]. Implementation taken from p5.js
float map(float value, float start1, float stop1, float start2, float stop2,
          bool withinBounds = false) {
  float m = start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
  if (!withinBounds)
    return m;
  if (start2 < stop2)
    return constrain(value, start2, stop2);
  else
    return constrain(value, stop2, start2);
}

// Mixes the base color (light gray) with col at a certain percentage.
QColor mixColor(QColor col, double percentage) {
  QColor base = QColor(225, 225, 225);
  if (percentage > 1.0 || percentage < 0.0)
    return base;
  double base_percentage = 1.0 - percentage;
  unsigned int r1 = (int)((double)base.red() * base_percentage);
  unsigned int g1 = (int)((double)base.green() * base_percentage);
  unsigned int b1 = (int)((double)base.blue() * base_percentage);

  unsigned int r2 = (int)((double)col.red() * percentage);
  unsigned int g2 = (int)((double)col.green() * percentage);
  unsigned int b2 = (int)((double)col.blue() * percentage);

  return QColor(r1 + r2, g1 + g2, b1 + b2);
}

MainWindow::MainWindow(QSpinBox *spinbox, QCheckBox *checkbox,
                       QSlider* hslider, QSlider* sslider, QSlider* vslider, QSlider* islider,
                       QLineEdit* custom, KCModule* config, QWidget *parent)
    : QMainWindow(parent), ui(new Ui::MainWindow) {

  // Predefined style for the QSlider groove and handle.
  style = "QSlider::groove:horizontal {"
          "background-color: GRADIENT_HERE;"
          "height: 5px;"
          "position: absolute;"
          "}"

          "QSlider::handle:horizontal {"
          "    height: 3px;"
          "    width: 8px;"
          "    background: #f0f0f0;"
          "    border: 1px solid #707070;"
          "    border-radius: 2px;"
          "    margin: -6px 1px;"
          "}"

          "QSlider::handle:horizontal:hover { "
          "    background: #def2fc;"
          "}";

  background_style =
      "QWidget#centralwidget { background-color: qlineargradient(spread:pad, "
      "x1:0, y1:1, x2:0.0, y2:0, stop:0 rgba(0,0,0,0) stop:0.105 rgba(0,0,0,0) "
      "stop:0.106 ! }";

  ui->setupUi(this);
  preventChanges = false;
  cancelChanges = true;

  kcfg_AccentColorName = spinbox;
  kcfg_EnableTransparency = checkbox;
  kcfg_AeroIntensity = islider;
  kcfg_AeroHue = hslider;
  kcfg_AeroSaturation = sslider;
  kcfg_AeroBrightness = vslider;
  kcfg_CustomColor = custom;
  config_parent = config;

  ui->kcfg_EnableTransparency->setChecked(checkbox->isChecked());
  // Setting attributes which will allow the window to have a transparent
  // blurred background.
  //this->setAttribute(Qt::WA_TranslucentBackground, true);
  //this->setAttribute(Qt::WA_NoSystemBackground, true);

  /*this->winId();
  KWindowEffects::enableBlurBehind(
      this->windowHandle(), true, QRegion(0, 0, this->width(), this->height()));*/
  fflush(stdout);

  QColor theme_color = QWidget::palette().window().color();
  background_style = background_style.replace(
      '!', "rgba(" + QString::number(theme_color.red()) + "," +
               QString::number(theme_color.green()) + "," +
               QString::number(theme_color.blue()) + "," + "255))");

  ui->centralwidget->setStyleSheet(background_style);

  // Setting up more UI stuff.

  ui->colorMixerGroupBox->setVisible(false);
  // Template string defining the CSS style for the hue slider.
  hue_gradient = "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #FF0000, "
                 "stop: 0.167 #FFFF00, stop: 0.33 #00FF00, stop: 0.5 #00FFFF, "
                 "stop: 0.667 #0000FF, stop: 0.833 #FF00FF, stop: 1 #FF0000)";
  ui->hue_Slider->setStyleSheet(
      QString(style).replace("GRADIENT_HERE", hue_gradient));
  // Likewise for the saturation and brightness sliders.
  saturation_gradient =
      "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #FFFFFF, stop: 1 " +
      QColor::fromHsl(ui->hue_Slider->value(), 255, 128).name(QColor::HexRgb) +
      ")";
  brightness_gradient =
      "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #000000, stop: 1 " +
      QColor::fromHsl(ui->hue_Slider->value(), 255, 128).name(QColor::HexRgb) +
      ")";
  ui->saturation_Slider->setStyleSheet(
      QString(style).replace("GRADIENT_HERE", saturation_gradient));
  ui->Lightness_Slider->setStyleSheet(
      QString(style).replace("GRADIENT_HERE", brightness_gradient));

  ui->hue_label->setText(QString::number(ui->hue_Slider->value()));
  ui->alpha_label->setText(QString::number(ui->alpha_slider->value()));
  ui->saturation_label->setText(
      QString::number(ui->saturation_Slider->value()));
  ui->brightness_label->setText(QString::number(ui->Lightness_Slider->value()));

  // Predefined color values directly pulled from Windows 7, with the exception
  // of Sunset, which is an original color value.
  QStringList values = {
      "6b74b8fc-Custom",   "6b74b8fc-Sky",     "a80046ad-Twilight",
      "8032cdcd-Sea",      "6614a600-Leaf",    "6697d937-Lime",
      "54fadc0e-Sun",      "80ff9c00-Pumpkin", "a8ce0f0f-Ruby",
      "66ff0099-Fuchsia",  "70fcc7f8-Blush ",  "856e3ba1-Violet",
      "528d5a94-Lavander", "6698844c-Taupe",   "a84f1b1b-Chocolate",
      "80555555-Slate",    "54fcfcfc-Frost",   "78b3198d-Sunset",
      "45409efe-Default",
      "a3000000-Graphite",
      "a8004ade-Blue",
      "82008ca5-Teal",
      "9cce0c0f-Red",
      "a6ff7700-Orange",
      "49f93ee7-Pink",
      "cceff7f7-Frost",
  };
  for (int i = 0; i < values.size(); i++) {
    QStringList temp = values[i].split("-");
    predefined_colors.push_back(
        ColorWindow(temp[1], QColor("#" + temp[0]), ui->groupBox, i));
  }

  // By default, the selected color is Sky.
  selected_color = kcfg_AccentColorName->value();

  // Creating a FlowLayout and storing all the colors there.
  colorLayout = new FlowLayout(ui->groupBox);
  colorLayout->setContentsMargins(25, 25, 25, 25);

  for (unsigned int i = 0; i < predefined_colors.size(); i++) {
    colorLayout->addWidget(predefined_colors[i].getFrame());
    connect(predefined_colors[i].getFrameButton(), SIGNAL(clicked()), this,
            SLOT(on_colorWindow_Clicked()));
  }
  colorLayout->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);

  predefined_colors[0].setColor(QColor::fromString(kcfg_CustomColor->text()));
  predefined_colors[selected_color].getFrameButton()->setSelected(true);
  changeColor(selected_color);
}

MainWindow::~MainWindow() {
  for (unsigned int i = 0; i < predefined_colors.size(); i++) {
    predefined_colors[i].clear();
  }
  delete ui;
}

/*
 * Returns the currently set color. Depending on the transparency settings, the
 * alpha value will either be directly used as the transparency value, or it
 * will be used to define the saturation of the color.
 */
QColor MainWindow::exportColor() {
  if (ui->kcfg_EnableTransparency->isChecked()) {
    // The color intensity doesn't actually make the alpha component fully
    // transparent or opaque.
    double alpha_dec = map(ui->alpha_slider->value(), 0, 255, 0.1f, 0.8f);
    QColor c = predefined_colors[selected_color].getColor();
    c.setAlphaF(alpha_dec);
    return c;
  } else {
    return mixColor(predefined_colors[selected_color].getColor(),
                    ui->alpha_slider->value() / 255.0f);
  }
}

// Resets this window to default values.
// Used when closing the window without applying changes.
void MainWindow::resetToDefault() {
  int intensity  = kcfg_AeroIntensity->value();
  int hue        = kcfg_AeroHue->value();
  int saturation = kcfg_AeroSaturation->value();
  int brightness = kcfg_AeroBrightness->value();
  // resetting the custom color
  predefined_colors[0].setColor(QColor::fromString(kcfg_CustomColor->text()));
  predefined_colors[selected_color].getFrameButton()->setSelected(false);
  changeColor(kcfg_AccentColorName->value(), false);
  predefined_colors[kcfg_AccentColorName->value()].getFrameButton()->setSelected(true);
  preventChanges = true;
  ui->kcfg_EnableTransparency->setChecked(kcfg_EnableTransparency->isChecked());
  preventChanges = false;
}

void MainWindow::applyTemporarily() {
  KWin::BlurEffectConfig *conf = (KWin::BlurEffectConfig *)config_parent;

  int intensity  = ui->alpha_slider->value();
  int hue        = ui->hue_Slider->value();
  int saturation = ui->saturation_Slider->value();
  int brightness = ui->Lightness_Slider->value();
  conf->writeToMemory(hue, saturation, brightness, intensity, ui->kcfg_EnableTransparency->isChecked(), true);
}

// Changes the color between the custom and any of the predefined values.
void MainWindow::changeColor(int index, bool apply) {
  ui->color_name_label->setText("Current color: " +
                                predefined_colors[index].getName());
  selected_color = index;
  preventChanges = true;
  ui->hue_Slider->setValue(predefined_colors[index].getColor().hslHue());
  ui->saturation_Slider->setValue(
      predefined_colors[index].getColor().hsvSaturationF()*100.0f);
  ui->Lightness_Slider->setValue(predefined_colors[index].getColor().valueF()*100.0f);
  ui->alpha_slider->setValue(predefined_colors[index].getColor().alpha());
  preventChanges = false;
  if (apply)
    applyTemporarily();
}

// This event fires when a color from the FlowLayout is clicked.
void MainWindow::on_colorWindow_Clicked() {
  predefined_colors[selected_color].getFrameButton()->setSelected(false);
  int index = sender()->objectName().split("_")[1].toInt();

  predefined_colors[index].getFrameButton()->setSelected(true);
  changeColor(index);
}

// Changes the custom color, this method executes whenever the sliders are
// moved.
void MainWindow::changeCustomColor(bool apply) {
  if (!preventChanges) {
    predefined_colors[selected_color].getFrameButton()->setSelected(false);
    selected_color = 0;
    predefined_colors[0].getFrameButton()->setSelected(true);
    ui->color_name_label->setText("Current color: Custom");
    QColor c;
    c.setHsv(ui->hue_Slider->value(), ui->saturation_Slider->value()*2.55f,
             ui->Lightness_Slider->value()*2.55f, ui->alpha_slider->value());
    predefined_colors[selected_color].setColor(c);
    if (apply)
      applyTemporarily();
  }
}

// Toggles the visibility of the group box containing the color sliders.
void MainWindow::on_colorMixerLabel_linkActivated(const QString &link) {
  ui->colorMixerGroupBox->setVisible(!ui->colorMixerGroupBox->isVisible());
  ui->colorMixerLabel->setText(ui->colorMixerGroupBox->isVisible()
                                   ? "<a href=\"no\">Hide color mixer</a>"
                                   : "<a href=\"no\">Show color mixer</a>");
}

// Updates the color sliders and updates the custom color.
void MainWindow::on_hue_Slider_valueChanged(int value) {
  ui->hue_label->setText(QString::number(ui->hue_Slider->value()));
  saturation_gradient =
      "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #FFFFFF, stop: 1 " +
      QColor::fromHsl(ui->hue_Slider->value(), 255, 128).name(QColor::HexRgb) +
      ")";
  brightness_gradient =
      "qlineargradient(x1: 0, y1: 1, x2: 1, y2: 1, stop: 0 #000000, stop: 1 " +
      QColor::fromHsl(ui->hue_Slider->value(), 255, 128).name(QColor::HexRgb) +
      ")";
  ui->saturation_Slider->setStyleSheet(
      QString(style).replace("GRADIENT_HERE", saturation_gradient));
  ui->Lightness_Slider->setStyleSheet(
      QString(style).replace("GRADIENT_HERE", brightness_gradient));
  changeCustomColor();
}

void MainWindow::on_pushButton_3_clicked() { this->close(); }

void MainWindow::on_saturation_Slider_valueChanged(int value) {
  ui->saturation_label->setText(
      QString::number(ui->saturation_Slider->value()));
  changeCustomColor();
}

void MainWindow::on_Lightness_Slider_valueChanged(int value) {
  ui->brightness_label->setText(QString::number(ui->Lightness_Slider->value()));
  changeCustomColor();
}

void MainWindow::on_alpha_slider_valueChanged(int value) {
  ui->alpha_label->setText(QString::number(ui->alpha_slider->value()));
  changeCustomColor();
}

void MainWindow::applyChanges() {
  cancelChanges = false;
  kcfg_CustomColor->setText(predefined_colors[0].getColor().name(QColor::HexArgb));
  kcfg_AccentColorName->setValue(selected_color);
  kcfg_EnableTransparency->setChecked(ui->kcfg_EnableTransparency->isChecked());
  kcfg_AeroIntensity->setValue(ui->alpha_slider->value());
  kcfg_AeroHue->setValue(ui->hue_Slider->value());
  kcfg_AeroSaturation->setValue(ui->saturation_Slider->value());
  kcfg_AeroBrightness->setValue(ui->Lightness_Slider->value());

  KWin::BlurEffectConfig *conf = (KWin::BlurEffectConfig *)config_parent;
  conf->save();
}

// This function runs whenever the window is being closed.
// I wrote this at 3 AM it's probably overengineered but it works
// I'll simplify this down the line later
void MainWindow::closeEvent(QCloseEvent *event) {
  int intensity  = kcfg_AeroIntensity->value();
  int hue        = kcfg_AeroHue->value();
  int saturation = kcfg_AeroSaturation->value();
  int brightness = kcfg_AeroBrightness->value();
  KWin::BlurEffectConfig *conf = (KWin::BlurEffectConfig *)config_parent;
  conf->writeToMemory(hue, saturation, brightness, intensity,
                      kcfg_EnableTransparency->isChecked(), cancelChanges);
  resetToDefault();
  QMainWindow::closeEvent(event);
}
void MainWindow::on_apply_Button_clicked() { applyChanges(); }

void MainWindow::on_cancel_Button_clicked() { this->close(); }

void MainWindow::on_saveChanges_Button_clicked() {
  applyChanges();
  this->close();
}

void MainWindow::on_kcfg_EnableTransparency_stateChanged(int arg1) {
  if (!preventChanges)
    applyTemporarily();
}
