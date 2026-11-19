import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Aplikasi ini dirancang khusus untuk ponsel dalam orientasi potret:
  // tata letak, bottom nav, dan sheet mengasumsikan satu kolom sempit.
  // Kunci orientasi supaya tablet yang diputar tidak memecah tata letak.
  SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const KarsaApp());
}
