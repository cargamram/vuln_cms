node 'nodo01.domain.local' {

  class { 'apache': 
   default_vhost => false, 
   mpm_module => 'prefork', 
  } 

  class { 'apache::mod::php': 
    php_version => '7.4', 
  }

  class { 'mysql::server':
    root_password => 'rootpassword',
  }

  apache::vhost { 'vulncms.com':
    port    => 80,
    docroot => '/var/www/vulncms',
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
  }

  mysql::db { 'drupaldb':
    user     => 'drupaluser',
    password => 'drupalpass',
    host     => 'localhost',
    grant    => ['ALL'],
    require  => Class['mysql::server'],
  }

  exec { 'remove_existing_directory_vulncms':
    command => 'rm -rf /var/www/vulncms',
    onlyif  => 'test -d /var/www/vulncms',
    path    => ['/bin', '/usr/bin'],
    require => Class['apache'],
  }

  file { '/etc/php/7.4/apache2/php.ini':
    ensure  => present,
    content => "mbstring.func_overload = 0\nmbstring.internal_encoding = UTF-8\nmbstring.http_input = pass\nmbstring.http_output = pass\n",
    require => Class['apache'],
  }

  drupal::site { 'drupal':
    core_version => '7.32',
    require => File['/etc/php/7.4/apache2/php.ini']
  }

  file { '/var/www/vulncms':
    ensure => 'link',
    target => '/var/www/drupal/',
    require => [Drupal::Site['drupal'], Exec['remove_existing_directory_vulncms']],
  }  

  exec { 'drush_site_install':
    command => '/usr/local/bin/drush site-install standard --account-name=admin --account-pass=adminpassword --db-url=mysql://drupaluser:drupalpass@localhost/drupaldb --site-name="Vulncms Site" -y',
    cwd     => '/var/www/vulncms',
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    require => [Drupal::Site['drupal'], File['/var/www/vulncms']],
  }

}
