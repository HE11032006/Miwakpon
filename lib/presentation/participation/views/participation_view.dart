import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/participation_viewmodel.dart';
import '../../../core/theme/app_colors.dart';

class ParticipationView extends StatefulWidget {
  final String eventId;
  const ParticipationView({super.key, required this.eventId});

  @override
  State<ParticipationView> createState() => _ParticipationViewState();
}

class _ParticipationViewState extends State<ParticipationView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ParticipationViewModel>().loadParticipants(widget.eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Participants',
          style: GoogleFonts.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Consumer<ParticipationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(color: AppColors.error),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => vm.loadParticipants(widget.eventId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (vm.participants.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: AppColors.outline.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun participant pour le moment.',
                    style: GoogleFonts.beVietnamPro(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Recapitulatif du nombre
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.group_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          '${vm.count} personne${vm.count > 1 ? 's' : ''} inscrite${vm.count > 1 ? 's' : ''}',
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Liste des participants
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = vm.participants[index];
                      final userData = p['users'] as Map<String, dynamic>?;
                      final name = userData?['display_name'] ??
                          userData?['username'] ??
                          'Anonyme';
                      final avatarUrl = userData?['avatar_url'] as String?;
                      final joinedAt = p['joined_at'] != null
                          ? DateTime.tryParse(p['joined_at'])
                          : null;

                      return _ParticipantTile(
                        name: name,
                        avatarUrl: avatarUrl,
                        joinedAt: joinedAt,
                        isLast: index == vm.participants.length - 1,
                      );
                    },
                    childCount: vm.participants.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final DateTime? joinedAt;
  final bool isLast;

  const _ParticipantTile({
    required this.name,
    this.avatarUrl,
    this.joinedAt,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Avatar avec ombre
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (joinedAt != null)
                      Text(
                        'A rejoint le ${_formatDate(joinedAt!)}',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              // Status chip
              const _StatusChip(confirmed: true),
            ],
          ),
        ),
        if (!isLast)
          // Separateur style brushstroke (degrade subtil)
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.0),
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final bool confirmed;
  const _StatusChip({required this.confirmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: confirmed
            ? AppColors.secondary.withValues(alpha: 0.1)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        confirmed ? 'Confirme' : 'En attente',
        style: GoogleFonts.beVietnamPro(
          fontSize: 11,
          color: confirmed ? AppColors.secondary : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}