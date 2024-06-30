node 'nodo01.domain.local' {

  $vulncms_path = '/var/www/vulncms'
  $mysql_root_pass = 'rootpassword'
  $drupal_db = 'drupaldb'
  $drupal_user = 'drupaluser'
  $drupal_pass = 'drupalpass'
  $php_ini_path = '/etc/php/7.0/cli/php.ini'

  notice('Ruta vulncms: ${vulncms_path}')
  notice('MySQL Root Password: ${mysql_root_pass}')
  notice('Drupal DB: ${drupal_db}')
  notice('Drupal User: ${drupal_user}')
  notice('Drupal Password: ${drupal_pass}')
  notice('PHP ini Path: ${php_ini_path}')

  include apt

  apt::source { 'sury-php':
    location    => 'https://packages.sury.org/php/',
    repos       => 'main',
    release     => $::lsbdistcodename,
    key         => {
      'id'     => '89DF5277',
      'source' => 'https://packages.sury.org/php/apt.gpg',
    },
    include     => {
      'deb'    => true,
      'src'    => true,
    },
  }

  exec { 'apt_update':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    subscribe   => Apt::Source['sury-php'],
  }

  package { ['php5.6', 'php5.6-cli', 'php5.6-common', 'php5.6-mbstring', 'php5.6-mysql', 'php5.6-fpm']:
    ensure  => installed,
    require => Exec['apt_update'],
  }

  package { 'apache2':
    ensure  => installed,
    require => Exec['apt_update'],
  }

  class { 'apache':
    mpm_module => 'event',
  }

  class { 'apache::mod::proxy_fcgi': }

  service { 'apache2':
    ensure  => running,
    enable  => true,
    require => Package['apache2'],
  }

  file { '/etc/apache2/sites-available/000-default.conf':
    ensure  => file,
    content => template('/etc/template/apache/000-default.conf.erb'),
    require => Package['php5.6-fpm'],
    notify  => Service['apache2'],
  }

  exec { 'enable_php5.6_fpm':
    command => 'a2enconf php5.6-fpm && systemctl reload apache2',
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    unless  => 'test -L /etc/apache2/conf-enabled/php5.6-fpm.conf',
    require => Package['php5.6-fpm'],
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

  exec { 'remove_existing_directory_vulncms':
    command => 'rm -rf ${vulncms_path}',
    onlyif  => 'test -d ${vulncms_path}',
    path    => ['/bin', '/usr/bin'],
    require => Class['apache'],
  }

  drupal::site { 'drupal':
    core_version => '7.32',
    require => [Package['php5.6'], Class['apache']]
  }

  file { $vulncms_path:
    ensure => 'link',
    target => '/var/www/drupal/',
    require => [Drupal::Site['drupal'], Exec['remove_existing_directory_vulncms']],
  }  

  exec { 'drush_site_install':
    command => '/usr/local/bin/drush site-install standard --account-name=admin --account-pass=adminpassword --db-url=mysql://${drupal_user}:${drupal_pass}@localhost/${drupal_db} --site-name="Vulncms Site" -y',
    cwd     => $vulncms_path,
    logoutput => true,
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    require => [Drupal::Site['drupal'], File[$vulncms_path]],
  }

}
