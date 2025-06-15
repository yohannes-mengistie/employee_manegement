// DTOs to match your NestJS backend
class CreateEmployeeDto {
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final int departmentId;
  final String position;
  final double salary;
  final DateTime joinDate;
  final String? profileImage;
  final String? status;

  const CreateEmployeeDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    required this.departmentId,
    required this.position,
    required this.salary,
    required this.joinDate,
    this.profileImage,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (gender != null) 'gender': gender,
      'departmentId': departmentId,
      'position': position,
      'salary': salary,
      'joinDate': joinDate.toIso8601String(),
      if (profileImage != null) 'profileImage': profileImage,
      if (status != null) 'status': status,
    };
  }
}

class UpdateEmployeeDto {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final int? departmentId;
  final String? position;
  final double? salary;
  final DateTime? joinDate;
  final String? profileImage;
  final String? status;

  const UpdateEmployeeDto({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.departmentId,
    this.position,
    this.salary,
    this.joinDate,
    this.profileImage,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (gender != null) data['gender'] = gender;
    if (departmentId != null) data['departmentId'] = departmentId;
    if (position != null) data['position'] = position;
    if (salary != null) data['salary'] = salary;
    if (joinDate != null) data['joinDate'] = joinDate!.toIso8601String();
    if (profileImage != null) data['profileImage'] = profileImage;
    if (status != null) data['status'] = status;
    return data;
  }
}

class SearchEmployeeDto {
  final String? name;
  final String? email;
  final int? departmentId;
  final String? position;
  final String? status;
  final int? page;
  final int? limit;

  const SearchEmployeeDto({
    this.name,
    this.email,
    this.departmentId,
    this.position,
    this.status,
    this.page,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (departmentId != null) data['departmentId'] = departmentId;
    if (position != null) data['position'] = position;
    if (status != null) data['status'] = status;
    if (page != null) data['page'] = page;
    if (limit != null) data['limit'] = limit;
    return data;
  }
}

// User DTOs
class CreateUserDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final int? roleId;
  final bool? isActive;

  const CreateUserDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.roleId,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (roleId != null) 'roleId': roleId,
      if (isActive != null) 'isActive': isActive,
    };
  }
}

class UpdateUserDto {
  final String? email;
  final String? password;
  final String? firstName;
  final String? lastName;
  final int? roleId;
  final bool? isActive;

  const UpdateUserDto({
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.roleId,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (roleId != null) data['roleId'] = roleId;
    if (isActive != null) data['isActive'] = isActive;
    return data;
  }
}

class CreateRoleDto {
  final String name;
  final String? description;
  final List<String>? permissions;

  const CreateRoleDto({
    required this.name,
    this.description,
    this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (permissions != null) 'permissions': permissions,
    };
  }
}

class UpdateRoleDto {
  final String? name;
  final String? description;
  final List<String>? permissions;

  const UpdateRoleDto({
    this.name,
    this.description,
    this.permissions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (permissions != null) data['permissions'] = permissions;
    return data;
  }
}

// Response models
class EmployeeStats {
  final int totalAttendance;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final double attendancePercentage;
  final Duration totalWorkingHours;
  final double averageWorkingHours;

  const EmployeeStats({
    required this.totalAttendance,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.attendancePercentage,
    required this.totalWorkingHours,
    required this.averageWorkingHours,
  });

  factory EmployeeStats.fromJson(Map<String, dynamic> json) {
    return EmployeeStats(
      totalAttendance: json['totalAttendance'] ?? 0,
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      lateDays: json['lateDays'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 0.0).toDouble(),
      totalWorkingHours: Duration(minutes: json['totalWorkingHours'] ?? 0),
      averageWorkingHours: (json['averageWorkingHours'] ?? 0.0).toDouble(),
    );
  }
}

enum EmployeeStatus { ACTIVE, INACTIVE, TERMINATED, ON_LEAVE }

EmployeeStatus parseEmployeeStatus(String? status) {
  switch (status?.toUpperCase()) {
    case 'ACTIVE':
      return EmployeeStatus.ACTIVE;
    case 'INACTIVE':
      return EmployeeStatus.INACTIVE;
    case 'TERMINATED':
      return EmployeeStatus.TERMINATED;
    case 'ON_LEAVE':
      return EmployeeStatus.ON_LEAVE;
    default:
      return EmployeeStatus.ACTIVE;
  }
}
