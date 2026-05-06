import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

/// A rich event card shown in the home screen list.
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool isSaved;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onSave,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = AppConstants.categoryEmoji[event.category] ?? '📌';
    final moodEmoji = event.mood != null
        ? (AppConstants.moodEmoji[event.mood] ?? '')
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header strip with category colour ─────────
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentGold],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category + mood chips ────────────────
                  Row(
                    children: [
                      _chip('$emoji ${event.category}'),
                      if (moodEmoji.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _chip(moodEmoji),
                      ],
                      const Spacer(),
                      // Save/bookmark button
                      GestureDetector(
                        onTap: onSave,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            key: ValueKey(isSaved),
                            color: isSaved ? AppTheme.accent : AppTheme.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Title ────────────────────────────────
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // ── Meta row: date + location ─────────────
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: AppTheme.accentGold),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(event.date),
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.divider),
    ),
    child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
  );

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final months = ['','Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[int.parse(parts[1])]} ${parts[2]}, ${parts[0]}';
    } catch (_) {
      return dateStr;
    }
  }
}
