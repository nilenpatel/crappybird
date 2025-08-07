import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _particleOpacity;

  bool _isLoading = true;
  String _loadingText = 'Initializing Quantum Chess...';
  double _loadingProgress = 0.0;

  final List<String> _loadingSteps = [
    'Initializing Quantum Chess...',
    'Loading piece assets...',
    'Preparing AI opponents...',
    'Setting up weather system...',
    'Configuring AR support...',
    'Loading sound effects...',
    'Ready to play!',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _particleOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.easeInOut,
      ),
    );

    _logoController.forward();
  }

  Future<void> _startLoadingSequence() async {
    final soundService = SoundService();
    await soundService.initialize();

    for (int i = 0; i < _loadingSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        setState(() {
          _loadingText = _loadingSteps[i];
          _loadingProgress = (i + 1) / _loadingSteps.length;
        });
      }

      // Perform actual initialization tasks
      switch (i) {
        case 1:
          await _loadAssets();
          break;
        case 2:
          await _initializeAI();
          break;
        case 3:
          await _setupWeatherSystem();
          break;
        case 4:
          await _configureAR();
          break;
        case 5:
          await _loadSounds();
          break;
      }
    }

    // Navigate to home screen
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToHome();
    }
  }

  Future<void> _loadAssets() async {
    // Simulate asset loading
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _initializeAI() async {
    // Initialize AI system
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> _setupWeatherSystem() async {
    if (mounted) {
      final weatherProvider = context.read<WeatherProvider>();
      await weatherProvider.updateWeatherFromLocation();
    }
  }

  Future<void> _configureAR() async {
    // Configure AR support
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _loadSounds() async {
    final soundService = SoundService();
    await soundService.preloadSounds();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            if (themeProvider.particleEffects) ..._buildParticles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animation
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value * 0.1,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white,
                                  theme.primaryColor,
                                  Colors.black,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // App name
                  Text(
                    Constants.appName,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 20),

                  // Subtitle
                  Text(
                    Constants.appDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1500.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 80),

                  // Loading indicator
                  if (_isLoading) ...[
                    SizedBox(
                      width: 250,
                      child: Column(
                        children: [
                          // Progress bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: _loadingProgress,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor.withOpacity(0.8),
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 2000.ms)
                              .slideX(begin: -1, end: 0),

                          const SizedBox(height: 20),

                          // Loading text
                          Text(
                            _loadingText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 2200.ms)
                              .slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Version info
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Text(
                'Version ${Constants.appVersion}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              )
                  .animate()
                  .fadeIn(delay: 3000.ms, duration: 1000.ms),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(20, (index) {
      final random = (index * 137.5) % 360;
      final size = 2.0 + (index % 3);
      final left = (index * 25.7) % MediaQuery.of(context).size.width;
      final top = (index * 31.3) % MediaQuery.of(context).size.height;

      return Positioned(
        left: left,
        top: top,
        child: AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Transform.rotate(
              angle: random + _particleController.value * 6.28,
              child: Opacity(
                opacity: _particleOpacity.value * (0.3 + (index % 3) * 0.2),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: size * 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}