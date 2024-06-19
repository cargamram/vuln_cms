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

  apache::vhost { '200-vulncms.com':
    port    => 80,
    servername => 'vulncms.com',
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

  drupal::site { 'drupal':
    core_version => '7.32',
  }

  file { '/var/www/vulncms':
    ensure => 'link',
    target => '/var/www/drupal/',
    require => Drupal::Site['drupal'],
  }

}
