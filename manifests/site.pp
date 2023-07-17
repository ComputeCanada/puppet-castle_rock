stage { ['first', 'second']: }
Stage['first'] -> Stage['second'] -> Stage['main']

node default {
  $instance_tags = lookup("terraform.instances.${facts['networking']['hostname']}.tags")

  if 'puppet' in $instance_tags {
    include profile::consul::server
  } else {
    include profile::consul::client
  }

  include profile::base
  include profile::users::local
  include profile::sssd::client
  include profile::metrics::node_exporter

  if 'login' in $instance_tags {
    include profile::fail2ban
    include profile::cvmfs::client
    include profile::slurm::submitter
    include profile::ssh::hostbased_auth::client
    include profile::ceph::client
  }

  if 'mgmt' in $instance_tags {
    include profile::freeipa::server

    include profile::metrics::server
    include profile::metrics::slurm_exporter
    include profile::rsyslog::server
    include profile::squid::server
    include profile::slurm::controller

    include profile::freeipa::mokey
    include profile::slurm::accounting

    include profile::accounts
    include profile::users::ldap
    include profile::users::external_ldap

    include profile::ceph::client
  } else {
    include profile::freeipa::client
    include profile::rsyslog::client
  }

  if 'node' in $instance_tags {
    include profile::cvmfs::client
    include profile::gpu
    include profile::jupyterhub::node

    include profile::slurm::node
    include profile::ssh::hostbased_auth::client
    include profile::ssh::hostbased_auth::server

    include profile::metrics::slurm_job_exporter

    include profile::ceph::client

    Class['profile::nfs::client'] -> Service['slurmd']
    Class['profile::gpu'] -> Service['slurmd']
  }

  if 'nfs' in $instance_tags {
    include profile::nfs::server
    include profile::cvmfs::alien_cache
  } else {
    include profile::nfs::client
  }

  if 'proxy' in $instance_tags {
    include profile::jupyterhub::hub
    include profile::reverse_proxy
  }

  if 'dtn' in $instance_tags {
    include profile::globus
  }

  if 'mfa' in $instance_tags {
    include profile::mfa
  }
}
