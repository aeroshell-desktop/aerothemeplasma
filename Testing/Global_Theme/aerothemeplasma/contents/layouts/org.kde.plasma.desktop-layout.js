var plasma = getApiVersion(1);

panel = new plasma.Panel;
panel.location = "bottom";
panel.height = 40;

panel.addWidget("io.gitgud.wackyideas.SevenStart");
panel.addWidget("io.gitgud.wackyideas.seventasks");
panel.addWidget("org.kde.plasma.keyboardlayout");
panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("io.gitgud.wackyideas.digitalclocklite");
panel.addWidget("io.gitgud.wackyideas.win7showdesktop");

var allDesktops = desktopsForActivity(currentActivity());
for(var j = 0; j < allDesktops.length; j++) {
    var d = allDesktops[j];
    print(d);
    var groups = d.configGroups;

    var general = groups["General"];
    d.currentConfigGroup = ["General"];

    d.writeConfig("iconSize", 2);
    d.writeConfig("labelWidth", 0);
    d.writeConfig("popups", false);
    d.writeConfig("sortMode", -1);
    d.writeConfig("toolTips", true);
    d.reloadConfig();
}
