import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/search_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Class for accessing provider functions related to Project objects.
class ProjectProvider {
  // Variable for accessing FirebaseDB class.
  var firebaseDB = FirebaseDB();

  // Variable setup for individual and lists of Projects
  List<ProjectModel>? _allProjects;
  List<ProjectModel>? _allVendorProjects;
  ProjectModel? _currentProjectData;
  List<ProjectModel>? _filteredProjects;
  List<ProjectModel>? _favouriteProjects;

  // Getter function to return list of all Projects.
  List<ProjectModel>? get allProjects {
    return [...?_allProjects];
  }

  // Getter function to return list of Projects related to a particular vendor.
  List<ProjectModel>? get allVendorProjects {
    return [...?_allVendorProjects];
  }

  // Getter function to return list of filtered/searched for Projects.
  List<ProjectModel>? get filteredProjects {
    return [...?_filteredProjects];
  }

  // Getter function to return list of favourited Projects for a Client user.
  List<ProjectModel>? get favouriteProjects {
    return [...?_favouriteProjects];
  }

  // Getter function to return data related to a specific Project.
  ProjectModel? get currentProjectData {
    return _currentProjectData;
  }

  // Function to add project to Firestore collection
  Future<void> addProject(ProjectModel project) async {
    var docId = await firebaseDB.generateProjectDocumentId();
    project.projectId = docId;
    await firebaseDB.fbAddProject(project);
  }

  // Function to update specific project within Firestore collection
  Future<void> updateProject(ProjectModel updatedProject) async {
    final projectIndex = _allProjects!
        .indexWhere((project) => project.projectId == updatedProject.projectId);
    _allProjects![projectIndex] = updatedProject;
    await firebaseDB.updateProject(updatedProject);
  }

  // Function to create a list of all projects from a Firebase instance/snapshot
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

  // Function to create a list of all projects related to a specific vendor, as a subset of all projects from a Firebase instance/snapshot
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

