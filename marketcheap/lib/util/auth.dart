import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient, Supabase, AuthProvider;


class Auth {
  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 1. Iniciar sesión con email y contraseña
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // 2. Registrarse con email
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Error al registrarse: $e');
      return null;
    }
  }

  // 3. Iniciar sesión con proveedor (Google/Facebook)
  Future<void> signInWithProvider(String provider) async {
   
    try {
      OAuthProvider? providerEnum;
      switch (provider.toLowerCase()) {
        case 'google':
          providerEnum = OAuthProvider.google;
          break;
        case 'facebook':
          providerEnum = OAuthProvider.facebook;
          break;
        default:
          throw Exception('Proveedor no soportado');
      }

      await supabase.auth.signInWithOAuth(
        providerEnum!,
        redirectTo: 'com.googleusercontent.apps.644370726477-l0a05u6pfsjnhggefmqcb13pgrkvm3u8:/auth/callback',
      );
    } catch (e) {
      print('Error con $provider: $e');
    }
  }

  // 4. Cerrar sesión
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // 5. Obtener usuario actual
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // 6. Verificar si hay sesión activa
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  // 7. Enviar enlace mágico (opcional)
  Future<void> sendMagicLink(String email) async {
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'tu-scheme://auth-callback',
      );
    } catch (e) {
      print('Error al enviar enlace mágico: $e');
    }
  }
  Future<User?> signInWithGoogle() async {
  await signInWithProvider('google');
  return supabase.auth.currentUser;
}

Future<User?> signInWithFacebook() async {
  await signInWithProvider('facebook');
  return supabase.auth.currentUser;
}



}