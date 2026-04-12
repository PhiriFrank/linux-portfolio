#!/bin/bash

echo "================================"
echo "    USER MANAGEMENT SYSTEM      "
echo "================================"
echo ""

echo "==GROUP CREATION=="
if ! getent group staff > /dev/null; then
    sudo groupadd staff
    echo "Group staff created ✅"
else
    echo "Group staff already exists — skipping"
fi
echo ""

echo "==USER CREATION=="
for user in alice bob charlie; do
    if ! id "$user" > /dev/null 2>&1; then
        sudo adduser $user
        echo "User $user created ✅"
    else
        echo "User $user already exists — skipping"
    fi
done
echo ""

echo "==ADDING USERS TO GROUP=="
for user in alice bob charlie; do
    sudo usermod -aG staff $user
    echo "$user added to staff ✅"
done
echo ""

echo "==CREATING SHARED FOLDER=="
if [ ! -d "/home/staff" ]; then
    sudo mkdir /home/staff
    sudo chown root:staff /home/staff
    sudo chmod 2770 /home/staff
    echo "Folder created ✅"
else
    echo "Folder already exists — skipping"
fi
echo ""

echo "==VERIFICATION=="
echo "--- Staff group members ---"
cat /etc/group | grep staff
echo ""
echo "--- User profiles ---"
cat /etc/passwd | grep -E "alice|bob|charlie"
echo ""
echo "--- Folder permissions ---"
ls -la /home/ | grep staff
echo ""
echo "================================"
echo "  USER MANAGEMENT COMPLETE! ✅  "
echo "================================"
