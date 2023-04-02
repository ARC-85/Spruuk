import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';

// Class for accessing provider functions related to User objects.
class UserProvider {
  // Variable for accessing FirebaseDB class.
  var firebaseDB = FirebaseDB();

  // Variable setup for individual and lists of Users
  UserModel? _currentUserData;
  UserModel? _searchedUserData;
  List<UserModel>? _allUsers;
  List<UserModel>? _favouriteVendors;

  // Variable setup for permissions required to use User's current location
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? locationData;
  Location location = Location();
  LatLng? _currentUserLocation;

  // Getter function to return data related to a specific User.
  UserModel? get currentUserData {
    return _currentUserData;
  }

  // Getter function to return list of all Users.
  List<UserModel>? get allUsers {
    return [...?_allUsers];
  }

  // Getter function to return list of favourite vendor users.
  List<UserModel>? get favouriteVendors {
    return [...?_favouriteVendors];
  }

  // Getter function to return user's current location.
  LatLng? get currentUserLocation {
    return _currentUserLocation;
  }

  // Function to return data on current user as a snapshot of Firestore collection
  Future<UserModel?> getCurrentUserData(String uid) async {
    _currentUserData = await firebaseDB.fbGetVendorUserData(uid);
    return _currentUserData;
  }

  // Function to create a list of all users from a Firebase instance/snapshot
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

  // Function to add user to Firestore collection
  Future<void> addUser(UserModel user) async {
    await firebaseDB.fbAddVendorUser(user);
  }

  // Function to receive permission to use User's current location
  Future<LatLng?> getPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        // If service is not available, use an arbitrary location for user
        _currentUserLocation =  const LatLng(53.37466222698207, -9.1528495028615);
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // If user permission is not available, use an arbitrary location for user
        _currentUserLocation = const LatLng(53.37466222698207, -9.1528495028615);
      }
    } else {
      // If service is available and permission given then use the current location of the user.
      locationData = await location.getLocation();
      _currentUserLocation = LatLng(locationData!.latitude!, locationData!.longitude!);
    }
    return _currentUserLocation;
  }

  // Function to get current location of user, assuming permissions are already given
  Future<LatLng?> getUserLocation() async {
      locationData = await location.getLocation();
      _currentUserLocation = LatLng(locationData!.latitude!, locationData!.longitude!);
    return _currentUserLocation;
  }

  // Add the ID of a project to a list of Client user's favourite projects.
  Future<void> addProjectFavouriteToClient(String projectId) async {
    // Check if already on list of favourites
    bool? alreadyFavourite = _currentUserData?.userProjectFavourites!.any((_projectId) => _projectId == projectId);

    // Only add if not already on list
    if(alreadyFavourite != null && !alreadyFavourite && _currentUserData?.userProjectFavourites != null) {
      _currentUserData?.userProjectFavourites!.add(projectId);
      await firebaseDB.updateUser(_currentUserData!);
    }
  }

  // Remove the ID of a project from a list of Client user's favourite projects.
  Future<void> removeProjectFavouriteToClient(String projectId) async {

    // Check if already on list of favourites
    bool? alreadyFavourite = _currentUserData?.userProjectFavourites!.any((_projectId) => _projectId == projectId);

    // Only remove if already on list
    if(alreadyFavourite != null && alreadyFavourite) {
      _currentUserData?.userProjectFavourites?.remove(projectId);
      await firebaseDB.updateUser(_currentUserData!);
    }
  }

  // Add the ID of a vendor user to a list of Client user's favourite vendors.
  Future<void> addVendorFavouriteToClient(String userId) async {
    bool? alreadyFavourite = _currentUserData?.userVendorFavourites!.any((_userId) => _userId == userId);

    if(alreadyFavourite != null && !alreadyFavourite) {
      _currentUserData?.userVendorFavourites!.add(userId);
      await firebaseDB.updateUser(_currentUserData!);
    }
  }

  // Remove the ID of a vendor user from a list of Client user's favourite Vendors.
  Future<void> removeVendorFavouriteToClient(String userId) async {
    bool? alreadyFavourite = _currentUserData?.userVendorFavourites!.any((_userId) => _userId == userId);

    if(alreadyFavourite != null && alreadyFavourite) {
      _currentUserData?.userVendorFavourites!.remove(userId);
      await firebaseDB.updateUser(_currentUserData!);
    }
  }

  // Function for getting user based on specific ID.
  Future<UserModel?> getUserById(String? userId) async {
    _searchedUserData = await firebaseDB.fbGetUserData(userId!);
    return _searchedUserData;
  }

  // Method for filtering vendors base on Client user's list of favourite vendor IDs. Adapted from https://stackoverflow.com/questions/57270015/how-to-filter-list-in-flutter
  Future<List<UserModel>?> getFavouriteVendorsForClients(UserModel? user) async {
    final allUsersList = await getAllUsers();
    _favouriteVendors = allUsersList;
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
        }
        _favouriteVendors = _extraTempFavouriteVendors;
      }

    }
    return _favouriteVendors;
  }

  // Function to update specific user within Firestore collection
  Future<void> updateUser(UserModel updatedUser) async {
    final allUsersList = await getAllUsers();
    final userIndex = allUsersList!
        .indexWhere((user) => user.uid == updatedUser.uid);
    _allUsers![userIndex] = updatedUser;
    await firebaseDB.updateUser(updatedUser);
  }
}

// Provider to enable access to all functions within UserProvider class
final userProvider = Provider((ref) => UserProvider());