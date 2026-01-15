import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/combat_mode/presentation/screens/combat_mode_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database
  // await _initializeDatabase();

  runApp(
    const ProviderScope(
      child: PincheJuanApp(),
    ),
  );
}

/// Pinche Juan - Kitchen Operating System
///
/// The Ultimate Kitchen Utility App for Expert Home Cooks
class PincheJuanApp extends StatelessWidget {
  const PincheJuanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinche Juan - KitchenOS',
      debugShowCheckedModeBanner: false,

      // Standard theme for navigation and settings
      theme: AppTheme.standardTheme,

      // Dark theme (default)
      darkTheme: AppTheme.standardTheme,
      themeMode: ThemeMode.dark,

      // Start with Combat Mode Dashboard for demo
      home: const CombatModeDashboard(),

      // Production: Use proper routing
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => const HomeScreen(),
      //   '/unit-converter': (context) => const UnitConverterScreen(),
      //   '/timeline': (context) => const TimelineScreen(),
      //   '/combat-mode': (context) => const CombatModeDashboard(),
      //   '/substitutions': (context) => const SubstitutionsScreen(),
      // },
    );
  }
}

// Future<void> _initializeDatabase() async {
//   // Initialize Isar database
//   final dir = await getApplicationDocumentsDirectory();
//   final isar = await Isar.open(
//     [
//       // Schema definitions here
//     ],
//     directory: dir.path,
//   );
// }
