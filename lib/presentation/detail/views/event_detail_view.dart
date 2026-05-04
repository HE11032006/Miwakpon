import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/event_detail_viewmodel.dart';
import '../../participation/viewmodels/participation_viewmodel.dart';
import '../../participation/views/participation_view.dart';

class EventDetailView extends StatefulWidget {
  final String eventId;
  const EventDetailView({super.key, required this.eventId});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EventDetailViewModel>().loadEvent(widget.eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Consumer<EventDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final event = viewModel.event;
          if (event == null) {
            return const Center(child: Text("Événement introuvable"));
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        image: event.imageUrl != null 
                          ? DecorationImage(
                              image: NetworkImage(event.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Overlay dégradé pour la lisibilité
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end, // Texte en bas pour mieux voir l'image
                                children: [
                                  Text(
                                    event.title,
                                    style: GoogleFonts.newsreader(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white, // Texte en blanc sur l'overlay
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.location,
                                        style: GoogleFonts.beVietnamPro(
                                          fontSize: 14,
                                          color: Colors.white70,
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
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(32, 24, 32, 32), // Plus d'espace en haut
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _avatarStack(viewModel.participantCount),
                              Text(
                                "Attending",
                                style: GoogleFonts.beVietnamPro(
                                  color: AppColors.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Consumer<EventDetailViewModel>(
  builder: (context, vm, _) {
    final isFull = vm.isFull && !vm.isParticipating;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isFull
                ? null
                : () async {
                    final error = vm.isParticipating
                        ? await vm.leaveEvent()
                        : await vm.joinEvent();
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
            icon: Icon(
              vm.isParticipating
                  ? Icons.cancel_outlined
                  : Icons.check_circle_outline,
              size: 20,
            ),
            label: Text(
              isFull
                  ? "COMPLET"
                  : vm.isParticipating
                      ? "LEAVE EVENT"
                      : "JOIN EVENT",
              style: const TextStyle(letterSpacing: 1.1),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: vm.isParticipating
                  ? AppColors.error
                  : isFull
                      ? AppColors.surfaceDim
                      : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => ParticipationViewModel(),
                  child: ParticipationView(eventId: widget.eventId),
                ),
              ),
            );
          },
          child: Text(
            'Voir les ${vm.participantCount} participant${vm.participantCount > 1 ? 's' : ''}',
            style: TextStyle(color: AppColors.secondary),
          ),
        ),
      ],
    );
  },
),
                        ],
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _sectionHeader(Icons.info_outline, "About"),
                        
                        _divider(),
                        const SizedBox(height: 12),
                        Text(
                          event.description,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 15,
                            height: 1.7,
                            color: const Color(0xFF1D1B20).withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 24),                       
                        _sectionHeader(Icons.location_on_outlined, "Location"),
                        _divider(),
                        const SizedBox(height: 12),
                        _locationCard(event.location),
                        const SizedBox(height: 40),
                        
                        
                        _sectionHeader(Icons.person_outline, "Host"),
                        const SizedBox(height: 16),
                        _hostCard(event),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),

              Positioned(
                top: 50,
                left: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Retour',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.newsreader(
            fontSize: 24, 
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface, // Couleur plus foncée
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.0),
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

Widget _avatarStack(int participantCount) {
  return SizedBox(
    width: 120,
    height: 35,
    child: Stack(
      children: [
        for (var i = 0; i < 3; i++)
          Positioned(
            left: i * 20,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=user$i'),
              ),
            ),
          ),
        Positioned(
          left: 65,
          child: CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFF0F0F0),
            child: Text(
              participantCount > 3 ? '+${participantCount - 3}' : '',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _locationCard(String location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location, 
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w700, 
                    fontSize: 17,
                    color: const Color(0xFF1D1B20),
                  )
                ),
                Text(
                  "Abomey, Benin", 
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF49454F), 
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  )
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "VIEW MAP", 
                    style: GoogleFonts.beVietnamPro(
                      color: AppColors.primary, 
                      fontWeight: FontWeight.w800, 
                      fontSize: 12,
                      letterSpacing: 1.1,
                    )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hostCard(dynamic event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.organizerName ?? "Artisan Miwakpon", 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.bold, 
                        fontSize: 17,
                        color: AppColors.onSurface,
                      )
                    ),
                    const Text("Organisateur de l'événement", style: TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Contact Host", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

class GeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 15; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.3),
        i * 20.0, 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}