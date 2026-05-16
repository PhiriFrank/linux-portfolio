#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Score counter
SCORE=0
TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    if [ $1 -eq 0 ]; then
        SCORE=$((SCORE + 1))
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}      SECURITY HARDENING        ${NC}"
echo -e "${BLUE}================================${NC}"
echo "Started: $(date)"
echo "Running as: $(whoami)"
echo ""

# SSH Hardening
echo -e "${YELLOW}==SSH HARDENING==${NC}"
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
check $? "Root SSH login disabled"
echo -e "${GREEN}Max auth tries set to 3 ✅${NC}"
echo -e "${GREEN}Password authentication disabled ✅${NC}"
echo ""

# Firewall Rules
echo -e "${YELLOW}==FIREWALL RULES==${NC}"
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 23/tcp
sudo ufw enable
UFW_STATUS=$(sudo ufw status | grep "Status" | awk '{print $2}')
if [ "$UFW_STATUS" = "active" ]; then
    check 0 "Firewall is active"
else
    check 1 "Firewall is not active"
fi
echo ""

# Empty Password Check
echo -e "${YELLOW}==EMPTY PASSWORD CHECK==${NC}"
EMPTY=$(sudo awk -F: '($2 == "") {print $1}' /etc/shadow | wc -l)
if [ $EMPTY -eq 0 ]; then
    check 0 "No empty passwords found"
else
    check 1 "WARNING: $EMPTY users have empty passwords!"
    sudo awk -F: '($2 == "") {print $1}' /etc/shadow
fi
echo ""

# Dangerous Permissions
echo -e "${YELLOW}==DANGEROUS PERMISSIONS==${NC}"
DANGEROUS=$(find /home -perm 777 -type f 2>/dev/null | wc -l)
if [ $DANGEROUS -eq 0 ]; then
    check 0 "No dangerous files found"
else
    check 1 "WARNING: $DANGEROUS dangerous files found!"
    find /home -perm 777 -type f 2>/dev/null
fi
echo ""

# Check for unattended upgrades
echo -e "${YELLOW}==AUTO UPDATES==${NC}"
if systemctl is-active unattended-upgrades > /dev/null 2>&1; then
    check 0 "Auto updates enabled"
else
    check 1 "Auto updates not enabled"
    sudo apt install unattended-upgrades -y > /dev/null
    echo -e "${GREEN}Auto updates installed ✅${NC}"
fi
echo ""

# Unnecessary Services
echo -e "${YELLOW}==UNNECESSARY SERVICES==${NC}"
for service in bluetooth cups avahi-daemon; do
    if systemctl is-active $service > /dev/null 2>&1; then
        sudo systemctl stop $service
        sudo systemctl disable $service
        echo -e "${GREEN}$service disabled ✅${NC}"
    else
        echo -e "${YELLOW}$service already disabled — skipping${NC}"
    fi
done
echo ""

# Disk Space Check
echo -e "${YELLOW}==DISK SPACE CHECK==${NC}"
DISK_USED=$(df / | awk 'NR==2{print $5}' | tr -d '%')
if [ $DISK_USED -lt 80 ]; then
    check 0 "Disk usage healthy at $DISK_USED%"
else
    check 1 "WARNING: Disk usage critical at $DISK_USED%!"
fi
echo ""

# Security Score
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}      SECURITY SCORE            ${NC}"
echo -e "${BLUE}================================${NC}"
PERCENTAGE=$((SCORE * 100 / TOTAL))
echo "Checks passed: $SCORE/$TOTAL"
echo "Security score: $PERCENTAGE%"

if [ $PERCENTAGE -eq 100 ]; then
    echo -e "${GREEN}EXCELLENT — System is fully secured! 🔒${NC}"
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${GREEN}GOOD — System is mostly secured! ✅${NC}"
elif [ $PERCENTAGE -ge 60 ]; then
    echo -e "${YELLOW}WARNING — Some issues need attention! ⚠️${NC}"
else
    echo -e "${RED}CRITICAL — System needs immediate attention! 🚨${NC}"
fi

# Save Report
echo ""
echo -e "${YELLOW}==SAVING REPORT==${NC}"
{
echo "================================"
echo "SECURITY REPORT"
echo "Date: $(date)"
echo "Score: $SCORE/$TOTAL ($PERCENTAGE%)"
echo "Firewall: $UFW_STATUS"
echo "SSH: $(systemctl is-active ssh)"
echo "Empty passwords: $EMPTY"
echo "Dangerous files: $DANGEROUS"
echo "Disk usage: $DISK_USED%"
echo "================================"
} >> ~/security_report.txt
echo -e "${GREEN}Report saved to security_report.txt ✅${NC}"

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}   SECURITY HARDENING DONE! 🔒  ${NC}"
echo -e "${BLUE}================================${NC}"
