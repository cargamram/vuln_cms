node 'nodo01.domain.local' {

  drupal::site { 'vulncms.com':
    core_version => '8.2.0',
  }

  class { 'apache': 
   default_vhost => false, 
   mpm_module => 'prefork', 
  } 

  class { 'apache::mod::php': 
    php_version => '7.0', 
  }

  apache::vhost { 'vulncms.com':
    port    => 80,
    docroot => '/var/www/drupal',
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
  }

  class { 'mysql::server':
    root_password => 'rootpassword',
  }

  mysql::db { 'drupaldb':
    user     => 'drupaluser',
    password => 'drupalpass',
    host     => 'localhost',
    grant    => ['ALL'],
    require  => Class['mysql::server'],
  }

}
