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
  UserModel? _searchedUserData;
  List<UserModel>? _allUsers;
  List<UserModel>? _favouriteVendors;

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? locationData;
  Location location = Location();
  LatLng? _currentUserLocation;

  UserModel? get currentUserData {
    return _currentUserData;
  }

  List<UserModel>? get allUsers {
    return [...?_allUsers];
  }

  List<UserModel>? get favouriteVendors {
    return [...?_favouriteVendors];
  }

  LatLng? get currentUserLocation {
    return _currentUserLocation;
  }

  Future<UserModel?> getCurrentUserData(String uid) async {
    _currentUserData = await firebaseDB.fbGetVendorUserData(uid);
    return _currentUserData;
  }

  Future<List<UserModel>?> getAllUsers() async {
    List<UserModel> downloadedUsers = [];
    var snapshot = await firebaseDB.getUsers();

    final downloadedDocuments =
    snapshot.docs.map((docs) => docs.data()).toList();
    downloadedDocuments.forEach((user) {
      UserModel userItem =
      UserModel.fromJson(user as Map<String, dynamic>);
      downloadedUsers.add(userItem);
    });
    _allUsers = downloadedUsers;
    return _allUsers;
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

  Future<LatLng?> getUserLocation() async {
      locationData = await location.getLocation();
      _currentUserLocation = LatLng(locationData!.latitude!, locationData!.longitude!);
      print("this is searchlat $_currentUserLocation");
    return _currentUserLocation;
  }

  Future<void> addProjectFavouriteToClient(String projectId) async {
    bool? alreadyFavourite = _currentUserData?.userProjectFavourites!.any((_projectId) => _projectId == projectId);

    if(alreadyFavourite != null && !alreadyFavourite && _currentUserData?.userProjectFavourites != null) {
      _currentUserData?.userProjectFavourites!.add(projectId);
      await firebaseDB.updateUser(_currentUserData!);
    }
  }

  Future<void> removeProjectFavouriteToClient(String projectId) async {

    bool? alreadyFavourite = _currentUserData?.userProjectFavourites!.any((_projectId) => _projectId == projectId);

    if(alreadyFavourite != null && alreadyFavourite) {
      _currentUserData?.userProjectFavourites?.remove(projectId);
      await firebaseDB.updateUser(_currentUserData!);
    }
  }

  Future<void> addVendorFavouriteToClient(String userId) async {
    bool? alreadyFavourite = _currentUserData?.userVendorFavourites!.any((_userId) => _userId == userId);

    if(alreadyFavourite != null && !alreadyFavourite) {
      _currentUserData?.userVendorFavourites!.add(userId);
      await firebaseDB.updateUser(_currentUserData!);
    }
  }

  Future<void> removeVendorFavouriteToClient(String userId) async {
    bool? alreadyFavourite = _currentUserData?.userVendorFavourites!.any((_userId) => _userId == userId);

    if(alreadyFavourite != null && alreadyFavourite) {
      _currentUserData?.userVendorFavourites!.remove(userId);
      await firebaseDB.updateUser(_currentUserData!);
    }
  }

  Future<UserModel?> getUserById(String? userId) async {
    _searchedUserData = await firebaseDB.fbGetUserData(userId!);
    return _searchedUserData;
  }

  // Method for filtering projects base on search terms provided. Adapted from https://stackoverflow.com/questions/57270015/how-to-filter-list-in-flutter
  Future<List<UserModel>?> getFavouriteVendorsForClients(UserModel? user) async {
    final allUsersList = await getAllUsers();
    _favouriteVendors = allUsersList;
    print("this is favouriteVendors initial $_favouriteVendors");
    List<UserModel>? _tempFavouriteVendors;
    if (_favouriteVendors != null) {

      if (user != null && user.userVendorFavourites!.isNotEmpty) {
        _tempFavouriteVendors = [];
        List<UserModel>? _extraTempFavouriteVendors = [];
        for (var favourite in user.userVendorFavourites!) {
          _tempFavouriteVendors = [
            ..._favouriteVendors!.where((user) =>
            (user.uid == favourite))
          ];
          _extraTempFavouriteVendors.addAll(_tempFavouriteVendors);
          print(
              "this is extraTempFavouriteVendors $_extraTempFavouriteVendors");
        }
        _favouriteVendors = _extraTempFavouriteVendors;
        print("this is favouriteVendors favourites $_favouriteVendors");
      }

    }
    print("this is favouriteVendors final $_favouriteVendors");
    return _favouriteVendors;
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final allUsersList = await getAllUsers();
    print("this is allUsers $allUsersList");
    final userIndex = allUsersList!
        .indexWhere((user) => user.uid == updatedUser.uid);
    _allUsers![userIndex] = updatedUser;
    await firebaseDB.updateUser(updatedUser);
  }
}

final userProvider = Provider((ref) => UserProvider());