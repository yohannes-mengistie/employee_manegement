import 'package:employee_manegement/core/models/employee.dart';
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

  const AuthAuthenticated({required this.employee});

  @override
  List<Object> get props => [employee];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Dummy authentication - in real app, validate with backend
      if (event.email == 'employee@company.com' && event.password == 'password123') {
        final employee = Employee(
          employeeId: 1,
          firstName: 'John',
          lastName: 'Habtamu',
          email: event.email,
          phone: '+1234567890',
          department: 'Engineering',
          position: 'Senior Developer',
          profileImage: 'https://via.placeholder.com/150',
          joinDate: DateTime(2022, 1, 15),
          salary: 75000.0,
          tenantId: 2,
          address: '123 Main St, City, Country',
          dateOfBirth: DateTime(1990, 1, 1),
          departmentId: 3,
          gender: Gender.male
        );
        
        emit(AuthAuthenticated(employee: employee));
      } else {
        emit(const AuthError(message: 'Invalid email or password'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Check if user is already logged in
    emit(AuthUnauthenticated());
  }
}
