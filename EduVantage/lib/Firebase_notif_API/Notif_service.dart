import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    print('Initializing notifications...');
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          print('Received local notification in the foreground: id=$id, title=$title, body=$body, payload=$payload');
        });

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
          print('Received notification response: ${notificationResponse.toString()}');
        });
    print('Notification initialization completed.');
  }

  notificationDetails() {
    print('Creating notification details...');
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    print('Showing notification: id=$id, title=$title, body=$body, payload=$payLoad');
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future scheduleNotification(
      {int id = 0,
        String? title,
        String? body,
        String? payLoad,
        required DateTime scheduledNotificationDateTime}) async {
    print('Scheduling notification: id=$id, title=$title, body=$body, payload=$payLoad, scheduledDateTime=$scheduledNotificationDateTime');
    return notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledNotificationDateTime,
          tz.local,
        ),
        await notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }
}
