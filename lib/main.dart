// Imports/Packages
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/native.dart';
import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/data/local_store.dart';
import 'package:adhd_todo/view/list_view.dart';
import 'package:adhd_todo/domain/scheduler.dart';
import 'package:adhd_todo/platform/notification_gateway.dart';
import 'package:adhd_todo/data/drift/database.dart';
import 'package:adhd_todo/data/drift/local_store_drift.dart';
import 'package:sqlite3/open.dart' as sqlite3;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:adhd_todo/data/secure_key.dart';

// Open the encrypted Drift store
Future<ILocalStore> _openEncryptedStore() async {
  // Resolve DB location
  final dir = await getApplicationDocumentsDirectory();
  final dbFile = File('${dir.path}/adhd_todo.db');

  // Get or create encryption key
  final hexKey = await SecureKeyManager.instance.getOrCreateHexKey256();

  // Open database with SQLCipher key
  final db = NativeDatabase(
    dbFile,
    // Configure SQLCipher and pragmas
    setup: (rawDb) {
      rawDb.execute("PRAGMA key = 'x''$hexKey'''");
      rawDb.execute('PRAGMA cipher_memory_security = ON');
      rawDb.execute('PRAGMA foreign_keys = ON');
    },
  );

  // Create Drift database wrapper
  final appDb = AppDb(db);
  return LocalStoreDrift(appDb);
}

// App entry point
Future<void> main() async {
  // Prepare Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Load SQLCipher on Android
  sqlite3.open.overrideFor(
    sqlite3.OperatingSystem.android,
    openCipherOnAndroid,
  );

  // Create store
  final ILocalStore store = await _openEncryptedStore();

  // Create services
  final notifier = LocalNotificationGateway();
  final appModel = AppModel(
    store: store,
    scheduler: Scheduler(),
    notifier: notifier,
  );

  // Initialize model
  await appModel.initialize();

  // Start app
  runApp(MyApp(appModel: appModel));
}

class MyApp extends StatelessWidget {
  final AppModel appModel;
  const MyApp({super.key, required this.appModel});

  // Build the app widget tree
  @override
  Widget build(BuildContext context) {
    // Seed color
    const seed = Color.fromARGB(255, 0, 255, 242);

    // Light theme
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      dividerTheme: const DividerThemeData(space: 0.5, thickness: 0.5),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    // Dark theme
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      dividerTheme: const DividerThemeData(space: 0.5, thickness: 0.5),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    // App widget
    return MaterialApp(
      title: 'ADHD TODO',
      theme: light,
      darkTheme: dark,
      themeMode: ThemeMode.system,
      home: ListViewScreen(appModel: appModel),
    );
  }
}
