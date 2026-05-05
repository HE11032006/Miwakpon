import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/participation_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
// TODO: Implémentation par Membre 5
// Écran Figma correspondant : "Participants List"
//
// Ce fichier affiche la liste des participants d'un événement.
//
// Design Figma "Atelier Benin" :
// - Liste avec séparateurs "brushstroke"
// - Avatars circulaires avec ombre légère
// - Chips pour le statut (confirmé, en attente)

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
      context.read<ParticipationViewModel>().loadParticipants(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
      ),
      body: Consumer<ParticipationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vm.errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        vm.loadParticipants(widget.eventId),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (vm.participants.isEmpty) {
            return const Center(
              child: Text('Aucun participant pour le moment.'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      '${vm.count} participant${vm.count > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: vm.participants.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    indent: 72,
                  ),
                  itemBuilder: (context, index) {
                    final p = vm.participants[index];
                    final name = 'Participant ${index + 1}';
                    final joinedAt = p['joined_at'] != null
                        ? DateTime.tryParse(p['joined_at'])
                        : null;

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: joinedAt != null
                        ? Text(
                            'Inscrit le ${joinedAt.day}/${joinedAt.month}/${joinedAt.year}',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    trailing: const _StatusChip(confirmed: true),
                  );
                },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }
                }

class _StatusChip extends StatelessWidget {
  final bool confirmed;
  const _StatusChip({required this.confirmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        confirmed ? 'Confirmé' : 'En attente',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}