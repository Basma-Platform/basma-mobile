import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

String _apiBaseUrl() {
  const origin = String.fromEnvironment(
    'BASMA_API_BASE_URL',
    defaultValue: 'https://basma-backend.onrender.com',
  );
  return origin.endsWith('/') ? origin : '$origin/';
}

/// Laravel Sanctum uses a CSRF cookie and a session cookie, not an invented token.
class AuthService {
  AuthService._()
    : _cookies = CookieJar(),
      _dio = Dio(
        BaseOptions(
          baseUrl: _apiBaseUrl(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(CookieManager(_cookies));
  }

  static final AuthService instance = AuthService._();
  final Dio _dio;
  final CookieJar _cookies;
  bool _csrfReady = false;

  Future<void> _ensureCsrf() async {
    if (_csrfReady) return;
    await _dio.get<void>('sanctum/csrf-cookie');
    _csrfReady = true;
  }

  Future<dynamic> _post(String path, Map<String, dynamic> data) async {
    try {
      await _ensureCsrf();
      return await _sendPost(path, data);
    } on DioException catch (error) {
      if (error.response?.statusCode != 419) rethrow;
      _csrfReady = false;
      await _ensureCsrf();
      return _sendPost(path, data);
    }
  }

  Future<dynamic> _sendPost(String path, Map<String, dynamic> data) async {
    final cookies = await _cookies.loadForRequest(
      Uri.parse(_dio.options.baseUrl),
    );
    final token = cookies
        .where((cookie) => cookie.name == 'XSRF-TOKEN')
        .firstOrNull;
    final response = await _dio.post<dynamic>(
      'api/v1/auth/$path',
      data: data,
      options: Options(
        headers: {
          if (token != null) 'X-XSRF-TOKEN': Uri.decodeComponent(token.value),
        },
      ),
    );
    return response.data;
  }

  Future<BasmaUser> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    return _safe(() async {
      final data = await _post('login', {
        'email': email,
        'password': password,
        'remember': remember,
      });
      final user =
          (data as Map<String, dynamic>)['user'] as Map<String, dynamic>;
      return BasmaUser.fromJson(user);
    });
  }

  Future<BasmaUser> register({
    required String name,
    required String email,
    required String password,
    required String whatsapp,
    required int governorateId,
    required int cityId,
    required bool termsAccepted,
  }) async {
    return _safe(() async {
      final data = await _post('register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'whatsapp': whatsapp,
        'governorate_id': governorateId,
        'city_id': cityId,
        'terms_accepted': termsAccepted,
      });
      return BasmaUser.fromJson(
        (data as Map<String, dynamic>)['user'] as Map<String, dynamic>,
      );
    });
  }

  Future<void> forgotPassword(String email) => _safe(() async {
    await _post('forgot-password', {'email': email});
  });

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) => _safe(() async {
    await _post('reset-password', {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': password,
    });
  });

  Future<void> resendVerification(String email) => _safe(() async {
    await _post('resend-verification', {'email': email});
  });

  Future<List<BasmaRegion>> getGovernorates() => _safe(() async {
    final response = await _dio.get<dynamic>('api/v1/governorates');
    return (response.data as List<dynamic>)
        .map((item) => BasmaRegion.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<List<BasmaRegion>> getCities(int governorateId) => _safe(() async {
    final response = await _dio.get<dynamic>(
      'api/v1/governorates/$governorateId/cities',
    );
    return (response.data as List<dynamic>)
        .map((item) => BasmaRegion.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<BasmaUser> currentUser() => _safe(() async {
    final response = await _dio.get<dynamic>('api/v1/auth/user');
    final data = response.data as Map<String, dynamic>;
    return BasmaUser.fromJson(
      data.containsKey('user') ? data['user'] as Map<String, dynamic> : data,
    );
  });

  Future<void> logout() async {
    try {
      await _safe(() => _post('logout', {}));
    } finally {
      await _cookies.deleteAll();
      _csrfReady = false;
    }
  }

  Future<T> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      final response = error.response?.data;
      if (response is Map<String, dynamic>) {
        final errors = response['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            throw AuthApiException(first.first.toString());
          }
        }
        if (response['message'] is String) {
          throw AuthApiException(response['message'] as String);
        }
      }
      if (error.response?.statusCode == 419) {
        throw const AuthApiException('انتهت صلاحية الجلسة، حاول مرة أخرى');
      }
      if (error.response?.statusCode == 401) {
        throw const AuthApiException('بيانات الدخول غير صحيحة');
      }
      throw const AuthApiException(
        'تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا',
      );
    } on FormatException {
      throw const AuthApiException('استجابة غير صالحة من الخادم');
    } on TypeError {
      throw const AuthApiException('صيغة الاستجابة من الخادم غير متوقعة');
    }
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BasmaUser {
  const BasmaUser({
    required this.name,
    required this.email,
    required this.isEmailVerified,
  });
  final String name;
  final String email;
  final bool isEmailVerified;

  factory BasmaUser.fromJson(Map<String, dynamic> data) => BasmaUser(
    name: data['name'] as String,
    email: data['email'] as String,
    isEmailVerified: data['email_verified_at'] != null,
  );
}

class BasmaRegion {
  const BasmaRegion({required this.id, required this.name});
  final int id;
  final String name;

  factory BasmaRegion.fromJson(Map<String, dynamic> data) =>
      BasmaRegion(id: data['id'] as int, name: data['name'] as String);
}
), '')}/';
}

