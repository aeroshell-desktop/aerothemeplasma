#!/bin/bash

RULE_DESC=POLKIT_RULES
CONFIG_DIR=~/.config/kwinrulesrc
SHOULD_ADD=$(grep $RULE_DESC $CONFIG_DIR)
 
if [[ -n "$SHOULD_ADD" ]]; then
	echo "Rule already added, closing..."
	exit
fi

COUNT=$(kreadconfig6 --file $CONFIG_DIR --group General --key count --default 0)
RULES=$(kreadconfig6 --file $CONFIG_DIR --group General --key rules)
UUID=$(uuidgen)
COUNT=$((COUNT+1))

echo "Adding KWin rule $RULE_DESC..."
kwriteconfig6 --file $CONFIG_DIR --group $UUID --key Description $RULE_DESC
kwriteconfig6 --file $CONFIG_DIR --group $UUID --key clientmachine localhost
kwriteconfig6 --file $CONFIG_DIR --group $UUID --key minimizerule 2
kwriteconfig6 --file $CONFIG_DIR --group $UUID --key wmclass "(polkit-kde-authentication-agent-1)|(polkit-kde-manager)|(org.kde.polkit-kde-authentication-agent-1)"
kwriteconfig6 --file $CONFIG_DIR --group $UUID --key wmclassmatch 3

kwriteconfig6 --file $CONFIG_DIR --group General --key count $COUNT
kwriteconfig6 --file $CONFIG_DIR --group General --key rules $RULES,$UUID

echo "Reloading KWin..."

qdbus6 org.kde.KWin /KWin reconfigure

echo "Done."

