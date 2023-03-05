import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';

class ClientFavouriteProjectsMapScreen extends ConsumerStatefulWidget {
  static const routeName = '/ClientFavouriteProjectsMapScreen';
  const ClientFavouriteProjectsMapScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ClientFavouriteProjectsMapScreen> createState() =>
      _ClientFavouriteProjectsMapScreen();
}

class _ClientFavouriteProjectsMapScreen extends ConsumerState<ClientFavouriteProjectsMapScreen> {
  bool firstLoad = true;
  // Bool variables for animation while loading
  bool _isLoading = false;
  UserType? _userType;
  UserModel? currentUser1;
  User? user;
  FirebaseAuthentication? _auth;
  String? userImage;
  List<ProjectModel>? favouriteProjects;
  LatLng? currentUserLocation;
  GoogleMapController? _controller;
  double? lat;
  double? lng;
  Location location = Location();
  Set<Marker>? _markers = {};
  List<LatLng>? _points = [];
  Marker? _marker;
  String? cardProjectId;
  String? cardTitle = "";
  String? cardSubtitle = "";
  String? cardImage;
  int? cardMinPrice;
  int? cardMaxPrice;

  @override
  Future<void> didChangeDependencies() async {
    if (firstLoad = true) {
      _isLoading = true;

      final authData = ref.watch(fireBaseAuthProvider);

      ref
          .watch(userProvider)
          .getCurrentUserData(authData.currentUser!.uid)
          .then((value) {
        ref
            .watch(projectProvider)
            .getFavouriteProjectsForClients(value)
            .then((value) {
          setState(() {
            favouriteProjects = value;
            _isLoading = false;
          });
        });
        setState(() {
          currentUser1 = value;
          _isLoading = false;
        });
      });

      ref.watch(userProvider).getPermissions().then((value) {
        setState(() {
          currentUserLocation = value;
          _isLoading = false;
        });
      }).then((value) {
        setState(() {
          lat = currentUserLocation?.latitude;
          lng = currentUserLocation?.longitude;
          _isLoading = false;
        });
      });

    } else {
      setState(() {
        _isLoading = false;
      });
    }
    firstLoad = false;
    super.didChangeDependencies();
  }

  void loading() {
    // Check mounted property for state class of widget. https://www.stephenwenceslao.com/blog/error-might-indicate-memory-leak-if-setstate-being-called-because-another-object-retaining
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  // Setting up the map, taken from https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6
  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    print("on map is called");
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat!, lng!), zoom: 15),
      ),
    );
  }

  void _setMarkersFavouriteProjects(BuildContext context) {
    if (favouriteProjects != null) {
      favouriteProjects?.forEach((project) {
        if (project.projectLat != null) {
          _marker = Marker(
              markerId: MarkerId(project.projectId),
              position: LatLng(project.projectLat!, project.projectLng!),
              infoWindow: InfoWindow(
                  title: project.projectTitle, snippet: project.projectType),
              onTap: () {
                setState(() {
                  cardProjectId = project.projectId;
                  cardTitle = project.projectTitle;
                  cardSubtitle = project.projectBriefDescription;
                  cardImage = project.projectImages != null &&
                          project.projectImages!.isNotEmpty
                      ? project.projectImages![0]
                      : null;
                  cardMinPrice = project.projectMinCost;
                  cardMaxPrice = project.projectMaxCost;
                });
              });
          _markers?.add(_marker!);
          _points?.add(LatLng(project.projectLat!, project.projectLng!));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _setMarkersFavouriteProjects(context);
    print("this is lat $lat");
    final screenDimensions = MediaQuery.of(context).size;
    print("this is markers $_markers");

    return Scaffold(
      appBar: AppBar(title: const Text("Favourite Projects Map"), actions: [
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.cancel,
              size: 25,
            )),
      ]),
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(
            height: screenDimensions.height * 0.72,
            width: screenDimensions.width,
            child: Stack(
              children: [
                if (lat != null)
                  GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: LatLng(lat!, lng!), zoom: 15),
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    markers: favouriteProjects != null &&
                            favouriteProjects!.isNotEmpty &&
                            _markers!.isNotEmpty
                        ? _markers!
                        : {},
                  ),
              ],
            ),
          ),
          Flexible(
              child: Stack(children: [
            if (cardTitle == null || cardTitle!.isEmpty)
              Container(
                alignment: Alignment.center,
                height: screenDimensions.height * 0.18,
                width: screenDimensions.width,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 95, 1).withOpacity(0.6),
                ),
                child: const Text("Select a project",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
            if (cardTitle != null && cardTitle!.isNotEmpty)
              InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 95, 1).withOpacity(0.6),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                            width: screenDimensions.width * 0.2,
                            height: screenDimensions.width * 0.2,
                            child: cardImage != null
                                ? Image.network(cardImage!, fit: BoxFit.cover)
                                : const CircleAvatar(
                                radius: 60,
                                backgroundImage: AssetImage(
                                    "assets/images/circular_avatar.png"))),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(cardTitle!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              cardSubtitle!,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.normal,
                                color: Colors.white70,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                        text: "Price Range:",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white54,
                                        ),
                                        children: [
                                          TextSpan(
                                              text:
                                              "€$cardMinPrice - €$cardMaxPrice",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.lightBlueAccent,
                                              ))
                                        ]),
                                  ),
                                ])
                          ],
                        )
                      ]),
                ),
                  onTap: () {
                  if(cardProjectId != null) {
                    Navigator.pushNamed(context, '/ClientProjectDetailsScreen', arguments: cardProjectId);
                  }
                  }
              ),
          ])),
        ],
      )),
    );
  }
}
