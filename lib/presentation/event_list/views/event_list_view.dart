import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/event_list_viewmodel.dart';

class EventListView extends StatefulWidget {
  const EventListView({super.key});

  @override
  State<EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<EventListViewModel>(
        builder: (context, viewModel, child) {
          final events = viewModel.events;

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ambient.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: CustomScrollView(
              slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evenements',
                        style: GoogleFonts.newsreader(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explorez les evenements de la communaute.',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 15,
                          height: 1.4,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Barre de recherche
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => viewModel.setSearchQuery(val),
                            style: GoogleFonts.beVietnamPro(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Rechercher par nom...',
                              hintStyle: GoogleFonts.beVietnamPro(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Bouton filtres
                      GestureDetector(
                        onTap: () {
                          setState(() => _showFilters = !_showFilters);
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _showFilters
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _showFilters
                                  ? AppColors.primary
                                  : AppColors.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: _showFilters
                                ? Colors.white
                                : AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Zone de filtres avances
              if (_showFilters)
                SliverToBoxAdapter(
                  child: _filtersSection(context, viewModel),
                ),

              // Chips de filtres actifs
              if (viewModel.showOnlyMine ||
                  viewModel.locationFilter.isNotEmpty ||
                  viewModel.dateFilter != null)
                SliverToBoxAdapter(
                  child: _activeFiltersChips(context, viewModel),
                ),

              // Liste
              if (viewModel.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (events.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 50,
                          color: AppColors.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Aucun evenement trouve",
                          style: GoogleFonts.beVietnamPro(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        if (viewModel.searchQuery.isNotEmpty ||
                            viewModel.showOnlyMine ||
                            viewModel.dateFilter != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextButton(
                              onPressed: () {
                                viewModel.clearFilters();
                                _searchController.clear();
                                _locationController.clear();
                              },
                              child: Text(
                                'Effacer les filtres',
                                style: GoogleFonts.beVietnamPro(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
                        const Color(0xFFB9732A),
                        const Color(0xFF8D96E9),
                        const Color(0xFFFDB981),
                      ];
                      final Color cardColor = colors[index % colors.length];
                      return _eventCard(context, event, cardColor);
                    },
                    childCount: events.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _filtersSection(BuildContext context, EventListViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtre par lieu
          Text(
            'Lieu',
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _locationController,
              onChanged: (val) => viewModel.setLocationFilter(val),
              style: GoogleFonts.beVietnamPro(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Rechercher par lieu...',
                hintStyle: GoogleFonts.beVietnamPro(
                  color: AppColors.textLight,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.location_on_outlined,
                    color: AppColors.primary, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Filtre par date
          Text(
            'Date',
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: viewModel.dateFilter ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              viewModel.setDateFilter(picked);
            },
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    viewModel.dateFilter != null
                        ? DateFormat('dd/MM/yyyy').format(viewModel.dateFilter!)
                        : 'Selectionner une date...',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      color: viewModel.dateFilter != null
                          ? AppColors.onSurface
                          : AppColors.textLight,
                    ),
                  ),
                  const Spacer(),
                  if (viewModel.dateFilter != null)
                    GestureDetector(
                      onTap: () => viewModel.setDateFilter(null),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Toggle mes evenements / tout le monde
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (viewModel.showOnlyMine) viewModel.toggleShowOnlyMine();
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: !viewModel.showOnlyMine
                          ? AppColors.primary
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Tout le monde',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: !viewModel.showOnlyMine
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!viewModel.showOnlyMine) viewModel.toggleShowOnlyMine();
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: viewModel.showOnlyMine
                          ? AppColors.primary
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Mes evenements',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: viewModel.showOnlyMine
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeFiltersChips(
      BuildContext context, EventListViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (viewModel.showOnlyMine)
            _filterChip('Mes evenements', () => viewModel.toggleShowOnlyMine()),
          if (viewModel.locationFilter.isNotEmpty)
            _filterChip(
              'Lieu: ${viewModel.locationFilter}',
              () {
                viewModel.setLocationFilter('');
                _locationController.clear();
              },
            ),
          if (viewModel.dateFilter != null)
            _filterChip(
              'Date: ${DateFormat('dd/MM').format(viewModel.dateFilter!)}',
              () => viewModel.setDateFilter(null),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
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
                    color: Colors.white.withValues(alpha: 0.1),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: Colors.white),
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
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white.withValues(alpha: 0.8),
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