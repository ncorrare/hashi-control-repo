class profile::vault {
  include profile::base
  include openssl
  include ssh
  user { "$::training_username":
    home             => "/home/$::training_username",
    password         => '$1$k1F0mu0m$sR7WXY6mMU/SEc2iJVNWN.',
    managehome       => true,
    password_max_age => '99999',
    password_min_age => '0',
    shell            => '/bin/bash',
    gid              => 'vault',
    require          => Group['vault'],
  }

  package { 'easy-rsa':
    ensure => installed,
    source => 'ftp://195.220.108.108/linux/epel/7/x86_64/e/easy-rsa-2.2.2-1.el7.noarch.rpm',
    before => File['/bin/generatecert.sh'],
  }

  file { '/bin/generatecert.sh':
    source  => 'puppet:///modules/profile/generatecert.sh',
    require => User['vault'],
    mode    => '0755',
  }
  
  exec { '/bin/generatecert.sh':
    creates => '/etc/vault/ca.crt',
    before  => Class['vault'],
  }
  
  file { "/home/$::training_username/.bash_profile":
    source  => 'puppet:///modules/profile/bash_profile',
    require => User[$::training_username],
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
    download_url   => $::vaulturl,
    backend      => {
      'consul' => {
        'address'       => "$::consulserver:8500",
        'path'          => $::training_username,
        'redirect_addr' => "https://$::fqdn:8200/",
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
    extra_config => {
      'cluster_name'  => $::training_username,
    },
    manage_user   => false,
    manage_group  => false,
  }

  file { '/etc/ssl/vault':
    ensure => directory,
  }

  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'enablement',
      'log_level'  => 'INFO',
      'bind_addr'  => $facts['networking']['interfaces']['eth0']['ip'],
      'node_name'  => $::fqdn,
      'retry_join' => [$::consulserver],
    }
  }

  consul::service { 'vault':
    checks  => [
      {
        script   => 'curl -k https://localhost:8200/v1/sys/seal-status &> /dev/null',
        interval => '10s'
      }
    ],
    port    => 8200,
    tags    => ['production'],
  }
}
