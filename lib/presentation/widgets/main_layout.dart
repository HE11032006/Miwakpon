import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Layout principal avec AppBar globale et BottomNavigationBar.
///
/// Design Figma "Atelier Benin" :
/// - AppBar : titre "Miwakpon" centré (Newsreader), avatar profil à droite
/// - Navbar : 3 onglets (Feed, Events, Profile) avec effet de sélection arrondi
class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  /// La Shell de GoRouter qui gère l'état de la navigation par onglets
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppConstants.appName,
          style: GoogleFonts.newsreader(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _goBranch(2), // Aller vers le profil
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view,
                  label: 'Fil',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today,
                  label: 'Événements',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => _goBranch(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
