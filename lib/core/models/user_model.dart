import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String businessName;
  final bool isPremium;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.businessName,
    this.isPremium = false,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      businessName: json['businessName'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'businessName': businessName,
      'isPremium': isPremium,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      businessName: data['businessName'] as String,
      isPremium: data['isPremium'] as bool? ?? false,
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'businessName': businessName,
      'isPremium': isPremium,
      'avatarUrl': avatarUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
