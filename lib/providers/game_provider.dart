import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/chess_piece.dart';
import '../models/game_state.dart';
import '../services/ai_service.dart';
import '../services/evolution_service.dart';
import '../services/sound_service.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState.newGame();
  Position? _selectedPosition;
  List<Position> _highlightedMoves = [];
  bool _isAIThinking = false;
  String? _lastEvolutionMessage;
  
  // Services
  final AIService _aiService = AIService();
  final EvolutionService _evolutionService = EvolutionService();
  final SoundService _soundService = SoundService();

  // Getters
  GameState get gameState => _gameState;
  Position? get selectedPosition => _selectedPosition;
  List<Position> get highlightedMoves => _highlightedMoves;
  bool get isAIThinking => _isAIThinking;
  String? get lastEvolutionMessage => _lastEvolutionMessage;
  
  bool get isPlayerTurn => !_isAIThinking;
  bool get canUndo => _gameState.moveHistory.isNotEmpty;
  
  // Game control methods
  void startNewGame({GameMode mode = GameMode.classic, Duration? timeLimit}) {
    _gameState = GameState.newGame(gameMode: mode, timeLimit: timeLimit);
    _selectedPosition = null;
    _highlightedMoves = [];
    _isAIThinking = false;
    _lastEvolutionMessage = null;
    
    _soundService.playGameStart();
    notifyListeners();
  }

  void selectSquare(Position position) {
    if (_gameState.gameStatus != GameStatus.playing && 
        _gameState.gameStatus != GameStatus.waiting) return;
    if (_isAIThinking) return;

    final piece = _gameState.board[position.row][position.col];
    
    // If selecting own piece
    if (piece != null && piece.color == _gameState.currentPlayer) {
      _selectedPosition = position;
      _highlightedMoves = piece.getPossibleMoves(position, _gameState.board);
      _soundService.playPieceSelect();
    }
    // If making a move
    else if (_selectedPosition != null && _highlightedMoves.contains(position)) {
      _makeMove(_selectedPosition!, position);
    }
    // Deselect
    else {
      _selectedPosition = null;
      _highlightedMoves = [];
    }
    
    notifyListeners();
  }

  void _makeMove(Position from, Position to) {
    final piece = _gameState.board[from.row][from.col];
    if (piece == null) return;

    final capturedPiece = _gameState.board[to.row][to.col];
    final move = Move(
      from: from,
      to: to,
      piece: piece,
      capturedPiece: capturedPiece,
      timestamp: DateTime.now(),
      weatherAtMove: _gameState.currentWeather,
    );

    // Check for evolution before making the move
    final willEvolve = piece.canEvolve() && _gameState.gameMode == GameMode.evolution;
    
    _gameState = _gameState.makeMove(move);
    _selectedPosition = null;
    _highlightedMoves = [];

    // Play appropriate sound
    if (capturedPiece != null) {
      _soundService.playCapture();
    } else {
      _soundService.playMove();
    }

    // Handle evolution
    if (willEvolve) {
      _handleEvolution(to, piece);
    }

    // Check for special game states
    if (_gameState.checkStatus == CheckStatus.check) {
      _soundService.playCheck();
    } else if (_gameState.checkStatus == CheckStatus.checkmate) {
      _soundService.playCheckmate();
    }

    // Trigger AI move if in single player mode
    if (_gameState.gameStatus == GameStatus.playing && _shouldTriggerAI()) {
      _triggerAIMove();
    }

    notifyListeners();
  }

  void _handleEvolution(Position position, ChessPiece originalPiece) {
    final evolvedPiece = _gameState.board[position.row][position.col];
    if (evolvedPiece != null && evolvedPiece.type != originalPiece.type) {
      _lastEvolutionMessage = _evolutionService.getEvolutionMessage(originalPiece.type, evolvedPiece.type);
      _soundService.playEvolution();
      
      // Clear evolution message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _lastEvolutionMessage = null;
        notifyListeners();
      });
    }
  }

  bool _shouldTriggerAI() {
    // In multiplayer modes, don't trigger AI
    if (_gameState.gameMode == GameMode.multiplayer) return false;
    
    // For now, assume AI plays as black in single player modes
    return _gameState.currentPlayer == PieceColor.black;
  }

  void _triggerAIMove() async {
    _isAIThinking = true;
    notifyListeners();

    try {
      // Add thinking delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      final aiMove = await _aiService.getBestMove(_gameState);
      if (aiMove != null) {
        _gameState = _gameState.makeMove(aiMove);
        
        // Play sound for AI move
        if (aiMove.capturedPiece != null) {
          _soundService.playCapture();
        } else {
          _soundService.playMove();
        }

        // Check for AI evolution
        final aiPiece = _gameState.board[aiMove.to.row][aiMove.to.col];
        if (aiPiece != null && aiPiece.canEvolve() && _gameState.gameMode == GameMode.evolution) {
          _handleEvolution(aiMove.to, aiMove.piece);
        }
      }
    } catch (e) {
      debugPrint('AI move error: $e');
    } finally {
      _isAIThinking = false;
      notifyListeners();
    }
  }

  // Evolution system methods
  void triggerEvolution(Position position) {
    final piece = _gameState.board[position.row][position.col];
    if (piece == null || !piece.canEvolve()) return;

    final evolvedPiece = piece.evolve();
    final newBoard = _gameState.board.map((row) => List<ChessPiece?>.from(row)).toList();
    newBoard[position.row][position.col] = evolvedPiece;

    _gameState = _gameState.copyWith(board: newBoard);
    _handleEvolution(position, piece);
    notifyListeners();
  }

  List<Position> getEvolvablePieces() {
    final evolvable = <Position>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _gameState.board[row][col];
        if (piece != null && piece.canEvolve() && piece.color == _gameState.currentPlayer) {
          evolvable.add(Position(row, col));
        }
      }
    }
    return evolvable;
  }

  // Weather system methods
  void forceWeatherChange(WeatherEffect newWeather) {
    if (_gameState.gameMode != GameMode.weather) return;

    final newBoard = _gameState.board.map((row) => List<ChessPiece?>.from(row)).toList();
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = newBoard[row][col];
        if (piece != null) {
          piece.applyWeatherEffect(newWeather);
        }
      }
    }

    _gameState = _gameState.copyWith(
      board: newBoard,
      currentWeather: newWeather,
      weatherChangeTime: DateTime.now(),
    );

    _soundService.playWeatherChange();
    notifyListeners();
  }

  // Time management
  void pauseGame() {
    if (_gameState.gameStatus == GameStatus.playing) {
      _gameState = _gameState.copyWith(gameStatus: GameStatus.paused);
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState.gameStatus == GameStatus.paused) {
      _gameState = _gameState.copyWith(gameStatus: GameStatus.playing);
      notifyListeners();
    }
  }

  // Move history and undo
  void undoLastMove() {
    if (!canUndo) return;

    // For now, simple undo by recreating game state without last move
    // In a full implementation, this would be more sophisticated
    final moveHistory = List<Move>.from(_gameState.moveHistory);
    moveHistory.removeLast();
    
    // Rebuild game state from move history
    _rebuildGameFromHistory(moveHistory);
    
    _soundService.playUndo();
    notifyListeners();
  }

  void _rebuildGameFromHistory(List<Move> moves) {
    _gameState = GameState.newGame(gameMode: _gameState.gameMode);
    
    for (final move in moves) {
      _gameState = _gameState.makeMove(move);
    }
  }

  // Game analysis
  Map<String, dynamic> getGameAnalysis() {
    final analysis = <String, dynamic>{};
    
    // Material count
    final materialCount = _calculateMaterialCount();
    analysis['material'] = materialCount;
    
    // Evolution statistics
    final evolutionStats = _calculateEvolutionStats();
    analysis['evolution'] = evolutionStats;
    
    // Weather impact
    if (_gameState.gameMode == GameMode.weather) {
      analysis['weatherImpact'] = _calculateWeatherImpact();
    }
    
    return analysis;
  }

  Map<PieceColor, int> _calculateMaterialCount() {
    final count = {PieceColor.white: 0, PieceColor.black: 0};
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _gameState.board[row][col];
        if (piece != null) {
          count[piece.color] = (count[piece.color] ?? 0) + piece.getValue();
        }
      }
    }
    
    return count;
  }

  Map<String, dynamic> _calculateEvolutionStats() {
    final stats = <String, dynamic>{};
    final evolutions = <PieceType, int>{};
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _gameState.board[row][col];
        if (piece != null && piece.level > 1) {
          evolutions[piece.type] = (evolutions[piece.type] ?? 0) + 1;
        }
      }
    }
    
    stats['evolvedPieces'] = evolutions;
    stats['totalEvolutions'] = evolutions.values.fold(0, (sum, count) => sum + count);
    
    return stats;
  }

  Map<String, dynamic> _calculateWeatherImpact() {
    return {
      'currentWeather': _gameState.currentWeather.toString(),
      'intensity': _gameState.weatherIntensity,
      'duration': DateTime.now().difference(_gameState.weatherChangeTime).inMinutes,
    };
  }

  // Special game modes
  void activateTimeAttackMode() {
    if (_gameState.gameMode != GameMode.timeAttack) return;
    
    // Implement time attack specific logic
    // For example: pieces gain speed boosts, special time-based abilities
  }

  void activateARMode() {
    if (_gameState.gameMode != GameMode.ar3d) return;
    
    // This would integrate with AR provider
    // For now, just mark the mode as active
  }

  // Multiplayer support
  void handleOpponentMove(Move move) {
    if (_gameState.gameMode != GameMode.multiplayer) return;
    
    _gameState = _gameState.makeMove(move);
    _soundService.playMove();
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }
}