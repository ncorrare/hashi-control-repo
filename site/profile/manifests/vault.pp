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
        'tls_cert_file' => '/etc/vault/ssl/vault.crt',
        'tls_key_file'  => '/etc/vault/ssl/vault.key',
        }
      },
    require => Openssl::Certificate::X509['vault'],
  }
  file { '/etc/vault/ssl':
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
    altnames     => ['localhost'],
    email        => 'ncorrare@gmail.com',
    days         => 3456,
    base_dir     => '/etc/vault/ssl',
    owner        => 'root',
    group        => 'root',
    force        => false,
    require      => File['/etc/vault/ssl']
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
        script   => 'curl http://localhost:8200 &> /dev/null',
        interval => '10s'
      }
    ],
    port    => 8200,
  }
}
