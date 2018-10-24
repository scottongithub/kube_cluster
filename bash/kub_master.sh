#!/bin/bash
sudo apt update && sudo apt-get install -y apt-transport-https curl
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo su -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list'
sudo apt update
sleep 5
sudo apt install -y --allow-change-held-packages kubelet kubeadm kubectl docker.io
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl start docker.service
