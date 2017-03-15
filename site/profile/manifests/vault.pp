class profile::vault {
  include profile::base
  include openssl
  include ssh

  package { 'easy-rsa':
    ensure   => installed,
    source   => 'ftp://195.220.108.108/linux/epel/7/x86_64/e/easy-rsa-2.2.2-1.el7.noarch.rpm',
    provider => 'rpm',
    before   => File['/bin/generatecert.sh'],
  }

  file { '/bin/generatecert.sh':
    source  => 'puppet:///modules/profile/generatecert.sh',
    require => User['vault'],
    mode    => '0755',
  }
  
  exec { '/bin/generatecert.sh':
    creates  => '/etc/ssl/vault/ca.crt',
    notify   => Service['vault'],
  }
  
  file { "/home/ec2-user/.bash_profile":
    source  => 'puppet:///modules/profile/bash_profile',
  }
  

  user { 'vault':
    ensure           => 'present',
    home             => '/home/vault',
    password         => '!!',
    password_max_age => '99999',
    password_min_age => '0',
    shell            => '/bin/bash',
    gid              => 'vault',
    require          => Group['vault'],
  }

  group { 'vault':
    ensure => 'present',
  }

  file_line { 'sudo_rule':
    path => '/etc/sudoers',
    line => '%vault ALL=(ALL) NOPASSWD: ALL',
  }

  class { '::vault':
    install_method => 'archive',
    download_url   => '/tmp/vault.zip',
    backend      => {
      'file' => {
        'path'          => '/secrets',
      }
    },
    listener     => {
      'tcp' => {
        'address'       => '0.0.0.0:8200',
        'tls_disable'   => 0,
        'tls_cert_file' => "/etc/ssl/vault/$::fqdn.crt",
        'tls_key_file'  => "/etc/ssl/vault/$::fqdn.key",
      }
    },
    manage_user   => false,
    manage_group  => false,
    extra_config => {
      'ui'  => true,
    },
  }

  file { '/etc/ssl/vault':
    ensure => directory,
  }

}
