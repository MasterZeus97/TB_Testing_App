# TB_Testing_App
Voici les 3 apps que j'ai préparer afin de pouvoir tester le fonctionnement en arrière-plan des librairies que je propose d'utiliser pour l'application de la Roue Qui Marche.

## Installation

Tous les projets dans ce repo utilisent Flutter, il est donc nécessaire d'installer les instruments nécessaires.

### Android

Pour installer sur un appareil fonctionnant sous windows :

[Installer Flutter pour windows](https://docs.flutter.dev/get-started/install/windows/desktop)

A noter qu'il n'est pas possible de compiler sur iOS depuis Windows.

Il faut ensuite installer les plugins Dart et Flutter sur AndroidStudio, sous File -> Settings -> Plugins

Une fois cela fait, à la racine du projet, faire

```
flutter pub get
```

Il devrait normalement être possible de compiler le projet sur un appareil physique tournant sous android.

### iOS

Pour la partie iOS il ne sera pas fait mension des préparatifs pour pouvoir utiliser xcode afin de faire tourner un programme sur un smartphone.

Pour installer Flutter sur macOS :

[Installer Flutter pour macOS](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=download)

Une fois flutter installé, et xcode fonctionnel, ouvrir une console de commande, et aller à la racine du projet. lancer ensuite cette commande :
```
flutter clean && flutter pub get && cd ios/ && pod install
```
Une fois cela fait, ouvrir le dossier ios du projet dans l'explorateur de fichier, et double cliquer sur le fichier `Runner.xcworkspace`. Cela devrait ouvrir xcode, duquel il est alors possible de lanccer le projet sur un smartphnoe ou un emulateur.


## Utilisation des logiciels de tests

### TestingLocation & TestingGeolocator
Pour ces deux app, l'objectif est de lancer la géolocalisation en appuyant sur le bouton play.

 ### testing_background_location
 Pour cette app, presser Start Location Service

Au boout d'un moment, une notification devrait apparaître sur androd, et un logo sur iOS. Ces deux indication montrent que la géolocalisation en arrière-plan est bien activée. Une fois que ces indicateurs sont apparus, réduire l'app (NE PAS LA FERMER EN LA SLIDANT, juste changer d'app active) et continuer la journée.
En fin de journée ou lorsque l'indicateur a disparu, retourner sur l'app et presser le bouton stop. Une fois cela fait, envoyer le mail contenant le fichier de données collectées, soit en pressaant l'icone lettre, soit en pressant le bouton send email.

Si des information supplémentaires vous semble utiles, ajoutez-les au corps du mail avant d'envoyer.


## Remarque pour iOS
L'envoi de mail, que ce soit android ou iOS, se fait via une autre app sur le téléphone. Je n'ai pas eu le temps ou la possibilité de tester l'envoi de mail avec un autre logiciel que l'app mail par défaut d'iOS. Si, lorsque vous pressez le bouton pour envoyer un email, rien ne se passe, cela vient peut-être de cela. Essayez d'installer7réinstaller cette application mail de base.
Il est aussi très important qu'une adresse mail soit configurée sur cette application mail de base. Personnellement, j'ai fait mes essais avec une adresse gmail personnelle, et cela fonctionnait bien.
