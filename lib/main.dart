import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/WebRTC/webconfig.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Screens/first.dart';
import 'cubit/bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configurations = Configurations();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: configurations.apiKey,
          appId: configurations.appId,
          messagingSenderId: configurations.messagingSenderId,
          projectId: configurations.projectId,
          measurementId: configurations.messagingSenderId));

  // await Firebase.initializeApp();
  BlocOverrides.runZoned(
    () => runApp(MyApp()),
    blocObserver: MyBlocObserver(),
  );
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
      home: const Firstpage(),
    );
  }
}
