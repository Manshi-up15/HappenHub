import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/applied_event_service.dart';

/// Shows full event details.
/// [onToggleSave] is called when the user taps the save button —
/// the parent (HomeScreen / SavedEventsScreen) handles the actual API call.
class EventDetailScreen extends StatefulWidget {
  final EventModel event;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late bool _isSaved;

  void _handleToggle() {
    setState(() => _isSaved = !_isSaved);
    widget.onToggleSave(); // propagate to parent
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isSaved ? '❤️ Event saved!' : 'Removed from saved')),
    );
  }

  bool _isBusiness = false;
  int? _userId;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
    _checkRoleAndApplied();
  }

  Future<void> _checkRoleAndApplied() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(AppConstants.userRoleKey);
    _userId = prefs.getInt(AppConstants.userIdKey);
    if (mounted) {
      setState(() {
        _isBusiness = role == 'BUSINESS';
      });
    }
    if (_userId != null && !_isBusiness) {
      // Check if applied
      try {
         final applied = await AppliedEventService().getAppliedEvents(_userId!);
         if (applied.any((a) => a.event.id == widget.event.id)) {
           if (mounted) setState(() => _isApplied = true);
         }
      } catch (_) {}
    }
  }

  Future<void> _handleApply() async {
    if (_userId == null) return;
    try {
      await AppliedEventService().applyEvent(_userId!, widget.event.id);
      setState(() => _isApplied = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully applied to event!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already applied or error occurred')));
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      const months = ['','January','February','March','April','May','June',
                      'July','August','September','October','November','December'];
      return '${months[int.parse(parts[1])]} ${parts[2]}, ${parts[0]}';
    } catch (_) { return dateStr; }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) { return timeStr; }
  }

  @override
  Widget build(BuildContext context) {
    final event     = widget.event;
    final emoji     = AppConstants.categoryEmoji[event.category] ?? '📌';
    final moodEmoji = event.mood != null
        ? (AppConstants.moodEmoji[event.mood] ?? '') : '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: _handleToggle,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      key: ValueKey(_isSaved),
                      color: _isSaved ? AppTheme.accent : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null && event.imageUrl!.isNotEmpty
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackHeader(emoji, event.category),
                    )
                  : _buildFallbackHeader(emoji, event.category),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (moodEmoji.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                      ),
                      child: Text('$moodEmoji ${event.mood}',
                          style: const TextStyle(color: AppTheme.accentGold, fontSize: 13)),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Text(event.title, style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 20),

                  _infoRow(Icons.calendar_today_rounded, 'Date', _formatDate(event.date)),
                  if (event.time != null)
                    _infoRow(Icons.access_time_rounded, 'Time', _formatTime(event.time)),
                  _infoRow(Icons.location_on_rounded, 'Location', event.location),
                  _infoRow(Icons.person_outline_rounded, 'Organiser', event.createdByName),

                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 20),

                  Text('About this Event', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    event.description.isEmpty ? 'No description provided.' : event.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 15, height: 1.6),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleToggle,
                      icon: Icon(_isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                      label: Text(_isSaved ? 'Saved!' : 'Save This Event'),
                      style: _isSaved
                          ? ElevatedButton.styleFrom(backgroundColor: AppTheme.cardBg,
                              side: const BorderSide(color: AppTheme.accent))
                          : null,
                    ),
                  ),
                  if (!_isBusiness) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isApplied ? null : _handleApply,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(_isApplied ? 'Already Applied' : 'Apply for Event'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isApplied ? Colors.grey : AppTheme.accentGold,
                          foregroundColor: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHeader(String emoji, String category) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppTheme.cardBg, AppTheme.surface],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Text(emoji, style: const TextStyle(fontSize: 64)),
            Text(category,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
