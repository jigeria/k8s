#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR" || exit

multipass launch -c 2 -m 2G -n vm1
multipass launch -c 2 -m 2G -n vm2
multipass launch -c 2 -m 2G -n vm3


rm -f ansible ansible.pub
ssh-keygen -f ansible -q -N "" -C ""

multipass transfer ./ansible.pub vm1:/home/ubuntu
multipass transfer ./ansible.pub vm2:/home/ubuntu
multipass transfer ./ansible.pub vm3:/home/ubuntu

multipass exec vm1 -- bash -c 'cat ansible.pub >> /home/ubuntu/.ssh/authorized_keys'
multipass exec vm2 -- bash -c 'cat ansible.pub >> /home/ubuntu/.ssh/authorized_keys'
multipass exec vm3 -- bash -c 'cat ansible.pub >> /home/ubuntu/.ssh/authorized_keys'

mkdir -p inventory
cat<<EOF > inventory/cluster.yaml
all:
  hosts:
    vm1:
      ansible_host: 127.0.0.1
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ansible
    vm2:
      ansible_host: 127.0.0.1
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ansible
    vm3:
      ansible_host: 127.0.0.1
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ansible
  children:
    master:
      hosts:
        vm1:
    control-planes:
      hosts:
        vm1:
    nodes:
      hosts:
        vm2:
        vm3:
EOF

IP=$(multipass info vm1 --format=yaml | yq '.vm1.[0].ipv4[0]') yq -i '.all.hosts.vm1.ansible_host=env(IP)' inventory/cluster.yaml
IP=$(multipass info vm2 --format=yaml | yq '.vm2.[0].ipv4[0]') yq -i '.all.hosts.vm2.ansible_host=env(IP)' inventory/cluster.yaml
IP=$(multipass info vm3 --format=yaml | yq '.vm3.[0].ipv4[0]') yq -i '.all.hosts.vm3.ansible_host=env(IP)' inventory/cluster.yaml


