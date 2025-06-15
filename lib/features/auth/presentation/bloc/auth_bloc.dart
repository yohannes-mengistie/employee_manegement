import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class RefreshTokenRequested extends AuthEvent {}

// Add these new events after the existing ones

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? department;
  final String? position;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.department,
    this.position,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, phone, department, position];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String password;

  const ResetPasswordRequested({required this.token, required this.password});

  @override
  List<Object> get props => [token, password];
}

class VerifyEmailRequested extends AuthEvent {
  final String token;

  const VerifyEmailRequested({required this.token});

  @override
  List<Object> get props => [token];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Employee employee;
  final String token;

  const AuthAuthenticated({required this.employee, required this.token});

  @override
  List<Object> get props => [employee, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// Add these new states after the existing ones

class AuthPasswordResetSent extends AuthState {
  final String message;

  const AuthPasswordResetSent({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthPasswordResetSuccess extends AuthState {
  final String message;

  const AuthPasswordResetSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthEmailVerified extends AuthState {
  final String message;

  const AuthEmailVerified({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  // Add these new event handlers in the AuthBloc constructor
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final authResponse = await _authRepository.login(
        event.email,
        event.password,
      );
      
      emit(AuthAuthenticated(
        employee: authResponse.employee,
        token: authResponse.token,
      ));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout API fails, clear local state
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      
      if (isAuthenticated) {
        final employee = await _authRepository.getCurrentUser();
        if (employee != null) {
          emit(AuthAuthenticated(
            employee: employee,
            token: '', // Token is managed internally
          ));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshed = await _authRepository.refreshToken();
      
      if (refreshed) {
        final employee = await _authRepository.getCurrentUser();
        if (employee != null) {
          emit(AuthAuthenticated(
            employee: employee,
            token: '', // Token is managed internally
          ));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // Add these new event handler methods

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final registerDto = RegisterDto(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        department: event.department,
        position: event.position,
      );
      
      final authResponse = await _authRepository.register(registerDto);
      
      emit(AuthAuthenticated(
        employee: authResponse.employee,
        token: authResponse.token,
      ));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Registration failed: ${e.toString()}'));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final response = await _authRepository.forgotPassword(event.email);
      emit(AuthPasswordResetSent(
        message: response['message'] ?? 'Password reset email sent successfully',
      ));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Failed to send password reset email: ${e.toString()}'));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final response = await _authRepository.resetPassword(event.token, event.password);
      emit(AuthPasswordResetSuccess(
        message: response['message'] ?? 'Password reset successfully',
      ));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Failed to reset password: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyEmailRequested(
    VerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final response = await _authRepository.verifyEmail(event.token);
      emit(AuthEmailVerified(
        message: response['message'] ?? 'Email verified successfully',
      ));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Failed to verify email: ${e.toString()}'));
    }
  }
}
