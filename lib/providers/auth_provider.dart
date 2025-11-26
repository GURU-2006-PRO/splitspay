import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthState() async {
    _setLoading(true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // Fetch full profile from DB
        final profile = await _dbService.getUserById(user.id);
        _currentUser = profile ?? user; // Fallback to auth user if profile missing
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      User authUser = await _authService.signInWithEmail(email, password);
      
      // Check if profile exists
      User? profile = await _dbService.getUserById(authUser.id);
      
      if (profile == null) {
        // First time user, create profile
        await _dbService.createUserProfile(authUser);
        _currentUser = authUser;
      } else {
        _currentUser = profile;
      }
      
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      User authUser = await _authService.signUpWithEmail(email, password, name);
      
      // Create user profile in database
      await _dbService.createUserProfile(authUser);
      _currentUser = authUser;
      
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
