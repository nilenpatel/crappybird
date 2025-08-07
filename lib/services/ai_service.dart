import 'dart:math' as math;
import '../models/chess_piece.dart';
import '../models/game_state.dart';

enum AIPersonality {
  aggressive,
  defensive,
  tactical,
  unpredictable,
  grandmaster,
  beginner,
  creative,
  calculating,
}

enum AIDifficulty {
  easy,
  medium,
  hard,
  expert,
  master,
}

class AIOpponent {
  final String name;
  final AIPersonality personality;
  final AIDifficulty difficulty;
  final String description;
  final String avatar;
  final List<String> catchphrases;
  final Map<String, double> tendencies;

  const AIOpponent({
    required this.name,
    required this.personality,
    required this.difficulty,
    required this.description,
    required this.avatar,
    required this.catchphrases,
    required this.tendencies,
  });
}

class AIService {
  static final List<AIOpponent> opponents = [
    AIOpponent(
      name: 'Magnus the Bold',
      personality: AIPersonality.aggressive,
      difficulty: AIDifficulty.hard,
      description: 'An aggressive player who loves tactical sacrifices',
      avatar: 'assets/avatars/magnus.png',
      catchphrases: [
        'Attack is the best defense!',
        'Time to sacrifice for victory!',
        'No retreat, no surrender!',
      ],
      tendencies: {
        'aggression': 0.9,
        'tactics': 0.8,
        'sacrifice': 0.7,
        'development': 0.6,
        'safety': 0.3,
      },
    ),
    AIOpponent(
      name: 'Petra the Fortress',
      personality: AIPersonality.defensive,
      difficulty: AIDifficulty.medium,
      description: 'A defensive mastermind who builds impenetrable positions',
      avatar: 'assets/avatars/petra.png',
      catchphrases: [
        'Patience is key to victory.',
        'Every piece has its place.',
        'Defense wins championships!',
      ],
      tendencies: {
        'aggression': 0.2,
        'tactics': 0.6,
        'sacrifice': 0.1,
        'development': 0.8,
        'safety': 0.9,
      },
    ),
    AIOpponent(
      name: 'Zara the Mystic',
      personality: AIPersonality.unpredictable,
      difficulty: AIDifficulty.expert,
      description: 'An enigmatic player with surprising moves',
      avatar: 'assets/avatars/zara.png',
      catchphrases: [
        'The unexpected path leads to victory.',
        'Chaos brings opportunity.',
        'Can you predict the unpredictable?',
      ],
      tendencies: {
        'aggression': 0.6,
        'tactics': 0.9,
        'sacrifice': 0.8,
        'development': 0.5,
        'safety': 0.4,
      },
    ),
    AIOpponent(
      name: 'Professor Logicus',
      personality: AIPersonality.calculating,
      difficulty: AIDifficulty.master,
      description: 'A methodical genius who calculates every variation',
      avatar: 'assets/avatars/professor.png',
      catchphrases: [
        'Logic prevails over emotion.',
        'Every move has been calculated.',
        'Mathematics never lies.',
      ],
      tendencies: {
        'aggression': 0.5,
        'tactics': 1.0,
        'sacrifice': 0.6,
        'development': 0.9,
        'safety': 0.8,
      },
    ),
    AIOpponent(
      name: 'Spark the Creative',
      personality: AIPersonality.creative,
      difficulty: AIDifficulty.hard,
      description: 'An artistic player who finds beauty in unusual combinations',
      avatar: 'assets/avatars/spark.png',
      catchphrases: [
        'Chess is art in motion.',
        'Beauty lies in the unexpected.',
        'Let creativity flow!',
      ],
      tendencies: {
        'aggression': 0.7,
        'tactics': 0.8,
        'sacrifice': 0.9,
        'development': 0.7,
        'safety': 0.5,
      },
    ),
  ];

  final math.Random _random = math.Random();
  AIOpponent? _currentOpponent;
  int _thinkingTime = 1000;
  List<String> _gameComments = [];

  // Getters
  AIOpponent? get currentOpponent => _currentOpponent;
  List<String> get gameComments => _gameComments;

