import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/user_provider.dart';

class MyRequestLocation extends ConsumerStatefulWidget {
  const MyRequestLocation({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MyRequestLocation> createState() => _MyRequestLocation();
}

class _MyRequestLocation extends ConsumerState<MyRequestLocation> {
  bool firstLoad = true;

  @override
  void didChangeDependencies() {
    //getPermissions();
    ref.watch(userProvider).getPermissions().then((value) {
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
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 10),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    lat = ref.watch(requestLatLngProvider)?.latitude;
    lng = ref.watch(requestLatLngProvider)?.longitude;

    return Container(
      height: 300,
      width: 300,
      child: Stack(
        children: [
          if (currentUserLocation == null) const CircularProgressIndicator(),
          if (currentUserLocation != null)
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: currentUserLocation!, zoom: 12),
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
                        zoom: 12)));
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
                    ? ref.read(requestLatLngProvider.notifier).state = _latLng
                    : ref.read(requestLatLngProvider.notifier).state =
                        LatLng(lat!, lng!);
                Navigator.pushNamed(
                    context, '/ClientRequestLocationSelectionScreen');
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
          // Floating action button to allow user to switch to bigger map when entering location of request.
        ],
      ),
    );
  }
}
