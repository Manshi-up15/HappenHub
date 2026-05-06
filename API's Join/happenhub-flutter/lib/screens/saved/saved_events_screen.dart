import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/saved_event_model.dart';
import '../../services/saved_event_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';
import '../events/event_detail_screen.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({super.key});

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  final _service = SavedEventService();
  List<SavedEventModel> _saved = [];
  bool _loading = false;
  bool _hasError = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt(AppConstants.userIdKey);
    if (_userId != null) _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    setState(() { _loading = true; _hasError = false; });
    try {
      final result = await _service.getSavedEvents(_userId!);
      setState(() => _saved = result);
    } catch (_) {
      setState(() => _hasError = true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _remove(int savedId) async {
    try {
      await _service.removeSavedEvent(savedId);
      setState(() => _saved.removeWhere((s) => s.id == savedId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Events')),
      body: _userId == null
          ? const Center(
              child: EmptyView(
                emoji: '🔐',
                title: 'Login required',
                subtitle: 'Sign in to see your saved events',
              ),
            )
          : _loading
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: EventShimmer(),
                )
              : _hasError
                  ? ErrorView(message: 'Failed to load saved events', onRetry: _load)
                  : _saved.isEmpty
                      ? const EmptyView(
                          emoji: '💫',
                          title: 'No saved events yet',
                          subtitle: 'Tap ❤️ on any event to save it here',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: AppTheme.accent,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _saved.length,
                            itemBuilder: (_, i) {
                              final saved = _saved[i];
                              final event = saved.event;
                              final emoji = AppConstants.categoryEmoji[event.category] ?? '📌';

                              return Dismissible(
                                key: Key('saved-${saved.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.redAccent),
                                ),
                                onDismissed: (_) => _remove(saved.id),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(
                                        event: event,
                                        isSaved: true,
                                        onToggleSave: () => _remove(saved.id),
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardBg,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: AppTheme.divider),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 52, height: 52,
                                          decoration: BoxDecoration(
                                            color: AppTheme.surface,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Center(child: Text(emoji,
                                              style: const TextStyle(fontSize: 26))),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(event.title,
                                                  style: Theme.of(context).textTheme.titleMedium,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_today_rounded,
                                                      size: 12, color: AppTheme.accentGold),
                                                  const SizedBox(width: 4),
                                                  Text(event.date,
                                                      style: const TextStyle(
                                                        color: AppTheme.accentGold, fontSize: 12)),
                                                  const SizedBox(width: 10),
                                                  const Icon(Icons.location_on_rounded,
                                                      size: 12, color: AppTheme.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(event.location,
                                                        style: const TextStyle(
                                                            color: AppTheme.textSecondary,
                                                            fontSize: 12),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.favorite_rounded,
                                              color: AppTheme.accent, size: 20),
                                          onPressed: () => _remove(saved.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
    );
  }
}
