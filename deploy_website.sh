#!/bin/bash
# deploy-website.sh - Update website content

RESUME_DIR="/var/www/resume"
BACKUP_DIR="/tmp/resume_backup_$(date +%Y%m%d_%H%M%S)"

echo "Starting website deployment..."

# Backup existing content
if [ -d "$RESUME_DIR" ]; then
    echo "Backing up existing content to $BACKUP_DIR"
    sudo cp -r "$RESUME_DIR" "$BACKUP_DIR"
fi

# Create fresh directory
sudo rm -rf "$RESUME_DIR"
sudo mkdir -p "$RESUME_DIR"

# Copy new content (in real scenario, clone from git)
echo "Copying new website content..."
sudo cp -r website-content/* "$RESUME_DIR/"

# Set proper permissions
sudo chown -R www-data:www-data "$RESUME_DIR"
sudo chmod -R 755 "$RESUME_DIR"

# Test and reload Nginx
echo "Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "Reloading Nginx..."
    sudo systemctl reload nginx
    echo "Deployment successful! Website updated."
else
    echo "Nginx configuration test failed. Restoring backup..."
    sudo rm -rf "$RESUME_DIR"
    sudo cp -r "$BACKUP_DIR" "$RESUME_DIR"
    echo "Backup restored. Please check your configuration."
fi
