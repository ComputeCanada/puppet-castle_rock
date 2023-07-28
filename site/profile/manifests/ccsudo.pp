class profile::ccsudo::sudoers {
  file { '/etc/sudoers.d/99-ccsudo': 
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => '%cc_staff ALL=(root) NOPASSWD:/software/sbin/ccsudo'
  }
}
