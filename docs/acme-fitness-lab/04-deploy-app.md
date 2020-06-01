# Get, update, and deploy Acme-fitness app

## Set configuration parameters

The scripts to prepare the YAML to deploy acme-fitness depend on a parameters to be set.  Ensure the following are set in `params.yaml':

```yaml
acme-fitness:
  fqdn: acme-fitness.highgarden.tkg-aws-e2-lab.winterfell.live
```

## Retrieve acme-fitness source code

```bash
./scripts/retrieve-acme-fitness-source.sh
```

## Prepare Manifests for acme-fitness

Prepare the YAML manifests for customized acme-fitness K8S objects.  Manifests will be output into `generated/$WORKLOAD_CLUSTER_NAME/acme-fitness/` in case you want to inspect.

```bash
./scripts/generate-acme-fitness-yaml.sh $(yq r params.yaml workload-cluster.name)
```

## Deploy acme-fitness

Once we use our "cody" kubeconfig and set it into the shell, we can update the current context and then avoid specifying namespace for each command below.  These will all apply to the acme-fitness namespace.

```bash
export KUBECONFIG=~/Downloads/kubeconf.txt
kubectl config set-context --current --namespace acme-fitness

kubectl apply -f acme-fitness/acme-fitness-mongodata-pvc.yaml
kubectl create secret generic cart-redis-pass --from-literal=password=KeepItSimple1!
kubectl label secret cart-redis-pass app=acmefit
kubectl apply -f acme_fitness_demo/kubernetes-manifests/cart-redis-total.yaml 
kubectl apply -f acme_fitness_demo/kubernetes-manifests/cart-total.yaml 
kubectl create secret generic catalog-mongo-pass --from-literal=password=KeepItSimple1! 
kubectl label secret catalog-mongo-pass app=acmefit
kubectl create -f acme_fitness_demo/kubernetes-manifests/catalog-db-initdb-configmap.yaml 
kubectl label cm catalog-initdb-config app=acmefit
kubectl apply -f acme_fitness_demo/kubernetes-manifests/catalog-db-total.yaml 
kubectl apply -f acme_fitness_demo/kubernetes-manifests/catalog-total.yaml
kubectl apply -f acme_fitness_demo/kubernetes-manifests/payment-total.yaml
kubectl create secret generic order-postgres-pass --from-literal=password=KeepItSimple1!
kubectl label secret order-postgres-pass app=acmefit
kubectl apply -f acme_fitness_demo/kubernetes-manifests/order-db-total.yaml
kubectl apply -f acme_fitness_demo/kubernetes-manifests/order-total.yaml
kubectl create secret generic users-mongo-pass --from-literal=password=KeepItSimple1!
kubectl label secret users-mongo-pass app=acmefit
kubectl create secret generic users-redis-pass --from-literal=password=KeepItSimple1!
kubectl label secret users-redis-pass app=acmefit
kubectl create -f acme_fitness_demo/kubernetes-manifests/users-db-initdb-configmap.yaml
kubectl label cm users-initdb-config app=acmefit
kubectl apply -f acme_fitness_demo/kubernetes-manifests/users-db-total.yaml
kubectl apply -f acme_fitness_demo/kubernetes-manifests/users-redis-total.yaml
kubectl apply -f acme_fitness_demo/kubernetes-manifests/users-total.yaml
kubectl patch deployment catalog-mongo --type merge -p "$(cat acme-fitness/catalog-db-patch-volumes.yaml)"
kubectl apply -f acme_fitness_demo/kubernetes-manifests/frontend-total.yaml
kubectl apply -f generated/$(yq r params.yaml workload-cluster.name)/acme-fitness/acme-fitness-frontend-ingress.yaml

# Wait for acme-fitness-tls to be generated by cert-manager to be READY: True
watch kubectl get cert acme-fitness-tls 
kubectl label secret acme-fitness-tls app=acmefit
unset KUBECONFIG
```

### Validation Step

Go to the ingress URL to test out.  

```bash
open https://$(yq r params.yaml acme-fitness.fqdn)
# login with eric/vmware1! in order to make a purchase.
```