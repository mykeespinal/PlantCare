import 'package:firebase_auth/firebase_auth.dart';

String friendlyError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'email-already-in-use' => 'Ese correo ya está registrado.',
      'invalid-email' => 'El correo no tiene un formato válido.',
      'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Correo o contraseña incorrectos.',
      'too-many-requests' => 'Demasiados intentos. Inténtalo más tarde.',
      'network-request-failed' => 'Revisa tu conexión a internet.',
      'account-exists-with-different-credential' =>
        'Ya existe una cuenta con este correo usando otro método de acceso.',
      'popup-closed-by-user' => 'Cerraste la ventana de inicio de sesión.',
      'web-context-canceled' => 'Cancelaste el inicio de sesión.',
      'user-cancelled' => 'Cancelaste el inicio de sesión.',
      'operation-not-allowed' =>
        'El acceso con Google no está habilitado en Firebase.',
      _ => error.message ?? 'No se pudo completar la operación.',
    };
  }
  return error.toString();
}
