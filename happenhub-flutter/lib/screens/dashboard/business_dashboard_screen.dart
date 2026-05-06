import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import '../../utils/constants.dart';
import '../../widgets/event_card.dart';
import '../events/event_detail_screen.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  List<EventModel> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt(AppConstants.userIdKey);
      if (id != null) {
        final events = await EventService().getEventsByCreator(id);
        if (mounted) setState(() => _events = events);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('You have not posted any events yet.'))
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _events.length,
                    itemBuilder: (_, i) {
                      final event = _events[i];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => EventDetailScreen(
                              event: event,
                              isSaved: false,
                              onToggleSave: () {},
                            ),
                          )).then((_) => _loadEvents());
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
