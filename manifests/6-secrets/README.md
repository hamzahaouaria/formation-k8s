# Pod avec un secret contenant un certificat TLS: `1-pod-with-secret.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kuard-with-tls
spec:
  containers:
    - name: kuard-with-tls
      image: gcr.io/kuar-demo/kuard-amd64:blue
      volumeMounts: # Point de montage des données du secret
      - name: tls-certs # Nom du volume
        mountPath: "/tls" # Chemin de montage
  volumes:
    - name: tls-certs # Nom du volume
      secret:
        secretName: kuard-tls # Nom du secret
```

## Etapes à suivre:

- `kubectl create secret generic kuard-tls --from-file=kuard.crt --from-file=kuard.key` : Créer un secret à partir des fichiers `kuard.crt` et `kuard.key`
- `kubectl describe secrets kuard-tls` : Voir une description du secret
- `kubectl get secret kuard-tls -o yaml` : Voir le contenu du secret au format yaml (Decoder la valeur depuis la base64)
- `kubectl apply -f 1-pod-with-secret.yaml`: Soumettre le manifest pour créer le pod
- `kubectl describe pod kuard-with-tls`: Avoir des détails sur le pod (Voir le volume du secret monté)
- `kubectl logs kuard-with-tls`: Voir que le pod écoute sur le port 8443 pour le traffic HTTPS
- `kubectl port-forward kuard-tls 8443:8443`: Tester que le pod supporte HTTPS (Ne fonctionne pas sur Gitpod car il ne supporte que HTTP => Tester en local)