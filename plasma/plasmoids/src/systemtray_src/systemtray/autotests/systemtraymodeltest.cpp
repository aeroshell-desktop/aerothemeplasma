/*
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

#include <QAbstractItemModelTester>
#include <QPointer>
#include <QTest>

#include <Plasma/Applet>
#include <Plasma/PluginLoader>

#include <KConfigLoader>

#include "../plasmoidregistry.h"
#include "../systemtraymodel.h"
#include "../systemtraysettings.h"

using namespace Qt::StringLiterals;

static const QString DEVICENOTIFIER_ID = QStringLiteral("org.kde.plasma.devicenotifier.test");
static const QString MEDIACONROLLER_ID = QStringLiteral("org.kde.plasma.mediacontroller.test");

class SystemTrayModelTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    void init();
    void testPlasmoidModel();
};

void SystemTrayModelTest::init()
{
    QLocale::setDefault(QLocale(u"en_US"_s));
    qunsetenv("LANGUAGE");
    qunsetenv("LC_ALL");
    qunsetenv("LC_MESSAGES");
    qunsetenv("LANG");
}

class MockedPlasmoidRegistry : public PlasmoidRegistry
{
public:
    MockedPlasmoidRegistry(QPointer<SystemTraySettings> settings)
        : PlasmoidRegistry(settings)
    {
    }
    QMap<QString, KPluginMetaData> systemTrayApplets() override
    {
        return m_systemTrayApplets;
    }

    QMap<QString, KPluginMetaData> m_systemTrayApplets;
};

void SystemTrayModelTest::testPlasmoidModel()
{
    // given: mocked PlasmoidRegistry with sample plugin meta data
    const QString configFileName = QFINDTESTDATA("data/systraysettingsrc");
    const QString schemaFileName = QFINDTESTDATA("../package/contents/config/main.xml");
    QFile schemaFile(schemaFileName);
    KConfigLoader loader(configFileName, &schemaFile);
    SystemTraySettings *settings = new SystemTraySettings(&loader);
    MockedPlasmoidRegistry *plasmoidRegistry = new MockedPlasmoidRegistry(settings);
    plasmoidRegistry->m_systemTrayApplets.insert(DEVICENOTIFIER_ID, KPluginMetaData::fromJsonFile(QFINDTESTDATA("data/devicenotifier/metadata.json")));
    plasmoidRegistry->m_systemTrayApplets.insert(MEDIACONROLLER_ID, KPluginMetaData::fromJsonFile(QFINDTESTDATA("data/mediacontroller/metadata.json")));

    // when: model is initialized
    PlasmoidModel *model = new PlasmoidModel(settings, plasmoidRegistry);

    // expect: passes consistency tests
    new QAbstractItemModelTester(model, QAbstractItemModelTester::FailureReportingMode::Fatal);

    // and expect: correct model size
    QCOMPARE(model->rowCount(), 2);
    QCOMPARE(model->roleNames().size(), 10);
    // and expect: correct data returned
    QModelIndex idx = model->index(0, 0);
    QCOMPARE(model->data(idx, Qt::DisplayRole).toString(), u"Device Notifier");
    QVERIFY(model->data(idx, Qt::DecorationRole).isValid());
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::ItemType)).toString(), u"Plasmoid");
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::ItemId)).toString(), DEVICENOTIFIER_ID);
    QVERIFY(!model->data(idx, static_cast<int>(BaseModel::BaseRole::CanRender)).toBool());
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::Category)).toString(), u"Hardware");
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::Status)), QVariant(Plasma::Types::ItemStatus::UnknownStatus));
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::EffectiveStatus)), QVariant(Plasma::Types::ItemStatus::HiddenStatus));
    QVERIFY(!model->data(idx, static_cast<int>(PlasmoidModel::Role::HasApplet)).toBool());
    idx = model->index(1, 0);
    QCOMPARE(model->data(idx, Qt::DisplayRole).toString(), u"Media Player");
    QVERIFY(model->data(idx, Qt::DecorationRole).isValid());
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::ItemType)).toString(), u"Plasmoid");
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::ItemId)).toString(), MEDIACONROLLER_ID);
    QVERIFY(!model->data(idx, static_cast<int>(BaseModel::BaseRole::CanRender)).toBool());
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::Category)).toString(), u"ApplicationStatus");
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::Status)), QVariant(Plasma::Types::ItemStatus::UnknownStatus));
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::EffectiveStatus)), QVariant(Plasma::Types::ItemStatus::HiddenStatus));
    QVERIFY(!model->data(idx, static_cast<int>(PlasmoidModel::Role::HasApplet)).toBool());

    // when: language is changed
    QLocale::setDefault(QLocale(u"pl_PL"_s));
    qputenv("LANG", "pl_PL.UTF-8");
    qputenv("LC_MESSAGES", "pl_PL.UTF-8");
    // then expect: translated data returned
    QCOMPARE(model->data(model->index(0, 0), Qt::DisplayRole).toString(), u"Powiadomienia o urz\u0105dzeniach");

    // when: applet added
    model->addApplet(new Plasma::Applet(nullptr, plasmoidRegistry->m_systemTrayApplets.value(MEDIACONROLLER_ID), QVariantList{}));
    // then: applet can be rendered
    QVERIFY(model->data(idx, static_cast<int>(BaseModel::BaseRole::CanRender)).toBool());
    QVERIFY(model->data(idx, static_cast<int>(PlasmoidModel::Role::HasApplet)).toBool());
    QCOMPARE(model->data(idx, static_cast<int>(BaseModel::BaseRole::EffectiveStatus)), QVariant(Plasma::Types::ItemStatus::ActiveStatus));

    // and when: applet removed
    model->removeApplet(new Plasma::Applet(nullptr, plasmoidRegistry->m_systemTrayApplets.value(MEDIACONROLLER_ID), QVariantList{}));
    // then: applet cannot be rendered anymore
    QVERIFY(!model->data(idx, static_cast<int>(BaseModel::BaseRole::CanRender)).toBool());
    QVERIFY(!model->data(idx, static_cast<int>(PlasmoidModel::Role::HasApplet)).toBool());

    // and when: invalid index
    idx = model->index(4, 0);
    // then: empty value
    QVERIFY(model->data(idx, static_cast<int>(BaseModel::BaseRole::ItemType)).isNull());
    QVERIFY(!model->data(idx, static_cast<int>(BaseModel::BaseRole::ItemType)).isValid());
    idx = model->index(1, 1);
    QVERIFY(model->data(idx, static_cast<int>(BaseModel::BaseRole::ItemType)).isNull());
    QVERIFY(!model->data(idx, static_cast<int>(BaseModel::BaseRole::ItemType)).isValid());

    delete model;
}

QTEST_MAIN(SystemTrayModelTest)

#include "systemtraymodeltest.moc"
