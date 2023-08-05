## Run:
The application is set to local/developmnent in it's current stage. To change to production we need to change the notification.yaml and taskit.yaml and uncomment "production".

### Local:
helm install rabbit --set auth.password=secretpassword my-repo/rabbitmq
helm install redis --set auth.password=secretpassword my-repo/redis

### Production:
1. helm repo add my-repo https://charts.bitnami.com/bitnami

2. kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/baremetal/deploy.yaml
(nginx-ingress-controller)

3.
helm install redis \
  	--set auth.password=secretpassword \
  	--set volumePermissions.enabled=true \
  	--set master.persistence.existingClaim=redis-data-redis-master-0 \
  	--set replica.persistence.existingClaim=redis-data-redis-replicas-0 \
	my-repo/redis

4. helm install rabbit --set auth.password=secretpassword,volumePermissions.enabled=true,master.persistence.existingClaim=data-rabbit-rabbitmq-0 my-repo/rabbitmq

#### Troubleshooting
Useful commands if application not working correctly in production:  
    Run staging exec first then commands:  
    kubectl delete pvc --all  
    kubectl delete pv --all  
    kubectl delete pods --all  
    (i usually run staging/produktion deploy first and then helm install's above). Sometimes the rabbitMQ pv/pvc's needs to be deleted before running "helm install" because of permission conflicts.

Notes:
When upgrading or deleting RabbitMQ or deleting the rabbitmq-volume(PV) the credentials will get lost to easily fix this run:
kubectl exec --stdin --tty rabbit-rabbitmq-0 -- /bin/bash  
rabbitmqctl change_password user RABBITMQ_PASSWORD  
Delete(restart) affected pods using kubectl delete pod PODNAME  
