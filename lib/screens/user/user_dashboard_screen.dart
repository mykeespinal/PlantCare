import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'about_app_screen.dart';
import 'categories_screen.dart';
import 'search_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(const ['Explorar', 'Buscar', 'Favoritos', 'Mi perfil'][_selectedTab]),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: AuthService.instance.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: switch (_selectedTab) {
        0 => _dashboard(),
        1 => const SearchScreen(),
        2 => FavoritesScreen(uid: uid),
        _ => ProfileScreen(uid: uid),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _dashboard() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [forestGreen, Color(0xFF397354)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido a tu espacio natural',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Explora el conocimiento de las plantas '
                              'medicinales de forma sencilla y responsable.',
                              style: TextStyle(
                                color: Color(0xFFEAF3E8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.eco_outlined,
                        size: 48,
                        color: Color(0xFFEAF3E8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _exploreAction(
                  context,
                  icon: Icons.volunteer_activism_outlined,
                  title: 'Misión, visión y objetivo',
                  subtitle: 'Conoce el propósito de esta aplicación',
                  primary: true,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutAppScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _exploreAction(
                  context,
                  icon: Icons.grid_view_rounded,
                  title: 'Ver categorías',
                  subtitle: 'Encuentra recetas por tema o necesidad',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CategoriesScreen(),
                    ),
                  ),
                ),
      ],
    );
  }

  Widget _exploreAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    final foreground = primary ? Colors.white : forestGreen;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: primary ? forestGreen : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: foreground, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: foreground.withValues(
                            alpha: primary ? 0.82 : 0.72,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: foreground, size: 17),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