  // Function for filtering projects based on search terms provided. Adapted from https://stackoverflow.com/questions/57270015/how-to-filter-list-in-flutter
  Future<List<ProjectModel>?> getFilteredProjects(SearchModel? search) async {
    // Start with list of all projects
    final allProjectsList = await getAllProjects();
    _filteredProjects = allProjectsList;
    // Create a temporary variable to store results from first filter
    List<ProjectModel>? _tempFilteredProjects;
    if (_filteredProjects != null) {
      // First search based on terms entered by users
      if (search?.searchQuery != null) {
        // Pass filtered list to temporary variable (search within title or either long/short description of project).
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
        // Filtered list passed back to main variable to move to next filter term.
        _filteredProjects = _tempFilteredProjects;
      }

      // Next filter on types (skip if term not set by user)...
      if (search?.searchTypes != null && search!.searchTypes!.isNotEmpty) {
        _tempFilteredProjects = [];
        List<ProjectModel>? _extraTempFilteredProjects = [];
        // Loop used for assessing each project against the list of types select by user.
        for (var type in search.searchTypes!) {
          _tempFilteredProjects = [
            ..._filteredProjects!.where((project) =>
                (project.projectType != null &&
                    project.projectType!.toLowerCase() == type!.toLowerCase()))
          ];
          _extraTempFilteredProjects.addAll(_tempFilteredProjects);
        }
        _filteredProjects = _extraTempFilteredProjects;
      }

      // Next filter on minimum costs (skip if term not set by user)...
      if (search?.searchMinCost != null && search!.searchMinCost! > 0) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectMinCost != null &&
                  project.projectMinCost! >= search.searchMinCost!))
        ];
        _filteredProjects = _tempFilteredProjects;
      }

      // Next filter on maximum costs (skip if term not set by user)...
      if (search?.searchMaxCost != null && search!.searchMaxCost! < 1000000) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectMaxCost != null &&
                  project.projectMaxCost! <= search.searchMaxCost!))
        ];
        _filteredProjects = _tempFilteredProjects;
      }

      // Next filter on earliest date of completion (skip if term not set by user)...
      if (search?.searchEarliestCompletionYear != null &&
          search!.searchEarliestCompletionYear! > 1901) {
        final date = DateTime(
            search.searchEarliestCompletionYear!,
            search.searchEarliestCompletionMonth!,
            search.searchEarliestCompletionDay!);
        if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          _tempFilteredProjects = [];
          _tempFilteredProjects = [
            ..._filteredProjects!.where((project) =>
                (project.projectCompletionYear != null &&
                    date.isBefore(DateTime(
                        project.projectCompletionYear!,
                        project.projectCompletionMonth!,
                        project.projectCompletionDay!))))
          ];
          _filteredProjects = _tempFilteredProjects;
        }
      }

      // Next filter on latest date of completion (skip if term not set by user)...
      if (search?.searchLatestCompletionYear != null &&
          search!.searchLatestCompletionYear! < 2101) {
        final date = DateTime(
            search.searchLatestCompletionYear!,
            search.searchLatestCompletionMonth!,
            search.searchLatestCompletionDay!);
        if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          _tempFilteredProjects = [];
          _tempFilteredProjects = [
            ..._filteredProjects!.where((project) =>
                (project.projectCompletionYear != null &&
                    date.isAfter(DateTime(
                        project.projectCompletionYear!,
                        project.projectCompletionMonth!,
                        project.projectCompletionDay!))))
          ];
          _filteredProjects = _tempFilteredProjects;
        }
      }

      // Next filter on selected styles (skip if term not set by user)...
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
      }

      // Next filter on minimum area selected (skip if term not set by user)...
      if (search?.searchMinArea != null && search!.searchMinArea! > 0) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectArea != null &&
                  project.projectArea! >= search.searchMinArea!))
        ];
        _filteredProjects = _tempFilteredProjects;
      }

      // Next filter on maximum area selected (skip if term not set by user)...
      if (search?.searchMaxArea != null && search!.searchMaxArea! < 500) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
              (project.projectArea != null &&
                  project.projectArea! <= search.searchMaxArea!))
        ];
        _filteredProjects = _tempFilteredProjects;
      }

      // Next filter on distance from user's current position (skip if term not set by user)...
      // Note this has been left commented out due to random crashing of app (loss of device connection) caused by Geolocator
      /*if (search?.searchLat != null && search?.searchLng != null && search?.searchLat != 53.37466222698207 && search?.searchDistanceFrom != null) {
        _tempFilteredProjects = [];
        _tempFilteredProjects = [
          ..._filteredProjects!.where((project) =>
          (Geolocator.distanceBetween(search!.searchLat!, search.searchLng!, project.projectLat!, project.projectLng!) <= search.searchDistanceFrom! * 1000))
        ];
        _filteredProjects = _tempFilteredProjects;
      }*/
    }
    // Return final list of filtered projects.
    return _filteredProjects;
  }

  // Function for filtering projects based on those favourited by the Client user
  Future<List<ProjectModel>?> getFavouriteProjectsForClients(
      UserModel? user) async {
    final allProjectsList = await getAllProjects();
    _favouriteProjects = allProjectsList;
    List<ProjectModel>? _tempFavouriteProjects;
    if (_favouriteProjects != null) {
      if (user != null &&
          user.userProjectFavourites != null &&
          user.userProjectFavourites!.isNotEmpty) {
        _tempFavouriteProjects = [];
        List<ProjectModel>? _extraTempFavouriteProjects = [];
        // Loop for assessing all projects that are contained within the Client user's list of favourites.
        for (var favourite in user.userProjectFavourites!) {
          _tempFavouriteProjects = [
            ..._favouriteProjects!.where((project) =>
                (project.projectId != null && project.projectId == favourite))
          ];
          _extraTempFavouriteProjects.addAll(_tempFavouriteProjects);
        }
        _favouriteProjects = _extraTempFavouriteProjects;
      }
    }
    return _favouriteProjects;
  }

  // Function for getting project based on specific ID.
  Future<ProjectModel?> getProjectById(String? projectId) async {
    _currentProjectData = await firebaseDB.fbGetProjectData(projectId!);
    return _currentProjectData;
  }

  // Function to delete project from local list of all projects and Firestore database.
  void deleteProject(String projectId) {
    _allProjects?.removeWhere((project) => project.projectId == projectId);
    firebaseDB.deleteProject(projectId);
  }

  // Function to add client user ID to project's list of users that have given it a favourite.
  Future<void> addClientFavouriteToProject(String uid, String projectId) async {
    ProjectModel _currentProject =
        _allProjects!.firstWhere((project) => project.projectId == projectId);
    // Check to see if the user is already included in the project's list of users that have given it a favourite.
    bool? alreadyFavourite = _currentProject.projectFavouriteUserIds
        ?.any((_userId) => _userId == uid);

    if (alreadyFavourite != null && !alreadyFavourite) {
      _currentProject.projectFavouriteUserIds?.add(uid);
      await firebaseDB.updateProject(_currentProject);
    }
  }

  // Function to remove client user ID from project's list of users that have given it a favourite.
  Future<void> removeClientFavouriteToProject(
      String uid, String projectId) async {
    ProjectModel _currentProject =
        _allProjects!.firstWhere((project) => project.projectId == projectId);
    // Check to see if the user is already included in the project's list of users that have given it a favourite.
    bool? alreadyFavourite = _currentProject.projectFavouriteUserIds
        ?.any((_userId) => _userId == uid);

    if (alreadyFavourite != null && alreadyFavourite) {
      _currentProject.projectFavouriteUserIds?.remove(uid);
      await firebaseDB.updateProject(_currentProject);
    }
  }
}

