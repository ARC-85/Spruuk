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
import 'package:spruuk/widgets/text_label.dart';

class MyProjectLocationSpare extends ConsumerStatefulWidget {
  const MyProjectLocationSpare({
    Key? key,
    this.projectLocationLatProvider,
    this.projectLocationLngProvider,
  }) : super(key: key);
  final StateProvider<double?>? projectLocationLatProvider;
  final StateProvider<double?>? projectLocationLngProvider;

  @override
  ConsumerState<MyProjectLocationSpare> createState() => _MyProjectLocationSpare();
}

class _MyProjectLocationSpare extends ConsumerState<MyProjectLocationSpare> {
  bool firstLoad = true;

  @override
  void didChangeDependencies() {

    setState(() {
      getUserLocation();
      getPermissions();
      if(_locationData != null) {
        lat = _locationData?.latitude;
        lng = _locationData?.longitude;}


      print("setting state");
    });
    /*if (firstLoad = true) {
      setState(() {
        getPermissions();
      });
    }
    firstLoad = false;*/
    super.didChangeDependencies();
  }

  LatLng _initialcameraposition = LatLng(53.37466222698207, -9.1528495028615);
  GoogleMapController? _controller;

  double? lat;
  double? lng;

  Location location = Location();
  Location _location = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  String? _error;

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

  /*void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    //lat = l.latitude;
    //lng = l.longitude;
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat!, lng!), zoom: 15),
      ),
    );
  }*/

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

  Future<void> getUserLocation() async {
    print("getUserLocation run");
    setState(() {
      _error = null;
    });

    try {
      final _locationResult = await location.getLocation();
      setState(() {
        _locationData = _locationResult;
      });
    }
    on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    getPermissions();
    getUserLocation();
    lat = ref.watch(projectLatLngProvider)?.latitude;
    lng = ref.watch(projectLatLngProvider)?.longitude;

    return Container(
      height: 300,
      width: 300,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: _initialcameraposition, zoom: 10),
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

              )
            },
          ),
          // Floating action button to allow user to switch to bigger map when entering location of project.
          FloatingActionButton(
            onPressed: () {
              // Provider is initialised to prevent no marker appearing on location screen, i.e. if lat/lng are still null.
              LatLng _latLng = _locationData != null ?
              LatLng(_locationData!.latitude!, _locationData!.longitude!) : const LatLng(53.37466222698207, -9.1528495028615);
              lat == null
                  ? ref.read(projectLatLngProvider.notifier).state = _latLng
                  : ref.read(projectLatLngProvider.notifier).state =
                  LatLng(lat!, lng!);
              Navigator.pushNamed(context, '/LocationSelectionScreen');
              print("this is location data $_locationData");
              //getUserLocation();
              //getPermissions();
              //print("location data $_locationData");
              lat = _locationData?.latitude;
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor:
            const Color.fromRGBO(242, 151, 101, 1).withOpacity(1),
            child: const Icon(
              Icons.map_outlined,
            ),
          ),
          /*Positioned(
            top: 55,
            left: -30,
            child: MyTextLabel(
              textLabel: "Lat: $lat",
              color: null,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              )),)*/
        ],
      ),
    );


  }


}
