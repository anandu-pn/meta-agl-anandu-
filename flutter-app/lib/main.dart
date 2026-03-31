import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const AGLQuizApp());
}

class AGLQuizApp extends StatelessWidget {
  const AGLQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGL Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00BFA5),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _aglVersion = 'Reading...';
  String _aglPrettyName = '';
  bool _showPicture = false;
  bool _soundPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _readAGLVersion();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Reads AGL version info from /etc/os-release
  Future<void> _readAGLVersion() async {
    try {
      final file = File('/etc/os-release');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final lines = contents.split('\n');

        String version = 'Unknown';
        String prettyName = '';

        for (final line in lines) {
          if (line.startsWith('VERSION=')) {
            version = line.substring(8).replaceAll('"', '').trim();
          } else if (line.startsWith('VERSION_ID=')) {
            if (version == 'Unknown') {
              version = line.substring(11).replaceAll('"', '').trim();
            }
          } else if (line.startsWith('PRETTY_NAME=')) {
            prettyName = line.substring(12).replaceAll('"', '').trim();
          }
        }

        setState(() {
          _aglVersion = version;
          _aglPrettyName = prettyName;
        });
      } else {
        // Fallback for development/testing outside AGL
        setState(() {
          _aglVersion = 'N/A (not running on AGL)';
          _aglPrettyName = 'Development Mode';
        });
      }
    } catch (e) {
      setState(() {
        _aglVersion = 'Error reading version: $e';
        _aglPrettyName = '';
      });
    }
  }

  /// Toggle picture display
  void _togglePicture() {
    setState(() {
      _showPicture = !_showPicture;
    });
    if (_showPicture) {
      _fadeController.forward();
    } else {
      _fadeController.reverse();
    }
  }

  /// Play notification sound
  Future<void> _playSound() async {
    setState(() {
      _soundPlaying = true;
    });

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/notification.wav'));

      // Reset state after sound duration
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _soundPlaying = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _soundPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sound playback error: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Header ───────────────────────────────
                _buildHeader(),
                const SizedBox(height: 32),

                // ─── AGL Version Card ─────────────────────
                _buildVersionCard(),
                const SizedBox(height: 24),

                // ─── Developer Info Card ──────────────────
                _buildDeveloperCard(),
                const SizedBox(height: 32),

                // ─── Action Buttons ───────────────────────
                _buildActionButtons(),
                const SizedBox(height: 24),

                // ─── Picture Display Area ─────────────────
                if (_showPicture) _buildPictureArea(),
                const SizedBox(height: 16),

                // ─── Footer ──────────────────────────────
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00BFA5).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.directions_car, size: 48, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'AGL Quiz App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Automotive Grade Linux • GSoC 2026',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E1E30),
        border: Border.all(
          color: const Color(0xFF00BFA5).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF00BFA5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AGL System Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          _infoRow('Version', _aglVersion),
          if (_aglPrettyName.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow('System', _aglPrettyName),
          ],
          const SizedBox(height: 8),
          _infoRow('Source', '/etc/os-release'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF00E5CC),
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.15),
            const Color(0xFF3F3D8C).withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anandu P N',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'GSoC 2026 Applicant • AGL Developer',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Button 1: Show Picture
        Expanded(
          child: _ActionButton(
            icon: _showPicture ? Icons.visibility_off : Icons.image,
            label: _showPicture ? 'Hide Picture' : 'Show Picture',
            gradient: const [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
            onTap: _togglePicture,
            isActive: _showPicture,
          ),
        ),
        const SizedBox(width: 16),
        // Button 2: Play Sound
        Expanded(
          child: _ActionButton(
            icon: _soundPlaying ? Icons.volume_up : Icons.music_note,
            label: _soundPlaying ? 'Playing...' : 'Play Sound',
            gradient: const [Color(0xFF4834DF), Color(0xFF6C63FF)],
            onTap: _soundPlaying ? null : _playSound,
            isActive: _soundPlaying,
          ),
        ),
      ],
    );
  }

  Widget _buildPictureArea() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/agl_car.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback: show a generated automotive graphic
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                      Color(0xFF0F3460),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPainter(),
                      ),
                    ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_filled,
                            size: 80,
                            color: const Color(0xFF00BFA5).withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Automotive Grade Linux',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA5).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF00BFA5).withOpacity(0.5),
                              ),
                            ),
                            child: const Text(
                              'Open Source IVI Platform',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF00E5CC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 8),
          Text(
            'Built with Flutter for AGL • GSoC 2026',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Custom action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isActive
                ? gradient.map((c) => c.withOpacity(0.8)).toList()
                : gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(isActive ? 0.5 : 0.3),
              blurRadius: isActive ? 24 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for background grid pattern
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00BFA5).withOpacity(0.05)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
