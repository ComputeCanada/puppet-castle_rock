class profile::ceph::client(
  String $share_name,
  String $access_key,
  String $export_path,
  Array[String] $mon_host,
  Array[String] $mount_binds = [],
  String $mount_name = 'cephfs01',
) {
  class { 'profile::ceph::client::install':
    share_name  => $share_name,
    access_key  => Sensitive($access_key),
    export_path => $export_path,
    mon_host    => $mon_host,
    mount_name  => $mount_name,
  }

  file { "/mnt/${mount_name}":
    ensure => directory
  }

  $mon_host_string = join($mon_host, ',')
  mount { "/mnt/${mount_name}":
    ensure  => 'mounted',
    fstype  => 'ceph',
    device  => "${mon_host_string}:${export_path}",
    options => "name=${share_name},secretfile=/etc/ceph/client.keyonly.${share_name}",
    require => Class['profile::ceph::client::install']
  }

  $mount_binds.each |$mount| {
    file { "/mnt/${mount_name}/${mount}":
      ensure  => directory,
      require => Class['profile::ceph::client::install']
    }
    mount { "/${mount}":
      ensure  => 'mounted',
      fstype  => 'bind',
      device  => "/mnt/${mount_name}/${mount}",
      require => File["/mnt/${mount_name}/${mount}"]
    }
  }
}

class profile::ceph::client::install(
  String $share_name,
  String $access_key,
  String $export_path,
  List[String] $mon_host,
) {

  yumrepo { 'ceph-stable':
    ensure        => present,
    enabled       => true,
    baseurl       => "https://download.ceph.com/rpm-nautilus/el${$::facts['os']['release']['major']}/${::facts['architecture']}/",
    gpgcheck      => 1,
    gpgkey        => 'https://download.ceph.com/keys/release.asc',
    repo_gpgcheck => 0,
  }

  package { [
    'libcephfs2',
    'python-cephfs',
    'ceph-common',
    'python-ceph-argparse',
#    'ceph-fuse',
  ] :
    ensure  => installed,
    require => [Yumrepo['epel'], Yumrepo['ceph-stable']]
  }

  file { "/etc/ceph/client.fullkey.${share_name}":
    ensure  => present,
    content => @("EOT"),
[client.${share_name}]
key = ${access_key}
|EOT
    mode    => '0600',
    owner   => 'root',
    group   => 'root'
  }

  file { "/etc/ceph/client.keyonly.${share_name}":
    ensure  => present,
    content => Sensitive($access_key),
    mode    => '0600',
    owner   => 'root',
    group   => 'root'
  }

  $mon_host_string = join($mon_host, ',')
  file { '/etc/ceph/ceph.conf':
    ensure  => present,
    content => @("EOT"),
[client]
    client quota = true
    mon host = ${mon_host_string}
|EOT
  }

}
