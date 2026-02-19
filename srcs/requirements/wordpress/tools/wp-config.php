<?php
/**
 * The base configuration for WordPress
 * Database settings pulled from environment variables
 */

// ** Database settings from environment ** //
define( 'DB_NAME', getenv('MYSQL_DATABASE') ?: 'wordpress' );
define( 'DB_USER', getenv('MYSQL_USER') ?: 'wp_user' );
define( 'DB_PASSWORD', getenv('MYSQL_PASSWORD') ?: 'secure_wp_password_123' );
define( 'DB_HOST', getenv('DB_HOST') ?: 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', 'utf8mb4_unicode_ci' );

/**#@+
 * Authentication unique keys and salts.
 * @since 2.6.0
 */
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

/**#@-*/

/** WordPress database table prefix. */
$table_prefix = 'wp_';

/** For developers: WordPress debugging mode. */
define( 'WP_DEBUG', getenv('WP_DEBUG') === 'true' );
define( 'WP_DEBUG_LOG', '/var/www/html/wp-content/debug.log' );
define( 'WP_DEBUG_DISPLAY', false );

/** Disable file editing */
define( 'DISALLOW_FILE_EDIT', true );

/** Set memory limit */
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '512M' );

/** Enable wp-cli */
define( 'WP_CLI', false );

/** ABSPATH - WordPress absolute path */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Absolute path to the WordPress directory. */
require_once ABSPATH . 'wp-settings.php';
