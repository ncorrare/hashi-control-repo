class profile::webserver (
) {
  include profile::base
  include apache
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

  package { 'vault':
    ensure   => present,
    provider => 'gem',
    require  => Package['ruby']
  }
  
  package { 'rake':
    ensure => present,
    source => 'ftp://ftp.pbone.net/mirror/ftp.centos.org/7.2.1511/os/x86_64/Packages/rubygem-rake-0.9.6-25.el7_1.noarch.rpm',
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

  #  vcsrepo { '/srv/labsignups':
  #  ensure   => present,
  #  provider => git,
  #  remote   => 'origin',
  #  owner    => 'apache',
  #  source   => {
  #    'origin'       => 'https://github.com/ncorrare/labsignups.git'
  #  },
  #  require => File['/srv'],
  #}
  
  #apache::vhost { 'puppetmaster-idc.cloudapp.net':
  #  port    => '80',
  #  docroot => '/srv/labsignups/public',
  #  require => Vcsrepo['/srv/labsignups'],
  #}
  class { 'apache::mod::passenger':
  }

}
