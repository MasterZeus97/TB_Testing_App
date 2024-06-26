import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

import 'file_treatment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Testing app for Geolocator', storage: CounterStorage())
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.storage});

  final String title;
  final CounterStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // Variable pour geolocator
  int _distance = 0;
  int _distanceParcouru = 0;
  late geo.Position _oldPos;
  late geo.Position _currentPos;
  final geo.GeolocatorPlatform _geolocatorPlatform = geo.GeolocatorPlatform.instance;
  bool positionStreamStarted = false;
  late StreamSubscription<geo.Position> _positionStream;


  Icon _icon = const Icon(Icons.play_arrow);

  @override
  void initState() {
    super.initState();
    _handlePermission().then((bool hasPermission) {
      if (hasPermission) {
        //_incrementCounter();
      }else{
        setState(() {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Your distance since last measure is :',
              ),
              Text(
                '$_distance',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Text(
                'Your total distance is :',
              ),
              Text(
                '$_distanceParcouru',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),


        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
                onPressed: _toggleListening,
                tooltip: 'Toggle listening',
                child: _icon//Icon(Icons.play_arrow),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _distance = 0;
                  _distanceParcouru = 0;
                });
              },
              tooltip: 'Reset all distances',
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: widget.storage.sendEmail,
              tooltip: 'Send Email',
              child: const Icon(Icons.email),
            ),
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.


    );
  }

  //Testing

  Future<geo.Position> _determinePosition() async {
    return await geo.Geolocator.getCurrentPosition();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return false;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      return false;
    }


    return true;
  }

  void _toggleListening() {
    if (positionStreamStarted) {
      stopListening();
      positionStreamStarted = false;
      setState(() {
        _icon = const Icon(Icons.play_arrow);
      });
    } else {
      startListening();
      positionStreamStarted = true;
      setState(() {
        _icon = const Icon(Icons.stop);
      });
    }
  }

  void stopListening() {
    _positionStream.cancel();
    widget.storage.writeStopMeasure();
  }

  Future<void> startListening() async {
    late geo.LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = geo.AndroidSettings(
          accuracy: geo.LocationAccuracy.high,
          forceLocationManager: true,
          foregroundNotificationConfig: const geo.ForegroundNotificationConfig(
            notificationText:
            "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = geo.AppleSettings(
        accuracy: geo.LocationAccuracy.high,
        activityType: geo.ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 5,
      );
    }


    widget.storage.writeStartMeasure();
    _oldPos = await _determinePosition();

    _positionStream = geo.Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((geo.Position position) {
      log("Entered position stream");
      var tmp = geo.Geolocator.distanceBetween(_oldPos.latitude, _oldPos.longitude, position.latitude, position.longitude).truncate();
      log("Distance: $tmp");
      _oldPos = position;
      //geo.Position(latitude: position.latitude, longitude: position.longitude, timestamp: position.timestamp, accuracy: position.accuracy, altitude: position.altitude, heading: position.heading, speed: position.speed, speedAccuracy: position.speedAccuracy, floor: position.floor, isMocked: position.isMocked, altitudeAccuracy: position.altitudeAccuracy, headingAccuracy: position.headingAccuracy);

      widget.storage.writeLatLong(position.latitude, position.longitude, tmp);

      setState(() {
        _distance = tmp;
        _distanceParcouru += tmp;
      });
    });
  }
}

