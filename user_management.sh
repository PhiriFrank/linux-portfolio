#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Log file
LOG="/home/mas/user_management.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG
}

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    USER MANAGEMENT SYSTEM      ${NC}"
echo -e "${BLUE}================================${NC}"
echo "Started: $(date)"
echo ""

# Groups to create
GROUPS=("staff" "developers" "admins")

echo -e "${YELLOW}==GROUP CREATION==${NC}"
for group in "staff" "developers" "admins"; do
    if ! getent group $group > /dev/null; then
        sudo groupadd $group
        echo -e "${GREEN}Group $group created ✅${NC}"
        log "Group $group created"
    else
        echo -e "${YELLOW}Group $group already exists — skipping${NC}"
    fi
done
echo ""

# Users to create
USERS=("alice" "bob" "charlie")

echo -e "${YELLOW}==USER CREATION==${NC}"
for user in "${USERS[@]}"; do
    if ! id "$user" > /dev/null 2>&1; then
        sudo adduser --disabled-password --gecos "" $user
        echo -e "${GREEN}User $user created ✅${NC}"
        log "User $user created"
    else
        echo -e "${YELLOW}User $user already exists — skipping${NC}"
    fi
done
echo ""

echo -e "${YELLOW}==ADDING USERS TO GROUPS==${NC}"
for user in "${USERS[@]}"; do
    sudo usermod -aG staff $user
    echo -e "${GREEN}$user added to staff ✅${NC}"
    log "$user added to staff group"
done
echo ""

echo -e "${YELLOW}==CREATING SHARED FOLDERS==${NC}"
for group in "${GROUPS[@]}"; do
    if [ ! -d "/home/$group" ]; then
        sudo mkdir /home/$group
        sudo chown root:$group /home/$group
        sudo chmod 2770 /home/$group
        echo -e "${GREEN}Folder /home/$group created ✅${NC}"
        log "Folder /home/$group created"
    else
        echo -e "${YELLOW}Folder /home/$group already exists — skipping${NC}"
    fi
done
echo ""

echo -e "${YELLOW}==VERIFICATION==${NC}"
echo "--- Groups created ---"
for group in "${GROUPS[@]}"; do
    cat /etc/group | grep "^$group"
done
echo ""
echo "--- User profiles ---"
for user in "${USERS[@]}"; do
    cat /etc/passwd | grep "^$user"
done
echo ""
echo "--- Folder permissions ---"
ls -la /home/ | grep -E "staff|developers|admins"
echo ""

echo "--- Activity Log ---"
cat $LOG
echo ""

echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}  USER MANAGEMENT COMPLETE! ✅  ${NC}"
echo -e "${BLUE}================================${NC}"
