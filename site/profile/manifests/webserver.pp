class profile::webserver (
) {
  include profile::base
  include epel
  file { '/srv':
    ensure => directory,
  }

  package { 'ruby':
    ensure => latest,
  }

  package { 'git':
    ensure   => latest,
  }

  package { 'bundler':
    ensure   => present,
    provider => 'gem',
    require  => Package['ruby']
  }

  
  package { ['ruby-devel','gcc-c++','mysql-devel']:
    ensure          => present,
    install_options => '--enablerepo=rhui-REGION-rhel-server-optional',
  }


  package { 'json_pure':
    ensure   => present,
    provider => 'gem',
    require  => Package['ruby']
  }

  package { 'json':
    ensure   => present,
    provider => 'gem',
    require  => Package['ruby']
  }

  package { 'vault':
    ensure   => present,
    provider => 'gem',
    require  => Package['ruby']
  }
  
  package { 'rubygem-rake':
    ensure   => present,
    install_options => ['--enablerepo=\*'],
  }

  package { 'rack':
    ensure   => '1.6.4',
    provider => 'gem',
    require  => Package['ruby']
  }

  package { 'sinatra':
    ensure   => latest,
    provider => 'gem',
    require  => Package['ruby']
  }

  vcsrepo { '/srv/hashidemo':
    ensure   => present,
    provider => git,
    remote   => 'origin',
    owner    => 'apache',
    source   => {
      'origin'       => 'https://github.com/ncorrare/hashidemo.git'
    },
    branch      => 'overkill',
    require  => [File['/srv'],User['apache']],
    notify   => Exec['bundle-install'],
  }

  exec { 'bundle-install':
    command     => '/usr/local/bin/bundle install',
    cwd         => '/srv/hashidemo',
    refreshonly => true
  }

  class { 'apache':
    default_vhost => false,
  }
  
  apache::vhost { $::fqdn:
    port        => '80',
    docroot     => '/srv/hashidemo/public',
    require     => Vcsrepo['/srv/hashidemo'],
  }
  class { 'apache::mod::passenger':
  }
  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'aws',
      'log_level'  => 'INFO',
      'node_name'  => $::fqdn,
      'retry_join' => [$::consulserver],
    }
  }
  consul::service { 'web':
    checks  => [
      {
        script   => "curl http://localhost > /dev/null",
        interval => '10s'
      }
    ],
    port    => 80,
    tags    => ['blogs']
  } 

}
