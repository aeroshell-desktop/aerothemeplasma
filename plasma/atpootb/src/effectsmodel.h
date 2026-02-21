/*
 *
 *   SPDX-FileCopyrightText: 2013 Antonis Tsiapaliokas <kok3rs@gmail.com>
 *   SPDX-FileCopyrightText: 2018 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef EFFECTSMODEL_H
#define EFFECTSMODEL_H

//#include <kwin_export.h>

#include <KSharedConfig>

#include <QAbstractItemModel>
#include <QQuickItem>
#include <QString>
#include <QUrl>

class EffectsModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    /**
     * This enum type is used to specify data roles.
     */
    enum AdditionalRoles {
        /**
         * The user-friendly name of the effect.
         */
        NameRole = Qt::UserRole + 1,
        /**
         * The description of the effect.
         */
        DescriptionRole,
        /**
         * The name of the effect's author. If there are several authors, they
         * will be comma separated.
         */
        AuthorNameRole,
        /**
         * The email of the effect's author. If there are several authors, the
         * emails will be comma separated.
         */
        AuthorEmailRole,
        /**
         * The license of the effect.
         */
        LicenseRole,
        /**
         * The version of the effect.
         */
        VersionRole,
        /**
         * The category of the effect.
         */
        CategoryRole,
        /**
         * The service name(plugin name) of the effect.
         */
        ServiceNameRole,
        /**
         * The icon name of the effect.
         */
        IconNameRole,
        /**
         * Whether the effect is enabled or disabled.
         */
        StatusRole,
        /**
         * Link to the home page of the effect.
         */
        WebsiteRole,
        /**
         * Whether the effect is supported.
         */
        SupportedRole,
        /**
         * The exclusive group of the effect.
         */
        ExclusiveRole,
        /**
         * Whether the effect is internal.
         */
        InternalRole,
        /**
         * Whether the effect has a KCM.
         */
        ConfigurableRole,
        /**
         * Whether the effect is enabled by default.
         */
        EnabledByDefaultRole,
        /**
         * Id of the effect's config module, empty if the effect has no config.
         */
        ConfigModuleRole,
        /**
         * Whether the effect has a function to determine if the effect is enabled by default.
         */
        EnabledByDefaultFunctionRole,
    };
    Q_ENUM(AdditionalRoles);

    /**
     * This enum type is used to specify the status of a given effect.
     */
    enum class Status {
        /**
         * The effect is disabled.
         */
        Disabled = Qt::Unchecked,
        /**
         * An enable function is used to determine whether the effect is enabled.
         * For example, such function can be useful to disable the blur effect
         * when running in a virtual machine.
         */
        EnabledUndeterminded = Qt::PartiallyChecked,
        /**
         * The effect is enabled.
         */
        Enabled = Qt::Checked
    };

    explicit EffectsModel(QObject *parent = nullptr);

    // Reimplemented from QAbstractItemModel.
    QHash<int, QByteArray> roleNames() const override;
    QModelIndex index(int row, int column, const QModelIndex &parent = {}) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    /**
     * Specify exclusive groups that the model should not store.
     *
     * @param exclusiveGroups A list of exclusive group strings for the model to ignore.
     */
    void setExcludeExclusiveGroups(const QStringList &exclusiveGroups);

    /**
     * Specify effect IDs that the model should not store.
     *
     * @param effects A list of effects by ServiceNameRole.
     */
    void setExcludeEffects(const QStringList &effects);

    /**
     * Changes the status of a given effect.
     *
     * @param rowIndex An effect represented by the given index.
     * @param effectState The new state.
     * @note In order to actually apply the change, you have to call save().
     */
    void updateEffectStatus(const QModelIndex &rowIndex, Status effectState);

    /**
     * This enum type is used to specify load options.
     */
    enum class LoadOptions {
        None,
        /**
         * Do not discard unsaved changes when reloading the model.
         */
        KeepDirty
    };

    /**
     * Loads effects.
     *
     * You have to call this method in order to populate the model.
     */
    void load(LoadOptions options = LoadOptions::None);

    /**
     * Saves status of each modified effect.
     */
    void save();

    /**
     * Resets the status of the effect to the default state.
     *
     * @note In order to actually apply the change, you have to call save().
     */
    void defaults(const QModelIndex &index);

    /**
     * Resets the status of each effect to the default state.
     *
     * @note In order to actually apply the change, you have to call save().
     */
    void defaults();

    /**
     * Whether the status of the effect is its default state.
     */
    bool isDefaults(const QModelIndex &index) const;

    /**
     * Whether the status of each effect is its default state.
     */
    bool isDefaults() const;

    /**
     * Whether the model has unsaved changes.
     */
    bool needsSave() const;

    /**
     * Finds an effect with the given plugin id.
     */
    QModelIndex findByPluginId(const QString &pluginId) const;

    /**
     * Shows a configuration dialog for a given effect.
     *
     * @param index An effect represented by the given index.
     * @param context The context in which to open configuration dialog.
     */
    void requestConfigure(const QModelIndex &index, QQuickItem *context);

Q_SIGNALS:
    /**
     * This signal is emitted when the model is loaded or reloaded.
     *
     * @see load
     */
    void loaded();

protected:
    struct EffectData
    {
        QString name;
        QString description;
        QString authorName;
        QString authorEmail;
        QString license;
        QString version;
        QString untranslatedCategory;
        QString category;
        QString serviceName;
        QString iconName;
        Status status;
        Status originalStatus;
        bool enabledByDefault;
        bool enabledByDefaultFunction;
        QUrl website;
        bool supported;
        QString exclusiveGroup;
        bool internal;
        bool changed = false;
        QString configModule;
        QVariantList configArgs;
    };

    /**
     * Returns whether the given effect should be stored in the model.
     *
     * @param data The effect.
     * @returns @c true if the effect should be stored, otherwise @c false.
     */
    virtual bool shouldStore(const EffectData &data) const;

private:
    void loadBuiltInEffects(const KConfigGroup &kwinConfig);
    void loadJavascriptEffects(const KConfigGroup &kwinConfig);
    void loadPluginEffects(const KConfigGroup &kwinConfig);

    QList<EffectData> m_effects;
    QList<EffectData> m_pendingEffects;
    QStringList m_excludeExclusiveGroups;
    QStringList m_excludeEffects;
    int m_lastSerial = -1;

    Q_DISABLE_COPY(EffectsModel)
};

#endif // EFFECTSMODEL_H
