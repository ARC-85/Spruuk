import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:spruuk/providers/request_provider.dart';

// Stateful class for screen allowing Client user to select request location
class ClientRequestLocationSelectionScreen extends ConsumerStatefulWidget {
  static const routeName = '/ClientRequestLocationSelectionScreen';
  const ClientRequestLocationSelectionScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ClientRequestLocationSelectionScreen> createState() =>
      _ClientRequestLocationSelectionScreen();
}

class _ClientRequestLocationSelectionScreen
    extends ConsumerState<ClientRequestLocationSelectionScreen> {
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

  GoogleMapController? _controller;

  double? lat;
  double? lng;

  Location location = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  // Setting up the map, taken from https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6
  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    print("on map is called");
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat!, lng!), zoom: 10),
      ),
    );
  }

  // Function for getting permissions to use user's current location
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
    lat = ref.watch(requestLatLngProvider)?.latitude;
    lng = ref.watch(requestLatLngProvider)?.longitude;

    final screenDimensions = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text("Request Location Selection"), actions: [
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
                  CameraPosition(target: LatLng(lat!, lng!), zoom: 10),
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
                      ref.read(requestLatLngProvider!.notifier).state =
                          newPosition;
                      setState(() {
                        _onMapCreated(_controller!);
                      });
                    }))
              },
            ),
          ],
        ),
      )),
    );
  }
}
