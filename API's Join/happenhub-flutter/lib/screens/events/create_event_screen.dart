import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/event_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/app_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _titleCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();

  final _eventService = EventService();
  bool _loading = false;

  String _category = 'Music';
  String? _mood;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(AppConstants.userIdKey) ?? 0;

      final dateStr = '${_selectedDate!.year}-'
          '${_selectedDate!.month.toString().padLeft(2, '0')}-'
          '${_selectedDate!.day.toString().padLeft(2, '0')}';

      String? timeStr;
      if (_selectedTime != null) {
        timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
            '${_selectedTime!.minute.toString().padLeft(2, '0')}:00';
      }

      await _eventService.createEvent({
        'title':       _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category':    _category,
        'mood':        _mood,
        'location':    _locationCtrl.text.trim(),
        'date':        dateStr,
        'time':        timeStr,
      }, userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Event created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Event Details',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),

              AppTextField(
                controller: _titleCtrl,
                label: 'Event Title',
                prefixIcon: Icons.event_rounded,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),

              AppTextField(
                controller: _descCtrl,
                label: 'Description',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 14),

              AppTextField(
                controller: _locationCtrl,
                label: 'Location / Venue',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Location is required' : null,
              ),

              const SizedBox(height: 24),
              const Text('Category & Mood',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),

              // ── Category dropdown ──────────────────────────
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppTheme.surface,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined, size: 20,
                      color: AppTheme.textSecondary),
                ),
                items: AppConstants.categories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            '${AppConstants.categoryEmoji[c] ?? ''} $c'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),

              const SizedBox(height: 14),

              // ── Mood dropdown ──────────────────────────────
              DropdownButtonFormField<String?>(
                value: _mood,
                dropdownColor: AppTheme.surface,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Mood (optional)',
                  prefixIcon: Icon(Icons.mood_rounded, size: 20,
                      color: AppTheme.textSecondary),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No mood')),
                  ...AppConstants.moods
                      .where((m) => m != 'All')
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                                '${AppConstants.moodEmoji[m] ?? ''} $m'),
                          )),
                ],
                onChanged: (v) => setState(() => _mood = v),
              ),

              const SizedBox(height: 24),
              const Text('Date & Time',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),

              // ── Date picker button ─────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: AppTheme.textSecondary),
                            const SizedBox(width: 10),
                            Text(
                              _selectedDate == null
                                  ? 'Pick a date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 18, color: AppTheme.textSecondary),
                            const SizedBox(width: 10),
                            Text(
                              _selectedTime == null
                                  ? 'Pick a time'
                                  : _selectedTime!.format(context),
                              style: TextStyle(
                                color: _selectedTime == null
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(_loading ? 'Creating...' : 'Create Event'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
