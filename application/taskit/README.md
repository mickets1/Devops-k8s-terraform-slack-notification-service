## Kubernetes

Development and production environment

### Requirements

#### kubctl
**Kubectl** is a command line interface to inspect and control the kubernetes instance.  

If you have Docker Desktop installed, you should already have kubectl. Verify with:
```bash
kubectl version
```

If not installed, or you need to upgrade: [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)  

#### Skaffold
**Skaffold** is a command line tool to helps with the development workflow.

[Install Skaffold](https://skaffold.dev/docs/install/)  

#### Minikube
**Minikube** is a small kubernetes instance running inside a Docker container. 

[Install minikube](https://minikube.sigs.k8s.io/docs/start/)  

### Development

Make sure Docker Desktop is running.

Start minikube:  
```bash
minikube start
```

Enable the Nginx ingress controller for minikube
```bash
minikube addons enable ingress
```

See Using [Docker with Minikube](https://codingbee.net/tutorials/kubernetes/using-docker-with-minikube) for details.
```bash
eval $(minikube -p minikube docker-env)
```

Start Skaffold for development:  
```bash
skaffold dev
```  

#### Connect to the exposed service in Minicube

Open a new terminal.

```bash
minikube tunnel
```
_You may be prompted for your computer password since minikube want´s to open priviliged ports._

Then visit the [http://localhost](http://localhost)

### Production

For production in CSCloud:

