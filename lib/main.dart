import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  AndroidInitializationSettings androidInitializationSettings =
  const AndroidInitializationSettings("@mipmap/ic_launcher");

  DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings();

  InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitializationSettings,
  );

  bool? notification = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    onDidReceiveNotificationResponse: (response){
        log("Background : ${response.payload.toString()}");
    }
  );

  log("Notification : $notification");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  void showNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        "0", "local", priority: Priority.max, importance: Importance.max);

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails
    );

    await flutterLocalNotificationsPlugin.show(
        0, 'First', "The boday",
        notificationDetails,
      payload: "Jai Shree Ram"
    );


    //var schedule = DateTime.now().add(Duration(seconds: 3));

    /*try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        1, "Schedule time",
        "If we want to an expression the bright thought in our head",
        tz.TZDateTime.now(tz.local).add(Duration(seconds: 3)),
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
      ).then((value) {
        print("Its working");
      });
    } catch (e) {
      print('The error is '+e.toString());
    }*/

  }

  void checkForNotification() async{
    NotificationAppLaunchDetails? details =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if(details!=null){
      NotificationResponse? response = details.notificationResponse;
      if(response!=null){
        String? payload = response.payload;
        log("Notification Payload : $payload");
      }
    }
  }

  @override
  Widget build(BuildContext context) {


    @override
    void initState() {
      checkForNotification();
      super.initState();
    }

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Text("Tap on floating Action Button",style: Theme.of(context).textTheme.headlineSmall,),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


}
