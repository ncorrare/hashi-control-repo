class profile::directory {
  include profile::base
include ::openldap
include ::openldap::client

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
    ldap_interfaces => [$ipaddress],
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

}
