node 'nodo01.domain.local' {

  $vulncms_path = '/var/www/vulncms'
  $mysql_root_pass = 'rootpassword'
  $drupal_db = 'drupaldb'
  $drupal_user = 'drupaluser'
  $drupal_pass = 'drupalpass'
  $php_ini_path = '/etc/php/7.4/apache2/php.ini'

  notice('Ruta vulncms: ${vulncms_path}')
  notice('MySQL Root Password: ${mysql_root_pass}')
  notice('Drupal DB: ${drupal_db}')
  notice('Drupal User: ${drupal_user}')
  notice('Drupal Password: ${drupal_pass}')
  notice('PHP ini Path: ${php_ini_path}')

  class { 'apache': 
   default_vhost => false, 
   mpm_module => 'prefork', 
  } 

  class { 'apache::mod::php': 
    php_version => '7.4', 
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
