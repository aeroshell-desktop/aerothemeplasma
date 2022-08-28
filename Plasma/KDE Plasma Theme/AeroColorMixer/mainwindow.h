#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QColor>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QRegExp>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QRegularExpressionMatchIterator>
#include <QProcess>
#include <QThread>
#include <QMessageBox>
#include <vector>
#include <QStandardPaths>

#include "flowlayout.h"
#include "colorwindow.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
    void changeCustomColor();
    void changeColor(int index);
    void applyChanges();
    bool loadConfig();
    bool saveConfig();
    void changeBackground();
    QColor exportColor();

protected:
    void changeEvent(QEvent* e);

private slots:
    void on_colorMixerLabel_linkActivated(const QString &link);

    void on_hue_Slider_valueChanged(int value);

    void on_pushButton_3_clicked();

    void on_saturation_Slider_valueChanged(int value);

    void on_Lightness_Slider_valueChanged(int value);

    //void on_horizontalSlider_valueChanged(int value);

    void on_colorWindow_Clicked();

    void on_apply_Button_clicked();

    void on_cancel_Button_clicked();

    void on_alpha_slider_valueChanged(int value);

    void on_saveChanges_Button_clicked();

    void on_enableTransparency_CheckBox_stateChanged(int arg1);

private:
    Ui::MainWindow *ui;
    bool plasmaThemeExists;
    bool emeraldThemeExists;
    FlowLayout* colorLayout;
    std::vector<ColorWindow> predefined_colors;
    std::map<QString, int> settings;
    QStringList paths;
    const QString configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/.aerorc";
    short selected_color;
    QColor color;
    QString hue_gradient;
    QString saturation_gradient;
    QString brightness_gradient;
    QString style;
    QString background_style = "QWidget#centralwidget { background-color: qlineargradient(spread:pad, x1:0, y1:1, x2:0.0, y2:0, stop:0 $, stop:0.12 $, stop:0.121 !); }";
};
#endif // MAINWINDOW_H
