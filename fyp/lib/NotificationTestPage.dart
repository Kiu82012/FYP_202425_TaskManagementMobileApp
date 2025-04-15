/*
import 'package:flutter/material.dart';
import 'AppNotification.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final AppNotification notification = AppNotification();
  bool _isInitialized = false;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await notification.init();
      setState(() {
        _isInitialized = true;
        _status = 'Ready to test notifications';
      });
    } catch (e) {
      setState(() => _status = 'Initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Tester')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 30),
            if (_isInitialized) ...[
              ElevatedButton(
                onPressed: _testInstantNotification,
                child: const Text('Test Instant Notification'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _testScheduledNotification,
                child: const Text('Test Scheduled (10 seconds)'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testInstantNotification() async {
    try {
      await notification.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Instant Test',
        body: 'This notification appeared immediately',
      );
      _updateStatus('Instant notification shown successfully');
    } catch (e) {
      _updateStatus('Error showing notification: $e');
    }
  }

  Future<void> _testScheduledNotification() async {
    try {
      // Get exact time 10 seconds from now
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

      // Convert to TZDateTime in local timezone
      final scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await notification.scheduleNotification(
        title: 'Scheduled Test',
        body: 'Scheduled for ${scheduledTime.hour}:${scheduledTime.minute}:${scheduledTime.second}',
        year: scheduledTZTime.year,
        month: scheduledTZTime.month,
        day: scheduledTZTime.day,
        hour: scheduledTZTime.hour,
        minute: scheduledTZTime.minute,
        second: scheduledTZTime.second, // Add this parameter to your method
      );

      _updateStatus('${scheduledTime.year}:${scheduledTime.month}:${scheduledTime.day}: ${scheduledTime.hour}:${scheduledTime.minute}:${scheduledTime.second}');
    } catch (e) {
      _updateStatus('Error scheduling notification: $e');
    }
  }

  void _updateStatus(String message) {
    setState(() => _status = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}*/
