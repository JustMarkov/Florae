import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'data/box.dart';
import 'data/plant.dart';
import 'screens/home_page.dart';
import 'package:florae/notifications.dart' as notify;



late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  objectbox = await ObjectBox.create();
  print ("florae: ENTERING MAIN");
  notify.initNotifications();

  runApp(FloraeApp());

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

}

/// This "Headless Task" is run when app is terminated.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  print("[BackgroundFetch] Headless event received: $taskId");

  ObjectBox obx = await ObjectBox.create();

  List<Plant> allPlants = obx.plantBox.getAll();

  obx.store.close();

  List<String> plants = [];

  for (Plant p in allPlants) {
    for (Care c in p.cares){
      var cpsr = DateTime.now().difference(c.effected!).inDays;
      if (cpsr != 0 && cpsr % c.cycles == 0) {
        plants.add(p.name);
      }
      break;
    }
  }

  print ("headless florae detected plants " + plants.join(' '));

//  notify.singleNotification("Florae", "Headless notification", 7);


  if (plants.isNotEmpty){
    notify.singleNotification("Plants require care", plants.join('\n'), 7);
  }
  else{
    print ("florae no plants require care");
  }

  print("[BackgroundFetch] Headless event finished: $taskId");


  BackgroundFetch.finish(taskId);
}

class FloraeApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Florae',
      theme: ThemeData(
          primaryColor: Colors.teal,
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.teal,
          fontFamily: "NotoSans",
          scaffoldBackgroundColor: Colors.grey[100]),
      home:  const MyHomePage(title: 'Today')
    );
  }
}
