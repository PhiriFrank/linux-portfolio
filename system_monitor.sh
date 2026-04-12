#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}      SYSTEM HEALTH REPORT      ${NC}"
echo -e "${BLUE}================================${NC}"
echo "Date: $(date)"
echo "User: $(whoami)"
echo "Hostname: $(hostname)"
echo ""

# CPU Usage
echo -e "${YELLOW}--- CPU Usage ---${NC}"
top -bn1 | grep "Cpu(s)"
echo ""

# Memory Usage with warning
echo -e "${YELLOW}--- Memory Usage ---${NC}"
free -h
MEM_USED=$(free | awk '/Mem/{printf("%.0f"), $3/$2*100}')
if [ $MEM_USED -gt 80 ]; then
    echo -e "${RED}WARNING: Memory usage is at $MEM_USED%! ⚠️${NC}"
else
    echo -e "${GREEN}Memory usage is healthy at $MEM_USED% ✅${NC}"
fi
echo ""

# Disk Usage with warning
echo -e "${YELLOW}--- Disk Usage ---${NC}"
df -h
DISK_USED=$(df / | awk 'NR==2{print $5}' | tr -d '%')
if [ $DISK_USED -gt 80 ]; then
    echo -e "${RED}WARNING: Disk usage is at $DISK_USED%! ⚠️${NC}"
else
    echo -e "${GREEN}Disk usage is healthy at $DISK_USED% ✅${NC}"
fi
echo ""

# Who is logged in
echo -e "${YELLOW}--- Logged In Users ---${NC}"
who
echo ""

# SSH Status
echo -e "${YELLOW}--- SSH Status ---${NC}"
systemctl is-active ssh
echo ""

# Internet Check
echo -e "${YELLOW}--- Internet Check ---${NC}"
ping -c 1 google.com > /dev/null
if [ $? = 0 ]; then
    echo -e "${GREEN}Internet: Reachable ✅${NC}"
else
    echo -e "${RED}Internet: Unreachable ❌${NC}"
fi

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}     REPORT COMPLETE! ✅        ${NC}"
echo -e "${BLUE}================================${NC}"
