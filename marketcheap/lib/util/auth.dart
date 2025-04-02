import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;



class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registro con email y contraseña
  Future<String?> createAccount(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('La contraseña es muy débil.');
      } else if (e.code == 'email-already-in-use') {
        print('Ya existe una cuenta con ese correo.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Inicio de sesión con email y contraseña
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Inicio de sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        return await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      print('Error en Google Sign-In: $e');
      return null;
    }
  }


  // Inicio de sesión con Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      if (kIsWeb) {
        final facebookProvider = FacebookAuthProvider();
        return await FirebaseAuth.instance.signInWithPopup(facebookProvider);
      } else {
        final LoginResult result = await FacebookAuth.instance.login();
        if (result.status != LoginStatus.success) return null;

        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        return await FirebaseAuth.instance.signInWithCredential(facebookCredential);
      }
    } catch (e) {
      print('Error en Facebook Sign-In: $e');
      return null;
    }
  }


  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // opcional
    await FacebookAuth.instance.logOut(); // opcional
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
