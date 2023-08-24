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
#include <QPlainTextEdit>
#include <QSpinBox>

#include "flowlayout.h"
#include "colorwindow.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QSpinBox* spinbox, QCheckBox* checkbox, QPlainTextEdit* textedit, QPlainTextEdit* customtextedit, QWidget *parent = nullptr);

    ~MainWindow();
    void changeCustomColor(bool apply = true);
    void changeColor(int index, bool apply = true);
    QColor exportColor();
    void applyTemporarily();
    void resetToDefault();
protected:
    void closeEvent(QCloseEvent *event) override;
private slots:
    void on_colorMixerLabel_linkActivated(const QString &link);
    void on_hue_Slider_valueChanged(int value);
    void on_pushButton_3_clicked();
    void on_saturation_Slider_valueChanged(int value);
    void on_Lightness_Slider_valueChanged(int value);
    void on_colorWindow_Clicked();
    void on_apply_Button_clicked();
    void on_cancel_Button_clicked();
    void on_alpha_slider_valueChanged(int value);
    void on_saveChanges_Button_clicked();
    void on_kcfg_EnableTransparency_stateChanged(int arg1);
    void applyChanges();
private:
    Ui::MainWindow *ui;
    bool preventChanges;
    bool cancelChanges;
    FlowLayout* colorLayout;
    std::vector<ColorWindow> predefined_colors;
    short selected_color; // Index of the currently selected color.
    QString hue_gradient;
    QString saturation_gradient;
    QString brightness_gradient;
    QString style; // Custom style for QSliders.
    QString background_style; // CSS for the main window background.

    // Pointers to the parent widgets.
    QPlainTextEdit* kcfg_AccentColor;
    QPlainTextEdit* kcfg_CustomColor;
    QSpinBox* kcfg_AccentColorName;
    QCheckBox* kcfg_EnableTransparency;
};
#endif // MAINWINDOW_H
