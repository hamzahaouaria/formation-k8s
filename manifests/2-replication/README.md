# ReplicaSet: `1-replica-set.yaml`

Ce manifest décrit un ReplicaSet

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: kuard-rs # Nom du ReplicaSet
spec:
  replicas: 3 # Nombre de replicas à maintenir
  selector:
    matchLabels:
      app: kuard # Selecteur utilisé pour se lier aux pods qui respectent la condition
  template: # Template du pod à créer
    metadata:
      labels:
        app: kuard
    spec:
      containers:
        - name: kuard
          image: gcr.io/kuar-demo/kuard-amd64:blue
          #        image: gcr.io/kuar-demo/kuard-amd64:purple
          ports:
            - containerPort: 8080
```

## Etapes à suivre:

- `kubectl apply -f 1-replica-set.yaml` : Soumettre le manifest pour créer le ReplicaSet
- `kubectl get rs` : Récuperer la liste des ReplicaSets
- `kubectl describe rs kuard-rs` : Avoir des détails sur le ReplicaSet
- `kubectl get pods -w` : Afficher les pods en temps réel
- `kubectl scale --replicas=5 rs kuard-rs` : Augmenter le nombre de replicas
- `kubectl delete pod kuard-rs-<valeur random>`: Supprimer un pod. Le ReplicaSet va en recréer un autre
- Décommenter la ligne 18 et commenter la ligne 17 pour modifier la version de l'image puis `kubectl apply -f 1-replica-set.yaml`
- La version des pods ne va pas se mettre à jour automatiquement. Il faut supprimer les pods pour que le ReplicaSet recréé des pods avec la nouvelle version. `kubectl delete pod -l app=kuard`

# Deployment: `2-deployment.yaml`

ce manifest décrit un Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kuard-deploy # Nom du Deployment
spec:
  replicas: 3 # Nombre de replicas à maintenir
  selector:
    matchLabels:
      app: kuard # Selecteur utilisé pour se lier aux pods qui respectent la condition
  template: # Template du pod à créer
    metadata:
      labels:
        app: kuard
    spec:
      containers:
        - name: kuard
          image: gcr.io/kuar-demo/kuard-amd64:blue
          # image: gcr.io/kuar-demo/kuard-amd64:purple
          ports:
            - containerPort: 8080
```

## Etapes à suivre:

- `kubectl apply -f 2-deployment.yaml` : Soumettre le manifest pour créer le Deployment
- `kubectl get deploy` : Lister les Deployments
- `kubectl get rs` : Lister les ReplicaSets => 1 Deployment crée automatiquement un ReplicaSet pour gérer ses replicas
- `kubectl get pods -w` : Lister les Pods
- Décommenter la ligne 18 et commenter la ligne 17 pour modifier la version de l'image puis `kubectl apply -f 2-deployment.yaml`
- `kubectl get rs` : Lister les ReplicaSet. On remarque que l'ancien ReplicaSet n'est pas supprimé.
- Décommenter la ligne 17 et commenter la ligne 18 pour revenir à la version précédente de l'image puis `kubectl apply -f 2-deployment.yaml`
- `kubectl get rs` : Le deployment va utiliser le ReplicaSet précédent
- `kubectl rollout history deploy kuard-deploy` : Afficher l'historique des changements effectués au deployment
- `kubectl rollout history deploy kuard-deploy --revision=X` : Afficher des détails sur la révision X
- `kubectl rollout undo deploy kuard-deploy` : Revenir en arrière d'une révision pour annuler le dernier changement effectué
