import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class CharStats {
  final String name;
  final Color color;
  final Color accent;
  final double speed;
  final double dmg;
  final double fireRate;
  CharStats(this.name, this.color, this.accent, this.speed, this.dmg, this.fireRate);
}

final chars = [
  CharStats('Fighter', const Color(0xFF6B8CCE), const Color(0xFFC4A88A), 220, 14, 0.18),
  CharStats('Girl', const Color(0xFF9B59B6), const Color(0xFFE8C4B0), 260, 10, 0.12),
  CharStats('Bear', const Color(0xFFC4A035), const Color(0xFF5B2C8A), 180, 20, 0.28),
];

class ShooterGame extends FlameGame with PanDetector, TapDetector {
  final int characterIndex;
  late CharStats stats;
  late Player player;
  final List<Bullet> bullets = [];
  final List<Enemy> enemies = [];
  final List<Particle> particles = [];
  int score = 0;
  int hp = 100;
  bool started = false;
  bool gameOver = false;
  double spawnTimer = 0;
  double fireTimer = 0;
  Vector2 aim = Vector2(0, -1);
  bool firing = false;

  ShooterGame({this.characterIndex = 0});

  @override
  Future<void> onLoad() async {
    stats = chars[characterIndex.clamp(0, 2)];
    player = Player(stats);
    add(player);
  }

  @override
  void update(double dt) {
    if (!started || gameOver) return;
    super.update(dt);

    // fire
    fireTimer += dt;
    if (firing && fireTimer >= stats.fireRate) {
      fireTimer = 0;
      final b = Bullet(player.position.clone(), aim.normalized() * 420, stats.color, stats.dmg);
      bullets.add(b);
      add(b);
    }

    // spawn
    spawnTimer += dt;
    if (spawnTimer > 0.9) {
      spawnTimer = 0;
      final side = Random().nextBool();
      final e = Enemy(
        Vector2(side ? -30 : size.x + 30, 40 + Random().nextDouble() * size.y * 0.5),
        16 + Random().nextDouble() * 12,
        25 + Random().nextDouble() * 30,
        80 + Random().nextDouble() * 100,
      );
      enemies.add(e);
      add(e);
    }

    // bullets move + hit
    for (final b in List.from(bullets)) {
      if (b.position.x < -40 || b.position.x > size.x + 40 ||
          b.position.y < -40 || b.position.y > size.y + 40) {
        b.removeFromParent();
        bullets.remove(b);
        continue;
      }
      for (final e in List.from(enemies)) {
        if (b.position.distanceTo(e.position) < b.radius + e.radius) {
          e.hp -= b.dmg;
          for (int i = 0; i < 6; i++) {
            final p = Particle(e.position.clone(), e.color);
            particles.add(p);
            add(p);
          }
          b.removeFromParent();
          bullets.remove(b);
          if (e.hp <= 0) {
            score += 10;
            e.removeFromParent();
            enemies.remove(e);
          }
          break;
        }
      }
    }

    // enemies move + hit player
    for (final e in List.from(enemies)) {
      final dir = (player.position - e.position).normalized();
      e.position += dir * e.speed * dt;
      if (e.position.distanceTo(player.position) < e.radius + player.radius) {
        hp -= 8;
        e.removeFromParent();
        enemies.remove(e);
        if (hp <= 0) {
          gameOver = true;
        }
      }
    }

    // particles
    for (final p in List.from(particles)) {
      p.life -= dt;
      if (p.life <= 0) {
        p.removeFromParent();
        particles.remove(p);
      }
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!started || gameOver) return;
    player.position += info.delta.global;
    player.position.x = player.position.x.clamp(player.radius, size.x - player.radius);
    player.position.y = player.position.y.clamp(player.radius, size.y - player.radius);
    aim = (info.eventPosition.global - player.position);
    if (aim.length2 > 0) aim = aim.normalized();
  }

  @override
  void onTapDown(TapDownInfo info) {
    firing = true;
    aim = (info.eventPosition.global - player.position);
    if (aim.length2 > 0) aim = aim.normalized();
  }

  @override
  void onTapUp(TapUpInfo info) => firing = false;

  @override
  void onTapCancel() => firing = false;

  @override
  void render(Canvas canvas) {
    // bg
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = const Color(0xFF0A0A12));
    final grid = Paint()..color = const Color(0xFF141420)..strokeWidth = 1;
    for (double i = 0; i < size.x; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.y), grid);
    }
    for (double i = 0; i < size.y; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.x, i), grid);
    }
    super.render(canvas);
  }
}

class Player extends PositionComponent {
  final CharStats stats;
  double radius = 22;

  Player(this.stats) : super(size: Vector2.all(44), anchor: Anchor.center);

  @override
  void onLoad() {
    position = Vector2(200, 500);
  }

  @override
  void render(Canvas canvas) {
    final body = Paint()..color = stats.color;
    final head = Paint()..color = stats.accent;
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 2.2), body);
    canvas.drawCircle(const Offset(0, -6), 10, head);
    // gun
    canvas.drawRect(const Rect.fromLTWH(-3, -radius - 14, 6, 18), Paint()..color = const Color(0xFFCCCCCC));
  }
}

class Bullet extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double dmg;
  final double radius = 5;

  Bullet(Vector2 pos, this.velocity, this.color, this.dmg)
      : super(position: pos, size: Vector2.all(10), anchor: Anchor.center);

  @override
  void update(double dt) {
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, Paint()..color = color);
  }
}

class Enemy extends PositionComponent {
  double radius;
  double hp;
  double speed;
  final Color color = Color.fromHSB(Random().nextDouble() * 0.15, 0.7, 0.55);

  Enemy(Vector2 pos, this.radius, this.hp, this.speed)
      : super(position: pos, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, Paint()..color = color);
    canvas.drawCircle(const Offset(-4, -3), 3, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(4, -3), 3, Paint()..color = Colors.black);
  }
}

class Particle extends PositionComponent {
  double life = 0.4;
  final Color color;
  final Vector2 vel;

  Particle(Vector2 pos, this.color)
      : vel = Vector2((Random().nextDouble() - 0.5) * 120, (Random().nextDouble() - 0.5) * 120),
        super(position: pos, size: Vector2.all(6), anchor: Anchor.center);

  @override
  void update(double dt) {
    position += vel * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 3, Paint()..color = color.withOpacity((life / 0.4).clamp(0, 1)));
  }
}
