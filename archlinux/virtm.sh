#!/usr/bin/bash -e

# Run as Root
if [[  $EUID -ne 0 ]];then
    echo "Run as root";
    exit 1
fi

pacman -S --needed --noconfirm virt-manager dnsmasq qemu-base qemu-desktop

# libvirt
sed -i "/uri_default/s/#//" /etc/libvirt/libvirt.conf
cp /etc/libvirt/libvirt.conf "${HOME}/.config/libvirt/"

# libvirtd
sed -i "/unix_sock_group/s/#//" /etc/libvirt/libvirtd.conf
sed -i "/unix_sock_ro_perms/s/#//" /etc/libvirt/libvirtd.conf

# network
if [[ -f /etc/libvirt/network.conf ]]; then
    echo -e "\nfirewall_backend = \"iptables\"" >> /etc/libvirt/network.conf
fi

# Qemu
if [[ -f /etc/libvirt/qemu.conf ]]; then
    echo "###################################################################
# Qemu user
user = \"${USER}\"
group = \"libvirt\"" >> /etc/libvirt/qemu.conf
fi

# enable ip forwarding for ufw firewall
sed -i "/net\/ipv4\/ip_forward=1/s/#//" /etc/ufw/sysctl.conf
sysctl -p /etc/ufw/sysctl.conf
ufw reload

# add user to groups
usermod -aG qemu,libvirt-qemu,libvirt,kvm "${USER}"

# Enable systemd services
# qemu interface network nodedev storage
systemctl enable --now virtqemud.service virtlxcd.service \
  virtinterfaced.service virtnetworkd.service virtstoraged.service \
  virtnodedevd.service

echo "Virt-Manager Insalled Reboot and launch virt-manager"
echo "Run virsh net-start default to startup NAT"

