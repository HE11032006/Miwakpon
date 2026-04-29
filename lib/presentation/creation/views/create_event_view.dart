import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/create_event_viewmodel.dart';
import '../../../core/theme/app_colors.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '50');
  
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _imageUrl;
  String _eventType = 'public';
  String _ambiance = 'Terre de Ouidah';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 23, minute: 0),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  DateTime? _getCombinedDateTime() {
    if (_selectedDate == null || _startTime == null) return null;
    
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _imageUrl = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
        );
      }
    }
  }

  void _createEvent(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    
    final dateTime = _getCombinedDateTime();
    if (dateTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date et une heure')),
        );
      }
      return;
    }

    final viewModel = context.read<CreateEventViewModel>();
    await viewModel.createEvent(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dateTime: dateTime,
      location: _locationController.text.trim(),
      imageUrl: _imageUrl,
      maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 50,
    );

    if (viewModel.isSuccess) {
      if (mounted) context.go('/home');
    } else if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'New',
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _createEvent(context),
            child: Text(
              'PUBLIER',
              style: GoogleFonts.beVietnamPro(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.canvasWhite,
              AppColors.canvasWhite.withValues(alpha: 0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Titre principal de l'événement
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Agogohoun in Ouidah',
                    hintStyle: GoogleFonts.newsreader(
                      color: AppColors.outline.withValues(alpha: 0.4),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  style: GoogleFonts.newsreader(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Section Select Cover
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _imageUrl != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_imageUrl!),
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _selectCoverButton();
                              },
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => setState(() => _imageUrl = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: _selectCoverButton(isCompact: true),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: _selectCoverButton(),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 32),

              // Section Chronology
              _sectionHeader('Chronology'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _dateSelector(),
                    const Divider(height: 32, color: AppColors.canvasWhite),
                    _timeSelector(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section Location
              _sectionHeader('Location'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.outline, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _locationController.text.isEmpty ? null : _locationController.text,
                        hint: Text('Select Location', style: GoogleFonts.beVietnamPro(color: AppColors.outline, fontSize: 14)),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                        items: ['Ouidah', 'Cotonou', 'Porto-Novo', 'Abomey', 'Grand-Popo']
                            .map((city) => DropdownMenuItem(value: city, child: Text(city, style: GoogleFonts.beVietnamPro(fontSize: 14))))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _locationController.text = value);
                        },
                        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section The Narrative
              _sectionHeader('The Narrative'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Tell the story of this gathering...',
                    hintStyle: GoogleFonts.beVietnamPro(color: AppColors.outline.withValues(alpha: 0.4), fontSize: 14),
                    border: InputBorder.none,
                  ),
                  maxLines: 5,
                  style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.onSurface),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 32),

              // Section Ambiance Palette
              _sectionHeader('Ambiance Palette'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ambianceOption('Terre de Ouidah', AppColors.primary),
                  _ambianceOption('Bleu Lagune', AppColors.bleuLagune),
                  _ambianceOption('Jaune Wax', AppColors.jauneSoleil),
                ],
              ),
              const SizedBox(height: 32),

              // Section Gathering Type
              Row(
                children: [
                  Expanded(
                    child: _gatheringTypeOption(
                      title: 'Public Gathering',
                      icon: Icons.people_outline,
                      isSelected: _eventType == 'public',
                      onTap: () => setState(() => _eventType = 'public'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _gatheringTypeOption(
                      title: 'Private Ceremony',
                      icon: Icons.key_outlined,
                      isSelected: _eventType == 'private',
                      onTap: () => setState(() => _eventType = 'private'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),


            ],
          ),
        ),
      ),
    );
  }

  Widget _selectCoverButton({bool isCompact = false}) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 18,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Select Cover',
              style: GoogleFonts.beVietnamPro(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.outline,
      ),
    );
  }

  Widget _dateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: AppColors.outline, size: 20),
          const SizedBox(width: 12),
          Text(
            _selectedDate != null
                ? '${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}'
                : '12 Oct 2024',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _selectedDate != null ? AppColors.onSurface : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeSelector() {
    final startTimeText = _startTime != null
        ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
        : '18:00';
    final endTimeText = _endTime != null
        ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
        : '23:00';
    
    return InkWell(
      onTap: () async {
        await _selectStartTime(context);
        if (_startTime != null && mounted) {
          await _selectEndTime(context);
        }
      },
      child: Row(
        children: [
          const Icon(Icons.access_time_outlined, color: AppColors.outline, size: 20),
          const SizedBox(width: 12),
          Text(
            '$startTimeText - $endTimeText',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ambianceOption(String name, Color color) {
    final isSelected = _ambiance == name;
    return GestureDetector(
      onTap: () => setState(() => _ambiance = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: GoogleFonts.beVietnamPro(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.onSurface : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gatheringTypeOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBF4EE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.black.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