// Provider to enable access to all functions within ProjectProvider class
final projectProvider = Provider((ref) => ProjectProvider());

// StateProviders to assist multiple image uploads for projects all within one image picker widget using Android app. Looked up https://felixblaschke.medium.com/riverpod-simplified-an-introduction-to-flutters-most-advanced-state-management-package-c698b4d5a019
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

// StateProviders to assist multiple image uploads for projects all within one image picker widget using Web app. Looked up https://felixblaschke.medium.com/riverpod-simplified-an-introduction-to-flutters-most-advanced-state-management-package-c698b4d5a019
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

// StateProvider to assist with latitude and longitude states
final projectLatLngProvider = StateProvider.autoDispose<LatLng?>((ref) => null);

// StateProvider to assist with project completion states
final projectDateProvider =
    StateProvider.autoDispose<List<DateTime?>?>((ref) => null);

// StateProvider to assist with latest date of project completion states (within search)
final projectLatestDateProvider = StateProvider.autoDispose<List<DateTime?>?>(
    (ref) => [DateTime.now(), DateTime.now()]);

// StateProvider to assist with project cost states
final projectCostProvider =
    StateProvider.autoDispose<RangeValues?>((ref) => null);

// StateProvider to assist with project area states
final projectAreaProvider = StateProvider.autoDispose<double?>((ref) => null);

// StateProvider to assist with project area range states (within search)
final projectAreaRangeProvider =
    StateProvider.autoDispose<RangeValues?>((ref) => null);

// StateProvider to assist with project distance from user states (within search)
final projectDistanceFromProvider =
    StateProvider.autoDispose<double?>((ref) => null);

// StateProvider to assist with project type states
final projectTypesProvider = StateProvider.autoDispose<List<String?>?>((ref) =>
    ["New Build", "Renovation", "Commercial", "Landscaping", "Interiors"]);

// StateProvider to assist with project style states
final projectStylesProvider = StateProvider.autoDispose<List<String?>?>((ref) =>
    ["Traditional", "Contemporary", "Retro", "Modern", "Minimalist", "None"]);
