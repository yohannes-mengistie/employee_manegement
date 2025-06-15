import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {}

class LoadProfileById extends ProfileEvent {
  final int employeeId;

  const LoadProfileById({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
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
  final EmployeeRepository _employeeRepository = EmployeeRepository();

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadProfileById>(_onLoadProfileById);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateProfileImage>(_onUpdateProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      final employee = await _employeeRepository.getCurrentEmployeeProfile();
      emit(ProfileLoaded(employee: employee));
    } on ApiException catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProfileById(
    LoadProfileById event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      final employee = await _employeeRepository.getEmployeeById(event.employeeId);
      emit(ProfileLoaded(employee: employee));
    } on ApiException catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      final updatedEmployee = await _employeeRepository.updateCurrentEmployeeProfile(event.employee);
      emit(ProfileUpdated(employee: updatedEmployee));
      emit(ProfileLoaded(employee: updatedEmployee));
    } on ApiException catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(ProfileError(message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      final updatedEmployee = await _employeeRepository.updateProfileImage(event.imagePath);
      emit(ProfileLoaded(employee: updatedEmployee));
    } on ApiException catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(ProfileError(message: 'Failed to update profile image: ${e.toString()}'));
    }
  }
}
