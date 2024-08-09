sudo cp -f smod-stcw-before.service smod-stcw-after.service /etc/systemd/system
sudo systemctl enable smod-stcw-before.service
sudo systemctl enable smod-stcw-after.service
