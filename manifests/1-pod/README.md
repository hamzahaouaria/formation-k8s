# Pod simple: `1-pod.yaml`

Ce manifest décrit un pod le plus simplement possible.

```yaml
apiVersion: v1
kind: Pod # Type de la ressource
metadata:
  name: kuard # Nom du pod
  labels: # Labels du pod
    app: kuard
spec:
  containers:
    - image: gcr.io/kuar-demo/kuard-amd64:blue # Image de conteneur
      name: kuard # Nom du conteneur
      ports:
        - containerPort: 8080 # Port du conteneur
```

## Etapes à suivre:

- `kubectl apply -f 1-pod.yaml` : Soumettre le manifest pour créer le pod
- `kubectl get pods` : Voir la liste des pods disponible dans le namespace actuel
- `kubectl describe pod kuard` : Avoir des détails sur le pod
- `kubectl logs kuard` : Voir les logs du pod
- `kubectl port-forward kuard 8080:8080`: Avoir acces au pod en localhost

# Pod avec des bonnes pratiques: `2-better-pod.yaml`

Ce manifest décrit un pod avec les liveness et readiness probes ainsi que les limits et les requests

```yaml
apiVersion: v1
kind: Pod # Type de la ressource
metadata:
  name: kuard-better # Nom du pod
  labels: # Labels du pod
    app: kuard-better
spec:
  containers:
    - image: gcr.io/kuar-demo/kuard-amd64:blue # Image de conteneur
      name: kuard # Nom du conteneur
      ports:
        - name: http-port
          containerPort: 8080 # Port du conteneur
      resources:
        requests: # Montant de resources minimum pour executer le pod
          memory: "100M"
          cpu: "50m"
        limits: # Montant de ressources maximum pour executer le pod
          memory: "150M"
          cpu: "100m"
      readinessProbe: # Requête à envoyer pour vérifier que l'application est ready
        httpGet:
          path: /ready
          port: http-port
        failureThreshold: 3
        initialDelaySeconds: 3
        periodSeconds: 5
      livenessProbe: # Requête à envoyer pour vérifier que l'application est healthy
        httpGet:
          path: /healthy
          port: http-port
        failureThreshold: 3
        initialDelaySeconds: 3
        periodSeconds: 5
```

## Etapes à suivre:

- `kubectl apply -f 2-better-pod.yaml` : Soumettre le manifest pour créer le pod
- `kubectl get pods` : Voir la liste des pods disponible dans le namespace actuel
- `kubectl describe pod kuard-better` : Avoir des détails sur le pod (Voir les probes et limits/requests)
- `kubectl port-forward kuard-better 8080:8080`: Avoir acces au pod en localhost
- `kubectl get pods -w` : Avoir la liste des pods en temps réel
- Faire en sorte que les probes échouent via la GUI de KUARD
- Au bout d'un moment le pod est redémarré si la liveness probe échoue
- Au bout d'un moment on verra que le pod sera Not Ready et ne sera plus en mesure de recevoir des requêtes depuis les services

# Utilisation des labels

On peut utiliser les labels pour filtrer sur la liste des pods comme suit:

- `kubectl get pods -l "app=kuard"` : Récupérer les pods avec un label app=kuard
- `kubectl get pods -l "app in (kuard, kuard-better)"` : Récupérer les pods avec un label app=kuard ou app=kuard-better
