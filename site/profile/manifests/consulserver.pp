class profile::consulserver {
  include profile::base
  class { '::consul':
    config_hash => {
      'bootstrap_expect' => 1,
      'client_addr'      => $facts['networking']['interfaces']['eth1']['ip'],
      'data_dir'         => '/opt/consul',
      'datacenter'       => 'aws',
      'log_level'        => 'INFO',
      'node_name'        => $::fqdn,
      'server'           => true,
      'ui_dir'           => '/opt/consul/ui',
    },
  }
}
