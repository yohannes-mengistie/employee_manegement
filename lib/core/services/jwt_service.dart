import 'dart:convert';

class JwtService {
  // Decode JWT token payload
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      print('🔍 Decoding JWT token...');
      
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid JWT token format - expected 3 parts, got ${parts.length}');
        return null;
      }

      final payload = parts[1];
      print('📦 Raw payload: $payload');
      
      // Add padding if needed for base64 decoding
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      print('🔧 Normalized payload: $normalizedPayload');

      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      print('📝 Decoded string: $decoded');
      
      final Map<String, dynamic> payloadMap = json.decode(decoded);
      
      print('✅ JWT Payload successfully decoded:');
      payloadMap.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
      
      return payloadMap;
    } catch (e) {
      print('❌ Error decoding JWT token: $e');
      print('🔍 Token: ${token.substring(0, 50)}...');
      return null;
    }
  }

  // Extract user ID from token - FIXED to prioritize correct fields
  static int? getUserId(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    
    print('🔍 Looking for user ID in JWT payload...');
    print('📋 Available fields: ${payload.keys.toList()}');
    
    // Try different possible field names for user ID in order of priority
    // Note: 'sub' is the standard JWT field for subject (user ID)
    final possibleFields = [
      'sub',           // Standard JWT subject field (highest priority)
      'userId',        // Common user ID field
      'user_id',       // Snake case user ID
      'id',            // Generic ID field
      'employeeId',    // Employee specific ID
      'employee_id',   // Snake case employee ID
      'uid',           // Short user ID
    ];
    
    for (final field in possibleFields) {
      final value = payload[field];
      if (value != null) {
        print('📋 Found potential user ID in field "$field": $value (${value.runtimeType})');
        
        if (value is int) {
          print('✅ User ID extracted from "$field": $value');
          return value;
        }
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            print('✅ User ID extracted from "$field" (parsed from string): $parsed');
            return parsed;
          } else {
            print('⚠️ Could not parse "$value" as integer from field "$field"');
          }
        }
        if (value is double) {
          final intValue = value.toInt();
          print('✅ User ID extracted from "$field" (converted from double): $intValue');
          return intValue;
        }
      }
    }
    
    print('❌ No valid user ID found in JWT payload');
    print('📋 All payload data:');
    payload.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });
    return null;
  }

  // Extract email from token
  static String? getEmail(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    
    // Try different possible email fields
    final emailFields = ['email', 'mail', 'emailAddress', 'email_address'];
    
    for (final field in emailFields) {
      final email = payload[field];
      if (email != null && email is String && email.isNotEmpty) {
        print('📧 Email from JWT field "$field": $email');
        return email;
      }
    }
    
    print('⚠️ No email found in JWT payload');
    return null;
  }


  // Extract tenant ID from token - SEPARATE from user ID
  static int? getTenantId(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    
    print('🔍 Looking for tenant ID in JWT payload...');
    
    // Try different possible field names for tenant ID
    final possibleFields = [
      'tenantId',      // Standard tenant ID field
      'tenant_id',     // Snake case tenant ID
      'companyId',     // Company ID as tenant
      'company_id',    // Snake case company ID
      'orgId',         // Organization ID
      'org_id',        // Snake case org ID
      'organizationId', // Full organization ID
      'organization_id', // Snake case full org ID
    ];
    
    for (final field in possibleFields) {
      final value = payload[field];
      if (value != null) {
        print('📋 Found potential tenant ID in field "$field": $value (${value.runtimeType})');
        
        if (value is int) {
          print('✅ Tenant ID extracted from "$field": $value');
          return value;
        }
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            print('✅ Tenant ID extracted from "$field" (parsed from string): $parsed');
            return parsed;
          }
        }
        if (value is double) {
          final intValue = value.toInt();
          print('✅ Tenant ID extracted from "$field" (converted from double): $intValue');
          return intValue;
        }
      }
    }
    
    print('⚠️ No tenant ID found in JWT payload');
    return null;
  }

  // Get role/permissions from token
  static List<String>? getRoles(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    
    print('🔍 Looking for roles in JWT payload...');
    
    final roleFields = ['roles', 'role', 'permissions', 'authorities', 'scopes'];
    
    for (final field in roleFields) {
      final value = payload[field];
      if (value != null) {
        print('📋 Found potential roles in field "$field": $value (${value.runtimeType})');
        
        if (value is List) {
          final roles = value.map((e) => e.toString()).toList();
          print('✅ Roles extracted from "$field": $roles');
          return roles;
        }
        if (value is String) {
          // Single role as string
          print('✅ Single role extracted from "$field": $value');
          return [value];
        }
      }
    }
    
    print('⚠️ No roles found in JWT payload');
    return null;
  }

  // Check if token is expired
  static bool isTokenExpired(String token) {
    final payload = decodeToken(token);
    if (payload == null) {
      print('❌ Cannot check expiration - invalid token');
      return true;
    }
    
    final exp = payload['exp'];
    if (exp is int) {
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final isExpired = DateTime.now().isAfter(expirationDate);
      
      print('⏰ Token expiration check:');
      print('  Expires at: $expirationDate');
      print('  Current time: ${DateTime.now()}');
      print('  Is expired: $isExpired');
      
      return isExpired;
    }
    
    print('⚠️ No expiration field found in JWT, assuming expired');
    return true;
  }

  // Get expiration date from token
  static DateTime? getExpirationDate(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    
    final exp = payload['exp'];
    if (exp is int) {
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      print('📅 Token expires at: $expirationDate');
      return expirationDate;
    }
    
    print('⚠️ No expiration date found in JWT');
    return null;
  }


  // Get issued at date from token
  static DateTime? getIssuedAt(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    
    final iat = payload['iat'];
    if (iat is int) {
      final issuedAt = DateTime.fromMillisecondsSinceEpoch(iat * 1000);
      print('📅 Token issued at: $issuedAt');
      return issuedAt;
    }
    
    return null;
  }

  // Get issuer from token
  static String? getIssuer(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    
    final iss = payload['iss'];
    if (iss is String) {
      print('🏢 Token issuer: $iss');
      return iss;
    }
    
    return null;
  }

  // Get audience from token
  static String? getAudience(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    
    final aud = payload['aud'];
    if (aud is String) {
      print('👥 Token audience: $aud');
      return aud;
    }
    
    return null;
  }

  // Get all claims from token (for debugging)
  static Map<String, dynamic>? getAllClaims(String token) {
    return decodeToken(token);
  }

  // Validate token structure and basic claims
  static bool validateToken(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) return false;
      
      // Check for required fields
      final hasSubject = payload.containsKey('sub') || 
                        payload.containsKey('userId') || 
                        payload.containsKey('user_id') ||
                        payload.containsKey('id');
      
      final hasExpiration = payload.containsKey('exp');
      
      print('🔍 Token validation:');
      print('  Has subject/user ID: $hasSubject');
      print('  Has expiration: $hasExpiration');
      print('  Is expired: ${isTokenExpired(token)}');
      
      return hasSubject && hasExpiration && !isTokenExpired(token);
    } catch (e) {
      print('❌ Token validation failed: $e');
      return false;
    }
  }

  // Extract user information summary
  static Map<String, dynamic> getUserInfo(String token) {
    final payload = decodeToken(token);
    if (payload == null) return {};
    
    return {
      'userId': getUserId(token),
      'email': getEmail(token),
      'tenantId': getTenantId(token),
      'roles': getRoles(token),
      'issuedAt': getIssuedAt(token),
      'expiresAt': getExpirationDate(token),
      'issuer': getIssuer(token),
      'audience': getAudience(token),
      'isExpired': isTokenExpired(token),
      'isValid': validateToken(token),
    };
  }
}
