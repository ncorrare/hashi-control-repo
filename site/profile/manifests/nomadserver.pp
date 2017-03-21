class profile::nomadserver {
  class { '::nomad':
    config_hash => {
    'region'     => 'uk',
    'datacenter' => 'poundhost',
    'log_level'  => 'INFO',
    'bind_addr'  => '0.0.0.0',
    'data_dir'   => '/opt/nomad',
    'server'     => {
      'enabled'          => true,
      'bootstrap_expect' => 1,
      }
    }
  }

}
