class profile::vault {
  include profile::base
  class { '::vault':
    backend => {
      'consul' => {
        'address' => "$::consulserver:8500",
        'path'    => 'vault',
      }
    },
    listener => {
      'tcp' => {
        'address' => '0.0.0.0:8200',
        'tls_disable' => 0,
      }
    }
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
    #checks  => [
    #  {
    #    script   => '/bin/mysql -u root -e "SELECT 1" > /dev/null',
    #    interval => '10s'
    #  }
    #],
    port    => 8200,
  }
}
