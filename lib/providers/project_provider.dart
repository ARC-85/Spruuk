import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spruuk/models/project_model.dart';
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

  List<ProjectModel>? get allProjects {
    return [...?_allProjects];
  }

  List<ProjectModel>? get allVendorProjects {
    return [...?_allVendorProjects];
  }

  Future<void> addProject(ProjectModel project) async {
    var docId = await firebaseDB.generateProjectDocumentId();
    project.projectId = docId;
    await firebaseDB.fbAddProject(project);
  }

  Future<List<ProjectModel>?> getAllProjects() async {
    List<ProjectModel> downloadedProjects = [];
    var snapshot = await firebaseDB.getProjects();

    final downloadedDocuments = snapshot.docs.map((docs) => docs.data()).toList();
    downloadedDocuments.forEach((project) {
      ProjectModel projectItem = ProjectModel.fromJson(project as Map<String, dynamic>);
      downloadedProjects.add(projectItem);
    });
    _allProjects = downloadedProjects;
    return _allProjects;
  }

  List<ProjectModel>? getAllVendorProjects(String? uid) {
    if(_allProjects != null) {
      _allVendorProjects = [..._allProjects!.where((project) => project.projectUserId == uid)];
    } else {
      _allVendorProjects = [];
    }
    return _allVendorProjects;
  }

  void deleteProject(String projectId) {
    _allProjects?.removeWhere((project) => project.projectId == projectId);
    firebaseDB.deleteProject(projectId);
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

final webProjectImageProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage2Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage3Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage4Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage5Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage6Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage7Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage8Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage9Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);
final webProjectImage10Provider = StateProvider.autoDispose<Uint8List?>((ref) => null);

final projectLatLngProvider = StateProvider.autoDispose<LatLng?>((ref) => null);

final projectDateProvider = StateProvider.autoDispose<List<DateTime?>?>((ref) => null);

final projectCostProvider = StateProvider.autoDispose<RangeValues?>((ref) => null);
