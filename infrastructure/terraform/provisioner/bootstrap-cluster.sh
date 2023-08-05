#!/bin/bash

JOIN="'sudo rm -fv /etc/containerd/config.toml \
    && sudo systemctl restart containerd \
    && sudo $(kubeadm token create --print-join-command)'"

for IP in "$@"
do
    echo -e "\n--------------------------\n${IP} join cluster\n--------------------------\n"
    {
        ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ma225gn_key_ssh.pem ubuntu@"$IP" 'bash -s' < $HOME/bin/node-init.sh
        ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ma225gn_key_ssh.pem ubuntu@"$IP" 'bash -c' $JOIN
    } &
done
wait