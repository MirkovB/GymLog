import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isGuest => _user == null;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Retry logika za učitavanje podataka iz Firestore-a
      // jer može postojati latencija nakon registracije
      UserModel? userData;
      int retries = 0;
      const maxRetries = 5;

      while (retries < maxRetries && userData == null) {
        try {
          userData = await _authService.getUserData(userId);
          if (userData != null) break;
        } catch (e) {
          // Ako dokument ne postoji, sačekamo malo i pokušamo ponovo
          if (retries < maxRetries - 1) {
            await Future.delayed(Duration(milliseconds: 500 * (retries + 1)));
          }
        }
        retries++;
      }

      _user = userData;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _user = null;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      await _loadUserData(userId);
    }
  }

  // Direktno setuje korisnika bez čekanja na auth state changes
  void setUser(UserModel user) {
    _user = user;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