  void setOpponent(AIOpponent opponent) {
    _currentOpponent = opponent;
    _thinkingTime = _calculateThinkingTime(opponent.difficulty);
    _gameComments.clear();
    _addComment('${opponent.name} enters the game!');
  }

  int _calculateThinkingTime(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return 500;
      case AIDifficulty.medium:
        return 1000;
      case AIDifficulty.hard:
        return 1500;
      case AIDifficulty.expert:
        return 2000;
      case AIDifficulty.master:
        return 3000;
    }
  }

  Future<Move?> getBestMove(GameState gameState) async {
    if (_currentOpponent == null) {
      _currentOpponent = opponents.first;
    }

    // Simulate thinking time
    await Future.delayed(Duration(milliseconds: _thinkingTime));

    final legalMoves = gameState.getLegalMoves();
    if (legalMoves.isEmpty) return null;

    // Apply personality-based move selection
    final bestMove = _selectMoveByPersonality(gameState, legalMoves);
    
    // Add personality-based comment
    _addPersonalityComment(bestMove, gameState);
    
    return bestMove;
  }

  Move _selectMoveByPersonality(GameState gameState, List<Move> legalMoves) {
    final opponent = _currentOpponent!;
    final board = gameState.board;
    
    // Score moves based on personality
    final scoredMoves = <Move, double>{};
    
    for (final move in legalMoves) {
      double score = _evaluateMove(move, gameState);
      
      // Apply personality modifiers
      score = _applyPersonalityModifiers(score, move, gameState, opponent);
      
      scoredMoves[move] = score;
    }
    
    // Select move based on difficulty and personality
    return _selectFinalMove(scoredMoves, opponent);
  }

  double _evaluateMove(Move move, GameState gameState) {
    double score = 0.0;
    
    // Basic material evaluation
    if (move.capturedPiece != null) {
      score += move.capturedPiece!.getValue() * 10;
    }
    
    // Position evaluation
    score += _evaluatePosition(move, gameState);
    
    // Tactical evaluation
    score += _evaluateTactics(move, gameState);
    
    // Safety evaluation
    score += _evaluateSafety(move, gameState);
    
    return score;
  }

  double _applyPersonalityModifiers(
    double baseScore, 
    Move move, 
    GameState gameState, 
    AIOpponent opponent
  ) {
    double score = baseScore;
    final tendencies = opponent.tendencies;
    
    // Aggression modifier
    if (move.capturedPiece != null) {
      score *= (1.0 + tendencies['aggression']!);
    }
    
    // Tactical modifier
    if (_isTacticalMove(move, gameState)) {
      score *= (1.0 + tendencies['tactics']!);
    }
    
    // Sacrifice modifier
    if (_isSacrificeMove(move, gameState)) {
      score *= (1.0 + tendencies['sacrifice']!);
    }
    
    // Safety modifier
    if (_isSafeMove(move, gameState)) {
      score *= (1.0 + tendencies['safety']!);
    }
    
    // Add personality-specific randomness
    switch (opponent.personality) {
      case AIPersonality.unpredictable:
        score *= (0.5 + _random.nextDouble());
        break;
      case AIPersonality.creative:
        if (_isCreativeMove(move, gameState)) {
          score *= 1.5;
        }
        break;
      case AIPersonality.calculating:
        // Prefer moves with clear advantages
        if (score > 0) score *= 1.2;
        break;
      default:
        break;
    }
    
    return score;
  }

  Move _selectFinalMove(Map<Move, double> scoredMoves, AIOpponent opponent) {
    final sortedMoves = scoredMoves.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Select from top moves based on difficulty
    int selectionRange;
    switch (opponent.difficulty) {
      case AIDifficulty.easy:
        selectionRange = math.min(5, sortedMoves.length);
        break;
      case AIDifficulty.medium:
        selectionRange = math.min(3, sortedMoves.length);
        break;
      case AIDifficulty.hard:
        selectionRange = math.min(2, sortedMoves.length);
        break;
      case AIDifficulty.expert:
      case AIDifficulty.master:
        selectionRange = 1;
        break;
    }
    
    final selectedIndex = _random.nextInt(selectionRange);
    return sortedMoves[selectedIndex].key;
  }

  double _evaluatePosition(Move move, GameState gameState) {
    // Evaluate piece positioning, control of center, etc.
    double score = 0.0;
    
    // Center control
    if (_isCenterSquare(move.to)) {
      score += 5.0;
    }
    
    // Piece development
    if (_isDevelopmentMove(move, gameState)) {
      score += 3.0;
    }
    
    return score;
  }

  double _evaluateTactics(Move move, GameState gameState) {
    double score = 0.0;
    
    // Check for forks, pins, skewers, etc.
    if (_createsFork(move, gameState)) {
      score += 15.0;
    }
    
    if (_createsPin(move, gameState)) {
      score += 10.0;
    }
    
    if (_createsSkewer(move, gameState)) {
      score += 12.0;
    }
    
    return score;
  }

  double _evaluateSafety(Move move, GameState gameState) {
    double score = 0.0;
    
    // Penalize moves that expose pieces
    if (_exposesKing(move, gameState)) {
      score -= 20.0;
    }
    
    if (_exposesQueen(move, gameState)) {
      score -= 10.0;
    }
    
    return score;
  }

  bool _isCenterSquare(Position position) {
    return (position.row >= 3 && position.row <= 4) &&
           (position.col >= 3 && position.col <= 4);
  }

  bool _isDevelopmentMove(Move move, GameState gameState) {
    // Check if piece is being developed from starting position
    final piece = move.piece;
    
    if (piece.type == PieceType.knight || piece.type == PieceType.bishop) {
      return _isStartingPosition(move.from, piece);
    }
    
    return false;
  }

  bool _isStartingPosition(Position position, ChessPiece piece) {
    if (piece.color == PieceColor.white) {
      return position.row == 7;
    } else {
      return position.row == 0;
    }
  }

  bool _isTacticalMove(Move move, GameState gameState) {
    return _createsFork(move, gameState) ||
           _createsPin(move, gameState) ||
           _createsSkewer(move, gameState);
  }

  bool _isSacrificeMove(Move move, GameState gameState) {
    if (move.capturedPiece == null) return false;
    
    // Simple sacrifice detection: giving up material for position
    return move.piece.getValue() >= move.capturedPiece!.getValue();
  }

  bool _isSafeMove(Move move, GameState gameState) {
    // Check if the move doesn't expose important pieces
    return !_exposesKing(move, gameState) && !_exposesQueen(move, gameState);
  }

  bool _isCreativeMove(Move move, GameState gameState) {
    // Unusual or unexpected moves
    final piece = move.piece;
    
    // Unusual piece movements
    if (piece.type == PieceType.king && gameState.turnNumber < 20) {
      return true; // Early king moves are creative/risky
    }
    
    // Sacrificial moves
    if (_isSacrificeMove(move, gameState)) {
      return true;
    }
    
    return false;
  }

  bool _createsFork(Move move, GameState gameState) {
    // Simplified fork detection
    // In a real implementation, this would check if the move attacks multiple pieces
    return false; // Placeholder
  }

  bool _createsPin(Move move, GameState gameState) {
    // Simplified pin detection
    return false; // Placeholder
  }

  bool _createsSkewer(Move move, GameState gameState) {
    // Simplified skewer detection
    return false; // Placeholder
  }

  bool _exposesKing(Move move, GameState gameState) {
    // Check if move exposes own king
    return false; // Placeholder - would need full implementation
  }

  bool _exposesQueen(Move move, GameState gameState) {
    // Check if move exposes own queen
    return false; // Placeholder
  }

  void _addComment(String comment) {
    _gameComments.add('[${DateTime.now().toString().substring(11, 19)}] $comment');
    
    // Keep only last 20 comments
    if (_gameComments.length > 20) {
      _gameComments.removeAt(0);
    }
  }

  void _addPersonalityComment(Move move, GameState gameState) {
    if (_currentOpponent == null) return;
    
    final opponent = _currentOpponent!;
    String? comment;
    
    // Add comments based on move type and personality
    if (move.capturedPiece != null) {
      if (opponent.personality == AIPersonality.aggressive) {
        comment = opponent.catchphrases[_random.nextInt(opponent.catchphrases.length)];
      } else if (opponent.personality == AIPersonality.calculating) {
        comment = 'Calculated exchange: ${move.piece.type.name} takes ${move.capturedPiece!.type.name}';
      }
    }
    
    if (_isTacticalMove(move, gameState)) {
      if (opponent.personality == AIPersonality.tactical) {
        comment = 'Tactical opportunity spotted!';
      } else if (opponent.personality == AIPersonality.creative) {
        comment = 'An artistic combination unfolds...';
      }
    }
    
    // Random personality comments
    if (comment == null && _random.nextDouble() < 0.1) {
      comment = opponent.catchphrases[_random.nextInt(opponent.catchphrases.length)];
    }
    
    if (comment != null) {
      _addComment('${opponent.name}: $comment');
    }
  }

  // Get AI analysis of current position
  Map<String, dynamic> getPositionAnalysis(GameState gameState) {
    if (_currentOpponent == null) return {};
    
    final analysis = <String, dynamic>{};
    
    // Material balance
    final materialBalance = _calculateMaterialBalance(gameState);
    analysis['materialBalance'] = materialBalance;
    
    // Position evaluation
    final positionScore = _evaluateCurrentPosition(gameState);
    analysis['positionScore'] = positionScore;
    
    // Suggested moves
    final legalMoves = gameState.getLegalMoves();
    if (legalMoves.isNotEmpty) {
      final topMoves = _getTopMoves(gameState, legalMoves, 3);
      analysis['suggestedMoves'] = topMoves.map((m) => m.toString()).toList();
    }
    
    // AI confidence
    analysis['confidence'] = _calculateConfidence(gameState);
    
    return analysis;
  }

  int _calculateMaterialBalance(GameState gameState) {
    int whiteValue = 0;
    int blackValue = 0;
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = gameState.board[row][col];
        if (piece != null) {
          if (piece.color == PieceColor.white) {
            whiteValue += piece.getValue();
          } else {
            blackValue += piece.getValue();
          }
        }
      }
    }
    
    return whiteValue - blackValue;
  }

  double _evaluateCurrentPosition(GameState gameState) {
    // Simplified position evaluation
    double score = 0.0;
    
    // Add material balance
    score += _calculateMaterialBalance(gameState).toDouble();
    
    // Add positional factors
    score += _evaluateKingSafety(gameState);
    score += _evaluatePieceActivity(gameState);
    score += _evaluatePawnStructure(gameState);
    
    return score;
  }

  double _evaluateKingSafety(GameState gameState) {
    // Placeholder for king safety evaluation
    return 0.0;
  }

  double _evaluatePieceActivity(GameState gameState) {
    // Placeholder for piece activity evaluation
    return 0.0;
  }

  double _evaluatePawnStructure(GameState gameState) {
    // Placeholder for pawn structure evaluation
    return 0.0;
  }

  List<Move> _getTopMoves(GameState gameState, List<Move> moves, int count) {
    final scoredMoves = <Move, double>{};
    
    for (final move in moves) {
      scoredMoves[move] = _evaluateMove(move, gameState);
    }
    
    final sortedMoves = scoredMoves.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedMoves.take(count).map((e) => e.key).toList();
  }

  double _calculateConfidence(GameState gameState) {
    // Calculate AI confidence based on position evaluation
    final positionScore = _evaluateCurrentPosition(gameState);
    final materialBalance = _calculateMaterialBalance(gameState);
    
    // Normalize to 0-1 scale
    double confidence = 0.5;
    
    if (gameState.currentPlayer == PieceColor.black) {
      // AI is black
      if (materialBalance < 0 && positionScore < 0) {
        confidence += 0.3;
      } else if (materialBalance > 0 || positionScore > 0) {
        confidence -= 0.2;
      }
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  // Clear game comments
  void clearComments() {
    _gameComments.clear();
  }
}