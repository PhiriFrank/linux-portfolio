#!/bin/bash
echo "================================"
echo "       BACKUP SYSTEM            "
echo "================================"
echo "Backup started: $(date)"
echo "== Setup=="
echo "Backup started..."
echo ""
mkdir -p /home/mas/backups
echo "== Backup files=="
tar -czf /home/mas/backups/finalproject-$(date +%Y-%m-%d).tar.gz /home/mas/finalproject
tar -czf /home/mas/backups/website-$(date +%Y-%m-%d).tar.gz /var/www/html
echo ""
echo "== Log it=="
echo "Backup completed at $(date)" >> /home/mas/backups/backup.log
echo ""
echo "== Show size=="
du -sh /home/mas/backups/
echo ""
echo "Backup complete! ✅"
