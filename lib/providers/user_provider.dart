import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';

class UserProvider {
  var firebaseDB = FirebaseDB();

  UserModel? _currentUserData;

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? locationData;
  Location location = Location();
  LatLng? _currentUserLocation;

  UserModel? get currentUserData {
    return _currentUserData;
  }

  LatLng? get currentUserLocation {
    return _currentUserLocation;
  }

  Future<UserModel?> getCurrentUserData(String uid) async {
    _currentUserData = await firebaseDB.fbGetVendorUserData(uid);
    return _currentUserData;
  }

  Future<void> addUser(UserModel user) async {
    await firebaseDB.fbAddVendorUser(user);
  }

  Future<LatLng?> getPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        _currentUserLocation =  const LatLng(53.37466222698207, -9.1528495028615);
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _currentUserLocation = const LatLng(53.37466222698207, -9.1528495028615);
      }
    } else {
      locationData = await location.getLocation();
      _currentUserLocation = LatLng(locationData!.latitude!, locationData!.longitude!);
    }
    return _currentUserLocation;
  }
}

final userProvider = Provider((ref) => UserProvider());