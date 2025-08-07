class Constants {
  // App Info
  static const String appName = 'Quantum Chess';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Revolutionary chess with unique gameplay mechanics';

  // API Keys (In production, these should be stored securely)
  static const String openWeatherApiKey = 'your_openweather_api_key_here';
  static const String firebaseApiKey = 'your_firebase_api_key_here';
  static const String multiplayerServerUrl = 'wss://quantum-chess-server.com/ws';

  // Game Configuration
  static const int maxEvolutionLevel = 5;
  static const int evolutionPointsPerMove = 1;
  static const int evolutionPointsPerCapture = 3;
  static const int evolutionPointsPerCheck = 2;
  
  // Weather System
  static const int weatherChangeIntervalMinutes = 5;
  static const double weatherIntensityMultiplier = 1.0;
  
  // AI Configuration
  static const int aiMaxThinkingTime = 5000; // milliseconds
  static const int aiMinThinkingTime = 500;
  static const double aiRandomnessFactor = 0.1;
  
  // Animation Durations
  static const Duration pieceMoveDuration = Duration(milliseconds: 300);
  static const Duration evolutionAnimationDuration = Duration(milliseconds: 2000);
  static const Duration weatherTransitionDuration = Duration(milliseconds: 1500);
  static const Duration uiAnimationDuration = Duration(milliseconds: 200);
  
  // Board Configuration
  static const double boardSize = 350.0;
  static const double pieceSize = 40.0;
  static const double squareSize = 43.75; // boardSize / 8
  
  // Colors
  static const int primaryColorValue = 0xFF8B4513;
  static const int accentColorValue = 0xFFFFD700;
  static const int errorColorValue = 0xFFD32F2F;
  static const int successColorValue = 0xFF388E3C;
  
  // Multiplayer
  static const int maxPlayersPerRoom = 2;
  static const int spectatorLimit = 50;
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration heartbeatInterval = Duration(seconds: 30);
  
  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String gameHistoryKey = 'game_history';
  static const String achievementsKey = 'achievements';
  static const String statisticsKey = 'statistics';
  static const String customPiecesKey = 'custom_pieces';
  
  // File Paths
  static const String assetsPath = 'assets/';
  static const String imagesPath = '${assetsPath}images/';
  static const String soundsPath = '${assetsPath}sounds/';
  static const String animationsPath = '${assetsPath}animations/';
  static const String fontsPath = '${assetsPath}fonts/';
  
  // Piece Values (for AI evaluation)
  static const Map<String, int> pieceValues = {
    'pawn': 1,
    'knight': 3,
    'bishop': 3,
    'rook': 5,
    'queen': 9,
    'king': 1000,
    // Evolved pieces
    'superPawn': 3,
    'megaRook': 8,
    'knightRider': 6,
    'archbishop': 7,
    'chancellor': 8,
    'emperor': 1200,
  };
  
  // Achievement Configuration
  static const Map<String, Map<String, dynamic>> achievements = {
    'first_evolution': {
      'title': 'Evolution Master',
      'description': 'Evolve your first piece',
      'points': 100,
      'icon': 'evolution_badge',
    },
    'weather_warrior': {
      'title': 'Weather Warrior',
      'description': 'Win a game in stormy weather',
      'points': 150,
      'icon': 'storm_badge',
    },
    'ai_conqueror': {
      'title': 'AI Conqueror',
      'description': 'Defeat all AI personalities',
      'points': 500,
      'icon': 'ai_badge',
    },
    'grandmaster': {
      'title': 'Quantum Grandmaster',
      'description': 'Reach the highest skill level',
      'points': 1000,
      'icon': 'grandmaster_badge',
    },
  };
  
  // Tutorial Steps
  static const List<String> tutorialSteps = [
    'Welcome to Quantum Chess!',
    'Move pieces like traditional chess',
    'Pieces evolve as they gain experience',
    'Weather affects piece abilities',
    'Use AR mode for immersive gameplay',
    'Challenge AI opponents with unique personalities',
    'Ready to play!',
  ];
  
  // Supported Languages
  static const List<String> supportedLanguages = [
    'en', // English
    'es', // Spanish
    'fr', // French
    'de', // German
    'it', // Italian
    'pt', // Portuguese
    'ru', // Russian
    'zh', // Chinese
    'ja', // Japanese
    'ko', // Korean
  ];
  
  // Game Modes
  static const Map<String, Map<String, dynamic>> gameModes = {
    'classic': {
      'name': 'Classic',
      'description': 'Traditional chess rules',
      'features': ['standard_pieces', 'traditional_rules'],
    },
    'evolution': {
      'name': 'Evolution',
      'description': 'Pieces evolve during gameplay',
      'features': ['piece_evolution', 'experience_system'],
    },
    'weather': {
      'name': 'Weather Chess',
      'description': 'Dynamic weather affects gameplay',
      'features': ['weather_effects', 'environmental_changes'],
    },
    'timeAttack': {
      'name': 'Time Attack',
      'description': 'Fast-paced chess with time pressure',
      'features': ['time_limit', 'speed_bonuses'],
    },
    'ar3d': {
      'name': 'AR Chess',
      'description': '3D and augmented reality chess',
      'features': ['3d_board', 'ar_support'],
    },
    'multiplayer': {
      'name': 'Multiplayer',
      'description': 'Play against other players online',
      'features': ['online_play', 'voice_chat', 'spectator_mode'],
    },
  };
  
  // Network Configuration
  static const int maxRetryAttempts = 3;
  static const Duration networkTimeout = Duration(seconds: 15);
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Performance Settings
  static const int maxParticleCount = 200;
  static const double defaultAnimationSpeed = 1.0;
  static const bool enableHapticFeedback = true;
  static const bool enableAnalytics = true;
  
  // Debug Settings
  static const bool enableDebugMode = false;
  static const bool showPerformanceOverlay = false;
  static const bool enableLogging = true;
  
  // Security
  static const int sessionTimeoutMinutes = 60;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Puzzle Configuration
  static const int dailyPuzzleCount = 3;
  static const int puzzleDifficultyLevels = 5;
  static const Map<String, int> puzzleRewards = {
    'easy': 10,
    'medium': 25,
    'hard': 50,
    'expert': 100,
    'master': 200,
  };
  
  // Campaign Configuration
  static const List<String> campaignChapters = [
    'The Awakening',
    'Evolution\'s Call',
    'Storm and Fury',
    'The Frozen Throne',
    'Volcanic Trials',
    'Mystic Realms',
    'The Final Evolution',
  ];
  
  // Social Features
  static const int maxFriends = 100;
  static const int maxChatMessageLength = 200;
  static const Duration chatCooldown = Duration(seconds: 2);
  
  // Monetization (if applicable)
  static const Map<String, Map<String, dynamic>> premiumFeatures = {
    'unlimited_evolution': {
      'price': '\$2.99',
      'description': 'Unlimited piece evolutions',
    },
    'premium_themes': {
      'price': '\$4.99',
      'description': 'Access to all premium themes',
    },
    'advanced_ai': {
      'price': '\$1.99',
      'description': 'Advanced AI opponents',
    },
  };
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Network connection failed. Please check your internet connection.',
    'invalid_move': 'Invalid move. Please try again.',
    'game_not_found': 'Game session not found.',
    'opponent_disconnected': 'Your opponent has disconnected.',
    'weather_service_error': 'Weather service unavailable. Using random weather.',
    'ar_not_supported': 'AR is not supported on this device.',
    'evolution_failed': 'Evolution failed. Requirements not met.',
    'save_failed': 'Failed to save game progress.',
    'load_failed': 'Failed to load game data.',
  };
  
  // Success Messages
  static const Map<String, String> successMessages = {
    'game_saved': 'Game progress saved successfully.',
    'evolution_complete': 'Piece evolution completed!',
    'achievement_unlocked': 'Achievement unlocked!',
    'opponent_joined': 'Opponent joined the game.',
    'weather_updated': 'Weather conditions updated.',
    'settings_saved': 'Settings saved successfully.',
  };
}