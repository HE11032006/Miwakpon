import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/supabase_config.dart';
import '../viewmodels/event_detail_viewmodel.dart';
import '../../participation/viewmodels/participation_viewmodel.dart';
import '../../participation/views/participation_view.dart';
import '../../creation/views/create_event_view.dart';
import '../../../data/models/event_model.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';

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
          if (viewModel.isLoading && viewModel.event == null) {
            return const _DetailSkeleton();
          }

          final event = viewModel.event;
          if (event == null) {
            return const Center(child: Text("Evenement introuvable"));
          }

          final currentUserId = SupabaseConfig.currentUser?.id;
          final isCreator = currentUserId == event.organizerId;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Image de couverture
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
                            // Overlay degrade
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    event.title,
                                    style: GoogleFonts.newsreader(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.white70, size: 16),
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

                  // Section participants et boutons
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(32, 24, 32, 32),
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
                              _participantsAvatars(viewModel),
                              Text(
                                "Inscrits",
                                style: GoogleFonts.beVietnamPro(
                                  color: AppColors.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Boutons join/leave uniquement si pas createur
                          if (!isCreator) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final error = viewModel.isParticipating
                                      ? await viewModel.leaveEvent()
                                      : await viewModel.joinEvent();
                                  if (error != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error)),
                                    );
                                  }
                                },
                                icon: Icon(
                                  viewModel.isParticipating
                                      ? Icons.cancel_outlined
                                      : Icons.check_circle_outline,
                                  size: 20,
                                ),
                                label: Text(
                                  viewModel.isFull && !viewModel.isParticipating
                                      ? "COMPLET"
                                      : viewModel.isParticipating
                                          ? "QUITTER EVENEMENT"
                                          : "REJOINDRE EVENEMENT",
                                  style: const TextStyle(letterSpacing: 1.1),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: viewModel.isParticipating
                                      ? AppColors.error
                                      : viewModel.isFull
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
                          ],
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider(
                                    create: (_) => ParticipationViewModel(),
                                    child: ParticipationView(
                                        eventId: widget.eventId),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Voir les ${viewModel.participantCount} participant${viewModel.participantCount > 1 ? 's' : ''}',
                              style: TextStyle(color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Description, Lieu, Organisateur
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _sectionHeader(Icons.info_outline, "A propos"),
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
                        _sectionHeader(Icons.location_on_outlined, "Lieu"),
                        _divider(),
                        const SizedBox(height: 12),
                        _locationCard(event.location),
                        const SizedBox(height: 40),
                        _sectionHeader(Icons.person_outline, "Organisateur"),
                        const SizedBox(height: 16),
                        _hostCard(event),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),

              // Bouton retour
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
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Retour',
                    ),
                  ),
                ),
              ),

              // Menu 3 points (uniquement si createur)
              if (isCreator)
                Positioned(
                  top: 50,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateEventView(
                                  editEvent: event,
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer l\'evenement'),
                                content: const Text('Voulez-vous vraiment supprimer cet evenement ? Cette action est irreversible.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('ANNULER'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              final error = await viewModel.deleteEvent();
                              if (error == null && context.mounted) {
                                Navigator.pop(context); // Retour au feed
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Evenement supprime avec succes')),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error!)),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Text(
                                  'Modifier l\'evenement',
                                  style: GoogleFonts.beVietnamPro(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                const SizedBox(width: 10),
                                Text(
                                  'Supprimer l\'evenement',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  /// Avatars des participants reels
  Widget _participantsAvatars(EventDetailViewModel viewModel) {
    final count = viewModel.participantCount;
    final avatars = viewModel.participantAvatars;

    if (count == 0) {
      return Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: const Icon(Icons.person_outline,
                size: 18, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Text(
            'Aucun inscrit',
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: 120,
      height: 35,
      child: Stack(
        children: [
          for (var i = 0; i < (count > 3 ? 3 : count); i++)
            Positioned(
              left: i * 20,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  backgroundImage: i < avatars.length && avatars[i] != null
                      ? NetworkImage(avatars[i]!)
                      : null,
                  child: (i >= avatars.length || avatars[i] == null)
                      ? const Icon(Icons.person,
                          size: 16, color: AppColors.primary)
                      : null,
                ),
              ),
            ),
          if (count > 3)
            Positioned(
              left: 65,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFF0F0F0),
                child: Text(
                  '+${count - 3}',
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
            color: AppColors.onSurface,
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
            child: const Icon(Icons.map_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location,
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: const Color(0xFF1D1B20),
                    )),
                Text("Benin",
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF49454F),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hostCard(EventModel event) {
    final currentUserId = SupabaseConfig.currentUser?.id;
    final isMe = currentUserId == event.organizerId;

    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, _) {
        final name = isMe ? profileVM.displayName : (event.organizerName ?? "Utilisateur Miwakpon");
        final avatar = isMe ? profileVM.avatarUrl : event.organizerAvatarUrl;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceContainerHigh,
                backgroundImage: avatar != null && avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: avatar == null || avatar.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.onSurface,
                        )),
                    Text("Organisateur de l'evenement",
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.black54,
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailSkeleton extends StatefulWidget {
  const _DetailSkeleton();

  @override
  State<_DetailSkeleton> createState() => _DetailSkeletonState();
}

class _DetailSkeletonState extends State<_DetailSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.5, end: 1.0).animate(_controller),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Container(
                height: 400,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(24)),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Container(width: double.infinity, height: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 32),
                    Container(width: 100, height: 20, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 12),
                    Container(width: double.infinity, height: 100, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
