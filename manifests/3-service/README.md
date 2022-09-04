# Service ClusterIP: `1-cluster-ip.yaml`

Ce manifest décrit un service de type `ClusterIP`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kuard-clusterip-service # Nom du service
spec:
  type: ClusterIP # Type du service
  selector: # Selecteur utilisé pour se lier aux pods qui respectent la condition
    app: kuard
  ports:
    - port: 8888 # Port du service
      targetPort: 8080 # Port du conteneur cible
```

## Etapes à suivre:

- `kubectl apply -f 1-cluster-ip.yaml` : Soumettre le manifest pour créer le service
- `kubectl describe service kuard-clusterip-service` : Avoir des détails sur le service
- `kubectl get pods -o wide` : Lister les pods avec plus de details (Les IP nous intéressent)
- Dans un autre terminal, executer `kubectl run curl --image=dwdraju/alpine-curl-jq -i --tty --rm` : Crée un pod qui contient un conteneur avec `curl` et `jq` pour faire des requêtes depuis l'interieur du cluster
- Dans le pod curl, on envoie une requête à un pod avec `curl -s http://<ip-de-pod>:8080/env/api | jq | grep HOSTNAME`. Le hostname est toujours le même.
- Dans le pod curl, on envoie une requête au service avec `curl -s http://<ip-de-service>:8888/env/api | jq | grep HOSTNAME`. le hostname change à chaque requête par ce que le service fait du load balancing.
- Tout les services sont aussi accessible via leur nom grâce au serveur DNS interne du cluster. On peut tester ça, dans le pod curl, avec `curl -s http://kuard-clusterip-service:8888/env/api | jq | grep HOSTNAME`. Ceci permet aux pods de communiquer sans savoir l'adresse IP du destinataire.

# Service NodePort: `2-node-port.yaml`

Tout ce qui s'applique pour un service `ClusterIP` s'applique à un service `NodePort`

Ce manifest décrit un service de type `NodePort`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kuard-nodeport-service # Nom du service
spec:
  type: NodePort # Type du service
  selector: # Selecteur utilisé pour se lier aux pods qui respectent la condition
    app: kuard
  ports:
    - port: 8888 # Port du service
      targetPort: 8080 # Port du conteneur cible
      nodePort: 30123 # Port utilisé par le service sur tout les noeuds
```

## Etapes à suivre:

- `kubectl apply -f 2-node-port.yaml` : Soumettre le manifest pour créer le service
- Dans un autre terminal, executer `kubectl run curl --image=dwdraju/alpine-curl-jq -i --tty --rm` : Crée un pod qui contient un conteneur avec `curl` et `jq` pour faire des requêtes depuis l'interieur du cluster
- Un service NodePort est aussi accessible en interne via son `targetPort`. On test cela avec `curl -s http://kuard-nodeport-service:8888/env/api | jq | grep HOSTNAME`
- `kubectl get nodes -o wide` : Lister les noeuds et leurs IP
- Aller dans le navigateur et tester ceci `http://<ip_de_noeud>:<nodePort_du_service>/env/api`

# Service LoadBalancer: `3-load-balancer.yaml`

Tout ce qui s'applique pour un service `NodePort` s'applique à un service `LoadBalancer`

Ce manifest décrit un service de type `LoadBalancer`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kuard-loadbalancer-service # Nom du service
spec:
  type: LoadBalancer # Type du service
  selector: # Selecteur utilisé pour se lier aux pods qui respectent la condition
    app: kuard
  ports:
    - port: 80 # Port du service
      targetPort: 8080 # Port du conteneur cible
      nodePort: 30124 # Port utilisé par le service sur tout les noeuds
```

## Etapes à suivre:

- `kubectl apply -f 3-load-balancer.yaml` : Soumettre le manifest pour créer le service
- `kubectl get services kuard-loadbalancer-service -w` : Attendre que le LoadBalancer nous assigne une adresse IP
- `curl -s http://<ip_du_service>:80/env/api | jq | grep HOSTNAME`. le hostname change à chaque requête par ce que le service fait du load balancing.

# Service ExternalName: `4-external-name.yaml`

Ce manifest décrit un service de type `ExternalName`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: k8s-external-name # Nom du service
spec:
  type: ExternalName # Type du service
  externalName: httpbin.org # nom de domaine du service externe
  ports:
    - port: 443 # Port du service externe
```

## Etapes à suivre:

- `kubectl apply -f 4-external-name.yaml` : Soumettre le manifest pour créer le service
- Dans un autre terminal, executer `kubectl run curl --image=dwdraju/alpine-curl-jq -i --tty --rm` : Crée un pod qui contient un conteneur avec `curl` et `jq` pour faire des requêtes depuis l'interieur du cluster
- `curl -s -k https://k8s-external-name/get | jq` : On reçoit la réponse depuis https://httpbin.org
