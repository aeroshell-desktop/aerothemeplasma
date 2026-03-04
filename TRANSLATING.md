# Translation guide

## TABLE OF CONTENTS

1. [Introduction](#intro)
2. [Translation formats](#formats)
    1. [index.theme files](#indextheme)
    2. [metadata.json files](#metadata)
    3. [MIME associations](#mime)
    4. [.po files](#po)
3. [Testing](#testing)
3. [Contributing](#contrib)
4. [References](#refs)

## Introduction <a name="intro"></a>

This document will cover the basic steps required for contributors to translate the project. For the sake of brevity,
it's **strongly recommended** to first consult the [references](#refs) at the end of this document, in order to get a basic understanding 
of how localization works across various components of the Linux desktop.

## Translation support for AeroThemePlasma is currently a work in progress, as many applications are still not prepared for localization.

Before diving into translations you should get yourself familiar with the way [locales are identified](https://develop.kde.org/docs/plasma/widget/translations-i18n/#frpo), and then find the locale codes for the languages you'd like to translate. 

## Translation formats <a name="formats"></a>

AeroThemePlasma is divided into multiple repositories, which contain various forms of translatable text. For now,
we're focusing on four main sources of translatable strings: 

1. `index.theme` files
2. `metadata.json` files
3. MIME associations
4. `.po` files

### index.theme files <a name="indextheme"></a>

These files belong to Freedesktop compliant themes such as icon, cursor and sound themes. These files provide
metadata associated with the theme, most importantly its name and description, which are the focus for translations.

The `Name` and `Comment` keys follow [this format](https://specifications.freedesktop.org/desktop-entry/latest/localized-keys.html) 
for localization:

```
# Some examples of translations for the Breeze icon theme
Name[pt_BR]=Breeze
Name[sl]=Sapica (Breeze)
Name[sr]=Поветарац
Name[sr@ijekavian]=Поветарац
Name[sr@ijekavianlatin]=Povetarac
Name[sr@latin]=Povetarac
Name[uk]=Breeze
Name[zh_CN]=Breeze 微风
Name[zh_TW]=Breeze

Comment[ca@valencia]=Brisa, creat pel VDG de KDE
Comment[cs]=Breeze od KDE VDG
Comment[da]=Breeze af KDE VDG
Comment[de]=Breeze von der KDE VDG
Comment[el]=Breeze από το KDE VDG
Comment[en_GB]=Breeze by the KDE VDG
Comment[fr]=Breeze, par l'équipe de conception graphique de KDE
Comment[pt]=Brisa da VDG do KDE
```

The `Name` and `Comment` keys without locale brackets are the fallback strings used when there isn't a localized version 
to be used instead. 

AeroThemePlasma and VistaThemePlasma have translatable `index.theme` entries in the following repos:

- [AeroThemePlasma Sounds](https://gitgud.io/aeroshell/atp/aerothemeplasma-sounds)
- [AeroThemePlasma Icons](https://gitgud.io/aeroshell/atp/aerothemeplasma-icons) 
- [VistaThemePlasma Sounds](https://gitgud.io/aeroshell/vtp/vistathemeplasma-sounds)
- [VistaThemePlasma Icons](https://gitgud.io/aeroshell/vtp/vistathemeplasma-icons) 

### 

### metadata.json files <a name="metadata"></a>

Various KDE Plasma plugins (Plasmoids, shells, KWin effects, KWin scripts, etc.) have a `metadata.json` file that contains
metadata information about a given plugin. The localization format is the same as the format followed by `index.theme`, except
now the translatable keys are `Name` and `Description`:

```json
{
        "Name[ca@valencia]": "Quadro de tasques del telèfon",
        "Name[ca]": "Plafó de tasques del telèfon",
        "Name[da]": "Opgavepanel til telefon",
        "Name[de]": "Task und Schnelleinstellungen",
        "Name[en_GB]": "Phone Task panel",
        "Description[pt_BR]": "Painel de navegação do Plasma Mobile",
        "Description[ru]": "Панель навигации Plasma Mobile",
        "Description[sa]": "प्लाज्मा मोबाईलस्य कृते नेविगेशन पैनल",
        "Description[ta]": "பிளாஸ்மா கைபேசிக்கான உலாவல் பலகை",
        "Description[tr]": "Plasma Cep için dolaşım paneli",
        "Description[uk]": "Панель навігації для мобільної Плазми",
        "Description[x-test]": "xxNavigation panel for Plasma Mobilexx",
        "Description[zh_CN]": "Plasma 移动版导航面板",
        "Description[zh_TW]": "Plasma 行動的導覽面板",
}
```

The `Name` and `Description` keys without locale brackets are the fallback strings used when there isn't a localized version 
to be used instead.

AeroThemePlasma and VistaThemePlasma have translatable `metadata.json` entries in most of the repositories from the AeroShell group. Besides SDDM themes, other `metadata.desktop` entries should be ignored as they aren't used anymore and should be removed.

### MIME associations <a name="mime"></a>

[AeroShell Workspace](https://gitgud.io/aeroshell/aeroshell-workspace/-/blob/Plasma/6.6/mimetype/x-ms-win.xml?ref_type=heads) features a XML file
for MIME associations, which follows the XML formatting. Keep in mind that the locale codes [differ](https://www.w3.org/International/questions/qa-choosing-language-tags) from the locale codes used in other file formats listed here. The `<comment>` tag that doesn't feature a `xml:lang` attribute is the default fallback string used when no matching string for a given locale can be found. 

### .po files <a name="po"></a>

Other translatable strings are found in code (.cpp, .h, .qml) and resource files (.ui) that shouldn't be modified directly. Instead, translation mappings are used which are defined using .po files, with the following directory structure, starting from the root of a repository:

```
./
./po/
./po/translation-domain.pot
./po/locale[_CODE][@variant]/
./po/locale[_CODE][@variant]/translation-domain.po
```

A `.pot` file is a template file generated by a script that acts as a template for all other `.po` files. The `translation-domain` part defines the translation domain that associates all defined translatable strings with an application or a set of applications. For example, a translation domain for [AeroShell KWin Components](https://gitgud.io/aeroshell/aeroshell-kwin-components) is defined to be `aeroshell-kwin-components`. 

This `.pot` file can then be copied to a subfolder that matches the target locale, renamed to have a `.po` extension. For example, targetting Serbian (Latin):

`./po/sr@latin/aeroshell-kwin-components.po`

If you don't see a `po` folder for a given repository in the AeroShell group, it means that translation support isn't completely ready. The previous three sources of translatable strings are still modifiable.

### Format

Examining the newly copied `.po` file, some metadata can be filled out at the beginning:

```
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
"Language-Team: LANGUAGE <LL@li.org>\n"
"Language: \n"
```

The `Language-Team` row can be omitted (unless you're actually part of a language translation team, which is probably unlikely). 

A typical entry in this file will look something like this: 

```
#. i18n: file: effects_cpp/wayland/kde-effects-aeroglassblur/src/kcm/blur_config.ui:27
#. i18n: ectx: attribute (title), widget (QWidget, blurWidget)
#. i18n: file: effects_cpp/x11/kde-effects-aeroglassblur/src/kcm/blur_config.ui:27
#. i18n: ectx: attribute (title), widget (QWidget, blurWidget)
#: rc.cpp:66 rc.cpp:288
#, kde-format
msgctxt "Appearance tab in the blur KCM"
msgid "Appearance"
msgstr ""
```

Where `msgid` is the original string which shouldn't be modified, and `msgstr` is the translated replacement string. `msgctxt` is the _context_ of the string found in `msgid`, which provides further context for the translator in order to avoid incorrect translations as a result of ambiguity (For example, translating 'Clear' in the appropriate context of removing or clearing out something, rather than in the context of transparency, like 'clear water').

There are also comments above these rows which outline every instance of the `msgid` string appearing in the source code, which can be helpful by providing additional context for the translator. 

Some `msgid` strings will contain parameters formatted as `%n` (`%1`, `%2`, `%3`, ...), which should be preserved in the translated `msgstr`. Some `msgid` strings can also contain markup or other kinds of non-readable text (HTML, Rich Text, etc.) which should also be preserved when translating.

Lastly, it is often the case that strings will be added, modified or removed, and so the old `.po` files should be updated accordingly. 

## Testing <a name="testing"></a>

If you're writing translations for a language that isn't set as the current display language, switching between languages can be mildly annoying on Linux. A faster way to test would be to override locale-related environment variables temporarily in a separate terminal session, and run applications from that terminal. For example, testing the AeroGlassBlur KCM with Serbian (Latin) (Assuming you've [generated the locales](https://wiki.archlinux.org/title/Locale#Generating_locales) beforehand):

```bash
export LANGUAGE=sr_RS.UTF-8@latin
export LANG=sr_RS.UTF-8@latin
export LC_TIME=sr_RS.UTF-8@latin # Sometimes needed if time-related localization is relevant
aeroshell-kcmloader kwin/effects/configs/kwin_aeroglassblur_config.so exec
```

## Contributing <a name="contrib"></a>

Improved translations should be contributed by forking the relevant repository, making changes to the fork, and creating a merge request to the original repository. Alternatively, you can send a [patch](https://stackoverflow.com/questions/5159185/how-to-create-a-git-patch-from-the-uncommitted-changes-in-the-current-working-di) via e-mail, along with your username and e-mail address which will be used for co-authoring the contribution.

## References <a name="refs"></a>

1. [KDE Tutorial - Translations / i18n](https://develop.kde.org/docs/plasma/widget/translations-i18n/)
2. [Arch Wiki - Locale](https://wiki.archlinux.org/title/Locale)
3. [Localized values for keys](https://specifications.freedesktop.org/desktop-entry/latest/localized-keys.html)
4. [w3 - Language tags in HTML and XML](https://www.w3.org/International/articles/language-tags/)
5. [w3 - Choosing a language tag](https://www.w3.org/International/questions/qa-choosing-language-tags)
6. [Freedesktop.org - Unified system | Shared MIME-info database](https://specifications.freedesktop.org/shared-mime-info/latest/ar01s02.html)
6. [KI18n - Programmer's guide](https://invent.kde.org/frameworks/ki18n/-/blob/master/docs/programmers-guide.md)

