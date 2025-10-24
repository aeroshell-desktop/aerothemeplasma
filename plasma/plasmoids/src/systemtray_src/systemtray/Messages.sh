#! /usr/bin/env bash
$XGETTEXT `find . -name \*.js -o -name \*.qml -o -name \*.cpp | grep -v '/tests/'` -o $podir/plasma_applet_org.kde.plasma.systemtray.pot
