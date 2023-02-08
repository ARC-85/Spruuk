import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:spruuk/providers/project_provider.dart';

class MyProjectLocation extends ConsumerStatefulWidget {
  const MyProjectLocation({
    Key? key,
    this.projectLocationLatProvider,
    this.projectLocationLngProvider,
  }) : super(key: key);
  final StateProvider<double?>? projectLocationLatProvider;
  final StateProvider<double?>? projectLocationLngProvider;

  @override
  ConsumerState<MyProjectLocation> createState() => _MyProjectLocation();
}

class _MyProjectLocation extends ConsumerState<MyProjectLocation> {
  bool firstLoad = true;

  @override
  void didChangeDependencies() {
    if (firstLoad = true) {
      setState(() {
        getPermissions();
      });
    }
    firstLoad = false;
    super.didChangeDependencies();
  }
  /*final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);*/

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  GoogleMapController? _controller;

  double? lat;
  double? lng;

  final Location location = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  // Setting up the map, taken from https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6
  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    location.onLocationChanged.listen((l) {
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

    _locationData = await location.getLocation();

  }


  @override
  Widget build(BuildContext context) {
    getPermissions();
    lat = ref.watch(projectLatLngProvider)?.latitude;
    lng = ref.watch(projectLatLngProvider)?.longitude;



    return Container(
      height: 300,
      width: 300,
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
                    //Navigator.pushNamed(context, '/LocationSelectionScreen');
                  },
                  //draggable: true,
                  markerId: MarkerId('Marker'),
                  position: lat != null ? LatLng(lat!, lng!) : const LatLng(0, 0),
                  onDragEnd: ((newPosition) {
                    //lat = newPosition.latitude;
                    //lng = newPosition.longitude;
                    print(newPosition.latitude);
                    print(newPosition.longitude);
                  }))
            },
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/LocationSelectionScreen');
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor:
            const Color.fromRGBO(242, 151, 101, 1).withOpacity(1),
            child: const Icon(
              Icons.map_outlined,
            ),
          )
        ],
      ),
    );

    /*return Container(
        height: 800,
        width: 800,
        child: Stack(children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          /*FloatingActionButton.extended(
            onPressed: _goToTheLake,
            label: const Text('To the lake!'),
            icon: const Icon(Icons.directions_boat),
          )*/
        ]));*/
  }



  /*Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }*/
}
