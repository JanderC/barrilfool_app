import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:barrilfood_app/api/auth_api.dart';
import 'package:barrilfood_app/models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isInitializing = true;
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _token;
  
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get token => _token;
  int get userRole => _currentUser?.rolId ?? 4; // Default to client role
  
  AuthProvider() {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    final storedToken = await _storage.read(key: 'bearer');
    
    if (storedToken != null) {
      try {
        final userData = await _authApi.checkToken(storedToken);
        _token = storedToken;
        _currentUser = userData;
        _isAuthenticated = true;
      } catch (e) {
        await _storage.delete(key: 'bearer');
      }
    }
    
    _isInitializing = false;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    try {
      final authData = await _authApi.login(email, password);
      
      _token = authData['access_token'];
      _currentUser = User.fromJson(authData['user']);
      _isAuthenticated = true;
      
      await _storage.write(key: 'bearer', value: _token);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> registerCustomer(Map<String, dynamic> userData) async {
    try {
      final authData = await _authApi.registerCustomer(userData);
      
      _token = authData['access_token'];
      _currentUser = User.fromJson(authData['user']);
      _isAuthenticated = true;
      
      await _storage.write(key: 'bearer', value: _token);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'bearer');
    
    _token = null;
    _currentUser = null;
    _isAuthenticated = false;
    
    notifyListeners();
  }
}
