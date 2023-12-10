import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class Notifications {

  static void send(DateTime scheduledNotificationDateTime, String title ,String alarmInfo) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      // 'Channel for Alarm notification',
      icon: 'logo1',
      // sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('logo1'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS : iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(0, title, alarmInfo,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }

}