import 'dart:convert';

import 'package:favorite_places/model/places.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class Locationinput extends StatefulWidget {
  const Locationinput({super.key, required this.onSelectedLocation});
  final void Function(PlaceLocation location) onSelectedLocation;
  @override
  State<Locationinput> createState() {
    return _LocationinputState();
  }
}

//AIzaSyAt0rMsTlNKGKEGmJ17oYqhOqAOAHyExDc
class _LocationinputState extends State<Locationinput> {
  PlaceLocation? _pickLocation;
  var _gettingLoation = false;

  String get locationImage {
    if (_pickLocation == null) {
      return '';
    }
    final lat = _pickLocation!.latitude;
    final lng = _pickLocation!.longitude;
    const key = 'AIzaSyAt0rMsTlNKGKEGmJ17oYqhOqAOAHyExDc';
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=$key';
  }

  void _savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyAt0rMsTlNKGKEGmJ17oYqhOqAOAHyExDc');
    final respons = await http.get(url);
    final resDate = json.decode(respons.body);
    final address = resDate['results'][0]['formatted_address'];

    setState(() {
      _pickLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _gettingLoation = false;
    });

    widget.onSelectedLocation(_pickLocation!);
  }

  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _gettingLoation = true;
    });
    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) {
      return;
    }
    _savePlace(lat, lng);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(),
      ),
    );
    if (pickedLocation == null) {
      return;
    }
    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget priviewContent = Text(
      'No Location choosen',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );
    if (_pickLocation != null) {
      priviewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_gettingLoation) {
      priviewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
            width: double.infinity,
            height: 170,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: priviewContent),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        )
      ],
    );
  }
}
