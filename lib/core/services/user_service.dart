import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUserProfile(UserModel user) {
    return _users.doc(user.id).set(user.toFirestoreMap());
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromFirestore(doc) : null,
        );
  }
}
