import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/saved_event_service.dart';
import '../../services/api_exception.dart';
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

  List<EventModel> _events  = [];
  Set<int> _savedEventIds   = {};
  Map<int, int> _savedIdMap = {}; // eventId → savedEventId

  bool _loading  = false;
  bool _hasError = false;
  String _errorMsg = '';

  String _selectedCategory = 'All';
  String _selectedMood     = 'All';
  String _searchQuery      = '';
  bool _showUpcomingOnly   = false;

  int? _userId;

  // Debounce timer for search
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUser().then((_) => _fetchEvents());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt(AppConstants.userIdKey);
    if (_userId != null) await _loadSavedIds();
  }

  Future<void> _loadSavedIds() async {
    if (_userId == null) return;
    try {
      final saved = await _savedEventService.getSavedEvents(_userId!);
      if (!mounted) return;
      setState(() {
        _savedEventIds = saved.map((s) => s.event.id).toSet();
        _savedIdMap    = {for (var s in saved) s.event.id: s.id};
      });
    } catch (_) {}
  }

  Future<void> _fetchEvents() async {
    setState(() { _loading = true; _hasError = false; _errorMsg = ''; });
    try {
      List<EventModel> result;
      if (_searchQuery.isNotEmpty) {
        result = await _eventService.searchEvents(_searchQuery);
      } else if (_showUpcomingOnly) {
        result = await _eventService.getUpcomingEvents();
      } else {
        result = await _eventService.getEvents(
          category: _selectedCategory == 'All' ? null : _selectedCategory,
          mood:     _selectedMood     == 'All' ? null : _selectedMood,
        );
      }
      if (mounted) setState(() => _events = result);
    } on ApiException catch (e) {
      if (mounted) setState(() { _hasError = true; _errorMsg = e.userMessage; });
    } catch (_) {
      if (mounted) setState(() { _hasError = true; _errorMsg = 'Unexpected error. Please retry.'; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = value.trim();
      _showUpcomingOnly = false;
      _fetchEvents();
    });
  }

  Future<void> _toggleSave(EventModel event) async {
    if (_userId == null) {
      _showSnack('Please log in to save events');
      return;
    }
    final alreadySaved = _savedEventIds.contains(event.id);
    // Optimistic UI update
    setState(() {
      if (alreadySaved) {
        _savedEventIds.remove(event.id);
      } else {
        _savedEventIds.add(event.id);
      }
    });
    try {
      if (alreadySaved) {
        final savedId = _savedIdMap[event.id];
        if (savedId != null) {
          await _savedEventService.removeSavedEvent(savedId);
          _savedIdMap.remove(event.id);
        }
      } else {
        final saved = await _savedEventService.saveEvent(_userId!, event.id);
        _savedIdMap[event.id] = saved.id;
      }
    } on ApiException catch (e) {
      // Roll back optimistic update
      setState(() {
        if (alreadySaved) {
          _savedEventIds.add(event.id);
        } else {
          _savedEventIds.remove(event.id);
        }
      });
      _showSnack(e.userMessage);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () async {
            await _loadSavedIds();
            await _fetchEvents();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              if (_loading)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: EventShimmer()),
                )
              else if (_hasError)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: ErrorView(message: _errorMsg, onRetry: _fetchEvents),
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
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final event = _events[i];
                      return EventCard(
                        event: event,
                        isSaved: _savedEventIds.contains(event.id),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(
                            builder: (_) => EventDetailScreen(
                              event: event,
                              isSaved: _savedEventIds.contains(event.id),
                              onToggleSave: () => _toggleSave(event),
                            ),
                          ));
                          // Refresh saved state when returning from detail
                          await _loadSavedIds();
                        },
                        onSave: () => _toggleSave(event),
                      );
                    }, childCount: _events.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                    const Text("What's happening near you 📍",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
              // Upcoming toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showUpcomingOnly = !_showUpcomingOnly;
                    _searchQuery = '';
                    _searchCtrl.clear();
                  });
                  _fetchEvents();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _showUpcomingOnly
                        ? const LinearGradient(colors: [AppTheme.accent, AppTheme.accentGold])
                        : null,
                    color: _showUpcomingOnly ? null : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _showUpcomingOnly ? Colors.transparent : AppTheme.divider,
                    ),
                  ),
                  child: Text('Upcoming 🗓',
                      style: TextStyle(
                        color: _showUpcomingOnly ? Colors.white : AppTheme.textSecondary,
                        fontSize: 12, fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search bar
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search events, places...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() { _searchQuery = ''; _showUpcomingOnly = false; });
                        _fetchEvents();
                      },
                      child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),

          // Category chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = AppConstants.categories[i];
                final selected = _selectedCategory == cat && !_showUpcomingOnly;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                      _showUpcomingOnly = false;
                      _searchQuery = '';
                      _searchCtrl.clear();
                    });
                    _fetchEvents();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.accent : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider),
                    ),
                    child: Text(
                      cat == 'All' ? cat : '${AppConstants.categoryEmoji[cat] ?? ''} $cat',
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Mood chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.moods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final mood = AppConstants.moods[i];
                final selected = _selectedMood == mood && !_showUpcomingOnly;
                final emoji = AppConstants.moodEmoji[mood] ?? '';
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                      _showUpcomingOnly = false;
                      _searchQuery = '';
                      _searchCtrl.clear();
                    });
                    _fetchEvents();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.accentGold.withOpacity(0.2) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected ? AppTheme.accentGold : AppTheme.divider),
                    ),
                    child: Text(
                      mood == 'All' ? 'All moods' : '$emoji $mood',
                      style: TextStyle(
                        color: selected ? AppTheme.accentGold : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                _showUpcomingOnly
                    ? '${_events.length} Upcoming'
                    : '${_events.length} Events',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async { await _loadSavedIds(); _fetchEvents(); },
                child: const Icon(Icons.refresh_rounded,
                    size: 20, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
