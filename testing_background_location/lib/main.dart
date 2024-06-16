import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:background_location/background_location.dart';
import 'package:flutter_testing_2/file_treatment.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

void main() => runApp(MyApp());

//----------------------------------------------------------------------------------------------

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
  State<MyHomePage> createState() => _MyAppState();
}

//----------------------------------------------------------------------------------------------
/*class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}*/

class _MyAppState extends State<MyHomePage> {
  int distance = 0;
  int distanceSinceLast = 0;
  bool? serviceRunning = null;

  int _distance = 0;
  int _distanceSinceLast = 0;
  mp.LatLng _from = mp.LatLng(0, 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Location Service'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              locationData('Distance since last: $distanceSinceLast'),
              locationData('Distance: $distance'),
              ElevatedButton(
                  onPressed: () async {
                    await BackgroundLocation.setAndroidNotification(
                      title: 'Background service is running',
                      message: 'Background location in progress',
                      icon: '@mipmap/ic_launcher',
                    );
                    //await BackgroundLocation.setAndroidConfiguration(1000);
                    await BackgroundLocation.startLocationService();
                    var firstLocation = await BackgroundLocation().getCurrentLocation();
                    /*BackgroundLocation().getCurrentLocation().then((location) {
                      _from = mp.LatLng(location.latitude!, location.longitude!);
                    });
*/
                    log("First Location: $firstLocation");
                    _from = mp.LatLng(firstLocation.latitude!, firstLocation.longitude!);

                    widget.storage.writeStartMeasure();

                    BackgroundLocation.getLocationUpdates((location) {
                      log('Listened Location: $location');

                      _distanceSinceLast = mp.SphericalUtil.computeDistanceBetween(
                          _from, mp.LatLng(location.latitude!, location.longitude!)).truncate();

                      _distance += _distanceSinceLast;

                      var tmp = mp.SphericalUtil.computeDistanceBetween(
                          _from, mp.LatLng(location.latitude!, location.longitude!)).truncate();

                      _from = mp.LatLng(location.latitude!, location.longitude!);
                      log ('Distance: $_distance');
                      log('_from: $_from');
                      log('tmp: $tmp');

                      widget.storage.writeLatLong(location.latitude!, location.longitude!, tmp);

                      setState(() {
                        distance = _distance;
                        distanceSinceLast = _distanceSinceLast;
                      });
                    });
                  },
                  child: Text('Start Location Service')),
              ElevatedButton(
                  onPressed: () {
                    BackgroundLocation.stopLocationService();

                    widget.storage.writeStopMeasure();
                  },
                  child: Text('Stop Location Service')),
              const SizedBox(height: 200,),
              ElevatedButton(
                  onPressed: widget.storage.sendEmail,
                  child: Text('Send Email')),
            ],
          ),
        ),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  void getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      print('This is current Location ' + location.toMap().toString());
    });
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}