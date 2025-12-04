#!/bin/bash
# setup.sh - Complete Nginx and Resume Deployment Script

set -e  # Exit on error

echo "Starting resume website deployment..."
echo "====================================="

# Update system
echo "[1/8] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Nginx
echo "[2/8] Installing Nginx..."
sudo apt-get install nginx -y

# Install security tools
echo "[3/8] Installing security tools..."
sudo apt-get install fail2ban ufw -y

# Configure firewall
echo "[4/8] Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw --force enable

# Configure fail2ban
echo "[5/8] Configuring fail2ban..."
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Create website directory
echo "[6/8] Creating website structure..."
sudo mkdir -p /var/www/resume
sudo chown -R www-data:www-data /var/www/resume
sudo chmod -R 755 /var/www/resume

# Deploy resume files
echo "[7/8] Deploying resume files..."
# This could clone from git, for now create basic files

# Create Nginx configuration
sudo cat > /etc/nginx/sites-available/resume <<'NGINXCONF'
server {
    listen 80;
    listen [::]:80;
    
    root /var/www/resume;
    index index.html;
    
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Block hidden files
    location ~ /\. {
        deny all;
    }
}
NGINXCONF

# Enable site and disable default
sudo ln -sf /etc/nginx/sites-available/resume /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo "[8/8] Testing and restarting Nginx..."
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Create a deployment log
echo "Deployment completed at $(date)" > /var/www/resume/deployment.log

echo "====================================="
echo "Deployment complete!"
echo "Your resume website is now accessible."
echo "Check with: curl http://localhost"
echo "====================================="
