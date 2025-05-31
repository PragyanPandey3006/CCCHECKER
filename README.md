# Raven - Telegram CC Checker Bot

A powerful Telegram bot for credit card checking with multiple payment gateways and tools.

## Features

- Multiple payment gateway integrations (Stripe, PayPal, Braintree, etc.)
- Credit card validation and checking
- BIN lookup functionality
- Mass checking capability
- User management system with different access levels (Free, Premium, VIP)
- Anti-spam protection
- Credit system
- Key generation and claiming
- Admin commands for user management

## Requirements

- PHP 7.4 or higher
- MySQL/MariaDB database
- Web server (Apache, Nginx, etc.)
- SSL certificate (for webhook mode)
- Telegram Bot Token

## Installation

1. Clone the repository to your web server
2. Create a MySQL database and import the SQL schema (see below)
3. Configure the `config.php` file with your bot details and database credentials
4. Set up a webhook or use polling method

### Database Schema

Create the following tables in your MySQL database:

```sql
CREATE TABLE `users` (
  `id` varchar(255) NOT NULL,
  `range` varchar(50) NOT NULL DEFAULT 'USER',
  `credits` int(11) NOT NULL DEFAULT 0,
  `antispam` int(11) NOT NULL DEFAULT 0,
  `status` varchar(50) NOT NULL DEFAULT 'PENDING',
  `warns` int(11) NOT NULL DEFAULT 0,
  `plan` varchar(50) NOT NULL DEFAULT 'Free',
  `expiry` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
);

CREATE TABLE `gates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu` varchar(50) NOT NULL DEFAULT 'charge',
  `name` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'premium',
  `info` varchar(255) NOT NULL,
  `cmd` varchar(50) NOT NULL,
  `file` varchar(255) NOT NULL,
  `comm` text DEFAULT NULL,
  `format` varchar(255) DEFAULT NULL,
  `creation` varchar(255) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT '✅',
  `extra` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cmd` (`cmd`)
);

CREATE TABLE `tools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'premium',
  `info` varchar(255) NOT NULL,
  `cmd` varchar(50) NOT NULL,
  `format` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `comm` text DEFAULT NULL,
  `creation` varchar(255) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT '✅',
  PRIMARY KEY (`id`),
  UNIQUE KEY `cmd` (`cmd`)
);

CREATE TABLE `keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'ACTIVE',
  `plan` varchar(50) NOT NULL DEFAULT 'Premium',
  `expiry` int(11) NOT NULL DEFAULT 0,
  `credits` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
);
```

## Configuration

Edit the `config.php` file with your bot details:

```php
// Bot Owner Information
define('BOT_OWNER_NAME', 'YourName');
define('BOT_OWNER_USERNAME', 'YourUsername');
define('BOT_OWNER_ID', 'YourTelegramID');

// Bot Information
define('BOT_NAME', 'YourBotName');
define('BOT_USERNAME', 'YourBotUsername');
define('BOT_TOKEN', 'YourBotToken');
define('BOT_LOGS', 'LogsChannelID');
define('BOT_GROUP', 'GroupID');

// Database Information
define('DB_DATABASE', 'database_name');
define('DB_HOST', 'localhost');
define('DB_USERNAME', 'database_user');
define('DB_PASSWORD', 'database_password');
```

## Deployment Methods

### Webhook Method (Recommended for production)

1. Upload all files to your web server
2. Make sure your server has a valid SSL certificate
3. Set the webhook URL using Telegram API:
   ```
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=https://your-domain.com/webhook.php
   ```

### Polling Method (For development)

Create a script to run the bot in polling mode:

```php
<?php
require_once 'bot.php';

while (true) {
    // Get updates
    $updates = $bot->getUpdates();
    
    // Process updates
    foreach ($updates as $update) {
        $bot->processUpdate($update);
    }
    
    sleep(1);
}
```

## Usage

### User Commands

- `/register` - Register to use the bot
- `/start` - Start the bot
- `/cmds` - Show available commands
- `/claim <key>` - Claim a subscription key

### Admin Commands

- `/auth <user_id>` - Authorize a user
- `/unauth <user_id>` - Unauthorize a user
- `/prom <user_id>` - Promote a user to admin
- `/ban <user_id>` - Ban a user
- `/bban <bin>` - Ban a BIN
- `/key <plan>|<days>|<credits>` - Generate a subscription key

### Owner Commands

- `/agate <name>|<type>|<info>|<cmd>|<file>|<extra>` - Add a new gate
- `/ugate <cmd>|<json_data>` - Update a gate
- `/atool <name>|<type>|<info>|<cmd>|<format>|<file>|<comment>` - Add a new tool
- `/utool <cmd>|<json_data>` - Update a tool

## Security Considerations

- Always use HTTPS for your webhook
- Keep your bot token secure
- Regularly update your dependencies
- Monitor your server for suspicious activities
- Don't store sensitive information in plain text

## License

This project is for educational purposes only. Use at your own risk.

## Disclaimer

This tool is provided for educational purposes only. The developers are not responsible for any misuse or damage caused by this program.