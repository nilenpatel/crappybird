import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _effectsPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _effectsVolume = 0.7;
  double _musicVolume = 0.5;
  double _ambientVolume = 0.3;

  String _currentTheme = 'classic';
  String? _currentAmbient;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get effectsVolume => _effectsVolume;
  double get musicVolume => _musicVolume;
  double get ambientVolume => _ambientVolume;

  // Initialize sound service
  Future<void> initialize() async {
    try {
      await _effectsPlayer.setReleaseMode(ReleaseMode.stop);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      
      await _effectsPlayer.setVolume(_effectsVolume);
      await _musicPlayer.setVolume(_musicVolume);
      await _ambientPlayer.setVolume(_ambientVolume);
      
      debugPrint('Sound service initialized');
    } catch (e) {
      debugPrint('Failed to initialize sound service: $e');
    }
  }

  // Settings
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _effectsPlayer.stop();
    }
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    } else {
      playBackgroundMusic();
    }
  }

  void setEffectsVolume(double volume) {
    _effectsVolume = volume.clamp(0.0, 1.0);
    _effectsPlayer.setVolume(_effectsVolume);
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  void setAmbientVolume(double volume) {
    _ambientVolume = volume.clamp(0.0, 1.0);
    _ambientPlayer.setVolume(_ambientVolume);
  }

  void setSoundTheme(String theme) {
    _currentTheme = theme;
  }

  // Game sounds
  void playGameStart() {
    _playEffect('game_start');
  }

  void playMove() {
    _playEffect('move');
  }

  void playCapture() {
    _playEffect('capture');
  }

  void playCheck() {
    _playEffect('check');
  }

  void playCheckmate() {
    _playEffect('checkmate');
  }

  void playEvolution() {
    _playEffect('evolution');
  }

  void playPieceSelect() {
    _playEffect('piece_select');
  }

  void playUndo() {
    _playEffect('undo');
  }

  void playWeatherChange() {
    _playEffect('weather_change');
  }

  void playButtonClick() {
    _playEffect('button_click');
  }

  void playMenuOpen() {
    _playEffect('menu_open');
  }

  void playMenuClose() {
    _playEffect('menu_close');
  }

  void playError() {
    _playEffect('error');
  }

  void playSuccess() {
    _playEffect('success');
  }

  void playNotification() {
    _playEffect('notification');
  }

  // Unique piece sounds
  void playPieceSound(String pieceType, String action) {
    final soundName = '${pieceType}_$action';
    _playEffect(soundName);
  }

  void playEvolutionSound(String fromType, String toType) {
    final soundName = 'evolution_${fromType}_to_$toType';
    _playEffect(soundName);
  }

  // Weather sounds
  void playWeatherSound(String weatherType) {
    final soundName = 'weather_$weatherType';
    _playAmbient(soundName);
  }

  // AI personality sounds
  void playAISound(String personality, String action) {
    final soundName = 'ai_${personality}_$action';
    _playEffect(soundName);
  }

  // Background music
  void playBackgroundMusic([String? specificTrack]) {
    if (!_musicEnabled) return;

    String track;
    if (specificTrack != null) {
      track = specificTrack;
    } else {
      track = _getThemeMusic(_currentTheme);
    }

    _playMusic(track);
  }

  void stopBackgroundMusic() {
    _musicPlayer.stop();
  }

  void pauseBackgroundMusic() {
    _musicPlayer.pause();
  }

  void resumeBackgroundMusic() {
    _musicPlayer.resume();
  }

  // Ambient sounds
  void playAmbientSound(String ambientType) {
    if (_currentAmbient == ambientType) return;

    _currentAmbient = ambientType;
    _playAmbient(ambientType);
  }

  void stopAmbientSound() {
    _ambientPlayer.stop();
    _currentAmbient = null;
  }

  // Dynamic music based on game state
  void updateMusicForGameState(String gameState) {
    String musicTrack;
    
    switch (gameState) {
      case 'menu':
        musicTrack = 'menu_theme';
        break;
      case 'playing':
        musicTrack = _getThemeMusic(_currentTheme);
        break;
      case 'thinking':
        musicTrack = 'thinking_music';
        break;
      case 'endgame':
        musicTrack = 'endgame_theme';
        break;
      case 'victory':
        musicTrack = 'victory_fanfare';
        break;
      case 'defeat':
        musicTrack = 'defeat_theme';
        break;
      default:
        musicTrack = _getThemeMusic(_currentTheme);
    }

    playBackgroundMusic(musicTrack);
  }

  // Spatial audio for 3D mode
  void playPositionalSound(String soundName, double x, double y, double z) {
    // In a full implementation, this would use spatial audio libraries
    // For now, just adjust volume based on distance
    final distance = (x * x + y * y + z * z).sqrt();
    final adjustedVolume = (_effectsVolume * (1.0 / (1.0 + distance * 0.1))).clamp(0.0, 1.0);
    
    _playEffect(soundName, volume: adjustedVolume);
  }

  // Voice synthesis for AI commentary
  void playAICommentary(String text, String personality) {
    // This would integrate with flutter_tts for speech synthesis
    // Different personalities would have different voice characteristics
    debugPrint('AI Commentary [$personality]: $text');
  }

  // Sound sequences for special events
  void playEvolutionSequence(String pieceType) {
    _playSequence([
      ('evolution_start', 0),
      ('evolution_${pieceType}_transform', 1000),
      ('evolution_complete', 2000),
    ]);
  }

  void playGameEndSequence(bool victory) {
    if (victory) {
      _playSequence([
        ('victory_buildup', 0),
        ('victory_fanfare', 1500),
        ('victory_celebration', 3000),
      ]);
    } else {
      _playSequence([
        ('defeat_buildup', 0),
        ('defeat_theme', 1000),
      ]);
    }
  }

  void playWeatherTransition(String fromWeather, String toWeather) {
    _playSequence([
      ('weather_${fromWeather}_fade', 0),
      ('weather_transition', 1000),
      ('weather_${toWeather}_enter', 2000),
    ]);
  }

  // Private methods
  void _playEffect(String soundName, {double? volume}) async {
    if (!_soundEnabled) return;

    try {
      final effectVolume = volume ?? _effectsVolume;
      final soundPath = _getSoundPath(soundName, 'effects');
      
      await _effectsPlayer.stop();
      await _effectsPlayer.setVolume(effectVolume);
      await _effectsPlayer.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint('Failed to play effect $soundName: $e');
    }
  }

  void _playMusic(String musicName) async {
    if (!_musicEnabled) return;

    try {
      final musicPath = _getSoundPath(musicName, 'music');
      
      await _musicPlayer.stop();
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(AssetSource(musicPath));
    } catch (e) {
      debugPrint('Failed to play music $musicName: $e');
    }
  }

  void _playAmbient(String ambientName) async {
    if (!_soundEnabled) return;

    try {
      final ambientPath = _getSoundPath(ambientName, 'ambient');
      
      await _ambientPlayer.stop();
      await _ambientPlayer.setVolume(_ambientVolume);
      await _ambientPlayer.play(AssetSource(ambientPath));
    } catch (e) {
      debugPrint('Failed to play ambient $ambientName: $e');
    }
  }

  void _playSequence(List<(String, int)> sequence) {
    for (final (soundName, delay) in sequence) {
      Future.delayed(Duration(milliseconds: delay), () {
        _playEffect(soundName);
      });
    }
  }

  String _getSoundPath(String soundName, String category) {
    return 'sounds/$category/${_currentTheme}/$soundName.mp3';
  }

  String _getThemeMusic(String theme) {
    switch (theme) {
      case 'classic':
        return 'classical_chess_theme';
      case 'space':
        return 'cosmic_battle_theme';
      case 'medieval':
        return 'medieval_court_theme';
      case 'cyberpunk':
        return 'neon_chess_theme';
      case 'underwater':
        return 'ocean_depths_theme';
      case 'volcanic':
        return 'molten_battlefield_theme';
      case 'arctic':
        return 'frozen_kingdom_theme';
      case 'mystical':
        return 'enchanted_realm_theme';
      default:
        return 'classical_chess_theme';
    }
  }

  // Sound preloading for better performance
  Future<void> preloadSounds() async {
    final essentialSounds = [
      'move',
      'capture',
      'check',
      'checkmate',
      'piece_select',
      'button_click',
    ];

    for (final sound in essentialSounds) {
      try {
        final soundPath = _getSoundPath(sound, 'effects');
        // Preload would go here in a full implementation
        debugPrint('Preloaded sound: $soundPath');
      } catch (e) {
        debugPrint('Failed to preload sound $sound: $e');
      }
    }
  }

  // Audio analysis for dynamic effects
  void adjustVolumeForGameIntensity(double intensity) {
    final baseVolume = _effectsVolume;
    final adjustedVolume = (baseVolume * (0.8 + intensity * 0.4)).clamp(0.0, 1.0);
    _effectsPlayer.setVolume(adjustedVolume);
  }

  void setMusicTempo(double tempoMultiplier) {
    // This would adjust playback speed in a full implementation
    debugPrint('Setting music tempo to ${tempoMultiplier}x');
  }

  // Cleanup
  void dispose() async {
    await _effectsPlayer.dispose();
    await _musicPlayer.dispose();
    await _ambientPlayer.dispose();
  }

  // Sound feedback for accessibility
  void playMoveConfirmation(String moveNotation) {
    // This could use text-to-speech to announce moves
    debugPrint('Move confirmation: $moveNotation');
    _playEffect('move_confirm');
  }

  void playPositionDescription(String description) {
    // Audio description of board position for visually impaired users
    debugPrint('Position description: $description');
  }

  // Interactive sound effects
  void playHoverSound() {
    _playEffect('hover', volume: _effectsVolume * 0.5);
  }

  void playDragStart() {
    _playEffect('drag_start');
  }

  void playDragEnd() {
    _playEffect('drag_end');
  }

  void playInvalidMove() {
    _playEffect('invalid_move');
  }

  // Multiplayer sounds
  void playOpponentMove() {
    _playEffect('opponent_move');
  }

  void playOpponentJoined() {
    _playEffect('opponent_joined');
  }

  void playOpponentLeft() {
    _playEffect('opponent_left');
  }

  void playChatMessage() {
    _playEffect('chat_message');
  }
}