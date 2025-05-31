#!/bin/bash

# Raven Telegram Bot Setup Script for Ubuntu 22.04
# This script will install all necessary dependencies and set up the bot

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Raven Telegram Bot setup...${NC}"

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
apt update && apt upgrade -y

# Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
apt install -y apache2 mysql-server php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath unzip curl

# Enable and start services
echo -e "${YELLOW}Starting services...${NC}"
systemctl enable apache2
systemctl enable mysql
systemctl start apache2
systemctl start mysql

# Secure MySQL installation
echo -e "${YELLOW}Securing MySQL installation...${NC}"
echo -e "${RED}Please set a root password and answer 'Y' to all security questions${NC}"
mysql_secure_installation

# Create database and user
echo -e "${YELLOW}Setting up database...${NC}"
read -p "Enter MySQL root password: " rootpass
read -p "Enter database name for the bot: " dbname
read -p "Enter database username for the bot: " dbuser
read -p "Enter database password for the bot: " dbpass

# Create database and user
mysql -u root -p"$rootpass" -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -u root -p"$rootpass" -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
mysql -u root -p"$rootpass" -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';"
mysql -u root -p"$rootpass" -e "FLUSH PRIVILEGES;"

# Create database tables
echo -e "${YELLOW}Creating database tables...${NC}"
mysql -u root -p"$rootpass" $dbname << EOF
CREATE TABLE \`users\` (
  \`id\` varchar(255) NOT NULL,
  \`range\` varchar(50) NOT NULL DEFAULT 'USER',
  \`credits\` int(11) NOT NULL DEFAULT 0,
  \`antispam\` int(11) NOT NULL DEFAULT 0,
  \`status\` varchar(50) NOT NULL DEFAULT 'PENDING',
  \`warns\` int(11) NOT NULL DEFAULT 0,
  \`plan\` varchar(50) NOT NULL DEFAULT 'Free',
  \`expiry\` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (\`id\`)
);

CREATE TABLE \`gates\` (
  \`id\` int(11) NOT NULL AUTO_INCREMENT,
  \`menu\` varchar(50) NOT NULL DEFAULT 'charge',
  \`name\` varchar(255) NOT NULL,
  \`type\` varchar(50) NOT NULL DEFAULT 'premium',
  \`info\` varchar(255) NOT NULL,
  \`cmd\` varchar(50) NOT NULL,
  \`file\` varchar(255) NOT NULL,
  \`comm\` text DEFAULT NULL,
  \`format\` varchar(255) DEFAULT NULL,
  \`creation\` varchar(255) NOT NULL,
  \`status\` varchar(10) NOT NULL DEFAULT '✅',
  \`extra\` text DEFAULT NULL,
  PRIMARY KEY (\`id\`),
  UNIQUE KEY \`cmd\` (\`cmd\`)
);

CREATE TABLE \`tools\` (
  \`id\` int(11) NOT NULL AUTO_INCREMENT,
  \`name\` varchar(255) NOT NULL,
  \`type\` varchar(50) NOT NULL DEFAULT 'premium',
  \`info\` varchar(255) NOT NULL,
  \`cmd\` varchar(50) NOT NULL,
  \`format\` varchar(255) DEFAULT NULL,
  \`file\` varchar(255) DEFAULT NULL,
  \`comm\` text DEFAULT NULL,
  \`creation\` varchar(255) NOT NULL,
  \`status\` varchar(10) NOT NULL DEFAULT '✅',
  PRIMARY KEY (\`id\`),
  UNIQUE KEY \`cmd\` (\`cmd\`)
);

CREATE TABLE \`keys\` (
  \`id\` int(11) NOT NULL AUTO_INCREMENT,
  \`key\` varchar(255) NOT NULL,
  \`status\` varchar(50) NOT NULL DEFAULT 'ACTIVE',
  \`plan\` varchar(50) NOT NULL DEFAULT 'Premium',
  \`expiry\` int(11) NOT NULL DEFAULT 0,
  \`credits\` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (\`id\`),
  UNIQUE KEY \`key\` (\`key\`)
);
EOF

# Configure Apache
echo -e "${YELLOW}Configuring Apache...${NC}"
read -p "Enter your domain name (e.g., example.com): " domain

# Create Apache virtual host
cat > /etc/apache2/sites-available/$domain.conf << EOF
<VirtualHost *:80>
    ServerAdmin webmaster@$domain
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot /var/www/html/$domain
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    
    <Directory /var/www/html/$domain>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Create directory for the site
mkdir -p /var/www/html/$domain

# Enable the site and required modules
a2ensite $domain.conf
a2enmod rewrite
systemctl restart apache2

# Install Certbot for SSL
echo -e "${YELLOW}Installing Certbot for SSL...${NC}"
apt install -y certbot python3-certbot-apache

# Get SSL certificate
echo -e "${YELLOW}Obtaining SSL certificate...${NC}"
certbot --apache -d $domain -d www.$domain

# Configure bot
echo -e "${YELLOW}Configuring the bot...${NC}"
read -p "Enter your Telegram Bot Token: " bottoken
read -p "Enter your Telegram User ID (owner): " ownerid
read -p "Enter your Telegram Username (without @): " ownerusername
read -p "Enter your Bot Username (without @): " botusername
read -p "Enter your Logs Channel ID (with -): " logschannel
read -p "Enter your Group ID (with -): " groupid

# Create config file
cat > /var/www/html/$domain/config.php << EOF
<?php

if (!defined('BOT_OWNER_NAME'))                      define('BOT_OWNER_NAME', 'Owner');
if (!defined('BOT_OWNER_USERNAME'))                  define('BOT_OWNER_USERNAME', '$ownerusername');
if (!defined('BOT_OWNER_ID'))                        define('BOT_OWNER_ID', '$ownerid');

if (!defined('BOT_NAME'))                            define('BOT_NAME', 'Raven');
if (!defined('BOT_USERNAME'))                        define('BOT_USERNAME', '$botusername');
if (!defined('BOT_TOKEN'))                           define('BOT_TOKEN', '$bottoken');
if (!defined('BOT_LOGS'))                            define('BOT_LOGS', '$logschannel');
if (!defined('BOT_GROUP'))                           define('BOT_GROUP', '$groupid');

if (!defined('DB_DATABASE'))                         define('DB_DATABASE', '$dbname');
if (!defined('DB_HOST'))                             define('DB_HOST', 'localhost');
if (!defined('DB_USERNAME'))                         define('DB_USERNAME', '$dbuser');
if (!defined('DB_PASSWORD'))                         define('DB_PASSWORD', '$dbpass');
EOF

# Set permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chown -R www-data:www-data /var/www/html/$domain
chmod -R 755 /var/www/html/$domain

# Install Composer
echo -e "${YELLOW}Installing Composer...${NC}"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Set up webhook
echo -e "${YELLOW}Setting up webhook...${NC}"
read -p "Do you want to set up the webhook now? (y/n): " setupwebhook

if [ "$setupwebhook" = "y" ]; then
    curl -F "url=https://$domain/webhook.php" https://api.telegram.org/bot$bottoken/setWebhook
    echo -e "${GREEN}Webhook set up successfully!${NC}"
fi

echo -e "${GREEN}Setup completed!${NC}"
echo -e "${YELLOW}Now upload all bot files to /var/www/html/$domain/${NC}"
echo -e "${YELLOW}Make sure to create an empty banned_bins.txt file in the root directory${NC}"
echo -e "${GREEN}Your bot should be ready to use!${NC}"