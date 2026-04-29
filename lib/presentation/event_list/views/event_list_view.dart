import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/event_list_viewmodel.dart';

class AppColors {
  static const Color primary = Color(0xFF8C4B00);
  static const Color secondary = Color(0xFF4C56AF);
  static const Color canvasWhite = Color(0xFFFDFBFA);
  static const Color outline = Color(0xFF877365);
  
  static const Color cardOrange = Color(0xFFB9732A);
  static const Color cardBlue = Color(0xFF8D96E9);
  static const Color cardPeach = Color(0xFFFDB981);
}

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Consumer<EventListViewModel>(
        builder: (context, viewModel, child) {
          final events = viewModel.events;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Découvrir les événements',
                        style: GoogleFonts.newsreader(
                          fontSize: 26, 
                          fontWeight: FontWeight.w600, 
                          color: AppColors.primary
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Explorez les rythmes culturels et les rencontres façonnés par notre communauté.',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16, 
                          height: 1.4,
                          color: Colors.black87.withOpacity(0.7)
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (viewModel.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (events.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy, size: 50, color: AppColors.outline),
                        const SizedBox(height: 16),
                        Text(
                          "Pas d'événements pour le moment",
                          style: GoogleFonts.beVietnamPro(
                            color: AppColors.outline, 
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = events[index];
                      final List<Color> colors = [
                        AppColors.cardOrange, 
                        AppColors.cardBlue, 
                        AppColors.cardPeach
                      ];
                      final Color cardColor = colors[index % colors.length];
                      return _eventCard(context, event, cardColor);
                    },
                    childCount: events.length,
                  ),
                ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _eventCard(BuildContext context, dynamic event, Color bgColor) {
    const List<String> months = [
      "JAN", "FEV", "MAR", "AVR", "MAI", "JUN",
      "JUL", "AOU", "SEP", "OCT", "NOV", "DEC"
    ];
    final String monthStr = months[event.dateTime.month - 1];
    final String dayStr = event.dateTime.day.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () => context.push('/events/detail/${event.id}'),
      child: Container(
        height: 240,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          image: event.imageUrl != null && event.imageUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(event.imageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Stack(
          children: [
            if (event.imageUrl == null || event.imageUrl!.isEmpty)
              Positioned(
                right: -20,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(200),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          "$monthStr $dayStr",
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.white, 
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.title,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined, 
                        size: 16, 
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}