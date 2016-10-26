class profile::consulserver {
  package { 'unzip':
    ensure => present,
    before => Class['consul'],
  }
  class { '::consul':
    config_hash => {
      'bootstrap_expect' => 1,
      'client_addr'      => '0.0.0.0',
      'data_dir'         => '/opt/consul',
      'datacenter'       => 'aws',
      'log_level'        => 'INFO',
      'node_name'        => $::fqdn,
      'server'           => true,
      'ui_dir'           => '/opt/consul/ui',
    },
  }
}
