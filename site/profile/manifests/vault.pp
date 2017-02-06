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
  class { '::vault':
    backend      => {
      'consul' => {
        'address' => "$::consulserver:8500",
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

  openssl::certificate::x509 { 'vault':
    ensure       => present,
    country      => 'GB',
    organization => 'example.com',
    commonname   => $fqdn,
    state        => 'Hertsforshire',
    locality     => 'Bishops Stortford',
    unit         => 'vault',
    altnames     => [$fqdn, 'localhost'],
    email        => 'nicolas@hashicorp.com',
    days         => 3456,
    base_dir     => '/etc/ssl/vault',
    owner        => 'vault',
    group        => 'root',
    force        => false,
    before       => Class['vault'],
    require      => User['vault'],
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
