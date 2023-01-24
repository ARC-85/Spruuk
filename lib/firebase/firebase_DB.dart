import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spruuk/models/user_model.dart';

class FirebaseDB {
  final CollectionReference vendorUserCollection =
  FirebaseFirestore.instance.collection('vendor_users');

  Future<void> fbAddVendorUser(UserModel user) async {
    return vendorUserCollection.doc(user.uid).set(user.toJson());
  }

  // Get user data from Firestore and convert to UserModel class object
  Future<UserModel> fbGetVendorUserData(String uid) async {
    var snapshot = await vendorUserCollection.doc(uid).get();
    UserModel userData = UserModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return userData;
  }
}