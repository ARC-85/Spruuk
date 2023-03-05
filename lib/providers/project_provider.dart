import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/search_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProjectProvider {
  var firebaseDB = FirebaseDB();

  List<ProjectModel>? _allProjects;
  List<ProjectModel>? _allVendorProjects;
  ProjectModel? _currentProjectData;
  List<ProjectModel>? _filteredProjects;
  List<ProjectModel>? _favouriteProjects;

  List<ProjectModel>? get allProjects {
    return [...?_allProjects];
  }

  List<ProjectModel>? get allVendorProjects {
    return [...?_allVendorProjects];
  }

  List<ProjectModel>? get filteredProjects {
    return [...?_filteredProjects];
  }

  List<ProjectModel>? get favouriteProjects {
    return [...?_favouriteProjects];
  }

  ProjectModel? get currentProjectData {
    return _currentProjectData;
  }

  Future<void> addProject(ProjectModel project) async {
    var docId = await firebaseDB.generateProjectDocumentId();
    project.projectId = docId;
    await firebaseDB.fbAddProject(project);
  }

  Future<void> updateProject(ProjectModel updatedProject) async {
    final projectIndex = _allProjects!
        .indexWhere((project) => project.projectId == updatedProject.projectId);
    _allProjects![projectIndex] = updatedProject;
    await firebaseDB.updateProject(updatedProject);
  }

  Future<List<ProjectModel>?> getAllProjects() async {
    List<ProjectModel> downloadedProjects = [];
    var snapshot = await firebaseDB.getProjects();

    final downloadedDocuments =
        snapshot.docs.map((docs) => docs.data()).toList();
    downloadedDocuments.forEach((project) {
      ProjectModel projectItem =
          ProjectModel.fromJson(project as Map<String, dynamic>);
      downloadedProjects.add(projectItem);
    });
    _allProjects = downloadedProjects;
    return _allProjects;
  }

  Future<List<ProjectModel>?> getAllVendorProjects(String? uid) async {
    final allProjectsList = await getAllProjects();
    if (allProjectsList != null) {
      _allVendorProjects = [
        ...allProjectsList.where((project) => project.projectUserId == uid)
      ];
    } else {
      _allVendorProjects = [];
    }
    return _allVendorProjects;
  }

  // Method for filtering projects base on search terms provided. Adapted from https://stackoverflow.com/questions/57270015/how-to-filter-list-in-flutter
  Future<List<ProjectModel>?> getFilteredProjects(SearchModel? search) async {
    final allProjectsList = await getAllProjects();
    _filteredProjects = allProjectsList;
    print("this is filteredProjects initial $_filteredProjects");
    List<ProjectModel>? _tempFilteredProjects;
    if (_filteredProjects != null) {
      if (search?.searchQuery != null) {
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectTitle
                  .toLowerCase()
                  .contains(search!.searchQuery!.toLowerCase())) ||
              (project.projectBriefDescription
                  .toLowerCase()
                  .contains(search.searchQuery!.toLowerCase())) ||
              (project.projectLongDescription != null &&
                  project.projectLongDescription!
                      .toLowerCase()
                      .contains(search.searchQuery!.toLowerCase())))
        ];
        _filteredProjects = _tempFilteredProjects;
        print("this is filteredProjects searchQuery $_filteredProjects");
      }

      if (search?.searchTypes != null && search!.searchTypes!.isNotEmpty) {
        _tempFilteredProjects = [];
        List<ProjectModel>? _extraTempFilteredProjects = [];
        print("this is search types ${search.searchTypes}");
        for (var type in search.searchTypes!) {
          _tempFilteredProjects = [
            ..._filteredProjects!.where((project) =>
                (project.projectType != null &&
                    project.projectType!.toLowerCase() == type!.toLowerCase()))
          ];
          _extraTempFilteredProjects.addAll(_tempFilteredProjects);
          print(
              "this is extraTempFilteredProjects $_extraTempFilteredProjects");
        }
        _filteredProjects = _extraTempFilteredProjects;
        print("this is filteredProjects types $_filteredProjects");
      }

      if (search?.searchMinCost != null && search!.searchMinCost! > 0) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectMinCost != null &&
                  project.projectMinCost! >= search.searchMinCost!))
        ];
        _filteredProjects = _tempFilteredProjects;
        print("this is filteredProjects minCost $_filteredProjects");
      }

      if (search?.searchMaxCost != null && search!.searchMaxCost! < 1000000) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectMaxCost != null &&
                  project.projectMaxCost! <= search.searchMaxCost!))
        ];
        _filteredProjects = _tempFilteredProjects;
        print("this is filteredProjects maxCost $_filteredProjects");
      }

      if (search?.searchEarliestCompletionYear != null &&
          search!.searchEarliestCompletionYear! > 1901) {
        final date = DateTime(
            search.searchEarliestCompletionYear!,
            search.searchEarliestCompletionMonth!,
            search.searchEarliestCompletionDay!);
        if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          _tempFilteredProjects = [];

          print("this is earliest date $date");
          var testDate = DateTime.now().subtract(const Duration(days: 1));
          print(testDate);
          _tempFilteredProjects = [
            ..._filteredProjects!.where((project) =>
                (project.projectCompletionYear != null &&
                    date.isBefore(DateTime(
                        project.projectCompletionYear!,
                        project.projectCompletionMonth!,
                        project.projectCompletionDay!))))
          ];
          _filteredProjects = _tempFilteredProjects;
          print(
              "this is filteredProjects earliest completion $_filteredProjects");
        }
      }

      if (search?.searchLatestCompletionYear != null &&
          search!.searchLatestCompletionYear! < 2101) {
        final date = DateTime(
            search.searchLatestCompletionYear!,
            search.searchLatestCompletionMonth!,
            search.searchLatestCompletionDay!);
        if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          _tempFilteredProjects = [];
          print("this is latest date $date");
          _tempFilteredProjects = [
            ..._filteredProjects!.where((project) =>
                (project.projectCompletionYear != null &&
                    date.isAfter(DateTime(
                        project.projectCompletionYear!,
                        project.projectCompletionMonth!,
                        project.projectCompletionDay!))))
          ];
          _filteredProjects = _tempFilteredProjects;
          print(
              "this is filteredProjects latest completion $_filteredProjects");
        }
      }

      if (search?.searchStyles != null && search!.searchStyles!.isNotEmpty) {
        _tempFilteredProjects = [];
        List<ProjectModel>? _extraTempFilteredProjects = [];
        for (var style in search!.searchStyles!) {
          _tempFilteredProjects = [
            ..._filteredProjects!.where((project) => (project.projectStyle !=
                    null &&
                project.projectStyle!.toLowerCase() == style!.toLowerCase()))
          ];
          _extraTempFilteredProjects.addAll(_tempFilteredProjects);
        }
        _filteredProjects = _extraTempFilteredProjects;
        print("this is filteredProjects styles $_filteredProjects");
      }

      if (search?.searchMinArea != null && search!.searchMinArea! > 0) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectArea != null &&
                  project.projectArea! >= search.searchMinArea!))
        ];
        _filteredProjects = _tempFilteredProjects;
        print("this is filteredProjects min area $_filteredProjects");
      }

      if (search?.searchMaxArea != null && search!.searchMaxArea! < 500) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectArea != null &&
                  project.projectArea! <= search.searchMaxArea!))
        ];
        _filteredProjects = _tempFilteredProjects;
        print("this is filteredProjects max area $_filteredProjects");
      }

      /*if (search?.searchLat != null && search?.searchLng != null && search?.searchLat != 53.37466222698207 && search?.searchDistanceFrom != null) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
          (Geolocator.distanceBetween(search!.searchLat!, search.searchLng!, project.projectLat!, project.projectLng!) <= search.searchDistanceFrom! * 1000))
        ];
        _filteredProjects = _tempFilteredProjects;
        print("this is filteredProjects distance from $_filteredProjects");
      }*/
    }
    print("this is filteredProjects final $_filteredProjects");
    return _filteredProjects;
  }

  // Method for filtering projects base on search terms provided. Adapted from https://stackoverflow.com/questions/57270015/how-to-filter-list-in-flutter
  Future<List<ProjectModel>?> getFavouriteProjectsForClients(UserModel? user) async {
    final allProjectsList = await getAllProjects();
    _favouriteProjects = allProjectsList;
    print("this is favouriteProjects initial $_favouriteProjects");
    print("this is user $user");
    List<ProjectModel>? _tempFavouriteProjects;
    if (_favouriteProjects != null) {

      if (user != null && user.userProjectFavourites != null && user.userProjectFavourites!.isNotEmpty) {
        _tempFavouriteProjects = [];
        List<ProjectModel>? _extraTempFavouriteProjects = [];
        for (var favourite in user.userProjectFavourites!) {
          _tempFavouriteProjects = [
            ..._favouriteProjects!.where((project) =>
            (project.projectId != null &&
                project.projectId == favourite))
          ];
          _extraTempFavouriteProjects.addAll(_tempFavouriteProjects);
          print(
              "this is extraTempFavouriteProjects $_extraTempFavouriteProjects");
        }
        _favouriteProjects = _extraTempFavouriteProjects;
        print("this is favouriteProjects favourites $_favouriteProjects");
      }

    }
    print("this is favouriteProjects final $_favouriteProjects");
    return _favouriteProjects;
  }

  Future<ProjectModel?> getProjectById(String? projectId) async {
    _currentProjectData = await firebaseDB.fbGetProjectData(projectId!);
    return _currentProjectData;
  }

  void deleteProject(String projectId) {
    _allProjects?.removeWhere((project) => project.projectId == projectId);
    firebaseDB.deleteProject(projectId);
  }

  Future<void> addClientFavouriteToProject(String uid, String projectId) async {
    ProjectModel _currentProject =
        _allProjects!.firstWhere((project) => project.projectId == projectId);
    bool? alreadyFavourite = _currentProject.projectFavouriteUserIds
        ?.any((_userId) => _userId == uid);

    if (alreadyFavourite != null && !alreadyFavourite) {
      _currentProject.projectFavouriteUserIds?.add(uid);
      await firebaseDB.updateProject(_currentProject);
    }
  }

  Future<void> removeClientFavouriteToProject(
      String uid, String projectId) async {
    ProjectModel _currentProject =
        _allProjects!.firstWhere((project) => project.projectId == projectId);
    bool? alreadyFavourite = _currentProject.projectFavouriteUserIds
        ?.any((_userId) => _userId == uid);

    if (alreadyFavourite != null && alreadyFavourite) {
      _currentProject.projectFavouriteUserIds?.remove(uid);
      await firebaseDB.updateProject(_currentProject);
    }
  }
}

