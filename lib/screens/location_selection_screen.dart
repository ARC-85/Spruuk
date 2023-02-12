import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:spruuk/providers/project_provider.dart';

class LocationSelectionScreen extends ConsumerStatefulWidget {
  static const routeName = '/LocationSelectionScreen';
  const LocationSelectionScreen({
    Key? key,
    this.projectLocationLatProvider,
    this.projectLocationLngProvider,
  }) : super(key: key);
  final StateProvider<double?>? projectLocationLatProvider;
  final StateProvider<double?>? projectLocationLngProvider;

  @override
  ConsumerState<LocationSelectionScreen> createState() =>
      _LocationSelectionScreen();
}

class _LocationSelectionScreen extends ConsumerState<LocationSelectionScreen> {
  bool firstLoad = true;

  @override
  Future<void> didChangeDependencies() async {
    if (firstLoad = true) {
      _locationData = await location.getLocation();

      setState(() {
        getPermissions();
        lat = _locationData?.latitude;
        lng = _locationData?.longitude;
      });
    }
    firstLoad = false;
    super.didChangeDependencies();
  }

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  GoogleMapController? _controller;
  Location _location = Location();
  double? lat;
  double? lng;

  Location location = new Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  // Setting up the map, taken from https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6
  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      //lat = l.latitude;
      //lng = l.longitude;
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          lat == null
              ? CameraPosition(
                  target: LatLng(l.latitude!, l.longitude!), zoom: 15)
              : CameraPosition(target: LatLng(lat!, lng!), zoom: 15),
        ),
      );
    });
  }

  Future<void> getPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getPermissions();
    lat = ref.watch(projectLatLngProvider)?.latitude;
    lng = ref.watch(projectLatLngProvider)?.longitude;
    final screenDimensions = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text("Location Selection"), actions: [
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.cancel,
              size: 25,
            )),
      ]),
      body: SafeArea(
          child: SizedBox(
        height: screenDimensions.height,
        width: screenDimensions.width,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialcameraposition),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              markers: <Marker>{
                // taken from https://stackoverflow.com/questions/55003179/flutter-drag-marker-and-get-new-position
                Marker(
                    onTap: () {
                      print('Tapped');
                    },
                    draggable: true,
                    markerId: MarkerId('Marker'),
                    position:
                        lat != null ? LatLng(lat!, lng!) : const LatLng(0, 0),
                    onDragEnd: ((newPosition) {
                      lat = newPosition.latitude;
                      lng = newPosition.longitude;
                      ref.read(projectLatLngProvider!.notifier).state =
                          newPosition;
                      print(newPosition.latitude);
                      print(newPosition.longitude);
                    }))
              },
            ),
          ],
        ),
      )),
    );
  }

  Future<void> moveMapCamera(double lat, double lng) async {
    CameraPosition nepPos = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 5,
    );

    final GoogleMapController? controller = await _controller;
    controller?.animateCamera(CameraUpdate.newCameraPosition(nepPos));
  }
}
