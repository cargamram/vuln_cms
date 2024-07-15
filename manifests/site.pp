Exec {
  path => ['/usr/local/bin', '/usr/bin', '/bin', '/usr/sbin', '/sbin'],
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
    require => Apt::Source['sury-php'],
  }

  exec{ 'composer_download': 
    command      => 'wget -O /usr/local/bin/composer https://getcomposer.org/download/2.2.24/composer.phar',
  }->
  exec{ 'composer_permission': 
    command      => 'chmod a+x /usr/local/bin/composer',
  }->
  exec{ 'composer_create_project': 
    environment   => ['COMPOSER_HOME=/tmp'],
    command       => 'composer create-project drupal-composer/drupal-project:7.x-dev /opt/vulncms --no-interaction',
    onlyif        => 'test ! -d /opt/vulncms',
  }->
  file { $vulncms_path:
    ensure => 'link',
    target => '/opt/vulncms/web',
  }->
  exec{ 'install_drupal': 
    command      => "/opt/vulncms/vendor/bin/drush site-install  --root=/opt/vulncms/web --account-pass=adminpassword --db-url=mysql://${drupal_user}:${drupal_pass}@localhost/${drupal_db} --yes",
  }

}