final projectProvider = Provider((ref) => ProjectProvider());

// StateProviders to assist multiple image uploads for projects all within one image picker widget. Looked up https://felixblaschke.medium.com/riverpod-simplified-an-introduction-to-flutters-most-advanced-state-management-package-c698b4d5a019
final projectImageProvider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage2Provider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage3Provider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage4Provider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage5Provider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage6Provider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage7Provider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage8Provider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage9Provider = StateProvider.autoDispose<File?>((ref) => null);
final projectImage10Provider = StateProvider.autoDispose<File?>((ref) => null);

final webProjectImageProvider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage2Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage3Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage4Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage5Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage6Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage7Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage8Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage9Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage10Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);

final projectLatLngProvider = StateProvider.autoDispose<LatLng?>((ref) => null);

final projectDateProvider =
    StateProvider.autoDispose<List<DateTime?>?>((ref) => null);

final projectLatestDateProvider = StateProvider.autoDispose<List<DateTime?>?>(
    (ref) => [DateTime.now(), DateTime.now()]);

final projectCostProvider =
    StateProvider.autoDispose<RangeValues?>((ref) => null);

final projectAreaProvider = StateProvider.autoDispose<double?>((ref) => null);

final projectAreaRangeProvider =
    StateProvider.autoDispose<RangeValues?>((ref) => null);

final projectDistanceFromProvider =
    StateProvider.autoDispose<double?>((ref) => null);

final projectTypesProvider = StateProvider.autoDispose<List<String?>?>((ref) =>
    ["New Build", "Renovation", "Commercial", "Landscaping", "Interiors"]);

final projectStylesProvider = StateProvider.autoDispose<List<String?>?>(
    (ref) => ["Traditional", "Contemporary", "Retro", "Modern", "Minimalist"]);
