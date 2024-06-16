import 'dart:async';
import 'dart:developer';

import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationClient {
  final Location _location = Location();
  PermissionStatus _permissionStatus = PermissionStatus.denied;

//  StreamSubscription<LocationData> _locationSubscription =

  Stream<LatLng> get locationStream =>
      _location.onLocationChanged.map((event) => LatLng(event.latitude!, event.longitude!));

  void init() async {
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      await _location.requestService();
    }
    _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
    }

  }

  void toggleBackgroundMode() async {
    if (await _location.isBackgroundModeEnabled()) {
      log("toggleBackgroundMode: false");
      await _location.enableBackgroundMode(enable: false);
    } else {
      log("toggleBackgroundMode: true");
      if (_permissionStatus == PermissionStatus.granted) {
        log("toggleBackgroundMode: granted");
        await _location.enableBackgroundMode();
        await _location.changeNotificationOptions(
          title: 'Geolocation',
          subtitle: 'Geolocation detection',
        );
      }
    }
  }

  Future<bool> isServiceEnabled() async {
    return _location.serviceEnabled();
  }
}
