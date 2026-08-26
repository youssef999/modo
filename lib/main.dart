import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/app/life_daily_app.dart';
import 'package:life_daily_app/core/ads/admob_bootstrap.dart';
import 'package:life_daily_app/core/network/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await FirebaseBootstrap.tryInit();
  await AdMobBootstrap.init();
  AppStartBinding().dependencies();
  runApp(const LifeDailyApp());
}
