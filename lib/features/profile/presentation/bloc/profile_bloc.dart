import 'dart:convert';
import 'package:employee_manegement/core/models/employee.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {
  final int id; 

  const LoadProfile({required this.id});

  @override
  List<Object> get props => [id];
}

class UpdateProfile extends ProfileEvent {
  final Employee employee;

  const UpdateProfile({required this.employee});

  @override
  List<Object> get props => [employee];
}

class UpdateProfileImage extends ProfileEvent {
  final String imagePath;

  const UpdateProfileImage({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Employee employee;

  const ProfileLoaded({required this.employee});

  @override
  List<Object> get props => [employee];
}

class ProfileUpdated extends ProfileState {
  final Employee employee;

  const ProfileUpdated({required this.employee});

  @override
  List<Object> get props => [employee];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateProfileImage>(_onUpdateProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final response = await http.get(
        Uri.parse('https://backend-r944.onrender.com/employee/${event.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("////////////////////////////////////Response status: ${response.statusCode}");
      print("////////////////////////////////////Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate required fields
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final employee = Employee(
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          department: data['department'] ?? '',
          position: data['position'] ?? '',
          profileImage: data['profileImage'] ?? '',
          joinDate: DateTime.parse(data['joinDate'] ?? DateTime.now().toIso8601String()),
          salary: (data['salary'] ?? 0).toDouble(),
          employeeId: data['employeeId'] ?? 0,
          tenantId: data['tenantId'] ?? 0,
          address: data['address'] ?? '',
          dateOfBirth: DateTime.parse(data['dateOfBirth'] ?? DateTime.now().toIso8601String()),
          departmentId: data['departmentId'] ?? 0,
          gender: Gender.values.firstWhere(
            (g) => g.name == data['gender'],
          ),
        );
        emit(ProfileLoaded(employee: employee));
      } else {
        emit(ProfileError(message: 'Failed to load profile: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Error loading profile: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final response = await http.put(
        Uri.parse('https://backend-r944.onrender.com/employee/${event.employee.employeeId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'employeeId': event.employee.employeeId,
          'firstName': event.employee.firstName,
          'lastName': event.employee.lastName,
          'email': event.employee.email,
          'phone': event.employee.phone,
          'department': event.employee.department,
          'position': event.employee.position,
          'profileImage': event.employee.profileImage,
          'joinDate': event.employee.joinDate.toIso8601String(),
          'salary': event.employee.salary,
          'employeeId': event.employee.employeeId,
          'tenantId': event.employee.tenantId,
          'address': event.employee.address,
          'dateOfBirth': event.employee.dateOfBirth.toIso8601String(),
          'departmentId': event.employee.departmentId,
          'gender': event.employee.gender.toString().split('.').last,
        }),
      );

      

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ProfileUpdated(employee: event.employee));
        emit(ProfileLoaded(employee: event.employee));
      } else {
        emit(ProfileError(message: 'Failed to update profile: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Error updating profile: $e'));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentEmployee = (state as ProfileLoaded).employee;
      final updatedEmployee = currentEmployee.copyWith(
        profileImage: event.imagePath,
      );

      emit(ProfileLoading());

      try {
        final response = await http.patch(
          Uri.parse('https://backend-r944.onrender.com/employee/${updatedEmployee.employeeId}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'profileImage': event.imagePath,
          }),
        );

        if (response.statusCode == 200) {
          emit(ProfileLoaded(employee: updatedEmployee));
        } else {
          emit(ProfileError(message: 'Failed to update profile image: ${response.statusCode}'));
        }
      } catch (e) {
        emit(ProfileError(message: 'Error updating profile image: $e'));
      }
    } else {
      emit(ProfileError(message: 'No profile loaded to update image'));
    }
  }
}