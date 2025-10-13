import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'dart:async';

// Mock User class for development
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  
  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.isAnonymous = false,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase instances (may be null if not available)
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  
  // Mock data for fallback
  MockUser? _mockCurrentUser;
  final StreamController<dynamic> _authStateController = StreamController<dynamic>.broadcast();
  final Map<String, UserModel> _mockUserData = {};
  
  bool _isFirebaseAvailable = false;

  // Initialize Firebase services if available
  void _initializeFirebase() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
      print('🔥 Using Firebase Auth');
    } catch (e) {
      print('📱 Firebase not available, using mock auth: $e');
      _isFirebaseAvailable = false;
      // Emit initial null state for mock mode
      Future.microtask(() => _authStateController.add(null));
    }
  }

  // Get current user (unified interface)
  dynamic get currentUser {
    _initializeFirebaseIfNeeded();
    return _isFirebaseAvailable ? _auth?.currentUser : _mockCurrentUser;
  }
  
  // Auth state changes stream (unified interface)
  Stream<dynamic> get authStateChanges {
    _initializeFirebaseIfNeeded();
    return _isFirebaseAvailable 
        ? _auth!.authStateChanges() 
        : _authStateController.stream;
  }

  void _initializeFirebaseIfNeeded() {
    if (_auth == null && _firestore == null) {
      _initializeFirebase();
    }
  }

  // Sign up with email and password
  Future<dynamic> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String state,
  }) async {
    _initializeFirebaseIfNeeded();
    
    if (_isFirebaseAvailable) {
      return _firebaseSignUp(email, password, name, state);
    } else {
      return _mockSignUp(email, password, name, state);
    }
  }

  // Sign in with email and password
  Future<dynamic> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _initializeFirebaseIfNeeded();
    
    if (_isFirebaseAvailable) {
      return _firebaseSignIn(email, password);
    } else {
      return _mockSignIn(email, password);
    }
  }

  // Sign in anonymously
  Future<dynamic> signInAnonymously() async {
    _initializeFirebaseIfNeeded();
    
    if (_isFirebaseAvailable) {
      return _firebaseSignInAnonymously();
    } else {
      return _mockSignInAnonymously();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _initializeFirebaseIfNeeded();
    
    if (_isFirebaseAvailable) {
      await _auth!.signOut();
    } else {
      _mockCurrentUser = null;
      _authStateController.add(null);
    }
  }

  // Firebase implementations
  Future<UserCredential?> _firebaseSignUp(String email, String password, String name, String state) async {
    try {
      UserCredential result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await _createFirebaseUserDocument(user, name, state);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase sign up error: ${e.message}');
      throw e;
    }
  }

  Future<UserCredential?> _firebaseSignIn(String email, String password) async {
    try {
      UserCredential result = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase sign in error: ${e.message}');
      throw e;
    }
  }

  Future<UserCredential?> _firebaseSignInAnonymously() async {
    try {
      UserCredential result = await _auth!.signInAnonymously();
      User? user = result.user;
      if (user != null) {
        await _createFirebaseUserDocument(user, 'Anonymous User', 'Unknown');
      }
      return result;
    } catch (e) {
      print('Firebase anonymous sign in error: $e');
      throw e;
    }
  }

  Future<void> _createFirebaseUserDocument(User user, String name, String state) async {
    try {
      await _firestore!.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': name,
        'state': state,
        'createdAt': FieldValue.serverTimestamp(),
        'totalScore': 0,
        'completedDrills': [],
        'streak': 0,
        'lastActiveDate': FieldValue.serverTimestamp(),
        'achievements': [],
        'profileImageUrl': '',
        'isAnonymous': user.isAnonymous,
      });
    } catch (e) {
      print('Error creating Firebase user document: $e');
      rethrow;
    }
  }

  // Mock implementations
  Future<MockUser?> _mockSignUp(String email, String password, String name, String state) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockUser = MockUser(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: name,
      );
      
      _mockUserData[mockUser.uid] = UserModel(
        uid: mockUser.uid,
        email: email,
        name: name,
        state: state,
        totalScore: 0,
        completedDrills: [],
        streak: 0,
        achievements: [],
        profileImageUrl: '',
        isAnonymous: false,
        createdAt: DateTime.now(),
        lastActiveDate: DateTime.now(),
      );
      
      _mockCurrentUser = mockUser;
      _authStateController.add(mockUser);
      
      return mockUser;
    } catch (e) {
      print('Mock sign up error: $e');
      rethrow;
    }
  }

  Future<MockUser?> _mockSignIn(String email, String password) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockUser = MockUser(
        uid: 'existing_user_${email.hashCode}',
        email: email,
        displayName: 'Test User',
      );
      
      if (!_mockUserData.containsKey(mockUser.uid)) {
        _mockUserData[mockUser.uid] = UserModel(
          uid: mockUser.uid,
          email: email,
          name: 'Test User',
          state: 'California',
          totalScore: 150,
          completedDrills: [],
          streak: 3,
          achievements: [],
          profileImageUrl: '',
          isAnonymous: false,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          lastActiveDate: DateTime.now(),
        );
      }
      
      _mockCurrentUser = mockUser;
      _authStateController.add(mockUser);
      
      return mockUser;
    } catch (e) {
      print('Mock sign in error: $e');
      rethrow;
    }
  }

  Future<MockUser?> _mockSignInAnonymously() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final mockUser = MockUser(
        uid: 'anonymous_${DateTime.now().millisecondsSinceEpoch}',
        displayName: 'Anonymous User',
        isAnonymous: true,
      );
      
      _mockUserData[mockUser.uid] = UserModel(
        uid: mockUser.uid,
        email: '',
        name: 'Anonymous User',
        state: 'Unknown',
        totalScore: 0,
        completedDrills: [],
        streak: 0,
        achievements: [],
        profileImageUrl: '',
        isAnonymous: true,
        createdAt: DateTime.now(),
        lastActiveDate: DateTime.now(),
      );
      
      _mockCurrentUser = mockUser;
      _authStateController.add(mockUser);
      
      return mockUser;
    } catch (e) {
      print('Mock anonymous sign in error: $e');
      rethrow;
    }
  }

  // Utility methods that work with both Firebase and Mock
  Future<UserModel?> getUserData() async {
    _initializeFirebaseIfNeeded();
    
    if (_isFirebaseAvailable) {
      return _getFirebaseUserData();
    } else {
      return _getMockUserData();
    }
  }

  Future<UserModel?> _getFirebaseUserData() async {
    try {
      User? user = _auth?.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore!.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting Firebase user data: $e');
      return null;
    }
  }

  UserModel? _getMockUserData() {
    try {
      if (_mockCurrentUser == null) return null;
      return _mockUserData[_mockCurrentUser!.uid];
    } catch (e) {
      print('Error getting mock user data: $e');
      return null;
    }
  }

  // Additional utility methods
  Future<void> updateScore(int additionalScore) async {
    _initializeFirebaseIfNeeded();
    
    if (_isFirebaseAvailable) {
      await _updateFirebaseScore(additionalScore);
    } else {
      _updateMockScore(additionalScore);
    }
  }

  Future<void> _updateFirebaseScore(int additionalScore) async {
    try {
      User? user = _auth?.currentUser;
      if (user == null) return;

      await _firestore!.collection('users').doc(user.uid).update({
        'totalScore': FieldValue.increment(additionalScore),
        'lastActiveDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating Firebase score: $e');
    }
  }

  void _updateMockScore(int additionalScore) {
    try {
      if (_mockCurrentUser == null) return;
      
      final userData = _mockUserData[_mockCurrentUser!.uid];
      if (userData != null) {
        _mockUserData[_mockCurrentUser!.uid] = userData.copyWith(
          totalScore: userData.totalScore + additionalScore,
          lastActiveDate: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error updating mock score: $e');
    }
  }

  // Helper methods for compatibility
  Future<void> resetPassword(String email) async {
    _initializeFirebaseIfNeeded();
    
    if (_isFirebaseAvailable) {
      try {
        await _auth!.sendPasswordResetEmail(email: email);
      } catch (e) {
        print('Firebase password reset error: $e');
        throw e;
      }
    } else {
      // Mock - just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  String? getCurrentUserId() {
    final user = currentUser;
    if (user is User) {
      return user.uid;
    } else if (user is MockUser) {
      return user.uid;
    }
    return null;
  }

  String? getCurrentUserEmail() {
    final user = currentUser;
    if (user is User) {
      return user.email;
    } else if (user is MockUser) {
      return user.email;
    }
    return null;
  }

  bool get isFirebaseEnabled => _isFirebaseAvailable;
}