class profile::vault {
  include profile::base
  include openssl
  class { '::vault':
    backend => {
      'consul' => {
        'address' => "$::consulserver:8500",
        'path'    => 'vault',
      }
    },
    listener => {
      'tcp' => {
        'address'       => '0.0.0.0:8200',
        'tls_disable'   => 0,
        'tls_cert_file' => '/etc/ssl/vault/vault.crt',
        'tls_key_file'  => '/etc/ssl/vault/vault.key',
        }
      },
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
    email        => 'ncorrare@gmail.com',
    days         => 3456,
    base_dir     => '/etc/ssl/vault',
    owner        => 'vault',
    group        => 'root',
    force        => false,
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
  consul::service { 'vault':
    checks  => [
      {
        script   => 'curl -k https://localhost:8200/v1/sys/seal-status &> /dev/null',
        interval => '10s'
      }
    ],
    port    => 8200,
  }
}
