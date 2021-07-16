/*
 * configmanager.h - Emerald window decoration for KDE
 *
 * Copyright (c) 2010 Christoph Feck <christoph@maxiom.de>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#ifndef CONFIGMANAGER_H
#define CONFIGMANAGER_H 1

#include <KConfigGroup>
#include <QMetaProperty>

namespace Smaragd
{

class ConfigManager
{
public:
    ConfigManager()
    {
        /* */
    }

    ~ConfigManager()
    {
        /* */
    }

public:
    void addWidgets(QWidget *parent)
    {
        typedef QList<QWidget *> WidgetList;
        WidgetList widgets = parent->findChildren<QWidget *>(QRegExp(QLatin1String("^cm_")));
        for (WidgetList::const_iterator i = widgets.constBegin(); i != widgets.constEnd(); ++i) {
            QWidget *widget = *i;
            items.append(Item(widget));
        }
    }

    void connectConfigChanged(QObject *receiver, const char slot[]) const
    {
        for (ItemList::const_iterator item = items.constBegin(); item != items.constEnd(); ++item) {
            item->connectValueChanged(receiver, slot);
        }
    }

    void save(KConfigGroup &configGroup) const
    {
        for (ItemList::const_iterator item = items.constBegin(); item != items.constEnd(); ++item) {
            QVariant value = item->value();
            if (!value.isNull()) {
                if (value == item->configDefault) {
                    configGroup.deleteEntry(item->configLabel());
                } else {
                    configGroup.writeEntry(item->configLabel(), value);
                }
            }
        }
    }

    void load(const KConfigGroup &configGroup) const
    {
        for (ItemList::const_iterator item = items.constBegin(); item != items.constEnd(); ++item) {
            item->setValue(((Item) *item).configSaved = configGroup.readEntry(item->configLabel(), item->configDefault.isNull() ? QString() : item->configDefault));
        }
    }

    bool hasChanged() const
    {
        for (ItemList::const_iterator item = items.constBegin(); item != items.constEnd(); ++item) {
            if (item->configSaved != item->value()) {
                return true;
            }
        }
        return false;
    }

    void defaults() const
    {
        for (ItemList::const_iterator item = items.constBegin(); item != items.constEnd(); ++item) {
            item->setValue(item->configDefault);
        }
    }

private:
    class Item
    {
    public:
        Item(QWidget *widget)
            : configWidget(widget)
            , configDefault(value())
        {
            /* */
        }

    public:
        inline void setValue(const QVariant &value) const;
        inline QVariant value() const;
        inline void connectValueChanged(QObject *receiver, const char slot[]) const;
        inline QString configLabel() const;

    public:
        QWidget *configWidget;
        QVariant configDefault;
        QVariant configSaved;
    };

private:
    typedef QList<Item> ItemList;

private:
    ItemList items;
};


void ConfigManager::Item::setValue(const QVariant &value) const
{
    QMetaProperty property = configWidget->metaObject()->userProperty();
    property.write(configWidget, value);
}

QVariant ConfigManager::Item::value() const
{
    QMetaProperty property = configWidget->metaObject()->userProperty();
    return property.read(configWidget);
}

void ConfigManager::Item::connectValueChanged(QObject *receiver, const char slot[]) const
{
    QMetaProperty property = configWidget->metaObject()->userProperty();
    if (property.hasNotifySignal()) {
        QMetaMethod method = property.notifySignal();
        QByteArray signalSignature(method.methodSignature());
        signalSignature.prepend(QSIGNAL_CODE + '0');
        QObject::connect(configWidget, signalSignature.constData(), receiver, slot);
    }
}

QString ConfigManager::Item::configLabel() const
{
    QString cmName = configWidget->objectName().mid(3);
    return cmName;
}

}; // namespace Smaragd

#endif

