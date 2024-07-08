node 'nodo01.domain.local' {

  $vulncms_path = '/opt/vulncms/web'
  $mysql_root_pass = 'rootpassword'
  $drupal_db = 'drupaldb'
  $drupal_user = 'drupaluser'
  $drupal_pass = 'drupalpass'
  $php_ini_path = '/etc/php/5.6/cli/php.ini'

  include apt

  apt::source { 'sury-php':
    location     => 'https://packages.sury.org/php',
    release      => 'bullseye',
    repos        => 'main',
    architecture => 'amd64',
    key          => {
        name   => 'sury-php',
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

  class { 'apache::mod::php': 
    php_version => '5.6', 
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

  package { ['php5.6', 'php5.6-gd', 'php5.6-curl', 'php5.6-xml', 'php5.6-zip', 'php5.6-mysqli', 'unzip', 'gnupg2']:
    ensure  => installed,
    require => Apt::Source['sury-php'],
  }->
  exec{ 'composer_copy': 
    command      => 'php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"',
  }->
  exec{ 'composer_setup': 
    command      => 'php composer-setup.php --2.2  --install-dir=/usr/local/bin --filename=composer',
  }->
  exec{ 'composer_unlink': 
    command      => 'php -r "unlink('composer-setup.php');"',
  }->
  exec{ 'composer_create_project': 
    command      => 'composer create-project drupal-composer/drupal-project:7.x-dev /opt/vulncms --no-interaction',
  }

  file { $vulncms_path:
    ensure => 'link',
    target => '/opt/vulncms',
    require => Exec['composer_create_project'],
  }  

  exec{ 'mysql_repo': 
    command      => 'echo "deb http://repo.mysql.com/apt/debian/ bullseye mysql-8.0" > /etc/apt/sources.list.d/mysql.list',
  }->
  exec{ 'mysql_apt_key': 
    command      => 'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A8D3785C',
  }->
  exec{ 'apt_get_update': 
    command      => 'apt-get update',
  }->
  exec{ 'install_mysql_client': 
    command      => 'apt-get install mysql-client',
  }

  exec{ 'install_mysql_client': 
    command      => '/opt/vulncms/vendor/bin/drush site-install  --root=/opt/vulncms/web --account-pass=adminpassword --db-url=mysql://${drupal_user}:${drupal_pass}@localhost/${drupal_db} --yes',
    require => [Exec['composer_create_project'], Exec['install_mysql_client']],
  }

}
