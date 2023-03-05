import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/user_model.dart';

class FirebaseDB {
  final CollectionReference vendorUserCollection =
  FirebaseFirestore.instance.collection('vendor_users');

  final CollectionReference projectCollection =
  FirebaseFirestore.instance.collection('projects');

  // Generates a document id within projects collection by opening new document. Doc id can then be used as project id for storing project on Firebase
  Future<String> generateProjectDocumentId() async {
    var newProjectDoc = await projectCollection.doc();
    String docId = newProjectDoc.id;
    return docId;
  }

  Future<void> fbAddVendorUser(UserModel user) async {
    return vendorUserCollection.doc(user.uid).set(user.toJson());
  }

  // Get user data from Firestore and convert to UserModel class object
  Future<UserModel> fbGetVendorUserData(String uid) async {
    var snapshot = await vendorUserCollection.doc(uid).get();
    UserModel userData = UserModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return userData;
  }

  // Add a new project (from vendor) to projects collection
  Future<void> fbAddProject(ProjectModel project) async {
    return projectCollection.doc(project.projectId).set(project.toJson());
  }

  // Get project data from Firestore and convert to ProjectModel class object
  Future<ProjectModel> fbGetProjectData(String projectId) async {
    var snapshot = await projectCollection.doc(projectId).get();
    ProjectModel projectData = ProjectModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return projectData;
  }

  Future<QuerySnapshot> getUsers() async {
    return vendorUserCollection.get();
  }

  Future<QuerySnapshot> getProjects() async {
    return projectCollection.get();
  }

  void deleteProject(String projectId) async {
    await projectCollection.doc(projectId).delete();
  }

  Future<void> updateUser(UserModel user) async {
    await vendorUserCollection.doc(user.uid).update(user.toJson());
  }

  Future<void> updateProject(ProjectModel project) async {
    await projectCollection.doc(project.projectId).update(project.toJson());
  }

  // Get user data from Firestore and convert to UserModel class object
  Future<UserModel> fbGetUserData(String userId) async {
    var snapshot = await vendorUserCollection.doc(userId).get();
    UserModel userData = UserModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return userData;
  }

}