import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import '../models/chess_piece.dart';
import '../utils/constants.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherEffect _currentEffect = WeatherEffect.none;
  double _intensity = 0.0;
  String _description = '';
  bool _isRealWeatherEnabled = true;
  bool _isLoading = false;
  String? _error;
  
  // Real weather data
  Weather? _currentWeather;
  Position? _currentLocation;
  DateTime? _lastUpdate;
  
  // Weather factory for creating weather API instance
  WeatherFactory? _weatherFactory;

  // Getters
  WeatherEffect get currentEffect => _currentEffect;
  double get intensity => _intensity;
  String get description => _description;
  bool get isRealWeatherEnabled => _isRealWeatherEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Weather? get currentWeather => _currentWeather;

  WeatherProvider() {
    _initializeWeatherService();
  }

  void _initializeWeatherService() {
    try {
      _weatherFactory = WeatherFactory(Constants.openWeatherApiKey);
    } catch (e) {
      _error = 'Failed to initialize weather service: $e';
      debugPrint(_error);
    }
  }

  // Enable/disable real weather integration
  void setRealWeatherEnabled(bool enabled) async {
    _isRealWeatherEnabled = enabled;
    
    if (enabled) {
      await updateWeatherFromLocation();
    } else {
      _currentEffect = WeatherEffect.none;
      _intensity = 0.0;
      _description = 'Real weather disabled';
      _currentWeather = null;
    }
    
    notifyListeners();
  }

  // Update weather based on current location
  Future<void> updateWeatherFromLocation() async {
    if (!_isRealWeatherEnabled || _weatherFactory == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      _currentLocation = position;

      // Get weather data
      final weather = await _weatherFactory!.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      _currentWeather = weather;
      _lastUpdate = DateTime.now();

      // Convert real weather to game weather effect
      _convertRealWeatherToEffect(weather);

    } catch (e) {
      _error = 'Failed to update weather: $e';
      debugPrint(_error);
      
      // Fallback to random weather if real weather fails
      _generateRandomWeather();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current location with permission handling
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  // Convert real weather conditions to game effects
  void _convertRealWeatherToEffect(Weather weather) {
    final condition = weather.weatherMain?.toLowerCase() ?? '';
    final description = weather.weatherDescription?.toLowerCase() ?? '';
    final windSpeed = weather.windSpeed ?? 0;
    final humidity = weather.humidity ?? 0;
    final temp = weather.temperature?.celsius ?? 20;

    // Determine weather effect based on conditions
    if (condition.contains('thunderstorm') || condition.contains('storm')) {
      _currentEffect = WeatherEffect.storm;
      _intensity = 1.0;
      _description = 'Thunderstorm brewing - pieces may teleport!';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      _currentEffect = WeatherEffect.rain;
      _intensity = _calculateRainIntensity(description);
      _description = 'Rain is falling - movement range reduced';
    } else if (condition.contains('snow') || temp < 0) {
      _currentEffect = WeatherEffect.ice;
      _intensity = temp < -10 ? 1.0 : 0.6;
      _description = 'Icy conditions - pieces may slip!';
    } else if (condition.contains('mist') || condition.contains('fog') || humidity > 85) {
      _currentEffect = WeatherEffect.fog;
      _intensity = humidity / 100.0;
      _description = 'Foggy weather - limited visibility';
    } else if (windSpeed > 10) {
      _currentEffect = WeatherEffect.wind;
      _intensity = (windSpeed / 20.0).clamp(0.0, 1.0);
      _description = 'Windy conditions - diagonal moves boosted';
    } else if (temp > 35) {
      _currentEffect = WeatherEffect.fire;
      _intensity = ((temp - 30) / 20.0).clamp(0.0, 1.0);
      _description = 'Hot weather - pieces gain fire power!';
    } else {
      _currentEffect = WeatherEffect.none;
      _intensity = 0.0;
      _description = 'Clear weather - normal gameplay';
    }
  }

  double _calculateRainIntensity(String description) {
    if (description.contains('heavy')) return 1.0;
    if (description.contains('moderate')) return 0.7;
    if (description.contains('light')) return 0.4;
    return 0.5; // default
  }

  // Generate random weather for testing or when real weather unavailable
  void _generateRandomWeather() {
    final effects = WeatherEffect.values.where((e) => e != WeatherEffect.none).toList();
    final randomEffect = effects[DateTime.now().millisecond % effects.length];
    
    _currentEffect = randomEffect;
    _intensity = (DateTime.now().millisecond % 100) / 100.0;
    _description = _getRandomWeatherDescription(randomEffect);
  }

  String _getRandomWeatherDescription(WeatherEffect effect) {
    switch (effect) {
      case WeatherEffect.rain:
        return 'Mystical rain affects the battlefield';
      case WeatherEffect.storm:
        return 'Magical storm creates teleportation rifts';
      case WeatherEffect.fog:
        return 'Enchanted fog limits vision';
      case WeatherEffect.ice:
        return 'Frost magic makes pieces slip';
      case WeatherEffect.fire:
        return 'Flame magic empowers pieces';
      case WeatherEffect.wind:
        return 'Wind magic boosts movement';
      case WeatherEffect.none:
        return 'Calm magical conditions';
    }
  }

  // Force a specific weather effect (for testing or game modes)
  void setWeatherEffect(WeatherEffect effect, {double? intensity}) {
    _currentEffect = effect;
    _intensity = intensity ?? 0.7;
    _description = _getEffectDescription(effect);
    notifyListeners();
  }

  String _getEffectDescription(WeatherEffect effect) {
    switch (effect) {
      case WeatherEffect.rain:
        return 'Rain reduces movement range';
      case WeatherEffect.storm:
        return 'Storm enables piece teleportation';
      case WeatherEffect.fog:
        return 'Fog limits piece visibility';
      case WeatherEffect.ice:
        return 'Ice creates slippery conditions';
      case WeatherEffect.fire:
        return 'Fire increases attack power';
      case WeatherEffect.wind:
        return 'Wind boosts diagonal movement';
      case WeatherEffect.none:
        return 'Clear conditions';
    }
  }

  // Weather-based piece modifications
  List<String> getWeatherAbilities(WeatherEffect effect) {
    switch (effect) {
      case WeatherEffect.rain:
        return ['movement_reduction', 'water_resistance'];
      case WeatherEffect.storm:
        return ['teleport_chance', 'lightning_strike'];
      case WeatherEffect.fog:
        return ['stealth_mode', 'vision_limit'];
      case WeatherEffect.ice:
        return ['slip_risk', 'freeze_chance'];
      case WeatherEffect.fire:
        return ['fire_boost', 'burn_damage'];
      case WeatherEffect.wind:
        return ['wind_boost', 'diagonal_enhancement'];
      case WeatherEffect.none:
        return [];
    }
  }

  // Check if weather should change (time-based or random)
  bool shouldChangeWeather() {
    if (_lastUpdate == null) return true;
    
    final timeSinceUpdate = DateTime.now().difference(_lastUpdate!);
    
    // Change weather every 5-10 minutes in game
    final changeInterval = Duration(
      minutes: 5 + (DateTime.now().minute % 5),
    );
    
    return timeSinceUpdate > changeInterval;
  }

  // Periodic weather updates
  void startPeriodicWeatherUpdates() {
    // Update weather every 5 minutes
    Stream.periodic(const Duration(minutes: 5)).listen((_) {
      if (_isRealWeatherEnabled) {
        updateWeatherFromLocation();
      } else if (shouldChangeWeather()) {
        _generateRandomWeather();
        notifyListeners();
      }
    });
  }

  // Get weather forecast for next few hours (if available)
  Future<List<Weather>> getWeatherForecast() async {
    if (_weatherFactory == null || _currentLocation == null) {
      return [];
    }

    try {
      final forecast = await _weatherFactory!.fiveDayForecastByLocation(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      
      // Return next 6 hours of forecast
      return forecast.take(6).toList();
    } catch (e) {
      debugPrint('Forecast error: $e');
      return [];
    }
  }

  // Weather impact on game statistics
  Map<String, dynamic> getWeatherImpact() {
    return {
      'effect': _currentEffect.toString(),
      'intensity': _intensity,
      'description': _description,
      'duration': _lastUpdate != null 
          ? DateTime.now().difference(_lastUpdate!).inMinutes
          : 0,
      'abilities': getWeatherAbilities(_currentEffect),
    };
  }

  // Visual effects configuration
  Map<String, dynamic> getVisualEffectConfig() {
    switch (_currentEffect) {
      case WeatherEffect.rain:
        return {
          'particleCount': (50 * _intensity).round(),
          'particleSpeed': 2.0 + _intensity,
          'color': Colors.blue.withOpacity(0.6),
          'direction': 'down',
        };
      case WeatherEffect.storm:
        return {
          'particleCount': (30 * _intensity).round(),
          'particleSpeed': 3.0 + _intensity * 2,
          'color': Colors.purple.withOpacity(0.8),
          'direction': 'random',
          'lightning': true,
        };
      case WeatherEffect.fog:
        return {
          'opacity': 0.3 + _intensity * 0.4,
          'color': Colors.grey.withOpacity(0.7),
          'blur': 2.0 + _intensity * 3,
        };
      case WeatherEffect.ice:
        return {
          'particleCount': (20 * _intensity).round(),
          'particleSpeed': 1.0 + _intensity,
          'color': Colors.lightBlue.withOpacity(0.5),
          'sparkle': true,
        };
      case WeatherEffect.fire:
        return {
          'particleCount': (40 * _intensity).round(),
          'particleSpeed': 1.5 + _intensity,
          'color': Colors.orange.withOpacity(0.7),
          'direction': 'up',
          'heat_shimmer': true,
        };
      case WeatherEffect.wind:
        return {
          'particleCount': (25 * _intensity).round(),
          'particleSpeed': 2.5 + _intensity * 2,
          'color': Colors.white.withOpacity(0.4),
          'direction': 'horizontal',
        };
      case WeatherEffect.none:
        return {'particleCount': 0};
    }
  }

  // Sound effects for weather
  String? getWeatherSoundEffect() {
    switch (_currentEffect) {
      case WeatherEffect.rain:
        return 'sounds/weather/rain.mp3';
      case WeatherEffect.storm:
        return 'sounds/weather/thunder.mp3';
      case WeatherEffect.fog:
        return 'sounds/weather/wind_soft.mp3';
      case WeatherEffect.ice:
        return 'sounds/weather/ice_crack.mp3';
      case WeatherEffect.fire:
        return 'sounds/weather/fire_crackle.mp3';
      case WeatherEffect.wind:
        return 'sounds/weather/wind_strong.mp3';
      case WeatherEffect.none:
        return null;
    }
  }

  // Cleanup
  @override
  void dispose() {
    super.dispose();
  }
}