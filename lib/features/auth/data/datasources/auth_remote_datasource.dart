import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final userDoc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(firebaseUser.uid)
        .get();

    if (!userDoc.exists) return null;

    return UserModel.fromFirestore(userDoc);
  }

  // Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign In cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      // Create user model
      final userModel = UserModel.fromFirebaseUser(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email!,
        photoUrl: firebaseUser.photoURL,
      );

      // Save to Firestore (if new user)
      await _saveUserToFirestore(userModel);

      return userModel;
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  // Sign in with Email/Password
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // Get user from Firestore
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      // ✅ FIX: Si el documento no existe, créalo
      if (!userDoc.exists) {
        final userModel = UserModel.fromFirebaseUser(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? email.split('@')[0],
          email: firebaseUser.email!,
          photoUrl: firebaseUser.photoURL,
        );

        await _saveUserToFirestore(userModel);
        return userModel;
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }


  // Sign up with Email/Password
  // Sign up with Email/Password
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user model
      final userModel = UserModel.fromFirebaseUser(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        photoUrl: null,
      );

      // ✅ MEJORADO: Usar set con merge en lugar de confiar en _saveUserToFirestore
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(userModel.toFirestore(), SetOptions(merge: false));

      return userModel;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Auth state changes stream
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    });
  }

  // Helper: Save user to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    final userRef = _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.id);

    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      // New user - create document
      await userRef.set(user.toFirestore());
    } else {
      // Existing user - update basic info only
      await userRef.update({
        FirebaseConstants.userNameField: user.name,
        FirebaseConstants.userEmailField: user.email,
        FirebaseConstants.userPhotoUrlField: user.photoUrl,
      });
    }
  }
}