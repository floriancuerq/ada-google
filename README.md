# Ada sur google cloud platform

## Qu'est ce que c'est ?
Ce script permet de lancer une instance vs code sur votre navigateur avec tous les packages pour développer en ada. Il aide aussi à mettre en place les clés ssh pour github.

## Installation
Créer un compte sur [google cloud platform](https://cloud.google.com/?hl=fr)
Lancer le cloud shell
Cloner le repo puis se rendre dans le dossier et enfin rendre le script exécutable.

```bash
git clone https://github.com/floriancuerq/ada-google.git
cd ada-google
chmod +x code
```
Lancer le script avec comme argument votre adresse mail associé à votre compte github, si vous vous voulez utiliser github dans cette instance de vs code.
```bash
./code test@exemple.com
```

Copier la clé ssh donné dans le script  à l'endroit approprié (plus d'information [ici](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account))

Enfin ouvrir la "web preview" pour accéder à vs code.