#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QColor>
#include <QDir>
#include <QSlider>
#include <QFile>
#include <QTextStream>
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
#include <KCModule>
#include <QMenu>
#include <QAction>
#include <QActionGroup>

#include "flowlayout.h"
#include "colorwindow.h"
#include "qgraphicsgloweffect.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QSpinBox* spinbox, QSpinBox* spinboxg, QCheckBox* checkbox, QSlider* hslider, QSlider* sslider, QSlider* vslider, QSlider* islider, QLineEdit* custom, KCModule* config, QWidget *parent = nullptr);

    ~MainWindow();
    void changeCustomColor(bool apply = true);
    void changeColor(int index, bool apply = true);
    QColor exportColor();
    void applyTemporarily();
    void resetToDefault();
protected:
    void applyFilter();
    void closeEvent(QCloseEvent *event) override;
    void showEvent(QShowEvent *event) override;
    bool eventFilter(QObject *o, QEvent *e) override;
private slots:
    void on_colorGroupSpinBox_valueChanged(int value);
    void on_colorGroupLabel_clicked();
    void on_colorGroup_triggered(QAction *action);
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
    void on_windowActiveChanged();
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
    QSlider* kcfg_AeroIntensity;
    QSlider* kcfg_AeroHue;
    QSlider* kcfg_AeroSaturation;
    QSlider* kcfg_AeroBrightness;
    QSpinBox* kcfg_AccentColorName;
    QSpinBox* kcfg_AccentColorGroup;
    QCheckBox* kcfg_EnableTransparency;
    QLineEdit* kcfg_CustomColor;
    KCModule* config_parent;

    QMenu groupContextMenu;

    // Predefined color values directly pulled from Windows 7, with the exception
    // of Sunset, which is an original color value.
    QStringList values = {

        // Win7
        "6b74b8fc-Custom-6",   "6b74b8fc-Sky-0",     "a80046ad-Twilight-0",
        "8032cdcd-Sea-0",      "6614a600-Leaf-0",    "6697d937-Lime-0",
        "54fadc0e-Sun-0",      "80ff9c00-Pumpkin-0", "a8ce0f0f-Ruby-0",
        "66ff0099-Fuchsia-0",  "70fcc7f8-Blush-0 ",  "856e3ba1-Violet-0",
        "528d5a94-Lavander-0", "6698844c-Taupe-0",   "a84f1b1b-Chocolate-0",
        "80555555-Slate-0",    "54fcfcfc-Frost-0",
        // Win Vista
        "45409efe-Default-1",
        "a3000000-Graphite-1",
        "a8004ade-Blue-1",
        "82008ca5-Teal-1",
        "9cce0c0f-Red-1",
        "a6ff7700-Orange-1",
        "49f93ee7-Pink-1",
        "cceff7f7-Frost-1",

        // Win 8
        "c48f8f8f-Color 1-2",
        "c484c6ff-Color 2-2",
        "c4f276c9-Color 3-2",
        "c4f0c300-Color 4-2",
        "c492cb2a-Color 5-2",
        "c44ccdcd-Color 6-2",
        "c4ff981d-Color 7-2",
        "c4ff4040-Color 8-2",
        "c4ff57ab-Color 9-2",
        "c40abf46-Color 10-2",
        "c4c071ff-Color 11-2",
        "c454afff-Color 12-2",
        "c48c90ff-Color 13-2",
        "c4b09d8b-Color 14-2",
        "c4ffffff-Color 15-2",

        // Win 10
        "c4203dbd-Color 1 (10)-3",
        "c40046ff-Color 2 (10)-3",
        "c40078d7-Color 3 (10)-3",
        "c40099bc-Color 4 (10)-3",
        "c400b294-Color 5 (10)-3",
        "c400ae56-Color 6 (10)-3",
        "c47dbd06-Color 7 (10)-3",
        "c4fce100-Color 8 (10)-3",
        "c4f7630c-Color 9 (10)-3",
        "c4d73539-Color 10 (10)-3",
        "c4e81123-Color 11 (10)-3",
        "c4ea005e-Color 12 (10)-3",
        "c4a9006a-Color 13 (10)-3",
        "c4534588-Color 14 (10)-3",
        "c4606e62-Color 15 (10)-3",

        // Win Vista (5270)
        "00000000-Aero-4",
        "89ffffff-Frost-4",
        "c11e0000-Smoke-4",
        "566c9b89-Seaform-4",
        "4ca03800-Heritage-4",
        "420037ff-Sky-4",
        "b5d31b1b-Heart-4",
        "75ef47ef-Candy-4",

        // Win 7 (6608)
        "45409efe-Default-5",
        "a3000000-Graphite-5",
        "a8004ade-Blue-5",
        "82008ca5-Teal-5",
        "9cce0c0f-Red-5",
        "a6ff7700-Orange-5",
        "49f93ee7-Pink-5",
        "cceff7f7-Frost-5",
        "bf7e17e6-Purple-5",
        "bf1bab6d-Green-5",
        "a800d5ff-Cyan-5",
        "8c78f20c-Lime-5",
        "bfff0040-Coral-5",
        "bfffee33-Yellow-5",
        "66692d4a-Mauve-5",
        "7298844c-Pewter-5",

        "78b3198d-Sunset-6"

    };
    QStringList colorGroups = {
      "Windows 7",
      "Windows Vista",
      "Windows 8",
      "Windows 10",
      "Windows Vista Beta 2",
      "Windows 7 Build 6608",
      "AeroThemePlasma"
    };
    QActionGroup *groupedActions;

    QWindow* window_handle;
    QColor background_color;
    QColor footer_color;

};
#endif // MAINWINDOW_H
