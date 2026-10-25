import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantas/main.dart';
import 'package:plantas/screens/auth/login_screen.dart';
import 'package:plantas/screens/user/about_app_screen.dart';
import 'package:plantas/screens/user/profile_edit_screen.dart';

void main() {
  testWidgets('shows Firebase setup instructions when not configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      const PlantasApp(startupError: 'Firebase no está configurado.'),
    );

    expect(find.text('Configuración requerida'), findsOneWidget);
    expect(
      find.textContaining('Firebase no está configurado.'),
      findsOneWidget,
    );
  });

  testWidgets('shows email and Google sign-in options', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
  });

  testWidgets('shows the app mission, vision, and objective', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutAppScreen()));

    expect(find.text('Misión'), findsOneWidget);
    expect(find.text('Visión'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Objetivo de la aplicación'),
      300,
    );
    expect(find.text('Objetivo de la aplicación'), findsOneWidget);
  });

  testWidgets('shows account details in the profile edit form', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileEditScreen(
          uid: 'user-1',
          nombre: 'Ana',
          apellidos: 'Verde',
          email: 'ana@example.com',
          role: 'user',
        ),
      ),
    );

    expect(find.text('Actualizar mis datos'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
  });
}
