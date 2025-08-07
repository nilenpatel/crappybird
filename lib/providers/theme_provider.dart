import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chess_piece.dart';

enum ChessTheme {
  classic,
  neon,
  nature,
  space,
  medieval,
  cyberpunk,
  underwater,
  volcanic,
  arctic,
  mystical,
}

class ThemeProvider extends ChangeNotifier {
  ChessTheme _currentTheme = ChessTheme.classic;
  bool _isDarkMode = false;
  bool _weatherBasedTheming = true;
  bool _particleEffects = true;
  double _animationSpeed = 1.0;

  // Getters
  ChessTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  bool get weatherBasedTheming => _weatherBasedTheming;
  bool get particleEffects => _particleEffects;
  double get animationSpeed => _animationSpeed;

  ThemeData get materialTheme => _buildMaterialTheme();
  Map<String, Color> get chessColors => _getChessColors();
  Map<String, String> get pieceAssets => _getPieceAssets();

  ThemeProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = ChessTheme.values[prefs.getInt('chess_theme') ?? 0];
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _weatherBasedTheming = prefs.getBool('weather_theming') ?? true;
    _particleEffects = prefs.getBool('particle_effects') ?? true;
    _animationSpeed = prefs.getDouble('animation_speed') ?? 1.0;
    notifyListeners();
  }

  void setTheme(ChessTheme theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chess_theme', theme.index);
    notifyListeners();
  }

  void setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
    notifyListeners();
  }

  void setWeatherBasedTheming(bool enabled) async {
    _weatherBasedTheming = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weather_theming', enabled);
    notifyListeners();
  }

  void setParticleEffects(bool enabled) async {
    _particleEffects = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('particle_effects', enabled);
    notifyListeners();
  }

  void setAnimationSpeed(double speed) async {
    _animationSpeed = speed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('animation_speed', speed);
    notifyListeners();
  }

  // Weather-based theme adaptation
  void adaptToWeather(WeatherEffect weather) {
    if (!_weatherBasedTheming) return;

    ChessTheme newTheme = _currentTheme;
    
    switch (weather) {
      case WeatherEffect.rain:
        newTheme = ChessTheme.nature;
        break;
      case WeatherEffect.storm:
        newTheme = ChessTheme.cyberpunk;
        break;
      case WeatherEffect.fog:
        newTheme = ChessTheme.mystical;
        break;
      case WeatherEffect.ice:
        newTheme = ChessTheme.arctic;
        break;
      case WeatherEffect.fire:
        newTheme = ChessTheme.volcanic;
        break;
      case WeatherEffect.wind:
        newTheme = ChessTheme.space;
        break;
      case WeatherEffect.none:
        // Keep current theme
        break;
    }

    if (newTheme != _currentTheme) {
      _currentTheme = newTheme;
      notifyListeners();
    }
  }

  ThemeData _buildMaterialTheme() {
    final colors = _getThemeColors();
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;

    return ThemeData(
      brightness: brightness,
      primarySwatch: colors['primary'] as MaterialColor? ?? Colors.blue,
      scaffoldBackgroundColor: colors['background'],
      appBarTheme: AppBarTheme(
        backgroundColor: colors['primary'],
        foregroundColor: colors['onPrimary'],
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: colors['surface'],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors['primary'],
          foregroundColor: colors['onPrimary'],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: colors['onBackground'], fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: colors['onBackground']),
        bodyMedium: TextStyle(color: colors['onSurface']),
      ),
    );
  }

  Map<String, Color> _getThemeColors() {
    switch (_currentTheme) {
      case ChessTheme.classic:
        return _isDarkMode ? _classicDarkColors : _classicLightColors;
      case ChessTheme.neon:
        return _neonColors;
      case ChessTheme.nature:
        return _natureColors;
      case ChessTheme.space:
        return _spaceColors;
      case ChessTheme.medieval:
        return _medievalColors;
      case ChessTheme.cyberpunk:
        return _cyberpunkColors;
      case ChessTheme.underwater:
        return _underwaterColors;
      case ChessTheme.volcanic:
        return _volcanicColors;
      case ChessTheme.arctic:
        return _arcticColors;
      case ChessTheme.mystical:
        return _mysticalColors;
    }
  }

  Map<String, Color> get _classicLightColors => {
    'primary': Colors.brown[700]!,
    'onPrimary': Colors.white,
    'background': Colors.grey[100]!,
    'onBackground': Colors.black87,
    'surface': Colors.white,
    'onSurface': Colors.black87,
  };

  Map<String, Color> get _classicDarkColors => {
    'primary': Colors.brown[300]!,
    'onPrimary': Colors.black,
    'background': Colors.grey[900]!,
    'onBackground': Colors.white,
    'surface': Colors.grey[800]!,
    'onSurface': Colors.white,
  };

  Map<String, Color> get _neonColors => {
    'primary': Colors.cyan[400]!,
    'onPrimary': Colors.black,
    'background': Colors.black,
    'onBackground': Colors.cyan[100]!,
    'surface': Colors.grey[900]!,
    'onSurface': Colors.cyan[100]!,
  };

  Map<String, Color> get _natureColors => {
    'primary': Colors.green[600]!,
    'onPrimary': Colors.white,
    'background': Colors.green[50]!,
    'onBackground': Colors.green[900]!,
    'surface': Colors.green[100]!,
    'onSurface': Colors.green[800]!,
  };

  Map<String, Color> get _spaceColors => {
    'primary': Colors.deepPurple[400]!,
    'onPrimary': Colors.white,
    'background': Colors.indigo[900]!,
    'onBackground': Colors.white,
    'surface': Colors.indigo[800]!,
    'onSurface': Colors.white,
  };

  Map<String, Color> get _medievalColors => {
    'primary': Colors.amber[800]!,
    'onPrimary': Colors.black,
    'background': Colors.brown[100]!,
    'onBackground': Colors.brown[900]!,
    'surface': Colors.brown[50]!,
    'onSurface': Colors.brown[800]!,
  };

  Map<String, Color> get _cyberpunkColors => {
    'primary': Colors.pink[400]!,
    'onPrimary': Colors.black,
    'background': Colors.black,
    'onBackground': Colors.pink[100]!,
    'surface': Colors.grey[900]!,
    'onSurface': Colors.pink[100]!,
  };

  Map<String, Color> get _underwaterColors => {
    'primary': Colors.blue[600]!,
    'onPrimary': Colors.white,
    'background': Colors.blue[50]!,
    'onBackground': Colors.blue[900]!,
    'surface': Colors.blue[100]!,
    'onSurface': Colors.blue[800]!,
  };

  Map<String, Color> get _volcanicColors => {
    'primary': Colors.red[700]!,
    'onPrimary': Colors.white,
    'background': Colors.red[50]!,
    'onBackground': Colors.red[900]!,
    'surface': Colors.red[100]!,
    'onSurface': Colors.red[800]!,
  };

  Map<String, Color> get _arcticColors => {
    'primary': Colors.lightBlue[300]!,
    'onPrimary': Colors.black,
    'background': Colors.grey[50]!,
    'onBackground': Colors.grey[800]!,
    'surface': Colors.white,
    'onSurface': Colors.grey[700]!,
  };

  Map<String, Color> get _mysticalColors => {
    'primary': Colors.purple[400]!,
    'onPrimary': Colors.white,
    'background': Colors.purple[50]!,
    'onBackground': Colors.purple[900]!,
    'surface': Colors.purple[100]!,
    'onSurface': Colors.purple[800]!,
  };

  Map<String, Color> _getChessColors() {
    final themeColors = _getThemeColors();
    
    switch (_currentTheme) {
      case ChessTheme.classic:
        return {
          'lightSquare': const Color(0xFFF0D9B5),
          'darkSquare': const Color(0xFFB58863),
          'selectedSquare': Colors.yellow[300]!,
          'possibleMove': Colors.green[300]!.withOpacity(0.6),
          'lastMove': Colors.orange[300]!.withOpacity(0.6),
          'check': Colors.red[400]!,
        };
      case ChessTheme.neon:
        return {
          'lightSquare': Colors.grey[900]!,
          'darkSquare': Colors.black,
          'selectedSquare': Colors.cyan[400]!,
          'possibleMove': Colors.cyan[200]!.withOpacity(0.6),
          'lastMove': Colors.pink[400]!.withOpacity(0.6),
          'check': Colors.red[400]!,
        };
      case ChessTheme.nature:
        return {
          'lightSquare': Colors.green[100]!,
          'darkSquare': Colors.green[600]!,
          'selectedSquare': Colors.yellow[400]!,
          'possibleMove': Colors.lime[300]!.withOpacity(0.6),
          'lastMove': Colors.orange[400]!.withOpacity(0.6),
          'check': Colors.red[500]!,
        };
      case ChessTheme.space:
        return {
          'lightSquare': Colors.indigo[100]!,
          'darkSquare': Colors.indigo[800]!,
          'selectedSquare': Colors.purple[300]!,
          'possibleMove': Colors.purple[200]!.withOpacity(0.6),
          'lastMove': Colors.amber[400]!.withOpacity(0.6),
          'check': Colors.red[400]!,
        };
      case ChessTheme.medieval:
        return {
          'lightSquare': Colors.amber[100]!,
          'darkSquare': Colors.brown[600]!,
          'selectedSquare': Colors.amber[400]!,
          'possibleMove': Colors.amber[300]!.withOpacity(0.6),
          'lastMove': Colors.orange[500]!.withOpacity(0.6),
          'check': Colors.red[600]!,
        };
      case ChessTheme.cyberpunk:
        return {
          'lightSquare': Colors.grey[800]!,
          'darkSquare': Colors.black,
          'selectedSquare': Colors.pink[400]!,
          'possibleMove': Colors.cyan[300]!.withOpacity(0.6),
          'lastMove': Colors.pink[300]!.withOpacity(0.6),
          'check': Colors.red[400]!,
        };
      case ChessTheme.underwater:
        return {
          'lightSquare': Colors.blue[50]!,
          'darkSquare': Colors.blue[400]!,
          'selectedSquare': Colors.teal[300]!,
          'possibleMove': Colors.teal[200]!.withOpacity(0.6),
          'lastMove': Colors.orange[400]!.withOpacity(0.6),
          'check': Colors.red[400]!,
        };
      case ChessTheme.volcanic:
        return {
          'lightSquare': Colors.red[100]!,
          'darkSquare': Colors.red[600]!,
          'selectedSquare': Colors.orange[400]!,
          'possibleMove': Colors.orange[300]!.withOpacity(0.6),
          'lastMove': Colors.yellow[500]!.withOpacity(0.6),
          'check': Colors.red[700]!,
        };
      case ChessTheme.arctic:
        return {
          'lightSquare': Colors.grey[50]!,
          'darkSquare': Colors.blueGrey[300]!,
          'selectedSquare': Colors.lightBlue[200]!,
          'possibleMove': Colors.lightBlue[100]!.withOpacity(0.6),
          'lastMove': Colors.blue[200]!.withOpacity(0.6),
          'check': Colors.red[400]!,
        };
      case ChessTheme.mystical:
        return {
          'lightSquare': Colors.purple[50]!,
          'darkSquare': Colors.purple[400]!,
          'selectedSquare': Colors.purple[200]!,
          'possibleMove': Colors.purple[100]!.withOpacity(0.6),
          'lastMove': Colors.pink[300]!.withOpacity(0.6),
          'check': Colors.red[500]!,
        };
    }
  }

  Map<String, String> _getPieceAssets() {
    final themePrefix = _currentTheme.name;
    
    return {
      // White pieces
      'w_king': 'assets/pieces/$themePrefix/w_king.png',
      'w_queen': 'assets/pieces/$themePrefix/w_queen.png',
      'w_rook': 'assets/pieces/$themePrefix/w_rook.png',
      'w_bishop': 'assets/pieces/$themePrefix/w_bishop.png',
      'w_knight': 'assets/pieces/$themePrefix/w_knight.png',
      'w_pawn': 'assets/pieces/$themePrefix/w_pawn.png',
      
      // Black pieces
      'b_king': 'assets/pieces/$themePrefix/b_king.png',
      'b_queen': 'assets/pieces/$themePrefix/b_queen.png',
      'b_rook': 'assets/pieces/$themePrefix/b_rook.png',
      'b_bishop': 'assets/pieces/$themePrefix/b_bishop.png',
      'b_knight': 'assets/pieces/$themePrefix/b_knight.png',
      'b_pawn': 'assets/pieces/$themePrefix/b_pawn.png',
      
      // Evolved pieces
      'w_super_pawn': 'assets/pieces/$themePrefix/w_super_pawn.png',
      'w_mega_rook': 'assets/pieces/$themePrefix/w_mega_rook.png',
      'w_knight_rider': 'assets/pieces/$themePrefix/w_knight_rider.png',
      'w_archbishop': 'assets/pieces/$themePrefix/w_archbishop.png',
      'w_chancellor': 'assets/pieces/$themePrefix/w_chancellor.png',
      'w_emperor': 'assets/pieces/$themePrefix/w_emperor.png',
      
      'b_super_pawn': 'assets/pieces/$themePrefix/b_super_pawn.png',
      'b_mega_rook': 'assets/pieces/$themePrefix/b_mega_rook.png',
      'b_knight_rider': 'assets/pieces/$themePrefix/b_knight_rider.png',
      'b_archbishop': 'assets/pieces/$themePrefix/b_archbishop.png',
      'b_chancellor': 'assets/pieces/$themePrefix/b_chancellor.png',
      'b_emperor': 'assets/pieces/$themePrefix/b_emperor.png',
    };
  }

  // Get particle effect for piece type
  String getParticleEffect(PieceType type, String action) {
    final themePrefix = _currentTheme.name;
    return 'assets/particles/$themePrefix/${type.name}_$action.json';
  }

  // Get background pattern or texture
  String getBackgroundAsset() {
    return 'assets/backgrounds/${_currentTheme.name}_bg.png';
  }

  // Get sound theme
  String getSoundTheme() {
    switch (_currentTheme) {
      case ChessTheme.space:
        return 'space';
      case ChessTheme.medieval:
        return 'medieval';
      case ChessTheme.cyberpunk:
        return 'cyberpunk';
      case ChessTheme.underwater:
        return 'underwater';
      default:
        return 'classic';
    }
  }

  // Animation duration based on speed setting
  Duration getAnimationDuration(Duration baseDuration) {
    return Duration(
      milliseconds: (baseDuration.inMilliseconds / _animationSpeed).round(),
    );
  }
}