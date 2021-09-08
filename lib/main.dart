import 'package:cachedrun/screens/feed_screen.dart';
import 'package:cachedrun/model/feed_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setup();
  runApp(MyApp());
}

final locator = GetIt.instance;

void setup() {
  locator.registerSingleton<FeedViewModel>(FeedViewModel());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FeedScreen(),
    );
  }
}

class CreateSongs extends StatelessWidget {
  List list = [
    {
      "url": '13OAhVyEKHzTnBguHOPWl1lBeIrQS5Z8j',
      "name": 'Awakening Instrumental',
      "duration": "Unknown",
    },
    {
      "url": '1vdXx4MBjJ_oqwYwA25xY_rlmifRzMzge',
      "name": 'Christmas',
      "duration": "Unknown"
    },
    {
      "url": '13W2yDoj0SDTQqPPAFelPMiEH30zIeo4K',
      "name": 'deep music every day kingdom',
      "duration": "Unknown"
    },
    {
      "url": '1b1cmsajsSsviduoSj_M1EITWELgCsnOS',
      "name": 'Fluidity 100 ig edit',
      "duration": "Unknown"
    },
    {
      "url": '1hZnCwxJeN5wPNpe2Iv6Obfk4NKxMeIgi',
      "name": 'funky trap sax 4864',
      "duration": "Unknown"
    },
    {
      "url": '1h7OW_yzXuRZ3PS_tWjue1iPnKY-MvW7K',
      "name": 'Future bass beat',
      "duration": "Unknown"
    },
    {
      "url": '1mY3tfOGBINxbs5KS6NjKbofvxv_yHBGM',
      "name": 'geovane bruno hello world',
      "duration": "Unknown"
    },
    {
      "url": '1uXH4qEjCq2WOw4oyW5EFtj845UJOuQD7',
      "name": 'happy-ukulele-and-bells-4349',
      "duration": "Unknown"
    },
    {
      "url": '1L45cmPu4TT1D-S-jbyzr9a9lVQheBxvu',
      "name": 'nightlife michael kobrin 95bpm',
      "duration": "Unknown"
    },
    {
      "url": '1AOPToG9i5VuyRTXHdu3mm28DbR4Fg5K6',
      "name": 'Snowflakes winter christmas swing music',
      "duration": "Unknown"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Trimmer"),
      ),
      body: Center(
        child: Container(
          child: ElevatedButton(
            child: Text("LOAD VIDEO"),
            onPressed: () async {
              for (var i = 0; i < list.length; i++) {
                await FirebaseFirestore.instance
                    .collection('Songs')
                    .doc(list[i]['url'])
                    .set({
                  "url": "https://docs.google.com/uc?export=open&id=" +
                      list[i]['url'],
                  "downloadurl":
                      "https://drive.google.com/u/0/uc?id=${list[i]['url']}&export=download",
                  "name": list[i]['name'],
                  "duration": list[i]['duration'],
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
