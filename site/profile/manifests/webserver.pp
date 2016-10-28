class profile::webserver (
  $webpath = '/var/www/wordpress',
  $dbuser  = 'wp-us3r',
  # Never ever ever ever ever ever ever ever do this!!!!! It's just for example purposes!!!!
  $dbpass  = 'h4rc0dingp4ssw0rds1sv3ryb4d', #Just effing putting it in Vault... Tomorrow
  $dbname  = 'wordpress',
) {
  include profile::base
  include apache
  include apache::mod::php
  $dbhost = consullookup('blogs.mysql.service.consul.')
  package {['php','mysql','php-mysql','php-gd']:
    ensure => installed,
  }
  apache::vhost { $vhost:
    port    => '80',
    docroot => $webpath,
    require => [File[$webpath]],
  }
  file { $webpath:
    ensure => directory,
    owner => 'apache',
    group => 'apache',
    require => Package['httpd'],
  }
  class { '::wordpress':
    db_user        => $dbuser,
    db_password    => $dbpass,
    db_host        => $dbhost,
    db_name        => $dbname,
    create_db      => false,
    create_db_user => false,
    install_dir    => $webpath,
    wp_owner    => 'apache',
    wp_group    => 'apache',
  }
}
