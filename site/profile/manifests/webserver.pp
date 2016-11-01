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

  package { 'mysql2':
    ensure   => present,
    provider => 'gem',
    require  => Package['ruby-devel']
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
    provider => 'rpm',
    source   => 'ftp://ftp.pbone.net/mirror/ftp.centos.org/7.2.1511/os/x86_64/Packages/rubygem-rake-0.9.6-25.el7_1.noarch.rpm',
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
    require => [File['/srv'],Class['apache']]
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
