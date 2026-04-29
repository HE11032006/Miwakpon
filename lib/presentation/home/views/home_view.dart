import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../data/models/event_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const AppLoadingIndicator();
          }

          if (viewModel.errorMessage != null) {
            return AppErrorWidget(message: viewModel.errorMessage!);
          }

          final userEvents = viewModel.userEvents;
          final latestEvents = viewModel.latestEvents;

          return CustomScrollView(
            slivers: [
              // ======================== HEADER ========================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tableau de bord',
                        style: GoogleFonts.newsreader(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bienvenue sur votre espace artisanat',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ======================== FEATURED / TOP 3 GLOBAL ========================
              if (viewModel.featuredEvents.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Le Premier en Grand
                      _FeaturedEventCard(event: viewModel.featuredEvents[0]),
                      
                      // Les autres en format normal (horizontal)
                      if (viewModel.featuredEvents.length > 1)
                        SizedBox(
                          height: 260, // Hauteur augmentée
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: viewModel.featuredEvents.length - 1,
                            itemBuilder: (context, index) {
                              return _NormalEventCard(event: viewModel.featuredEvents[index + 1]);
                            },
                          ),
                        ),
                    ],
                  ),
                ),

              // ======================== LATER THIS MONTH (USER EVENTS) ========================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'Mes Événements',
                    style: GoogleFonts.newsreader(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),

              if (latestEvents.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: AppEmptyState(message: 'Aucune actualité disponible'),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5E2E1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(latestEvents.length, (index) {
                        final event = latestEvents[index];
                        final isLast = index == latestEvents.length - 1;

                        return Column(
                          children: [
                            _LatestEventItem(event: event),
                            if (!isLast) const _HorizontalDivider(),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  }


/// Grand cadre en vedette pour le premier événement du Feed
class _FeaturedEventCard extends StatelessWidget {
  final EventModel event;
  const _FeaturedEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/detail/${event.id}'),
      child: Container(
        width: double.infinity,
        height: 400, // Retour à une grande taille immersive
        margin: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(
            image: event.imageUrl != null && event.imageUrl!.isNotEmpty
                ? NetworkImage(event.imageUrl!)
                : const AssetImage('assets/images/background.jpg') as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: AppColors.shadowMedium,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // Un blanc un peu plus "doux" et légèrement transparent
                  color: Colors.white.withValues(alpha: 0.72), 
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _badge('À LA UNE', const Color(0xFFFFEBD6), const Color(0xFF8C4B00)),
                    const SizedBox(height: 12),
                    Text(
                      event.title,
                      style: GoogleFonts.newsreader(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D1B20),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF8C4B00), size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 14,
                              color: const Color(0xFF49454F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.beVietnamPro(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// Carte normale (plus petite) pour les événements suivants
class _NormalEventCard extends StatelessWidget {
  final EventModel event;
  const _NormalEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/detail/${event.id}'),
      child: Container(
        width: 310,
        margin: const EdgeInsets.only(left: 10, right: 8, bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(
            image: event.imageUrl != null && event.imageUrl!.isNotEmpty
                ? NetworkImage(event.imageUrl!)
                : const AssetImage('assets/images/background.jpg') as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.newsreader(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item de liste verticale pour les derniers événements
class _LatestEventItem extends StatelessWidget {
  final EventModel event;
  const _LatestEventItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/detail/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.transparent, // Pour capturer les taps sur toute la zone
        child: Row(
          children: [
            // Boîte de date
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.dateTime.day}',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D1B20),
                    ),
                  ),
                  Text(
                    _getMonthAbbreviation(event.dateTime.month),
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF49454F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Image miniature (si disponible)
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(event.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D1B20),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      color: const Color(0xFF49454F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF49454F)),
          ],
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}

/// Séparateur horizontal avec dégradé linéaire selon le SVG
class _HorizontalDivider extends StatelessWidget {
  const _HorizontalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x008C4B00), // Transparent
            Color(0x4D8C4B00), // 30% d'opacité (0.3 * 255 = 77 -> 4D en hexa)
            Color(0x008C4B00), // Transparent
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}
