class profile::directory {
  include profile::base
  include ::openldap
  include ::openldap::client
  if $facts['virtual'] == 'Xen' {
    $ldap_interfaces = [$facts['networking']['interfaces']['eth0']['ip']]
  } 
  class { '::openldap::server':
    root_dn         => 'cn=Manager,dc=example,dc=com',
    root_password   => '{SSHA}xKQ0DsYNK6E2DG84c35XqWvrT6HWaiLn',
    suffix          => 'dc=example,dc=com',
    access          => [
      'to attrs=userPassword by self =xw by anonymous auth',
      'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by self write by users read',
    ],
    indices         => [
      'objectClass eq,pres',
      'ou,cn,mail,surname,givenname eq,pres,sub',
    ],
    ldap_interfaces => $ldap_interfaces,
  }
  ::openldap::server::schema { 'cosine':
    position => 1,
  }
  ::openldap::server::schema { 'inetorgperson':
    position => 2,
  }
  ::openldap::server::schema { 'nis':
    position => 3,
  }
  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'enablement',
      'log_level'  => 'INFO',
      'bind_addr'  => $facts['networking']['interfaces']['eth0']['ip'],
      'node_name'  => $::fqdn,
      'retry_join' => [$::consulserver],
    }
  }
  consul::service { 'ldap':
    checks  => [
      {
        script   => 'ldapsearch -D "cn=Manager,dc=example,dc=com" -w hashicorp -p 389 -h localhost -b "cn=Manager,dc=example,dc=com"',
        interval => '10s'
      }
    ],
    port    => 8200,
    tags    => ['production'],
  }

}
