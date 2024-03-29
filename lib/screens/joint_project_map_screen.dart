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

// Stateful class for screen showing maps of projects to both vendor (user-specific) and client (non-specific) users
class JointProjectMapScreen extends ConsumerStatefulWidget {
  static const routeName = '/JointProjectMapScreen';
  const JointProjectMapScreen({
    Key? key,
    this.projectLocationLatProvider,
    this.projectLocationLngProvider,
  }) : super(key: key);
  final StateProvider<double?>? projectLocationLatProvider;
  final StateProvider<double?>? projectLocationLngProvider;

  @override
  ConsumerState<JointProjectMapScreen> createState() =>
      _JointProjectMapScreen();
}

class _JointProjectMapScreen extends ConsumerState<JointProjectMapScreen> {
  bool firstLoad = true;
  // Bool variables for animation while loading
  bool _isLoading = false;
  String? _userType;
  UserModel? currentUser1;
  User? user;
  FirebaseAuthentication? _auth;
  String? userImage;
  List<ProjectModel>? allProjects;
  List<ProjectModel>? allVendorProjects;
  LatLng? currentUserLocation;
  GoogleMapController? _controller;
  double? lat;
  double? lng;
  Location location = Location();
  Set<Marker>? _markers = {};
  List<LatLng>? _points = [];
  Marker? _marker;

  // Variables for card at bottom of screen to show individual project info
  String? cardId = "";
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

      // Providers are used to get lists of projects related to different user types
      ref
          .watch(userProvider)
          .getCurrentUserData(authData.currentUser!.uid)
          .then((value) {
        setState(() {
          currentUser1 = value;
          _isLoading = false;
        });
      })
      .then((value) {
        setState(() {
          _userType = currentUser1?.userType;
        });
      });

      ref.watch(projectProvider).getAllProjects().then((value) {
        setState(() {
          allProjects = value;
          _isLoading = false;
        });
      });

      ref
          .watch(projectProvider)
          .getAllVendorProjects(authData.currentUser!.uid)
          .then((value) {
        setState(() {
          allVendorProjects = value;
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

      if (authData.currentUser != null) {
        setState(() {
          _isLoading = false;
        });
      }
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
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat!, lng!), zoom: 10),
      ),
    );
  }

  // Function for setting markers and allowing display or project details if marker is tapped
  void _setMarkersAllProjects(BuildContext context) {
    if (allProjects != null) {
      allProjects?.forEach((project) {
        if (project.projectLat != null) {
          _marker = Marker(
              markerId: MarkerId(project.projectId),
              position: LatLng(project.projectLat!, project.projectLng!),
              infoWindow: InfoWindow(
                  title: project.projectTitle, snippet: project.projectType),
              onTap: () {
                setState(() {
                  cardId = project.projectId;
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
    if (_userType == "Vendor") {
      allProjects = allVendorProjects;
      _setMarkersAllProjects(context);
    } else {
      _setMarkersAllProjects(context);
    }
    final screenDimensions = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
          title: _userType == "Client"
              ? const Text("All Projects Map")
              : const Text("My Projects Map"),
          actions: [
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
                        CameraPosition(target: LatLng(lat!, lng!), zoom: 10),
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    markers: allProjects != null &&
                            allProjects!.isNotEmpty &&
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
            if (cardTitle != null &&
                cardTitle!.isNotEmpty &&
                currentUser1 != null)
              InkWell(
                onTap: () {
                  if (currentUser1!.userType == "Vendor") {
                    Navigator.pushNamed(context, '/VendorProjectDetailsScreen',
                        arguments: cardId);
                  } else {
                    Navigator.pushNamed(context, '/ClientProjectDetailsScreen',
                        arguments: cardId);
                  }
                },
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
                        Container(
                          width: screenDimensions.width * 0.72,
                          child: Column(
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                          text: "Price Range:",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white54,
                                          ),
                                          children: [
                                            TextSpan(
                                                text:
                                                "€$cardMinPrice - €$cardMaxPrice",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.lightBlueAccent,
                                                ))
                                          ]),
                                    ),
                                  ])
                            ],
                          )
                        )
                      ]),
                ),
              ),
          ])),
        ],
      )),
    );
  }
}
