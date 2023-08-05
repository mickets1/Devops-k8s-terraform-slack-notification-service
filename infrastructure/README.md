# Set up a K8s cluster

> ⚠️ If you are a Windows user, it is important that you clone the repo with
`git -c core.autocrlf=false clone git@gitlab.lnu.se:2dv013/content/examples/just-task-it-kubernetes/infrastructure.git` so the line ending character LF is preserved for the three Bash script files.

1. Copy your PEM file to the `terraform` directory.
2. Rename the `example.terraform.tfvars` file to `terraform.tfvars` in the `terraform` directory and assign your OpenStack password to the `openstack_password` variable.
3. Replace all occurrences of `en999zz` in the files in the `terraform` directory with your username.
4. Change the value for `openstack_project_id` in `provider.tf`.
5. Open a terminal and change to the `terraform` directory containing Terraform configuration files.
6. Run the `terraform init` command to initialize a working directory.

    ```text
    terraform init
    ```

7. Run the `terraform apply` command.

    ```text
    terraform apply --auto-approve
    ```

8. The execution of the actions in the plan takes 10 to 15 minutes to complete. If the execution fails, just restart it again. (If necessary, run the `terraform destroy` command to destroy all objects before restarting the execution.)
    > 👉 If you find that it takes a long time, several minutes, for OpenStack to create an instance, you can use OpenStack's web interface to delete the instance that seems to have hung. The execution is canceled, and you can run the `terraform apply` command again.
9. Use SSH to connect to the cluster plane machine and verify with the `kubectl get nodes` command that all nodes have joined the cluster.

    ```text
    ubuntu@control-plane:~$ kubectl get nodes
    NAME            STATUS   ROLES           AGE     VERSION
    control-plane   Ready    control-plane   10m     v1.25.3
    node-1          Ready    <none>          2m42s   v1.25.3
    node-2          Ready    <none>          2m47s   v1.25.3
    node-3          Ready    <none>          2m50s   v1.25.3
    ```

10. If you miss any node, you need to join it manually by sending the address of the missing node to the `bin/bootstrap-cluster.sh` script.

     ```text
     ubuntu@control-plane:~$ bin/bootstrap-cluster.sh 172.16.0.6
    
     --------------------------
     172.16.0.6 join cluster
     --------------------------

     Warning: Permanently added '172.16.0.6' (ECDSA) to the list of known hosts.

     WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

     Hit:1 http://education.clouds.archive.ubuntu.com/ubuntu focal InRelease

     <omitted for clearance>
    
     Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
     ```
