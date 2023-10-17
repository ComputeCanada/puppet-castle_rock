class profile::localscratch::ephemeraldisk {
    mount { '/localscratch':
      ensure  => 'mounted',
      fstype  => 'none',
      options => 'rw,bind',
      device  => '/mnt',
      require => [
        File['/localscratch'],
      ],
    }
}
