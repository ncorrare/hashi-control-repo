class profile::vault {
  include profile::base
  include openssl
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
    require  => File['/etc/ssl/vault'],
    notify   => Service['vault'],
  }
  
  file { "/root/.bash_profile":
    source  => 'puppet:///modules/profile/bash_profile',
  }

  class { '::vault':
    install_method => 'archive',
    download_url   => '/tmp/vault.zip',
    backend      => {
      'consul' => {
        'address' => "consul.hashicorp.demo:8500",
        'path'    => 'vault',
      }
    },
    listener     => {
      'tcp' => {
        'address'       => '0.0.0.0:8200',
        'tls_disable'   => 0,
        'tls_cert_file' => '/etc/ssl/vault/vault.crt',
        'tls_key_file'  => '/etc/ssl/vault/vault.key',
      }
    },
    extra_config => {
      'cluster_name'  => 'demo',
      'ui'  => true,
    },
    notify       => Exec['vault-init'],
    manage_user  => false,
    manage_group => false,
  }
  #These following two execs are really a very bad idea. It would probably be way better if the vault is initialized manually and the keys are stored in Hiera eyaml or something like that.
  exec { 'vault-init':
    command     => '/usr/local/bin/vault init -address=https://localhost:8200/ -tls-skip-verify > /root/vault.txt',
    refreshonly => true,
    notify      => Exec['vault-unseal'],
  }

  exec { 'vault-unseal':
    command     => 'for key in $(cat /root/vault.txt | grep Unseal | awk \'{print $4}\'); do /usr/local/bin/vault unseal -address=https://localhost:8200/ -tls-skip-verify $key; done',
    refreshonly => true,
    provider    => shell,
    subscribe   => Service['vault'],
  }

  file { '/etc/ssl/vault':
    ensure => directory,
  }

  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'demo',
      'log_level'  => 'INFO',
      'bind_addr'  => $facts['networking']['interfaces']['eth1']['ip'],
      'node_name'  => $::fqdn,
      'retry_join' => ['consul.hashicorp.demo'],
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
