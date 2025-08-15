# SDDM Theme details

The SDDM theme features the following configuration options: 

- background - Background wallpaper
- branding - Branding logo
- forceUserSelect - Whether to always show the user selection page or not
- enableStartup - Play the Vista-style animation on the first time during boot
- playSound - Play the startup sound during boot

The startup animation plays at the beginning as SDDM is loaded for the first time during boot, and won't start again until the computer reboots. The way this is achieved is by checking for the existence of the file `/tmp/sddm.startup`, and the animation is played if the file doesn't exist. As the animation gets played, the file is also subsequently created, preventing the animation from playing again in cases where the user logs out of their session back into SDDM.

The sound effect that plays during startup gets the same treatment as described above. Note that the sound effect gets played on whatever (default) audio output Qt has access to during startup, which may lead to undesirable results. 
