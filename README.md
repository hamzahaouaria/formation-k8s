<div align="center">
  <img src="./logo.png" width="200">
</div>
<br>
<div align="center">

# Formation Kubernetes

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/AhmedMoalla/formation-k8s)

</div>

# Intro

La conteneurisation dans un contexte d'architecture distribuée a plusieurs avantages mais impose plusieurs contraintes. Un système d'orchestration de conteneur nous permet de gérer les problématiques posées par de tels systèmes.

Au cours de cette formation, nous découvrirons l'orchestrateur de conteneurs : **Kubernetes**.

# Les élément de la présentation

## Slides

Retrouvez les slides ici []()

## Le code

2 dossiers sont présents et sont définis comme suit:

- `cluster-setup` : Contient les fichiers Terraform nécessaire pour créer le cluster utilisé au cours du workshop sur Azure. Sous ce dossier il y a ce qui suit:
  - `terraform` : Dossier contenant les fichiers .tf
  - `setup_cluster.sh` : Script à lancer pour créer le cluster et configurer les roles / kubeconfig pour les utilisateurs
  - `destroy_cluster.sh` : Script à lancer pour détruire le cluster
  - `functions.sh` : Script contenant les fonctions utilisées par `setup_cluster.sh`
  - `users.txt` : Liste des emails Novencia des participants
- `manifests` : Contient les manifests yaml à utiliser pour le workshop

## Resources List

- [Kubernetes in Action - Oreilly](https://learning.oreilly.com/library/view/kubernetes-in-action/9781617293726/)
- [Kubernetes: Up and Running, 3rd Edition - Oreilly](https://learning.oreilly.com/library/view/kubernetes-up-and/9781098110192/)
- [Kubernetes RBAC - Stéphane ROBERT](https://blog.stephane-robert.info/post/kubernetes-gestion-access-rbac/)
- [Azure Provider - Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/3.0.2)
- [Complete Terraform Course - DevOps Directive](https://www.youtube.com/watch?v=7xngnjfIlK4)
- [API Reference Docs - Kubernetes](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/)
- [Demo application for "Kubernetes Up and Running" - Github](https://github.com/kubernetes-up-and-running/kuard)
