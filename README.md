<div align="center">
  <img src="./logo.png" width="200">
</div>
<br>
<div align="center">

# Entre Dev #3: Kubernetes

</div>

# Intro

La conteneurisation dans un contexte d'architecture distribuée a plusieurs avantages mais impose plusieurs contraintes. Un système d'orchestration de conteneur nous permet de gérer les problématiques posées par de tels systèmes.

Au cours de cet EntreDev, nous découvrirons l'orchestrateur de conteneurs : **Kubernetes**.

# Les élément de la présentation

## Video Replay

Vous trouvez le lien du replay sur ce [lien](https://novenciagroupe.sharepoint.com/sites/SkillCenterLentredev/Documents%20partages/General/Recordings/R%C3%A9union%20dans%20%C2%AB%C2%A0G%C3%A9n%C3%A9ral%C2%A0%C2%BB-20220331_183516-Meeting%20Recording.mp4?web=1)

## Slides

Retrouvez les slides ici [EntreDev3-Kubernetes.pptx](./EntreDev3-Kubernetes.pptx)

## Le code

3 dossiers sont présents et sont définis comme suit:

- `cluster-setup` : Contient les fichiers Terraform nécessaire pour créer le cluster utilisé au cours du workshop sur Azure. Sous ce dossier il y a ce qui suit:
  - `terraform` : Dossier contenant les fichiers .tf
  - `setup_cluster.sh` : Script à lancer pour créer le cluster et configurer les roles / kubeconfig pour les utilisateurs
  - `destroy_cluster.sh` : Script à lancer pour détruire le cluster
  - `functions.sh` : Script contenant les fonctions utilisées par `setup_cluster.sh`
  - `users.txt` : Liste des emails Novencia des participants
- `manifests` : Contient les manifests yaml à utiliser pour le workshop
- `setup` : Contient des scripts utilisable par les participants pour installer `kubectl` et les identifiants pour se connecter au cluster. Contient les scripts suivants:

  - `setup.sh` : à utiliser dans un environment **Linux**
  - `setup_git_bash.sh` : à utiliser dans un environment **Git Bash** sous Windows
  - `setup.bat` : à utiliser dans un environment **Windows**
  - `setup.ps1` : à utiliser dans un environment **PowerShell** sous Windows

  > Utilisation: `setup.sh prenom-nom` Exemple: `setup.sh ahmed-moalla`

## Resources List

- [Kubernetes in Action - Oreilly](https://learning.oreilly.com/library/view/kubernetes-in-action/9781617293726/)
- [Kubernetes: Up and Running, 3rd Edition - Oreilly](https://learning.oreilly.com/library/view/kubernetes-up-and/9781098110192/)
- [Kubernetes RBAC - Stéphane ROBERT](https://blog.stephane-robert.info/post/kubernetes-gestion-access-rbac/)
- [Azure Provider - Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/3.0.2)
- [Complete Terraform Course - DevOps Directive](https://www.youtube.com/watch?v=7xngnjfIlK4)
- [API Reference Docs - Kubernetes](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/)
- [Demo application for "Kubernetes Up and Running" - Github](https://github.com/kubernetes-up-and-running/kuard)
