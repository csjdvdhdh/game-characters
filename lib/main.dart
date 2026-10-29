import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/shooter_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CharacterShooterApp());
}

class CharacterShooterApp extends StatelessWidget {
  const CharacterShooterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Character Shooter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ShooterGame game;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    game = ShooterGame(characterIndex: selected);
  }

  void _restart(int idx) {
    setState(() {
      selected = idx;
      game = ShooterGame(characterIndex: idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          if (!game.started)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Character Shooter',
                        style: TextStyle(fontSize: 28, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('اختر شخصيتك',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _charBtn(0, '🥊', 'Fighter'),
                        const SizedBox(width: 12),
                        _charBtn(1, '🖤', 'Girl'),
                        const SizedBox(width: 12),
                        _charBtn(2, '🐻', 'Bear'),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          game = ShooterGame(characterIndex: selected);
                          game.started = true;
                        });
                      },
                      child: const Text('ابدأ', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          if (game.gameOver)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('انتهت اللعبة',
                        style: TextStyle(fontSize: 28, color: Colors.white)),
                    Text('النقاط: ${game.score}',
                        style: const TextStyle(color: Colors.white70, fontSize: 18)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                      ),
                      onPressed: () => _restart(selected),
                      child: const Text('العب مرة ثانية'),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hud('Score: ${game.score}'),
                _hud('HP: ${game.hp.clamp(0, 100)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _charBtn(int idx, String emoji, String name) {
    final sel = selected == idx;
    return GestureDetector(
      onTap: () => setState(() => selected = idx),
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? const Color(0xFF6C5CE7) : const Color(0xFF333333),
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _hud(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}