/// Contracts follow Basma-Platform/basma-web/src/services/authService.ts.
/// Laravel Sanctum uses a CSRF cookie and a session cookie, not an invented token.
class AuthService {
  AuthService._()
    : _cookies = CookieJar(),
      _dio = Dio(
        BaseOptions(
          baseUrl: _apiBaseUrl(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(CookieManager(_cookies));
  }

  static final AuthService instance = AuthService._();
  final Dio _dio;
  final CookieJar _cookies;
  bool _csrfReady = false;

  Future<void> _ensureCsrf() async {
    if (_csrfReady) return;
    await _dio.get<void>('sanctum/csrf-cookie');
    _csrfReady = true;
  }

  Future<dynamic> _post(String path, Map<String, dynamic> data) async {
    try {
      await _ensureCsrf();
      return await _sendPost(path, data);
    } on DioException catch (error) {
      if (error.response?.statusCode != 419) rethrow;
      _csrfReady = false;
      await _ensureCsrf();
      return _sendPost(path, data);
    }
  }

  Future<dynamic> _sendPost(String path, Map<String, dynamic> data) async {
    final cookies = await _cookies.loadForRequest(
      Uri.parse(_dio.options.baseUrl),
    );
    final token = cookies
        .where((cookie) => cookie.name == 'XSRF-TOKEN')
        .firstOrNull;
    final response = await _dio.post<dynamic>(
      'api/v1/auth/$path',
      data: data,
      options: Options(
        headers: {
          if (token != null) 'X-XSRF-TOKEN': Uri.decodeComponent(token.value),
        },
      ),
    );
    return response.data;
  }

  Future<BasmaUser> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    return _safe(() async {
      final data = await _post('login', {
        'email': email,
        'password': password,
        'remember': remember,
      });
      final user =
          (data as Map<String, dynamic>)['user'] as Map<String, dynamic>;
      return BasmaUser.fromJson(user);
    });
  }

  Future<BasmaUser> register({
    required String name,
    required String email,
    required String password,
    required String whatsapp,
    required int governorateId,
    required int cityId,
    required bool termsAccepted,
  }) async {
    return _safe(() async {
      final data = await _post('register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'whatsapp': whatsapp,
        'governorate_id': governorateId,
        'city_id': cityId,
        'terms_accepted': termsAccepted,
      });
      return BasmaUser.fromJson(
        (data as Map<String, dynamic>)['user'] as Map<String, dynamic>,
      );
    });
  }

  Future<void> forgotPassword(String email) => _safe(() async {
    await _post('forgot-password', {'email': email});
  });

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) => _safe(() async {
    await _post('reset-password', {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': password,
    });
  });

  Future<void> resendVerification(String email) => _safe(() async {
    await _post('resend-verification', {'email': email});
  });

  Future<List<BasmaRegion>> getGovernorates() => _safe(() async {
    final response = await _dio.get<dynamic>('api/v1/governorates');
    return (response.data as List<dynamic>)
        .map((item) => BasmaRegion.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<List<BasmaRegion>> getCities(int governorateId) => _safe(() async {
    final response = await _dio.get<dynamic>(
      'api/v1/governorates/$governorateId/cities',
    );
    return (response.data as List<dynamic>)
        .map((item) => BasmaRegion.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<BasmaUser> currentUser() => _safe(() async {
    final response = await _dio.get<dynamic>('api/v1/auth/user');
    final data = response.data as Map<String, dynamic>;
    return BasmaUser.fromJson(
      data.containsKey('user') ? data['user'] as Map<String, dynamic> : data,
    );
  });

  Future<void> logout() async {
    try {
      await _safe(() => _post('logout', {}));
    } finally {
      await _cookies.deleteAll();
      _csrfReady = false;
    }
  }

  Future<T> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      final response = error.response?.data;
      if (response is Map<String, dynamic>) {
        final errors = response['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            throw AuthApiException(first.first.toString());
          }
        }
        if (response['message'] is String) {
          throw AuthApiException(response['message'] as String);
        }
      }
      if (error.response?.statusCode == 419) {
        throw const AuthApiException('انتهت صلاحية الجلسة، حاول مرة أخرى');
      }
      if (error.response?.statusCode == 401) {
        throw const AuthApiException('بيانات الدخول غير صحيحة');
      }
      throw const AuthApiException(
        'تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا',
      );
    } on FormatException {
      throw const AuthApiException('استجابة غير صالحة من الخادم');
    } on TypeError {
      throw const AuthApiException('صيغة الاستجابة من الخادم غير متوقعة');
    }
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BasmaUser {
  const BasmaUser({
    required this.name,
    required this.email,
    required this.isEmailVerified,
  });
  final String name;
  final String email;
  final bool isEmailVerified;

  factory BasmaUser.fromJson(Map<String, dynamic> data) => BasmaUser(
    name: data['name'] as String,
    email: data['email'] as String,
    isEmailVerified: data['email_verified_at'] != null,
  );
}

class BasmaRegion {
  const BasmaRegion({required this.id, required this.name});
  final int id;
  final String name;

  factory BasmaRegion.fromJson(Map<String, dynamic> data) =>
      BasmaRegion(id: data['id'] as int, name: data['name'] as String);
}
