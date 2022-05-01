import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'library/config.dart';
import 'library/common.dart';
import 'pages/memo_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initApp();

  runZonedGuarded(
          () async {
        runApp(const MyApp());
      },
          (e, trace) {
        debug('ERROR : ' + e.toString(), trace);
      }
  );
}

void initApp() async {

  await Config.ready;

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  Common.initResource();

  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.pulse
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 36.0
    ..radius = 10.0
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.brandName,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MemoListPage(),
    );
  }
}
