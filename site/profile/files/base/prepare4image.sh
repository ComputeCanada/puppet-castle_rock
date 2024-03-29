#!/bin/bash -e
systemctl stop puppet
systemctl stop slurmd &> /dev/null || true
systemctl stop consul &> /dev/null || true
systemctl stop consul-template &> /dev/null || true
systemctl disable puppet
systemctl disable slurmd &> /dev/null || true
systemctl disable consul &> /dev/null || true
systemctl disable consul-template &> /dev/null || true
/sbin/ipa-client-install -U --uninstall
rm -rf /etc/puppetlabs
rm /opt/consul/node-id /opt/consul/checkpoint-signature /opt/consul/serf/local.snapshot
grep nfs /etc/fstab | cut -f 2 | xargs umount
sed -i '/nfs/d' /etc/fstab
systemctl stop syslog
: > /var/log/messages
if [ -f /etc/cloud/cloud-init.disabled ]; then
  # This is for GCP where we install cloud-init on first boot
  rm /etc/cloud/cloud-init.disabled
  yum install -y cloud-init
  systemctl disable cloud-init
fi
cloud-init clean --logs
halt -p