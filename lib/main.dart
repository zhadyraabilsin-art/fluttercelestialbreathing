import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MindfulBreathingApp());
}

class MindfulBreathingApp extends StatelessWidget {
  const MindfulBreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Celestial Breathing',
      theme: ThemeData.dark(useMaterial3: true),
      home: const BreathingScreen(),
    );
  }
}

class BreathingPattern {
  final String name;
  final String subtitle;
  final int inhaleSec;
  final int holdInSec;
  final int exhaleSec;
  final int holdOutSec;
  final Color accentColor;

  const BreathingPattern({
    required this.name,
    required this.subtitle,
    required this.inhaleSec,
    required this.holdInSec,
    required this.exhaleSec,
    required this.holdOutSec,
    required this.accentColor,
  });
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  final List<BreathingPattern> _patterns = const [
    BreathingPattern(
      name: 'Box Focus',
      subtitle: '4s Inhale • 4s Hold • 4s Exhale • 4s Hold',
      inhaleSec: 4,
      holdInSec: 4,
      exhaleSec: 4,
      holdOutSec: 4,
      accentColor: Colors.tealAccent,
    ),
    BreathingPattern(
      name: '4-7-8 Calm',
      subtitle: '4s Inhale • 7s Hold • 8s Exhale',
      inhaleSec: 4,
      holdInSec: 7,
      exhaleSec: 8,
      holdOutSec: 0,
      accentColor: Colors.indigoAccent,
    ),
    BreathingPattern(
      name: 'Quick Reset',
      subtitle: '3s Inhale • 2s Hold • 5s Exhale',
      inhaleSec: 3,
      holdInSec: 2,
      exhaleSec: 5,
      holdOutSec: 0,
      accentColor: Colors.amberAccent,
    ),
  ];

  int _selectedPatternIndex = 0;
  bool _isRunning = false;
  String _phaseLabel = 'Ready';
  int _secondsRemaining = 0;
  double _circleScale = 0.55;
  int _completedCycles = 0;
  Timer? _timer;

  BreathingPattern get _current => _patterns[_selectedPatternIndex];

  void _toggleSession() {
    if (_isRunning) {
      _stopSession();
    } else {
      _startSession();
    }
  }

  void _startSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = true;
      _completedCycles = 0;
    });
    _runPhase(0);
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _phaseLabel = 'Ready';
      _secondsRemaining = 0;
      _circleScale = 0.55;
    });
  }

  void _runPhase(int step) {
    if (!mounted || !_isRunning) return;

    int duration = 0;
    String label = '';
    double targetScale = _circleScale;

    if (step == 0) {
      duration = _current.inhaleSec;
      label = 'Inhale Slowly';
      targetScale = 1.0;
    } else if (step == 1) {
      duration = _current.holdInSec;
      label = 'Hold Breath';
      targetScale = 1.0;
    } else if (step == 2) {
      duration = _current.exhaleSec;
      label = 'Exhale Gently';
      targetScale = 0.52;
    } else {
      duration = _current.holdOutSec;
      label = 'Hold Empty';
      targetScale = 0.52;
    }

    if (duration == 0) {
      _advanceStep(step);
      return;
    }

    setState(() {
      _phaseLabel = label;
      _secondsRemaining = duration;
      _circleScale = targetScale;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !_isRunning) {
        t.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        t.cancel();
        _advanceStep(step);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _advanceStep(int currentStep) {
    if (currentStep == 3) {
      setState(() => _completedCycles++);
      _runPhase(0);
    } else {
      _runPhase(currentStep + 1);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _current.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Celestial Breath',
          style: TextStyle(letterSpacing: 1.4, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_patterns.length, (index) {
                  final p = _patterns[index];
                  final selected = index == _selectedPatternIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(p.name),
                      selected: selected,
                      onSelected: (_) {
                        _stopSession();
                        setState(() => _selectedPatternIndex = index);
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _current.subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const Spacer(),
            SizedBox(
              width: 270,
              height: 270,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  AnimatedScale(
                    scale: _circleScale,
                    duration: Duration(
                      seconds: _isRunning && _secondsRemaining > 0
                          ? _secondsRemaining
                          : 1,
                    ),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accent.withValues(alpha: 0.65),
                            accent.withValues(alpha: 0.12),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _phaseLabel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isRunning) ...[
                        const SizedBox(height: 6),
                        Text(
                          '$_secondsRemaining',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'Completed Cycles: $_completedCycles',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _toggleSession,
                icon: Icon(_isRunning ? Icons.stop : Icons.spa),
                label: Text(_isRunning ? 'Stop Session' : 'Begin Breathing'),
                style: FilledButton.styleFrom(
                  backgroundColor: _isRunning
                      ? Colors.redAccent.shade700
                      : accent.withValues(alpha: 0.85),
                  foregroundColor: _isRunning ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
