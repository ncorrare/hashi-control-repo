class profile::base {

  #the base profile should include component modules that will be on all nodes
  class { 'selinux':
     mode => 'disabled',
  }
  package { 'bind-utils':
    ensure => present,
  }

}
