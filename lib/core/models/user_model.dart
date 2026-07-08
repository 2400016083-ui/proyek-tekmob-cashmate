import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String businessName;
  final bool isPremium;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final String? address;
  final String? businessCategory;
  final String? businessDescription;
  final String? businessAddress;
  final String? businessPhone;
  final String? businessLogoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.businessName,
    this.isPremium = false,
    this.avatarUrl,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.address,
    this.businessCategory,
    this.businessDescription,
    this.businessAddress,
    this.businessPhone,
    this.businessLogoUrl,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? businessName,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    String? address,
    String? businessCategory,
    String? businessDescription,
    String? businessAddress,
    String? businessPhone,
    String? businessLogoUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      businessName: businessName ?? this.businessName,
      isPremium: isPremium,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      businessCategory: businessCategory ?? this.businessCategory,
      businessDescription: businessDescription ?? this.businessDescription,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      businessName: json['businessName'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      businessCategory: json['businessCategory'] as String?,
      businessDescription: json['businessDescription'] as String?,
      businessAddress: json['businessAddress'] as String?,
      businessPhone: json['businessPhone'] as String?,
      businessLogoUrl: json['businessLogoUrl'] as String?,
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
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'address': address,
      'businessCategory': businessCategory,
      'businessDescription': businessDescription,
      'businessAddress': businessAddress,
      'businessPhone': businessPhone,
      'businessLogoUrl': businessLogoUrl,
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
      phoneNumber: data['phoneNumber'] as String?,
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      gender: data['gender'] as String?,
      address: data['address'] as String?,
      businessCategory: data['businessCategory'] as String?,
      businessDescription: data['businessDescription'] as String?,
      businessAddress: data['businessAddress'] as String?,
      businessPhone: data['businessPhone'] as String?,
      businessLogoUrl: data['businessLogoUrl'] as String?,
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
      'phoneNumber': phoneNumber,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'gender': gender,
      'address': address,
      'businessCategory': businessCategory,
      'businessDescription': businessDescription,
      'businessAddress': businessAddress,
      'businessPhone': businessPhone,
      'businessLogoUrl': businessLogoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
