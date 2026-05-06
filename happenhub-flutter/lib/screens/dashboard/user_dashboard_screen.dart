import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/saved_event_service.dart';
import '../../services/applied_event_service.dart';
import '../../models/event_model.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';
import '../../widgets/event_card.dart';
import '../events/event_detail_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<EventModel> _savedEvents = [];
  List<EventModel> _appliedEvents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt(AppConstants.userIdKey);
      if (id != null) {
        final saved = await SavedEventService().getSavedEvents(id);
        final applied = await AppliedEventService().getAppliedEvents(id);
        if (mounted) {
          setState(() {
            _savedEvents = saved.map((s) => s.event).toList();
            _appliedEvents = applied.map((a) => a.event).toList();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          tabs: const [
            Tab(text: 'Saved Events'),
            Tab(text: 'Applied Events'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_savedEvents, 'No saved events.'),
                _buildList(_appliedEvents, 'You haven\'t applied to any events.'),
              ],
            ),
    );
  }

  Widget _buildList(List<EventModel> events, String emptyMsg) {
    if (events.isEmpty) {
      return Center(child: Text(emptyMsg));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: events.length,
        itemBuilder: (_, i) {
          final event = events[i];
          return EventCard(
            event: event,
            isSaved: _savedEvents.any((e) => e.id == event.id),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                  event: event,
                  isSaved: _savedEvents.any((e) => e.id == event.id),
                  onToggleSave: () {},
                ),
              )).then((_) => _loadData());
            },
          );
        },
      ),
    );
  }
}
