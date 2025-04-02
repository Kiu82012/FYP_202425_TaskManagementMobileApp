import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class AppNotification {
  static final AppNotification _instance = AppNotification._internal();
  final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  factory AppNotification() => _instance;
  AppNotification._internal();

  Future<void> init() async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    await notifications.initialize(
      const InitializationSettings(android: androidSettings),
    );


    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'calendar_reminders',
      'Calendar Reminders',
      importance: Importance.max,
      description: 'Channel for event reminders',
    );

    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }
  Future<bool> _checkAndRequestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    }

    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }


  Future<void> AzonedScheduleNotification() async {

    await notifications.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'calendar_reminders', 'Calendar Reminders',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required int second,

  }) async {
    try {
      // Check permission first
      final hasPermission = await _checkAndRequestExactAlarmPermission();
      if (!hasPermission) {
        throw Exception('Exact alarm permission not granted');
      }



      var scheduledDate = tz.TZDateTime(
        tz.local,
        year,
        month,
        day,
        hour,
        minute,
        second,
      );

      await notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
          '01', 'schedule',channelDescription: 'schedule')
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      await showNotification(
        id: id,
        title: title,
        body: 'Failed to schedule: $body',
      );
      rethrow;
    }
  }


  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'calendar_reminders',
      'Calendar Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    await notifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }
}