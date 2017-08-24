class profile::oraclexe {
  class { 'oraclexe::install':
    path            => '/tmp/oracle-xe-11.2.0-1.0.x86_64.rpm',
    oracle_password => 'hashicorp'
  }
}
