#include "qgraphicsgloweffect.h"
#include <QtCore/qmath.h>
#include <QFontMetrics>
#include <QLabel>

QGraphicsGlowEffect::QGraphicsGlowEffect(QObject *parent) : QGraphicsEffect(parent)
{
}

void QGraphicsGlowEffect::setColor(QColor value) {
  _color = value;
}

void QGraphicsGlowEffect::setStrength(int value) {
  _strength = value;
}

void QGraphicsGlowEffect::setBlurRadius(qreal value) {
  _blurRadius = value;
  _extent =  qCeil(value);
  updateBoundingRect();
}

QColor QGraphicsGlowEffect::color() const {
  return _color;
}

int QGraphicsGlowEffect::strength() const {
  return _strength;
}

qreal QGraphicsGlowEffect::blurRadius() const {
  return _blurRadius;
}

QRectF QGraphicsGlowEffect::boundingRectFor(const QRectF &rect) const {
  return QRect(
      rect.left() - _extent,
      rect.top() - _extent,
      rect.width() + 2 * _extent,
      rect.height() + 2 * _extent);
}

void QGraphicsGlowEffect::draw(QPainter* painter) {
  QPoint offset;
  QPixmap source = sourcePixmap(Qt::LogicalCoordinates, &offset);
  QPixmap glow;

  QGraphicsColorizeEffect *colorize = new QGraphicsColorizeEffect;
  colorize->setColor(_color);
  colorize->setStrength(1);
  glow = applyEffectToPixmap(source, colorize, 0);

  QGraphicsBlurEffect *blur = new QGraphicsBlurEffect;
  blur->setBlurRadius(_blurRadius);
  glow = applyEffectToPixmap(glow, blur, _extent);

  for (int i = 0; i < _strength; i++)
    painter->drawPixmap(offset - QPoint(_extent, _extent), glow);
  drawSource(painter);
}
QPixmap QGraphicsGlowEffect::drawBlur(QPixmap pixmap)
{
  QPixmap glow;

  QGraphicsColorizeEffect *colorize = new QGraphicsColorizeEffect;
  colorize->setColor(_color);
  //colorize->setStrength(0);
  glow = applyEffectToPixmap(pixmap, colorize, 0);

  QGraphicsBlurEffect *blur = new QGraphicsBlurEffect;
  blur->setBlurRadius(_blurRadius);
  blur->setBlurHints(QGraphicsBlurEffect::QualityHint);
  glow = applyEffectToPixmap(glow, blur, _extent);

  return glow;
}
QPixmap QGraphicsGlowEffect::applyEffectToPixmap(
  QPixmap src, QGraphicsEffect *effect, int extent)
{
  if (src.isNull()) return QPixmap();
  if (!effect) return src;
  QGraphicsScene scene;
  QGraphicsPixmapItem item;
  item.setPixmap(src);
  item.setGraphicsEffect(effect);
  scene.addItem(&item);
  QSize size = src.size() + QSize(extent * 2, extent * 2);
  QPixmap res(size.width(), size.height());
  res.fill(Qt::transparent);
  QPainter ptr(&res);
  scene.render(&ptr, QRectF(), QRectF(-extent, -extent, size.width(), size.height()));
  return res;
} 
