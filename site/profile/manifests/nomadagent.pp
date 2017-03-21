class profile::nomadagent {
  class { 'nomad':
    version       => '0.5.5',
    config_hash   => {
      'region'     => 'uk',
      'datacenter' => 'poundhost',
      'log_level'  => 'INFO',
      'bind_addr'  => '0.0.0.0',
      'data_dir'   => '/opt/nomad',
      'client'     => {
        'enabled'    => true,
        'servers'    => [
          "nomadserver.corrarello.net:4647"
        ]
      }
    },
  }
}
