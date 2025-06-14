import 'package:employee_manegement/core/models/employee.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {}

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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Dummy employee data
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Habtamu',
        email: 'john.doe@company.com',
        phone: '+1234567890',
        department: 'Engineering',
        position: 'Senior Developer',
        profileImage: 'https://via.placeholder.com/150',
        joinDate: DateTime(2022, 1, 15),
        salary: 75000.0,
        employeeId: 'EMP001',
      );
      
      emit(ProfileLoaded(employee: employee));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      emit(ProfileUpdated(employee: event.employee));
      emit(ProfileLoaded(employee: event.employee));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
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
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        emit(ProfileLoaded(employee: updatedEmployee));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    }
  }
}
