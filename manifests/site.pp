node 'nodo01' {
  class { 'drupal':
    drupal_version => '8.2.0',
    db_host        => 'localhost',
    db_name        => 'drupaldb',
    db_user        => 'drupaluser',
    db_password    => 'drupalpass',
    site_name      => 'My Drupal Site',
    site_mail      => 'admin@example.com',
    site_user      => 'admin',
    site_pass      => 'adminpassword',
    install_dir    => '/var/www/drupal',
  }

  drupal::site { 'example.com':
    core_version => '8.2.0',
    modules      => {
      'ctools'   => '1.4',
      'token'    => '1.5',
      'pathauto' => '1.2',
      'views'    => '3.8',
    },
    themes       => {
      'omega' => '4.3',
    },
    libraries    => {
      'jquery_ui' => {
        'download' => {
          'type' => 'file',
          'url'  => 'http://jquery-ui.googlecode.com/files/jquery.ui-1.6.zip',
          'md5'  => 'c177d38bc7af59d696b2efd7dda5c605',
        },
      },
    },
  }

  class { 'apache':
    default_vhost => false,
  }

  apache::vhost { 'drupal':
    port    => '80',
    docroot => '/var/www/drupal',
    require => Class['drupal'],
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
