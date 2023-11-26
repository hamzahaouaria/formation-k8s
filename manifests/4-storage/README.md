# Pod avec Volume: `1-pod-with-volume.yaml`

Ce manifest décrit un pod avec un volume attaché qui pointe sur un disque azure

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mongo
spec:
  volumes:
    - name: mongodb-data # Nom du Volume à référencer en bas dans volumeMounts
      azureDisk: # Définition du Azure Disk distant
        kind: Managed
        diskName: formationk8sdisk
        diskURI: $USER_DISK_URI
  containers:
    - image: mongo:3.6
      name: mongodb
      volumeMounts: # Définition du point de montage du volume défini plus haut
        - name: mongodb-data
          mountPath: /data/db
```

## Etapes à suivre:

- Voir le disque azure créé dans la GUI de Azure
- `kubectl apply -f 1-pod-with-volume.yaml` : Créer le Pod
- `kubectl describe pod mongo-with-volume`: On remarque que le disque azure est attaché au pod
- `kubectl exec -it mongo-with-volume -- mongo` : Executer le client `mongo` à l'intérieur du pod
- `use test;` : Utiliser la base de données par défaut `test`
- `db.formation.insert({sujet: 'k8s'})` : Insérer des données dans la collection `formation`
- `db.formation.find({})` : Récupérer tout les éléments de la collection `formation`
- `exit` : Pour sortir de l'invite de commande `mongo`
- `kubectl delete pod mongo-with-volume` : Supprimer le pod
- Recréer le pod et refaire les étapes. On remarque que les données ont persisté.

# Pod avec PersistentVolume et PersistentVolumeClaim: `4-pod-with-pvc.yaml`

Ce manifest représente un pod attaché à un PV via un PVC

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: azure-disk-pv
spec:
  capacity:
    storage: 2Gi # Capacité du volume
  accessModes: # Mode d'accès
    - ReadWriteOnce
  azureDisk: # Définition du Azure Disk distant
    kind: Managed
    diskName: formationk8sdisk
    diskURI: $USER_DISK_URI
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
spec:
  accessModes: # Mode d'accès
    - ReadWriteOnce
  resources: # Montant de stockage demandé
    requests:
      storage: 1Gi
  storageClassName: "" # StorageClass forcée à vide pour empêcher l'assignation de celle par défaut
---
apiVersion: v1
kind: Pod
metadata:
  name: mongo-with-pvc
spec:
  volumes:
    - name: mongodb-data
      persistentVolumeClaim: # PVC à utiliser
        claimName: pvc
  containers:
    - image: mongo:3.6
      name: mongodb
      volumeMounts: # Définition du point de montage du PVC défini plus haut
        - name: mongodb-data
          mountPath: /data/db
```

## Etapes à suivre:

- `kubectl apply -f 2-persistent-volume.yaml` : Un **Admin** crée le PV
- `kubectl get pv` : Récupérer la liste des PV
- `kubectl apply -f 3-persistent-volume-claim.yaml` : Créer le PVC
- `kubectl get pvc` : Récupérer la liste des PVC
- `kubectl delete pod mongo-with-volume` : Supprimer le pod d'avant pour libérer le disque
- `kubectl apply -f 4-pod-with-pvc.yaml` : Créer le pod
- `kubectl exec -it mongo-with-pvc -- mongo` : Executer le client `mongo` à l'intérieur du pod
- `db.formation.find({})` : Récupérer tout les éléments de la collection `formation`
- Les données sont là. Cela veut dire que le pod c'est bien attaché au PV via un PVC

# Pod avec StorageClass: `7-pod-with-pvc-storage-class.yaml`

Ce manifest représente un Pod attaché à un volume créé dynamiquement via StorageClass

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azurefile-storage-class
provisioner: kubernetes.io/azure-file # Provisioner utilisé pour crée la resource distante
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=1000
  - gid=1000
parameters:
  skuName: Standard_LRS
allowVolumeExpansion: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-with-storage-class
spec:
  accessModes: # Mode d'accès
    - ReadWriteOnce
  storageClassName: azurefile-storage-class # StorageClass à utiliser pour demander du stockage sur Azure
  resources: # Montant de stockage demandé
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: kuard-with-pvc-storage-class
spec:
  volumes:
    - name: kuard-data
      persistentVolumeClaim: # PVC à utiliser
        claimName: pvc-with-storage-class
  containers:
    - image: gcr.io/kuar-demo/kuard-amd64:blue
      name: kuard-with-storage-class
      volumeMounts: # Définition du point de montage du PVC défini plus haut
        - name: kuard-data
          mountPath: /data
```

## Etapes à suivre:

- `kubectl apply -f 5-storage-class.yaml` : Un **Admin** crée la StorageClass
- `kubectl apply -f 6-pvc-with-storage-class.yaml` : Créer le pvc
- `kubectl get pvc -w` : Attendre que le provisioner crée les resources nécessaires
- `kubectl get pv` : Voir qu'un volume a été automatiquement crée et lié à la pvc
- `kubectl apply -f 7-pod-with-pvc-storage-class.yaml` : Créer le pod
- `kubectl port-forward kuard-with-pvc-storage-class 8080:8080` : Avoir acces au pod en localhost
- Uploader un fichier sur le file share qui correspond au PVC attaché au pod dans la GUI d'Azure. Dans le pod de KUARD, on peut voir le fichier apparaître !
- `kubectl exec -it kuard-with-pvc-storage-class -- sh` : Executer un shell sur le Pod
- `cd /data && echo "From Pod" > test` : Créer un fichier dans le pod et le voir apparaitre dans le file share dans la GUI d'Azure
