/*import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'location_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Geolocation in the background'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _locationClient = LocationClient();
  final _points = <LatLng>[];
  LatLng _currPosition = const LatLng(-1000, -1000);
  bool _isServiceRunning = false;
  int _myDistance = 0;

  @override
  void initState() {
    super.initState();
    _locationClient.init();
    _listenLocation();
    Timer.periodic(const Duration(seconds: 3), (_) => _listenLocation());
  }

  void _listenLocation() async {
    if (!_isServiceRunning && await _locationClient.isServiceEnabled()) {
      _isServiceRunning = true;
      _locationClient.locationStream.listen((event) {
        _myDistance = mp.SphericalUtil.computeDistanceBetween(
            mp.LatLng(_currPosition.latitude, _currPosition.longitude),
            mp.LatLng(event.latitude, event.longitude)
        ).truncate();
        setState(() {
          _currPosition = event;
        });
        //_points.add(_currPosition!);
      });
    } else {
      _isServiceRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title)
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your current pos is :',
            ),
            Text(
              '$_currPosition',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'Your total distance is :',
            ),
            Text(
              '$_myDistance',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
*/





import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'location_client.dart';
import 'file_treatment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(title: 'Testing app for Location package', storage: CounterStorage())
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
  final _locationClient = LocationClient();
  final _points = <LatLng>[];
  LatLng _from = LatLng(-1000, -1000);
  StreamSubscription<LatLng>? _locationSubscription;
  LatLng? _currPosition;
  LatLng _currStreamPos = const LatLng(-1000, -1000);
  bool _isServiceRunning = false;
  int _distance = 0;
  int _myDistance = 0;
  int _myDistStream = 0;
  int _pointsDistance = 0;
  int _pointsD = 0;

  Icon _icon = const Icon(Icons.play_arrow);

  @override
  void initState() {
    super.initState();
    _locationClient.init();
  }

  void _toggleListenning(){
    _locationClient.toggleBackgroundMode();

    if (_isServiceRunning){
      log("Bla");
      _locationSubscription?.cancel();
      _isServiceRunning = false;
      widget.storage.writeStopMeasure();
      setState(() {
          _icon = const Icon(Icons.play_arrow);
      });
    }else {
      log("Blo");
      _locationSubscription?.resume();
      widget.storage.writeStartMeasure();
      addSubscription();
      _isServiceRunning = true;
      setState(() {
        _icon = const Icon(Icons.stop);
      });
    }
  }

  void addSubscription(){
    if(_locationSubscription != null){
      _locationSubscription?.pause();
      return;
    }
    _locationSubscription = _locationClient.locationStream.listen((event) {
      int distance = 0;
      if (_from.longitude != -1000 && _from.latitude != -1000){
        _distance = mp.SphericalUtil.computeDistanceBetween(
            mp.LatLng(_from.latitude, _from.longitude),
            mp.LatLng(event.latitude, event.longitude)
        ).truncate();
      }
      _from = event;
      log("data measured: ${event.latitude}, ${event.longitude}");
      log("from: ${_from.latitude}, ${_from.longitude}");
      log("distance: $_distance");
      log("myDistance: $_myDistance");
      log("-----------------------------------------------------------");
      widget.storage.writeLatLong(event.latitude, event.longitude, _distance);
      setState(() {
        _currPosition = event;
        _myDistance += _distance;
        //_pointsDistance = _pointsD;
      });
      //_points.add(_currPosition!);
    });
    //_locationSubscription?.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title)
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your distance is :',
            ),
            Text(
              '$_distance',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'Your total distance is :',
            ),
            Text(
              '$_myDistance',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /*FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.location_on),
            ),*/
            FloatingActionButton(
                onPressed: _toggleListenning,
                tooltip: 'Toggle listening',
                child: _icon//Icon(Icons.play_arrow),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _distance = 0;
                  _myDistance = 0;
                  _points.clear();
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
        )

    );
  }
}
