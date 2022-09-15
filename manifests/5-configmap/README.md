# ConfigMap Simple: `1-simple-configmap.yaml`

Ce manifest décrit une configmap le plus simplement possible.

```yaml
apiVersion: v1
kind: ConfigMap # Type de la resource
metadata:
  name: simple-configmap # Nom de la configmap
data: # Données sous format clé-valeur
  another-param: another-value
  extra-param: extra-value
  my-config.txt: | # Données au format fichier
    parameter1 = value1
    parameter2 = value2
```

## Etapes à suivre:

- `kubectl apply -f 1-simple-configmap.yaml` : Soumettre le manifest pour créer la configmap
- `kubectl get configmaps` : Voir la liste des pods disponible dans le namespace actuel
- `kubectl describe configmap simple-configmap` : Voir les détails / les données de la configmap

# Pod avec une configmap montée dans le système de fichier: `2-pod-with-volume-configmap.yaml`

Ce manifest décrit un pod dans lequel on vient monter un volume qui contient les données d'une configmap

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kuard-configmap-volume
spec:
  containers:
    - name: kuard-with-volume-config
      image: gcr.io/kuar-demo/kuard-amd64:blue
      volumeMounts: # Point de montage des données de la configmap
        - name: config-volume # Volume à monter
          mountPath: /config # Chemin de montage
  volumes:
    - name: config-volume # Nom du volume
      configMap:
        name: simple-configmap # Nom de la configmap
```

## Etapes à suivre:

- `kubectl apply -f 2-pod-with-volume-configmap.yaml` : Soumettre le manifest pour créer le pod
- `kubectl get pods` : Voir la liste des pods disponible dans le namespace actuel
- `kubectl describe pod kuard-configmap-volume` : Avoir des détails sur le pod (Voir le volume configmap monté)
- `kubectl port-forward kuard-configmap-volume 8080:8080`: Avoir acces au pod en localhost
- Dans la GUI de Kuard, vérifier dans le système de fichier du conteneur que la configmap est bien montée dans le chemin `/config`

# Pod avec une configmap exposée en variables d'environment: `3-pod-with-env-configmap.yaml`

Ce manifest décrit un pod dans lequel on expose les données d'une configmap dans des variables d'environment

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kuard-configmap-env
spec:
  containers:
    - name: kuard-with-env-config
      image: gcr.io/kuar-demo/kuard-amd64:blue
      env: # Définition de variables d'environment
        - name: ANOTHER_PARAM # Nom de la variable d'environment
          valueFrom: # Source de la valeur de la variable
            configMapKeyRef:
              name: simple-configmap # Nom de la configmap
              key: another-param # Clé de la configmap
        - name: EXTRA_PARAM
          valueFrom:
            configMapKeyRef:
              name: simple-configmap
              key: extra-param
```

## Etapes à suivre:

- `kubectl apply -f 3-pod-with-env-configmap.yaml` : Soumettre le manifest pour créer le pod
- `kubectl get pods` : Voir la liste des pods disponible dans le namespace actuel
- `kubectl describe pod kuard-configmap-env` : Avoir des détails sur le pod (Voir les variables d'environment exposées)
- `kubectl port-forward kuard-configmap-env 8080:8080`: Avoir acces au pod en localhost
- Dans la GUI de Kuard, vérifier dans les variables d'environment définies: `ANOTHER_PARAM` et `EXTRA_PARAM` sont bien présentes

# Pod avec une configmap passée en arguments: `4-pod-with-cli-configmap.yaml`

Ce manifest décrit un pod dans lequel on passe les données d'une configmap comme argument à l'executable dans le conteneur

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kuard-configmap-cli
spec:
  containers:
    - name: kuard-with-cli-config
      image: gcr.io/kuar-demo/kuard-amd64:blue
      command: # Le point d'entrée du conteneur. (Commande finale: /kuard extra-value)
        - "/kuard"
        - "$(EXTRA_PARAM)" # Substitution de la valeur de la variable d'environment EXTRA_PARAM
      env:
        - name: ANOTHER_PARAM
          valueFrom:
            configMapKeyRef:
              name: simple-configmap
              key: another-param
        - name: EXTRA_PARAM
          valueFrom:
            configMapKeyRef:
              name: simple-configmap
              key: extra-param
```

## Etapes à suivre:

- `kubectl apply -f 4-pod-with-cli-configmap.yaml` : Soumettre le manifest pour créer le pod
- `kubectl get pods` : Voir la liste des pods disponible dans le namespace actuel
- `kubectl describe pod kuard-configmap-cli` : Avoir des détails sur le pod (Voir les variables d'environment exposées et la commande)
- `kubectl port-forward kuard-configmap-cli 8080:8080`: Avoir acces au pod en localhost
- Dans la GUI de Kuard, vérifier dans les variables d'environment définies: `ANOTHER_PARAM` et `EXTRA_PARAM` sont bien présentes et que la valeur est bien passée en argument à l'executable (`/kuard extra-value`)
