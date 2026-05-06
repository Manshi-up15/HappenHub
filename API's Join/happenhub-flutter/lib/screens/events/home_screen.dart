import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/saved_event_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/event_card.dart';
import '../../widgets/common_widgets.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _eventService      = EventService();
  final _savedEventService = SavedEventService();
  final _searchCtrl        = TextEditingController();

  List<EventModel> _events    = [];
  Set<int> _savedEventIds     = {}; // track which events user has saved
  Map<int, int> _savedIdMap   = {}; // eventId → savedEventId (for removal)

  bool _loading  = false;
  bool _hasError = false;

  String _selectedCategory = 'All';
  String _selectedMood     = 'All';
  String _searchQuery      = '';

  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) => _fetchEvents());
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getInt(AppConstants.userIdKey));
    if (_userId != null) await _loadSavedIds();
  }

  Future<void> _loadSavedIds() async {
    if (_userId == null) return;
    try {
      final saved = await _savedEventService.getSavedEvents(_userId!);
      setState(() {
        _savedEventIds = saved.map((s) => s.event.id).toSet();
        _savedIdMap = {for (var s in saved) s.event.id: s.id};
      });
    } catch (_) {}
  }

  Future<void> _fetchEvents() async {
    setState(() { _loading = true; _hasError = false; });
    try {
      List<EventModel> result;
      if (_searchQuery.isNotEmpty) {
        result = await _eventService.searchEvents(_searchQuery);
      } else {
        result = await _eventService.getEvents(
          category: _selectedCategory == 'All' ? null : _selectedCategory,
          mood:     _selectedMood == 'All'     ? null : _selectedMood,
        );
      }
      setState(() => _events = result);
    } catch (_) {
      setState(() => _hasError = true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleSave(EventModel event) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save events')),
      );
      return;
    }

    final alreadySaved = _savedEventIds.contains(event.id);
    try {
      if (alreadySaved) {
        await _savedEventService.removeSavedEvent(_savedIdMap[event.id]!);
        setState(() {
          _savedEventIds.remove(event.id);
          _savedIdMap.remove(event.id);
        });
      } else {
        final saved = await _savedEventService.saveEvent(_userId!, event.id);
        setState(() {
          _savedEventIds.add(event.id);
          _savedIdMap[event.id] = saved.id;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Discover', style: Theme.of(context).textTheme.displayLarge),
                              const Text('What\'s happening near you 📍',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ),
                        // Upcoming chip
                        GestureDetector(
                          onTap: () async {
                            setState(() { _loading = true; _hasError = false; });
                            try {
                              final r = await _eventService.getUpcomingEvents();
                              setState(() { _events = r; _loading = false; });
                            } catch (_) {
                              setState(() { _hasError = true; _loading = false; });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.accent, AppTheme.accentGold],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Upcoming 🗓',
                                style: TextStyle(color: Colors.white, fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Search bar ───────────────────────────
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) {
                        _searchQuery = v.trim();
                        if (_searchQuery.isEmpty || _searchQuery.length > 2) _fetchEvents();
                      },
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search events, places...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppTheme.textSecondary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  _searchQuery = '';
                                  _fetchEvents();
                                },
                                child: const Icon(Icons.close_rounded,
                                    color: AppTheme.textSecondary),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Category chips ───────────────────────
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final cat = AppConstants.categories[i];
                          final selected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = cat);
                              _fetchEvents();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.accent : AppTheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? AppTheme.accent : AppTheme.divider,
                                ),
                              ),
                              child: Text(
                                cat == 'All'
                                    ? cat
                                    : '${AppConstants.categoryEmoji[cat] ?? ''} $cat',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Mood chips ───────────────────────────
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.moods.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final mood = AppConstants.moods[i];
                          final selected = _selectedMood == mood;
                          final emoji = AppConstants.moodEmoji[mood] ?? '';
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedMood = mood);
                              _fetchEvents();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.accentGold.withOpacity(0.2)
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.accentGold
                                      : AppTheme.divider,
                                ),
                              ),
                              child: Text(
                                mood == 'All' ? 'All moods' : '$emoji $mood',
                                style: TextStyle(
                                  color: selected
                                      ? AppTheme.accentGold
                                      : AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Text('${_events.length} Events',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        GestureDetector(
                          onTap: _fetchEvents,
                          child: const Icon(Icons.refresh_rounded,
                              size: 20, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Events list ──────────────────────────────────
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: EventShimmer(),
                ),
              )
            else if (_hasError)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: ErrorView(
                    message: 'Could not load events. Check your connection.',
                    onRetry: _fetchEvents,
                  ),
                ),
              )
            else if (_events.isEmpty)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: EmptyView(
                    emoji: '🔍',
                    title: 'No events found',
                    subtitle: 'Try changing your filters or search query',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final event = _events[i];
                      return EventCard(
                        event: event,
                        isSaved: _savedEventIds.contains(event.id),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(
                              event: event,
                              isSaved: _savedEventIds.contains(event.id),
                              onToggleSave: () => _toggleSave(event),
                            ),
                          ),
                        ),
                        onSave: () => _toggleSave(event),
                      );
                    },
                    childCount: _events.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}
