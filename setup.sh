#!/bin/bash
if [ x$1 = x"precustomization" ]; then
echo "Started doing pre-customization steps..."
echo "Finished doing pre-customization steps."
elif [ x$1 = x"postcustomization" ]; then
echo "Started doing post-customization steps..."
echo "iptables -I INPUT -p tcp --dport 80 -j ACCEPT" >> /etc/systemd/scripts/iptables
systemctl restart iptables.service
tdnf install httpd -y
systemctl enable httpd.service && systemctl start httpd.service
echo "<html><body><h1>It works!</h1><p>Hello from Terraform created machine: `uname -a`!</p><p>This machine was bootstrapped at: `date`</p><pre>`ps auxfwww`</pre></body></html>" > /etc/httpd/html/index.html
echo "Finished doing post-customization steps."
fi