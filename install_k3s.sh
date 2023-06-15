#!/bin/sh
multipass launch -c 2 -n linux
multipass exec linux -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -"
multipass exec linux cat /etc/rancher/k3s/k3s.yaml > k3s.yaml
multipass list | awk '/linux/ { print $3 }' | xargs -I{} yq e --inplace '.clusters[].cluster.server = "https://{}:6443"' k3s.yaml
mv k3s.yaml ~/.kube/config