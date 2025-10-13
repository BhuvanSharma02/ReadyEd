import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String state,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);
        
        // Create user document in Firestore
        await _createUserDocument(user, name, state);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error during sign up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  // Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      
      User? user = result.user;
      if (user != null) {
        // Create anonymous user document
        await _createUserDocument(user, 'Anonymous User', 'Unknown');
      }
      
      return result;
    } catch (e) {
      print('Anonymous sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      throw e;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete the user account
        await user.delete();
      }
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name, String state) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
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
      print('Error creating user document: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update(data);
      }
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // Update user's total score
  Future<void> updateScore(int additionalScore) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'totalScore': FieldValue.increment(additionalScore),
        'lastActiveDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating score: $e');
      rethrow;
    }
  }

  // Add completed drill
  Future<void> addCompletedDrill(String drillId, int score) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'completedDrills': FieldValue.arrayUnion([{
          'drillId': drillId,
          'score': score,
          'completedAt': FieldValue.serverTimestamp(),
        }]),
        'totalScore': FieldValue.increment(score),
        'lastActiveDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding completed drill: $e');
      rethrow;
    }
  }

  // Update user's streak
  Future<void> updateStreak() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return;

      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      DateTime? lastActiveDate = userData['lastActiveDate']?.toDate();
      int currentStreak = userData['streak'] ?? 0;

      DateTime today = DateTime.now();
      int newStreak = currentStreak;

      if (lastActiveDate != null) {
        DateTime lastActiveDay = DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
        DateTime todayDay = DateTime(today.year, today.month, today.day);
        
        int daysDifference = todayDay.difference(lastActiveDay).inDays;
        
        if (daysDifference == 1) {
          // Consecutive day - increment streak
          newStreak = currentStreak + 1;
        } else if (daysDifference > 1) {
          // Missed days - reset streak
          newStreak = 1;
        }
        // If daysDifference == 0, it's the same day, keep current streak
      } else {
        // First time user - start streak
        newStreak = 1;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'streak': newStreak,
        'lastActiveDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating streak: $e');
      rethrow;
    }
  }

  // Update user's state
  Future<void> updateUserState(String state) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'state': state,
        });
      }
    } catch (e) {
      print('Error updating user state: $e');
      rethrow;
    }
  }

  // Check if email is already in use
  Future<bool> isEmailInUse(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Error sending email verification: $e');
      rethrow;
    }
  }

  // Check if current user's email is verified
  bool get isEmailVerified {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Reload user data
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Error reloading user: $e');
    }
  }
}