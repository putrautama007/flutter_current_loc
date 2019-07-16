import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      builder: (context) => LocationService().locationStream,
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
            body: HomeView(),
          )),
    );
  }
}

class LocationService {
  UserLocation _currentLocation;
  var location = Location();
  Position position = Position();

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();

      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    return _currentLocation;
  }

  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {
    location.requestPermission().then((granted) {
      if (granted) {
        location.onLocationChanged().listen((locationData) async {
          List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(locationData.latitude, locationData.longitude);
          if (locationData != null) {
            _locationController.add(UserLocation(
                latitude: locationData.latitude,
                longitude: locationData.longitude,
                address: "${placemark[0].thoroughfare} ${placemark[0].subThoroughfare},${placemark[0].subLocality},${placemark[0].locality},${placemark[0].subAdministrativeArea},${placemark[0].administrativeArea} ${placemark[0].postalCode},${placemark[0].country}"
            ));
          }
        });
      }
    });
  }
}

class UserLocation {
  final double latitude;
  final double longitude;
  final String address;

  UserLocation({this.latitude, this.longitude, this.address});
}

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userLocation = Provider.of<UserLocation>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(
              'Location: Lat${userLocation?.latitude}, Long: ${userLocation?.longitude}'),
        ),
        Center(
          child: Text(' address : ${userLocation?.address}'),
        )
      ],
    );
  }
}
