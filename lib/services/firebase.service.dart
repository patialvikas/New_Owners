import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_chat/firebase_chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/notification.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/translations/order_details.i18n.dart';

class FirebaseService {
  static NotificationModel notificationModel;
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static dynamic notificationPayloadData;

  static setUpFirebaseMessaging() async {
    //Request for notification permission
    /*NotificationSettings settings = */
    await firebaseMessaging.requestPermission();

    // settings.authorizationStatus == AuthorizationStatus.authorized
    AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        //
        NotificationService.appNotificationChannel(),
      ],
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    //On your main page, starts to listen the notification actions (to detect tap)
    AwesomeNotifications().actionStream.listen((receivedNotification) {
      //on notification pressed
      selectNotification("From onBackgroundMessage");
    });

    //
    //subscribing to all topic
    firebaseMessaging.subscribeToTopic("all");

    //on notification received in background
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
    //on notification tap tp bring app back to life
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      print("Message Opened App Data ${message.data}");
      saveNewNotification(message);
      selectNotification("From onMessageOpenedApp");
    });

    //normal notification listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      print("Notiication Data ${message.data}");
      saveNewNotification(message);
      showNotification(message);
    });
  }

  //Hnadle background message
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    print("onBackgroundMessage: $message");
    print("Background Data ${message.data}");
    saveNewNotification(message);
    selectNotification("From onBackgroundMessage");
  }

  //write to notification list
  static saveNewNotification(RemoteMessage message) {
    //
    notificationPayloadData = message.data;
    //Saving the notification
    notificationModel = NotificationModel();
    notificationModel.title = message.notification.title;
    notificationModel.body = message.notification.body;
    notificationModel.timeStamp = DateTime.now().millisecondsSinceEpoch;

    //add to database/shared pref
    NotificationService.addNotification(notificationModel);
  }

  //
  static showNotification(RemoteMessage message) async {
    try {
      //
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: NotificationService.appNotificationChannel().channelKey,
          title: message.notification.title,
          body: message.notification.body,
          icon: "resource://drawable/notification_icon",
          notificationLayout: NotificationLayout.Default,
        ),
      );

      ///
    } catch (error) {
      print("Notification Show error ===> ${error.message}");
      print("Notification Show error ===> ${error.details}");
      print("Notification Show error ===> ${error.stacktrace}");
    }
  }

  //handle on notification selected
  static Future selectNotification(String payload) async {
    print("Payload ==> $payload");
    try {
      //
      final isChat = notificationPayloadData != null &&
          notificationPayloadData["is_chat"] != null;
      final isOrder = notificationPayloadData != null &&
          notificationPayloadData["is_order"] != null;
      //
      if (isChat) {
        //
        dynamic user = jsonDecode(notificationPayloadData['user']);
        dynamic peer = jsonDecode(notificationPayloadData['peer']);
        String chatPath = notificationPayloadData['path'];
        //
        Map<String, PeerUser> peers = {
          '${user['id']}': PeerUser(
            id: '${user['id']}',
            name: "${user['name']}",
            image: "${user['photo']}",
          ),
          '${peer['id']}': PeerUser(
            id: '${peer['id']}',
            name: "${peer['name']}",
            image: "${peer['photo']}",
          ),
        };
        //
        final peerRole = peer["role"];
        //
        final chatEntity = ChatEntity(
          mainUser: peers['${user['id']}'],
          peers: peers,
          //don't translate this
          path: chatPath,
          title: peer["role"] == null
              ? "Chat with".i18n + " ${peer['name']}"
              : peerRole == 'driver'
                  ? "Chat with driver".i18n
                  : "Chat with vendor".i18n,
        );
        AppService.navigatorKey.currentContext.navigator.pushNamed(
          AppRoutes.chatRoute,
          arguments: chatEntity,
        );
      }
      //order
      else if (isOrder) {
        //
        final order = Order(
          id: int.parse(notificationPayloadData['order_id'].toString()),
        );
        //
        AppService.navigatorKey.currentContext.navigator.pushNamed(
          AppRoutes.orderDetailsRoute,
          arguments: order,
        );
      }
      //regular notifications
      else {
        AppService.navigatorKey.currentContext.navigator.pushNamed(
            AppRoutes.notificationDetailsRoute,
            arguments: notificationModel);
      }
    } catch (error) {
      print("Error opening Notification ==> $error");
    }
  }
}
