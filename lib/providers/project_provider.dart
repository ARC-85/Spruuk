import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';


class ProjectProvider {
  var firebaseDB = FirebaseDB();

  Future<void> addProject(ProjectModel project) async {
    var docId = await firebaseDB.generateProjectDocumentId();
    project.projectId = docId;
    await firebaseDB.fbAddProject(project);
  }
}

final projectProvider = Provider((ref) => ProjectProvider());

// StateProviders to assist multiple image uploads for projects all within one image picker widget. Looked up https://felixblaschke.medium.com/riverpod-simplified-an-introduction-to-flutters-most-advanced-state-management-package-c698b4d5a019
final projectImageProvider = StateProvider<File?>((ref) => null);
final webProjectImageProvider = StateProvider<Uint8List?>((ref) => null);