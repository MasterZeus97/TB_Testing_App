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

Pour iOS, il faut également installer Flutter :

[Installer Flutter pour macOS](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=download)