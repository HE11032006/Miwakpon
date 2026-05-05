import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../profile/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.navigationShell,
  });

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
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF9),
        elevation: 0,
        centerTitle: true,
        // Shadow at the bottom of the appbar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icons/sans_fond.jpg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        leadingWidth: 64,
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
              onTap: () => _goBranch(2), // Profil
              child: Consumer<ProfileViewModel>(
                builder: (context, profileVM, _) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      backgroundImage: profileVM.avatarUrl != null && profileVM.avatarUrl!.isNotEmpty
                          ? NetworkImage(profileVM.avatarUrl!)
                          : null,
                      child: profileVM.avatarUrl == null || profileVM.avatarUrl!.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 20,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          // 1. Le contenu principal
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: navigationShell,
          ),
          
          // 2. Le bouton FAB (Affiché uniquement sur le FEED)
          if (navigationShell.currentIndex == 0)
            Positioned(
              right: (MediaQuery.of(context).size.width / 6) - 28,
              bottom: 75, // Ancré sur le bord supérieur (90 - 28)
              child: GestureDetector(
                onTap: () => context.push(AppConstants.createEventRoute),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C4B00),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFB77C).withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8C4B00).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),

          // 3. La Navbar (Placée en dernier pour être au-dessus du bas du bouton)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAF9),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFCC7722),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                    spreadRadius: -15, // Ombre très subtile
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    _navItem(
                      context,
                      index: 0,
                      icon: Icons.grid_view_outlined,
                      selectedIcon: Icons.grid_view_rounded,
                      label: 'FEED',
                    ),
                    _navItem(
                      context,
                      index: 1,
                      icon: Icons.calendar_today_outlined,
                      selectedIcon: Icons.calendar_today_rounded,
                      label: 'EVENTS',
                    ),
                    _navItem(
                      context,
                      index: 2,
                      icon: Icons.person_outline,
                      selectedIcon: Icons.person_rounded,
                      label: 'PROFILE',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = navigationShell.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _goBranch(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFED7AA).withValues(alpha: 0.4)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected ? const Color(0xFF7C2D12) : const Color(0xFFA8A29E),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF7C2D12) : const Color(0xFFA8A29E),
                letterSpacing: 0.5,
              ),
            ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
