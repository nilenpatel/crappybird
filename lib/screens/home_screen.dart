import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/ar_provider.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/game_mode_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/ai_opponent_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  
  final SoundService _soundService = SoundService();
  int _selectedModeIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _soundService.updateMusicForGameState('menu');
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _onGameModeSelected(GameMode mode) {
    _soundService.playButtonClick();
    
    final gameProvider = context.read<GameProvider>();
    gameProvider.startNewGame(mode: mode);
    
    // Navigate to game screen based on mode
    _navigateToGameScreen(mode);
  }

  void _navigateToGameScreen(GameMode mode) {
    // In a full implementation, this would navigate to the appropriate game screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${mode.name} mode...'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final weatherProvider = context.watch<WeatherProvider>();
    final arProvider = context.watch<ARProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    Constants.appName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  // Settings button
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _showSettingsDialog(),
                  ),
                  // Weather info
                  WeatherWidget(
                    weather: weatherProvider.currentEffect,
                    intensity: weatherProvider.intensity,
                  ),
                ],
              ),

              // Main content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Welcome message
                    _buildWelcomeSection(),
                    
                    const SizedBox(height: 30),
                    
                    // Game modes
                    _buildGameModesSection(),
                    
                    const SizedBox(height: 30),
                    
                    // Quick actions
                    _buildQuickActionsSection(),
                    
                    const SizedBox(height: 30),
                    
                    // Features showcase
                    _buildFeaturesSection(),
                    
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome to Quantum Chess',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Experience chess like never before with evolving pieces, dynamic weather, AR gameplay, and AI opponents with unique personalities.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildGameModesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Modes',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: GameMode.values.length,
          itemBuilder: (context, index) {
            final mode = GameMode.values[index];
            final modeInfo = Constants.gameModes[mode.name];
            
            return GameModeCard(
              mode: mode,
              title: modeInfo?['name'] ?? mode.name,
              description: modeInfo?['description'] ?? '',
              features: List<String>.from(modeInfo?['features'] ?? []),
              onTap: () => _onGameModeSelected(mode),
              isSelected: _selectedModeIndex == index,
            ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.3, end: 0);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.psychology,
                label: 'AI Challenge',
                onTap: () => _showAIOpponentSelector(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.view_in_ar,
                label: 'AR Mode',
                onTap: () => _toggleARMode(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.cloud,
                label: 'Weather',
                onTap: () => _showWeatherSettings(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.trending_up,
        'title': 'Piece Evolution',
        'description': 'Watch your pieces evolve and gain new abilities as they gain experience.',
      },
      {
        'icon': Icons.wb_cloudy,
        'title': 'Dynamic Weather',
        'description': 'Real-world weather affects gameplay with unique environmental effects.',
      },
      {
        'icon': Icons.view_in_ar,
        'title': 'AR & 3D Mode',
        'description': 'Immersive augmented reality and 3D chess experience.',
      },
      {
        'icon': Icons.smart_toy,
        'title': 'AI Personalities',
        'description': 'Challenge AI opponents with distinct playing styles and personalities.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unique Features',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureItem(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
        )).toList(),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    _soundService.playMenuOpen();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings dialog would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () {
              _soundService.playMenuClose();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAIOpponentSelector() {
    _soundService.playMenuOpen();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIOpponentSelector(),
    );
  }

  void _toggleARMode() {
    final arProvider = context.read<ARProvider>();
    if (arProvider.isARSupported) {
      _soundService.playSuccess();
      // Toggle AR mode
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AR Mode toggled!')),
      );
    } else {
      _soundService.playError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AR not supported on this device')),
      );
    }
  }

  void _showWeatherSettings() {
    _soundService.playMenuOpen();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weather Settings'),
        content: const Text('Weather settings dialog would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () {
              _soundService.playMenuClose();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}