import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PincheJuanApp());
}

class PincheJuanApp extends StatelessWidget {
  const PincheJuanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinche Juan - KitchenOS',
      debugShowCheckedModeBanner: false,
      theme: _buildCombatTheme(),
      home: const CombatModeDemoScreen(),
    );
  }

  ThemeData _buildCombatTheme() {
    const neonGreen = Color(0xFF00FF41);
    const neonRed = Color(0xFFFF0055);
    const neonYellow = Color(0xFFFFED00);
    const neonBlue = Color(0xFF00D9FF);
    const darkBackground = Color(0xFF0A0E27);
    const surfaceDark = Color(0xFF1A1F3A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonBlue,
        tertiary: neonYellow,
        error: neonRed,
        surface: surfaceDark,
        background: darkBackground,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          color: neonGreen,
        ),
        displayMedium: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: neonBlue,
        ),
        bodyLarge: TextStyle(
          fontSize: 24,
          color: Colors.white70,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF0F1529),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: neonGreen, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 80),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          backgroundColor: neonGreen,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CombatModeDemoScreen extends StatefulWidget {
  const CombatModeDemoScreen({super.key});

  @override
  State<CombatModeDemoScreen> createState() => _CombatModeDemoScreenState();
}

class _CombatModeDemoScreenState extends State<CombatModeDemoScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Critical Alert Banner
            _buildCriticalAlert(),
            // Main Content
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildActiveTimers(),
                  ),
                  Container(
                    width: 2,
                    color: const Color(0xFF00FF41).withOpacity(0.3),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildNextTask(),
                  ),
                ],
              ),
            ),
            // Control Bar
            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFF0055),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.black),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMMEDIATE ACTION REQUIRED',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Remove chicken from oven',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimers() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        _TimerCard(
          taskName: 'ROAST CHICKEN',
          duration: const Duration(minutes: 45, seconds: 30),
        ),
        const SizedBox(height: 24),
        _TimerCard(
          taskName: 'BOIL POTATOES',
          duration: const Duration(minutes: 12, seconds: 45),
        ),
      ],
    );
  }

  Widget _buildNextTask() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00D9FF), width: 2),
            ),
            child: Text(
              'NEXT UP',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF00D9FF),
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              color: const Color(0xFF1A1F3A),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.set_meal, size: 60, color: Color(0xFF00D9FF)),
                    const SizedBox(height: 24),
                    Text(
                      'REST MEAT',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'STARTS IN',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '10:30',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: const Color(0xFF00D9FF),
                            fontSize: 56,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D9FF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00D9FF), width: 2),
                      ),
                      child: Text(
                        'Duration: 15m',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF00D9FF),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1529),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00FF41).withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.pause_circle,
            label: 'PAUSE',
            color: const Color(0xFFFFED00),
            onPressed: () {},
          ),
          _ControlButton(
            icon: Icons.skip_next,
            label: 'SKIP',
            color: const Color(0xFFFF6B00),
            onPressed: () {},
          ),
          _ControlButton(
            icon: Icons.stop_circle,
            label: 'END',
            color: const Color(0xFFFF0055),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _TimerCard extends StatefulWidget {
  final String taskName;
  final Duration duration;

  const _TimerCard({
    required this.taskName,
    required this.duration,
  });

  @override
  State<_TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<_TimerCard> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_remaining.inSeconds > 0) {
            _remaining = Duration(seconds: _remaining.inSeconds - 1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    final progress = 1.0 - (_remaining.inSeconds / widget.duration.inSeconds);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.taskName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 120),
                  ),
                  onPressed: () {},
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 48, color: Colors.black),
                      SizedBox(height: 8),
                      Text('COMPLETE', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFF1A1F3A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF41)),
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        minimumSize: const Size(150, 80),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.black),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
