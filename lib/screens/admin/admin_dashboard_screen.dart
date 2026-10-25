import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../user/profile_screen.dart';
import 'categories_admin_screen.dart';
import 'recipes_admin_screen.dart';
import 'users_admin_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pages = [
      const UsersAdminScreen(),
      const CategoriesAdminScreen(),
      const RecipesAdminScreen(),
      ProfileScreen(uid: uid),
    ];
    const titles = ['Administración', 'Categorías', 'Recetas', 'Mi perfil'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: AuthService.instance.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            label: 'Usuarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Recetas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
