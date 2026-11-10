import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const VocabApp());
}

class VocabApp extends StatelessWidget {
  const VocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VokabelTrainer Bayern MVP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          primary: const Color(0xFF6C5CE7),
          secondary: const Color(0xFF00CEC9),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int _xp = 120;
  int _streak = 5;
  int _coins = 45;

  void _addXp(int amount) {
    setState(() {
      _xp += amount;
      _coins += (amount / 2).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TrainerTab(onXpGained: _addXp),
      OcrScanTab(onVocabAdded: () => _addXp(50)),
      StatsTab(xp: _xp, streak: _streak, coins: _coins),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('VokabelTrainer Gymnasium', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                const Icon(Icons.local_fire_bar, color: Colors.deepOrange),
                Text(' $_streak', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.stars, color: Colors.amber),
                Text(' $_xp XP', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.school), label: 'Lernen'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Foto Scan'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Fortschritt'),
        ],
      ),
    );
  }
}

class TrainerTab extends StatefulWidget {
  final Function(int) onXpGained;
  const TrainerTab({super.key, required this.onXpGained});

  @override
  State<TrainerTab> createState() => _TrainerTabState();
}

class _TrainerTabState extends State<TrainerTab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  int _currentIndex = 0;

  final List> _vocabs = [
    {'foreign': 'rex', 'grammar': 'regis, m. (3. Deklination)', 'translation': 'der König', 'lang': 'Latein'},
    {'foreign': 'amare', 'grammar': 'amō, amāvī, amātum (a-Konj.)', 'translation': 'lieben', 'lang': 'Latein'},
    {'foreign': 'ambition', 'grammar': 'noun [C/U]', 'translation': 'Ehrgeiz, Ziel', 'lang': 'Englisch'},
    {'foreign': 'étoile', 'grammar': 'f. (Substantiv)', 'translation': 'der Stern', 'lang': 'Französisch'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  void _nextVocab(bool remembered) {
    if (remembered) {
      widget.onXpGained(10);
    }
    if (!_isFront) _flipCard();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _vocabs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _vocabs[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Chip(label: Text('${item['lang']} – Lehrplan Bayern'), backgroundColor: Colors.purple.shade50),
          const SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  final isBack = angle >= pi / 2;
                  return Transform(
                    transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                    alignment: Alignment.center,
                    child: isBack
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(pi),
                            alignment: Alignment.center,
                            child: _buildCard(item['translation']!, 'ÜBERSETZUNG', Colors.teal.shade50, Colors.teal),
                          )
                        : _buildCard(item['foreign']!, item['grammar']!, Colors.white, Colors.deepPurple),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _nextVocab(false),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
                icon: const Icon(Icons.close),
                label: const Text('Üben'),
              ),
              ElevatedButton.icon(
                onPressed: () => _nextVocab(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                icon: const Icon(Icons.check),
                label: const Text('Gewusst (+10 XP)'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCard(String mainText, String subText, Color bg, Color textCol) {
    return Card(
      elevation: 6,
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mainText, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: textCol)),
            const SizedBox(height: 12),
            Text(subText, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('Tippen zum Umdrehen 🔄', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class OcrScanTab extends StatelessWidget {
  final VoidCallback onVocabAdded;
  const OcrScanTab({super.key, required this.onVocabAdded});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.document_scanner, size: 80, color: Color(0xFF6C5CE7)),
            const SizedBox(height: 20),
            const Text('Vokabelseite fotografieren', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Fotografiere eine Lektion aus Campus, Green Line oder Découvertes. Die KI erkennt Stammformen und Vokabeln automatisch.', textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                onVocabAdded();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vokabeln aus "Campus C3 - Lektion 12" erfolgreich gescannt! (+50 XP)')),
                );
              },
              icon: const Icon(Icons.camera),
              label: const Text('Foto aufnehmen / OCR Starten'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            )
          ],
        ),
      ),
    );
  }
}

class StatsTab extends StatelessWidget {
  final int xp;
  final int streak;
  final int coins;
  const StatsTab({super.key, required this.xp, required this.streak, required this.coins});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.military_tech, size: 40, color: Colors.amber),
            title: Text('Rang: Latein-Centurio (Level ${(xp / 100).floor() + 1})'),
            subtitle: Text('Gesamte XP: $xp | Münzen: $coins 🪙'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.local_fire_bar, size: 40, color: Colors.deepOrange),
            title: Text('$streak Tage Lernserie'),
            subtitle: const Text('Streak-Freeze aktiv – Kein Verlust bei Schulausfall!'),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Lehrplan-Abdeckung (Bayern Gymnasium G9)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        const LinearProgressIndicator(value: 0.65, minHeight: 10),
        const SizedBox(height: 6),
        const Text('65% der Vokabeln der Jahrgangsstufe 7 gemeistert'),
      ],
    );
  }
}
