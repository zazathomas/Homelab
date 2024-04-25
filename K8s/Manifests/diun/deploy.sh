wget https://github.com/crazy-max/diun/releases/download/v4.28.0/diun_4.28.0_linux_amd64.tar.gz
mkdir -p diun
tar -xvzf diun_4.28.0_linux_amd64.tar.gz -C diun/
groupadd diun
useradd -s /bin/false -d /bin/null -g diun diun
mkdir -p /var/lib/diun
chown diun:diun /var/lib/diun/
chmod -R 750 /var/lib/diun/
mkdir /etc/diun
chown diun:diun /etc/diun
chmod 770 /etc/diun
cp diun.yaml /etc/diun
chown diun:diun /etc/diun/diun.yaml
chmod 644 /etc/diun/diun.yaml
cp diun/diun /usr/local/bin/diun
cp diun.service /etc/systemd/system/diun.service
sudo systemctl enable diun
sudo systemctl start diun
# journalctl -fu diun.service
