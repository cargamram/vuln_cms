Exec {
  path => ['/usr/local/bin', '/usr/bin', '/bin', '/usr/sbin', '/sbin', '/var/www/drupal/vendor/bin'],
}

node 'nodo01.domain.local' {

  $vulncms_path = '/var/www/vulncms'
  $mysql_root_pass = 'rootpassword'
  $drupal_db = 'drupaldb'
  $drupal_user = 'drupaluser'
  $drupal_pass = 'drupalpass'

  include apt

  apt::source { 'sury-php':
    location     => 'https://packages.sury.org/php',
    release      => 'bullseye',
    repos        => 'main',
    architecture => 'amd64',
    key          => {
        name   => 'sury-php',
        id     => '89DF5277',
        source => 'https://packages.sury.org/php/apt.gpg',
    },
    notify       => Exec['apt_update'],
    include      => {
        'src' => false,
        'deb' => true,
    },
  }

  class { 'apache': 
    default_vhost => false, 
    mpm_module => 'prefork', 
  } 

  class { 'mysql::server':
    root_password => $mysql_root_pass,
  }

  apache::vhost { 'vulncms.com':
    port    => 80,
    docroot => $vulncms_path,
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
    directories => [
    {
      path => $vulncms_path,
      options => ['Indexes', 'FollowSymLinks', 'MultiViews'],
      allow_override => ['All'],
      require => ['all granted'],
    }
  ],
  }

  mysql::db { $drupal_db:
    user     => $drupal_user,
    password => $drupal_pass,
    host     => 'localhost',
    grant    => ['ALL'],
    require  => Class['mysql::server'],
  }

  package { ['php5.6', 'php5.6-gd', 'php5.6-curl', 'php5.6-xml', 'php5.6-zip', 'php5.6-mysqli', 'libapache2-mod-php5.6', 'unzip', 'gnupg2']:
    ensure  => installed,
    require => [Class['apache'], Apt::Source['sury-php']],
  }->
  exec{ 'composer_download': 
    command      => 'wget -O /usr/local/bin/composer https://getcomposer.org/download/2.2.24/composer.phar',
  }->
  exec{ 'composer_permission': 
    command      => 'chmod a+x /usr/local/bin/composer',
  }->
  exec { 'rm_drupal':
    command       => 'rm -r /var/www/drupal &>/dev/null',
  }
  exec{ 'composer_create_project': 
    environment   => ['COMPOSER_HOME=/tmp'],
    command       => 'composer create-project drupal-composer/drupal-project:7.x-dev /var/www/drupal --no-interaction',
  }->
  exec{ 'install_drupal': 
    command      => "drush site-install  --root=/var/www/drupal/web --account-pass=adminpassword --db-url=mysql://${drupal_user}:${drupal_pass}@localhost/${drupal_db} --yes",
  }->
  file { $vulncms_path:
    ensure => 'link',
    target => '/var/www/drupal/web',
  }->
  exec{ 'enable_rewrite': 
    command      => 'a2enmod php5.6 && a2enmod rewrite && systemctl restart apache2',
  }->
  exec{ 'mkdir_module_custom':
    command      => 'mkdir /var/www/drupal/web/sites/all/modules/custom',
  }->
  exec{ 'module_vulnerable_download':
    command      => 'wget -O /tmp/vulnerable7.zip https://github.com/greggles/vulnerable/archive/7.x-1.x.zip',
  }->
  exec{ 'install_vulnerable_download':
    command      => 'unzip /tmp/vulnerable7.zip -d /var/www/drupal/web/sites/all/modules/custom',
  }->
  exec { 'import_drupal_db':
    command => "mysql -u ${drupal_user} -p${drupal_pass} -h localhost ${drupal_db} < /vagrant_shared/drupal-dump.sql",
    path    => ['/usr/bin', '/usr/local/bin'],
    user    => 'root',
  }->
  exec{ 'drush_clear_cache':
    command      => 'drush cc all'
  }

}
