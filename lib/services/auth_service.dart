import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();


  Future<UserModel?> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
  
      if (password.length < 8) {
        throw Exception('Lozinka mora imati najmanje 8 karaktera.');
      }
      if (!_hasUpperCase(password)) {
        throw Exception('Lozinka mora sadržati barem jedno veliko slovo.');
      }
      if (!_hasDigit(password)) {
        throw Exception('Lozinka mora sadržati barem jednu cifru.');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Neispravan format email adrese.');
      }


      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) {
        throw Exception('Greška pri kreiranju korisnika.');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      final userModel = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
        role: UserRole.user,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          final signInResult = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          final user = signInResult.user;
          if (user == null) {
            throw Exception('Greška pri prijavljivanju.');
          }

          if (displayName != null && (user.displayName == null || user.displayName!.isEmpty)) {
            await user.updateDisplayName(displayName);
          }

          final userModel = UserModel(
            id: user.uid,
            email: email,
            displayName: displayName,
            role: UserRole.user,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap(), SetOptions(merge: true));

          return userModel;
        } on FirebaseAuthException catch (signInError) {
          throw _handleAuthException(signInError);
        }
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Greška pri registraciji: $e');
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) {
        throw Exception('Greška pri prijavljivanju.');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });

      return await getUserData(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Greška pri prijavljivanju: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Greška pri odjavljivanju: $e');
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Greška pri učitavanju podataka korisnika: $e');
    }
  }

  Stream<UserModel?> watchUserData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.name,
      });
    } catch (e) {
      throw Exception('Greška pri ažuriranju uloge: $e');
    }
  }


  Future<void> updateProfile({
    String? displayName,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('Korisnik nije prijavljen.');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
        });
      }
    } catch (e) {
      throw Exception('Greška pri ažuriranju profila: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Greška pri resetovanju lozinke: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
  
      await _firestore.collection('users').doc(userId).delete();
      
    
      await _deleteUserData(userId);
    } catch (e) {
      throw Exception('Greška pri brisanju korisnika: $e');
    }
  }

  Future<void> _deleteUserData(String userId) async {
    final batch = _firestore.batch();

    final exercises = await _firestore
        .collection('users')
        .doc(userId)
        .collection('exercises')
        .get();
    for (var doc in exercises.docs) {
      batch.delete(doc.reference);
    }

    final plans = await _firestore
        .collection('users')
        .doc(userId)
        .collection('plans')
        .get();
    for (var doc in plans.docs) {
      batch.delete(doc.reference);
    }

    final workouts = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .get();
    for (var doc in workouts.docs) {
      batch.delete(doc.reference);
    }

    final metrics = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bodyMetrics')
        .get();
    for (var doc in metrics.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _hasUpperCase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  bool _hasDigit(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Lozinka je previše slaba.';
      case 'email-already-in-use':
        return 'Email adresa je već u upotrebi.';
      case 'invalid-email':
        return 'Neispravan format email adrese.';
      case 'user-not-found':
        return 'Korisnik sa ovom email adresom ne postoji.';
      case 'wrong-password':
        return 'Pogrešna lozinka.';
      case 'user-disabled':
        return 'Ovaj nalog je onemogućen.';
      case 'too-many-requests':
        return 'Previše pokušaja. Pokušajte kasnije.';
      case 'operation-not-allowed':
        return 'Operacija nije dozvoljena.';
      default:
        return 'Greška pri autentikaciji: ${e.message}';
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju korisnika: $e');
    }
  }

  Stream<List<UserModel>> watchAllUsers() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
