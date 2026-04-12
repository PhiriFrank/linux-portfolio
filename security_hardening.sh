#!/bin/bash
echo "================================"
echo "      SECURITY HARDENING        "
echo "================================"
echo "Started: $(date)"
echo "Running as: $(whoami)"
echo ""

echo "==Configure SSH=="
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
echo "Root SSH login disabled ✅"
echo ""

echo "==Firewall Rules=="
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
echo "Firewall configured ✅"
echo ""

echo "==Empty Password Check=="
sudo awk -F: '($2 == "") {print $1}' /etc/shadow
echo "Empty password check complete ✅"
echo ""

echo "==Dangerous Permissions=="
DANGEROUS=$(find /home -perm 777 -type f 2>/dev/null | wc -l)
if [ $DANGEROUS -eq 0 ]; then
    echo "No dangerous files found ✅"
else
    echo "WARNING: $DANGEROUS dangerous files found! ⚠️"
    find /home -perm 777 -type f 2>/dev/null
fi
echo "Permission check complete ✅"
echo ""

echo "==Unnecessary Services=="
sudo systemctl disable bluetooth 2>/dev/null
echo "Bluetooth disabled ✅"
echo ""

echo "==Security Report=="
echo "Date: $(date)" >> ~/security_report.txt
echo "Firewall: $(sudo ufw status | head -1)" >> ~/security_report.txt
echo "SSH: $(systemctl is-active ssh)" >> ~/security_report.txt
echo "Users: $(cat /etc/passwd | wc -l)" >> ~/security_report.txt
echo "Report saved to security_report.txt ✅"
echo ""

echo "================================"
echo "   SECURITY HARDENING DONE! 🔒  "
echo "================================"

