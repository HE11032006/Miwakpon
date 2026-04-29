import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../event_list/views/event_list_view.dart'; 
import '../viewmodels/event_detail_viewmodel.dart';

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
                        color: const Color(0xFFF2F2F2),
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
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.2,
                                child: CustomPaint(painter: GeometricPainter()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    event.title,
                                    style: GoogleFonts.newsreader(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    event.description.length > 100 
                                      ? "${event.description.substring(0, 100)}..." 
                                      : event.description,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 15,
                                      color: Colors.black54,
                                      height: 1.4,
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

                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
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
                                _buildAvatarStack(),
                                Text(
                                  "Attending",
                                  style: GoogleFonts.beVietnamPro(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.check_circle_outline, size: 20),
                                label: const Text("JOIN EVENT", style: TextStyle(letterSpacing: 1.1)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionHeader(Icons.info_outline, "About"),
                        const SizedBox(height: 12),
                        Text(
                          event.description,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 15,
                            height: 1.7,
                            color: Colors.black87.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _buildSectionHeader(Icons.location_on_outlined, "Location"),
                        const SizedBox(height: 12),
                        _buildLocationCard(event.location),
                        const SizedBox(height: 32),
                        
                        _buildSectionHeader(Icons.person_outline, "Host"),
                        const SizedBox(height: 16),
                        _buildHostCard(event),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),

              Positioned(
                top: 60,
                left: 25,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(backgroundColor: Colors.white70),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAvatarStack() {
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
          const Positioned(
            left: 65,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFF0F0F0),
              child: Text("+42", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.map_outlined, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location, 
                  style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                const Text(
                  "Abomey, Benin", 
                  style: TextStyle(color: Colors.black54, fontSize: 13)
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "VIEW MAP", 
                    style: GoogleFonts.beVietnamPro(
                      color: AppColors.primary, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 12,
                      letterSpacing: 0.5,
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

  Widget _buildHostCard(dynamic event) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Host ID: ${event.organizerId}", style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold, fontSize: 17)),
                  const Text("Community Member", style: TextStyle(color: Colors.black54)),
                ],
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