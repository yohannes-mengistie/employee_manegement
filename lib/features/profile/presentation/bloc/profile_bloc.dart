import 'package:employee_manegement/core/exceptions/api_exceptions.dart';
import 'package:employee_manegement/core/models/user.dart';
// import 'package:employee_manegement/core/models/user_dto.dart';
import 'package:employee_manegement/core/repositories/user_repository.dart';
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
  final int userId;

  const LoadProfileById({required this.userId});

  @override
  List<Object> get props => [userId];
}

// class UpdateProfile extends ProfileEvent {
//   final UpdateUserDto userDto;

//   const UpdateProfile({required this.userDto});

//   @override
//   List<Object> get props => [userDto];
// }

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
  final User user;

  const ProfileLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final User user;

  const ProfileUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository = UserRepository();

  ProfileBloc()
      :
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadProfileById>(_onLoadProfileById);
    // on<UpdateProfile>(_onUpdateProfile);
    // on<UpdateProfileImage>(_onUpdateProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final userData = await _userRepository.getCurrentUser();
      final user = User.fromJson(userData);
      emit(ProfileLoaded(user: user));
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
      final userData = await _userRepository.getUserById(event.userId);
      
      final user = User.fromJson(userData);
      emit(ProfileLoaded(user: user));
    } on ApiException catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  // Future<void> _onUpdateProfile(
  //   UpdateProfile event,
  //   Emitter<ProfileState> emit,
  // ) async {
  //   emit(ProfileLoading());
  //   try {
  //     final userData = await _userRepository.updateUser(event.userDto.id, event.userDto);
  //     final updatedUser = User.fromJson(userData);
  //     emit(ProfileUpdated(user: updatedUser));
  //     emit(ProfileLoaded(user: updatedUser));
  //   } on ApiException catch (e) {
  //     emit(ProfileError(message: e.message));
  //   } catch (e) {
  //     emit(ProfileError(message: 'Failed to update profile: ${e.toString()}'));
  //   }
  // }

  // Future<void> _onUpdateProfileImage( // Future<void> _onUpdateProfile(
  //   UpdateProfile event,
  //   Emitter<ProfileState> emit,
  // ) async {
  //   emit(ProfileLoading());
  //   try {
  //     final userData = await _userRepository.updateUser(event.userDto.id, event.userDto);
  //     final updatedUser = User.fromJson(userData);
  //     emit(ProfileUpdated(user: updatedUser));
  //     emit(ProfileLoaded(user: updatedUser));
  //   } on ApiException catch (e) {
  //     emit(ProfileError(message: e.message));
  //   } catch (e) {
  //     emit(ProfileError(message: 'Failed to update profile: ${e.toString()}'));
  //   }
  // }
  //   UpdateProfileImage event,
  //   Emitter<ProfileState> emit,
  // ) async {
  //   emit(ProfileLoading());
  //   try {
  //     // Assuming updateUser can handle profile image updates
  //     final userData = await _userRepository.updateUser(
  //       (state as ProfileLoaded).user.id, // Get current user ID from state
  //       UpdateUserDto(profileImage: event.imagePath),
  //     );
  //     final updatedUser = User.fromJson(userData);
  //     emit(ProfileLoaded(user: updatedUser));
  //   } on ApiException catch (e) {
  //     emit(ProfileError(message: e.message));
  //   } catch (e) {
  //     emit(ProfileError(message: 'Failed to update profile image: ${e.toString()}'));
  //   }
  // }
}