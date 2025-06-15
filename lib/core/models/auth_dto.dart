// DTOs to match your NestJS backend
class RegisterDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? department;
  final String? position;

  const RegisterDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.department,
    this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (department != null) 'department': department,
      if (position != null) 'position': position,
    };
  }
}

class LoginDto {
  final String email;
  final String password;

  const LoginDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class ForgotPasswordDto {
  final String email;

  const ForgotPasswordDto({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordDto {
  final String token;
  final String password;

  const ResetPasswordDto({
    required this.token,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
    };
  }
}

class VerifyEmailDto {
  final String token;

  const VerifyEmailDto({required this.token});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
