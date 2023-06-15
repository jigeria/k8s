#!/bin/sh
multipass launch -c 2 -m 2G -n master
multipass launch -c 2 -m 2G -n worker-01
multipass launch -c 2 -m 2G -n worker-02

multipass exec master -- /bin/bash -c "curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --cluster-init"

export K3S_MASTER_IP="https://$(multipass list | awk '/master/ { print $3 }'):6443"
export K3S_TOKEN="$(multipass exec master -- /bin/bash -c "sudo cat /var/lib/rancher/k3s/server/node-token")"

multipass exec worker-01 -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_TOKEN=${K3S_TOKEN} K3S_URL=${K3S_MASTER_IP} sh -"
multipass exec worker-02 -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_TOKEN=${K3S_TOKEN} K3S_URL=${K3S_MASTER_IP} sh -"

multipass exec master cat /etc/rancher/k3s/k3s.yaml > k3s.yaml
multipass list | awk '/master/ { print $3 }' | xargs -I{} yq e --inplace '.clusters[].cluster.server = "https://{}:6443"' k3s.yaml
mv k3s.yaml ~/.kube/config

