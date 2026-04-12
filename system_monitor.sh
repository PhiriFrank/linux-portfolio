#!/bin/bash


echo "================================" 
echo "      SYSTEM HEALTH REPORT      "
echo "================================"
echo "Date: $(date)"
echo "User: $(whoami)"
echo ""
echo "--- CPU Usage ---"
top -bn1 | grep "Cpu(s)"
echo ""
echo "--- Memory Usage ---"
free -h
echo ""
echo "--- Disk Usage ---"
df -h
echo ""
echo "--- SSH Status ---"
systemctl is-active ssh
echo ""
echo "--- Internet Check ---"
ping -c 1 google.com > /dev/null
if [ $? = 0 ]; then
    echo "Internet: Reachable ✅"
else
    echo "Internet: Unreachable ❌"
fi
echo "================================"

