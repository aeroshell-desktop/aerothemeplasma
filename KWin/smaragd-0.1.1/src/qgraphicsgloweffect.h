#ifndef QGRAPHICSGLOWEVENT_H
#define QGRAPHICSGLOWEVENT_H

#include <QGraphicsEffect>
#include <QGraphicsBlurEffect>
#include <QGraphicsColorizeEffect>
#include <QGraphicsPixmapItem>
#include <QGraphicsScene>
#include <QPainter>
#include <QLabel>

class QGraphicsGlowEffect :
  public QGraphicsEffect
{
public:
  explicit QGraphicsGlowEffect(QObject *parent = 0);

  QRectF boundingRectFor(const QRectF &rect) const;
  void setColor(QColor value);
  void setStrength(int value);
  void setBlurRadius(qreal value);
  QColor color() const;
  int strength() const;
  qreal blurRadius() const;

  QPixmap drawBlur(QPixmap pixmap);

protected:
  void draw(QPainter* painter);

private:
  static QPixmap applyEffectToPixmap(QPixmap src, QGraphicsEffect *effect, int extent);
  int _extent = 5;
  QColor _color = QColor(255, 255, 255);
  int _strength = 3;
  qreal _blurRadius = 5.0;
};


#endif // QGRAPHICSGLOWEVENT_H
 
