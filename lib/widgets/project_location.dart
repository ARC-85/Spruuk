import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/text_label.dart';

class MyProjectLocation extends ConsumerStatefulWidget {
  const MyProjectLocation({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MyProjectLocation> createState() => _MyProjectLocation();
}

class _MyProjectLocation extends ConsumerState<MyProjectLocation> {
  bool firstLoad = true;

  @override
  void didChangeDependencies() {
    //getPermissions();
    ref.watch(userProvider).getPermissions()
    .then((value) {
      setState(() {
        currentUserLocation = value;
      });
    });

    super.didChangeDependencies();
  }

  final LatLng _initialCameraPosition =
      LatLng(53.37466222698207, -9.1528495028615);
  GoogleMapController? _controller;
  Location _location = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  Location location = new Location();

  bool? showMapButton = true;

  double? lat;
  double? lng;

  LatLng? currentUserLocation;

  // Setting up the map, taken from https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6
  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
        ),
      );
    });
  }

  /*Future<void> getPermissions() async {
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
    _locationData = await location.getLocation();
  }*/

  LatLng? initialCamera() {

    if(currentUserLocation != null) {
      return currentUserLocation;
    } else {
      return const LatLng(53.37466222698207, -9.1528495028615);
    }

  }

  @override
  Widget build(BuildContext context) {
    lat = ref.watch(projectLatLngProvider)?.latitude;
    lng = ref.watch(projectLatLngProvider)?.longitude;
    //currentUserLocation = ref.watch(userProvider).currentUserLocation;

    return Container(
      height: 300,
      width: 300,
      child: Stack(
        children: [
          if(currentUserLocation ==null)
          const CircularProgressIndicator(),
          if(currentUserLocation !=null)
          GoogleMap(
            /*initialCameraPosition: CameraPosition(
                target: _locationData != null
                    ? LatLng(
                        _locationData!.latitude!, _locationData!.longitude!)
                    : _initialCameraPosition,
                zoom: 17),*/
            initialCameraPosition:
                CameraPosition(target: currentUserLocation!, zoom: 17 ),
            mapType: MapType.normal,
            // Setting up map, taken from https://www.fluttercampus.com/guide/257/move-google-map-camera-postion-flutter/
            onMapCreated: (controller) {
              setState(() {
                _controller = controller;
              });

            },
            myLocationEnabled: true,
            markers: <Marker>{
              // taken from https://stackoverflow.com/questions/55003179/flutter-drag-marker-and-get-new-position
              Marker(
                onTap: () {
                  //Navigator.pushNamed(context, '/LocationSelectionScreen');
                },
                //draggable: true,
                markerId: MarkerId('Marker'),
                position:
                    lat != null ? LatLng(lat!, lng!) : currentUserLocation!,
              )
            },
          ),
          if (showMapButton != true)
            // Needed to introduce a floating button to take user to current location due to troubles with null values.
            FloatingActionButton(
              onPressed: () {
                LatLng newLatLng = currentUserLocation!;
                print(newLatLng);
                _controller?.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: lat != null ? LatLng(lat!, lng!) : newLatLng,
                        zoom: 17)));
                setState(() {
                  showMapButton = true;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor:
                  const Color.fromRGBO(242, 151, 101, 1).withOpacity(1),
              child: const Icon(
                Icons.location_on_outlined,
              ),
            ),
          if (showMapButton != false)
            FloatingActionButton(
              onPressed: () {
                // Provider is initialised to prevent no marker appearing on location screen, i.e. if lat/lng are still null.
                LatLng _latLng = currentUserLocation!;
                lat == null
                    ? ref.read(projectLatLngProvider.notifier).state = _latLng
                    : ref.read(projectLatLngProvider.notifier).state =
                        LatLng(lat!, lng!);
                Navigator.pushNamed(context, '/LocationSelectionScreen');
                print("this is location data $_locationData");
                setState(() {
                  showMapButton = false;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor:
                  const Color.fromRGBO(242, 151, 101, 1).withOpacity(1),
              child: const Icon(
                Icons.map_outlined,
              ),
            ),
          // Floating action button to allow user to switch to bigger map when entering location of project.
        ],
      ),
    );
  }
}
