import 'package:employee_manegement/core/models/employee.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final int tenantId;
  final String email;
  final String fullName;
  final String companyName;
  final bool isActive;
  final String? verificationToken;
  final DateTime? verificationExpiry;
  final String? resetPasswordToken;
  final DateTime? resetPasswordExpiry;
  final int roleId;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Role? role;
  final Tenant? tenant;
  final String profileImage;
  final String phone ;
  final String department ;
  final String position ;

  const User({
    required this.id,
    required this.tenantId,
    required this.email,
    required this.fullName,
    required this.companyName,
    required this.isActive,
    this.verificationToken,
    this.verificationExpiry,
    this.resetPasswordToken,
    this.resetPasswordExpiry,
    required this.roleId,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.role,
    this.tenant,
    this.profileImage = 'assets/images/profile.avif',
    this.phone = '+251911212121',
    this.department = 'General',
    this.position = 'Employee',
  });

  // Extract first and last name from fullName - IMPROVED
  String get firstName {
    if (fullName.trim().isEmpty) return 'User';
    
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : 'User';
  }

  String get lastName {
    if (fullName.trim().isEmpty) return 'Employee';
    
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return 'Employee';
    
    // Join all parts except the first one as last name
    // This handles cases like "John Doe Smith" -> firstName: "John", lastName: "Doe Smith"
    return parts.sublist(1).join(' ');
  }

  // Helper method to get individual name parts
  List<String> get nameParts {
    return fullName.trim().split(RegExp(r'\s+'));
  }

  // Method to update fullName from first and last name
  String createFullName(String firstName, String lastName) {
    final first = firstName.trim();
    final last = lastName.trim();
    
    if (first.isEmpty && last.isEmpty) return '';
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    
    return '$first $last';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 Parsing User from JSON: $json');
      
      return User(
        id: json['id'] ?? 0,
        tenantId: json['tenantId'] ?? 0,
        email: json['email'] ?? '',
        fullName: json['fullName'] ?? '',
        companyName: json['companyName'] ?? '',
        isActive: json['isActive'] ?? true,
        verificationToken: json['verificationToken'],
        verificationExpiry: json['verificationExpiry'] != null 
            ? DateTime.parse(json['verificationExpiry']) 
            : null,
        resetPasswordToken: json['resetPasswordToken'],
        resetPasswordExpiry: json['resetPasswordExpiry'] != null 
            ? DateTime.parse(json['resetPasswordExpiry']) 
            : null,
        roleId: json['roleId'] ?? 0,
        lastLogin: json['lastLogin'] != null 
            ? DateTime.parse(json['lastLogin']) 
            : null,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
        role: json['role'] != null ? Role.fromJson(json['role']) : null,
        tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null,
      );
    } catch (e) {
      print('❌ Error parsing User from JSON: $e');
      print('📦 Raw JSON: $json');
      rethrow;
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'email': email,
      'fullName': fullName,
      'companyName': companyName,
      'isActive': isActive,
      if (verificationToken != null) 'verificationToken': verificationToken,
      if (verificationExpiry != null) 'verificationExpiry': verificationExpiry!.toIso8601String(),
      if (resetPasswordToken != null) 'resetPasswordToken': resetPasswordToken,
      if (resetPasswordExpiry != null) 'resetPasswordExpiry': resetPasswordExpiry!.toIso8601String(),
      'roleId': roleId,
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (role != null) 'role': role!.toJson(),
      if (tenant != null) 'tenant': tenant!.toJson(),
    };
  }

  // Convert User to Employee for compatibility - IMPROVED name handling
  Employee toEmployee() {
    print('🔄 Converting User to Employee...');
    print('📋 Original fullName: "$fullName"');
    print('📋 Parsed firstName: "$firstName"');
    print('📋 Parsed lastName: "$lastName"');
    
    return Employee(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: '+1234567890', // Default phone since not in User model
      department: role?.name ?? 'General',
      position: role?.name ?? 'Employee',
      profileImage: 'assets/images/profile.avif', // Default image
      joinDate: createdAt,
      salary: 50000.0, // Default salary since not in User model
      employeeId: id,
      tenantId: tenantId,
      address: tenant?.address ?? '123 Main Street',
      dateOfBirth: DateTime(1990, 1, 1), // Default DOB
      departmentId: 1, // Default department ID
      gender: Gender.other, // Default gender
    );
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        email,
        fullName,
        companyName,
        isActive,
        verificationToken,
        verificationExpiry,
        resetPasswordToken,
        resetPasswordExpiry,
        roleId,
        lastLogin,
        createdAt,
        updatedAt,
        role,
        tenant,
      ];
}

class Role extends Equatable {
  final int id;
  final String name;
  final String description;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [id, name, description, permissions, createdAt, updatedAt];
}

class Tenant extends Equatable {
  final int id;
  final String name;
  final String subdomain;
  final String logo;
  final String primaryColor;
  final String secondaryColor;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String subscriptionPlan;
  final String subscriptionStatus;
  final DateTime createdAt;
  final DateTime updatedAt;


  const Tenant({
    required this.id,
    required this.name,
    required this.subdomain,
    required this.logo,
    required this.primaryColor,
    required this.secondaryColor,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subdomain: json['subdomain'] ?? '',
      logo: json['logo'] ?? '',
      primaryColor: json['primaryColor'] ?? '#1F2937',
      secondaryColor: json['secondaryColor'] ?? '#3B82F6',
      address: json['address'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      subscriptionPlan: json['subscriptionPlan'] ?? 'basic',
      subscriptionStatus: json['subscriptionStatus'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subdomain': subdomain,
      'logo': logo,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [
        id,
        name,
        subdomain,
        logo,
        primaryColor,
        secondaryColor,
        address,
        contactEmail,
        contactPhone,
        subscriptionPlan,
        subscriptionStatus,
        createdAt,
        updatedAt,
      ];
}
