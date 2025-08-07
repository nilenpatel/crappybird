import '../models/chess_piece.dart';

class EvolutionService {
  // Evolution messages for different piece types
  static const Map<PieceType, Map<PieceType, String>> evolutionMessages = {
    PieceType.pawn: {
      PieceType.superPawn: 'The humble pawn evolves into a Super Pawn with enhanced mobility!',
    },
    PieceType.rook: {
      PieceType.megaRook: 'The rook transforms into a Mega Rook with piercing power!',
    },
    PieceType.knight: {
      PieceType.knightRider: 'The knight becomes a Knight Rider with extended reach!',
    },
    PieceType.bishop: {
      PieceType.archbishop: 'The bishop ascends to Archbishop with hybrid powers!',
    },
    PieceType.queen: {
      PieceType.emperor: 'The queen evolves into an Emperor with supreme authority!',
    },
  };

  // Evolution requirements
  static const Map<PieceType, EvolutionRequirement> evolutionRequirements = {
    PieceType.pawn: EvolutionRequirement(
      minMoves: 5,
      minCaptures: 2,
      minLevel: 1,
      specialConditions: ['reach_6th_rank'],
    ),
    PieceType.rook: EvolutionRequirement(
      minMoves: 8,
      minCaptures: 3,
      minLevel: 2,
      specialConditions: ['control_file'],
    ),
    PieceType.knight: EvolutionRequirement(
      minMoves: 10,
      minCaptures: 2,
      minLevel: 2,
      specialConditions: ['fork_achieved'],
    ),
    PieceType.bishop: EvolutionRequirement(
      minMoves: 7,
      minCaptures: 2,
      minLevel: 3,
      specialConditions: ['long_diagonal_control'],
    ),
    PieceType.queen: EvolutionRequirement(
      minMoves: 15,
      minCaptures: 5,
      minLevel: 4,
      specialConditions: ['dominate_center'],
    ),
  };

  // Get evolution message
  String getEvolutionMessage(PieceType from, PieceType to) {
    return evolutionMessages[from]?[to] ?? 
           'The ${from.name} evolves into ${to.name}!';
  }

  // Check if piece can evolve based on its stats
  bool canPieceEvolve(ChessPiece piece, GameStats stats) {
    final requirement = evolutionRequirements[piece.type];
    if (requirement == null) return false;

    final pieceStats = stats.getPieceStats(piece.id);
    
    // Check basic requirements
    if (pieceStats.moveCount < requirement.minMoves) return false;
    if (pieceStats.captureCount < requirement.minCaptures) return false;
    if (piece.level < requirement.minLevel) return false;

    // Check special conditions
    for (final condition in requirement.specialConditions) {
      if (!_checkSpecialCondition(piece, condition, stats)) {
        return false;
      }
    }

    return true;
  }

  bool _checkSpecialCondition(ChessPiece piece, String condition, GameStats stats) {
    switch (condition) {
      case 'reach_6th_rank':
        return _hasReachedSixthRank(piece, stats);
      case 'control_file':
        return _controlsFile(piece, stats);
      case 'fork_achieved':
        return _hasAchievedFork(piece, stats);
      case 'long_diagonal_control':
        return _controlsLongDiagonal(piece, stats);
      case 'dominate_center':
        return _dominatesCenter(piece, stats);
      default:
        return true;
    }
  }

  bool _hasReachedSixthRank(ChessPiece piece, GameStats stats) {
    // Check if pawn has reached the 6th rank (or 3rd for black)
    // This would require position tracking in game stats
    return true; // Placeholder
  }

  bool _controlsFile(ChessPiece piece, GameStats stats) {
    // Check if rook controls an entire file
    return true; // Placeholder
  }

  bool _hasAchievedFork(ChessPiece piece, GameStats stats) {
    // Check if knight has achieved a fork
    return stats.getPieceStats(piece.id).forksAchieved > 0;
  }

  bool _controlsLongDiagonal(ChessPiece piece, GameStats stats) {
    // Check if bishop controls a long diagonal
    return true; // Placeholder
  }

  bool _dominatesCenter(ChessPiece piece, GameStats stats) {
    // Check if queen dominates the center squares
    return true; // Placeholder
  }

  // Get evolution path for a piece type
  List<PieceType> getEvolutionPath(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return [PieceType.pawn, PieceType.superPawn];
      case PieceType.rook:
        return [PieceType.rook, PieceType.megaRook];
      case PieceType.knight:
        return [PieceType.knight, PieceType.knightRider];
      case PieceType.bishop:
        return [PieceType.bishop, PieceType.archbishop];
      case PieceType.queen:
        return [PieceType.queen, PieceType.emperor];
      case PieceType.king:
        return [PieceType.king, PieceType.emperor];
      default:
        return [type];
    }
  }

  // Get evolution bonuses
  EvolutionBonus getEvolutionBonus(PieceType from, PieceType to) {
    switch (to) {
      case PieceType.superPawn:
        return EvolutionBonus(
          abilities: ['double_jump', 'diagonal_capture_boost'],
          statBoosts: {'movement': 1, 'attack': 1},
          specialPowers: ['en_passant_immunity'],
        );
      case PieceType.megaRook:
        return EvolutionBonus(
          abilities: ['pierce_through', 'castle_anywhere'],
          statBoosts: {'movement': 2, 'attack': 2},
          specialPowers: ['fortress_mode'],
        );
      case PieceType.knightRider:
        return EvolutionBonus(
          abilities: ['extended_l_moves', 'jump_over_pieces'],
          statBoosts: {'movement': 2, 'tactics': 3},
          specialPowers: ['knight_charge'],
        );
      case PieceType.archbishop:
        return EvolutionBonus(
          abilities: ['bishop_knight_hybrid', 'holy_protection'],
          statBoosts: {'movement': 2, 'defense': 2},
          specialPowers: ['blessing_aura'],
        );
      case PieceType.chancellor:
        return EvolutionBonus(
          abilities: ['rook_knight_hybrid', 'command_boost'],
          statBoosts: {'movement': 3, 'attack': 2},
          specialPowers: ['tactical_command'],
        );
      case PieceType.emperor:
        return EvolutionBonus(
          abilities: ['omnidirectional', 'time_manipulation'],
          statBoosts: {'movement': 3, 'attack': 3, 'defense': 3},
          specialPowers: ['imperial_decree', 'time_warp'],
        );
      default:
        return EvolutionBonus(
          abilities: [],
          statBoosts: {},
          specialPowers: [],
        );
    }
  }

  // Calculate evolution cost
  int getEvolutionCost(PieceType from, PieceType to) {
    switch (to) {
      case PieceType.superPawn:
        return 10;
      case PieceType.megaRook:
        return 15;
      case PieceType.knightRider:
        return 12;
      case PieceType.archbishop:
        return 18;
      case PieceType.chancellor:
        return 20;
      case PieceType.emperor:
        return 25;
      default:
        return 0;
    }
  }

  // Get all possible evolutions for current game state
  List<EvolutionOption> getAvailableEvolutions(
    List<List<ChessPiece?>> board,
    PieceColor playerColor,
    GameStats stats,
  ) {
    final options = <EvolutionOption>[];
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == playerColor) {
          if (canPieceEvolve(piece, stats)) {
            final evolutionPath = getEvolutionPath(piece.type);
            if (evolutionPath.length > piece.level) {
              final nextEvolution = evolutionPath[piece.level];
              final cost = getEvolutionCost(piece.type, nextEvolution);
              final bonus = getEvolutionBonus(piece.type, nextEvolution);
              
              options.add(EvolutionOption(
                piece: piece,
                position: Position(row, col),
                targetType: nextEvolution,
                cost: cost,
                bonus: bonus,
              ));
            }
          }
        }
      }
    }
    
    return options;
  }

  // Apply evolution to piece
  ChessPiece applyEvolution(ChessPiece piece, PieceType targetType) {
    final bonus = getEvolutionBonus(piece.type, targetType);
    final newAbilities = List<String>.from(piece.abilities)
      ..addAll(bonus.abilities);
    
    return piece.copyWith(
      type: targetType,
      level: piece.level + 1,
      evolutionPoints: 0,
      abilities: newAbilities,
      particleEffects: List.from(piece.particleEffects)
        ..add('evolution_glow')
        ..addAll(bonus.specialPowers),
    );
  }
}

class EvolutionRequirement {
  final int minMoves;
  final int minCaptures;
  final int minLevel;
  final List<String> specialConditions;

  const EvolutionRequirement({
    required this.minMoves,
    required this.minCaptures,
    required this.minLevel,
    required this.specialConditions,
  });
}

class EvolutionBonus {
  final List<String> abilities;
  final Map<String, int> statBoosts;
  final List<String> specialPowers;

  const EvolutionBonus({
    required this.abilities,
    required this.statBoosts,
    required this.specialPowers,
  });
}

class EvolutionOption {
  final ChessPiece piece;
  final Position position;
  final PieceType targetType;
  final int cost;
  final EvolutionBonus bonus;

  const EvolutionOption({
    required this.piece,
    required this.position,
    required this.targetType,
    required this.cost,
    required this.bonus,
  });
}

class GameStats {
  final Map<String, PieceStats> _pieceStats = {};
  
  PieceStats getPieceStats(String pieceId) {
    return _pieceStats[pieceId] ?? PieceStats();
  }
  
  void updatePieceStats(String pieceId, PieceStats stats) {
    _pieceStats[pieceId] = stats;
  }
  
  void incrementMoves(String pieceId) {
    final stats = getPieceStats(pieceId);
    _pieceStats[pieceId] = stats.copyWith(moveCount: stats.moveCount + 1);
  }
  
  void incrementCaptures(String pieceId) {
    final stats = getPieceStats(pieceId);
    _pieceStats[pieceId] = stats.copyWith(captureCount: stats.captureCount + 1);
  }
  
  void incrementForks(String pieceId) {
    final stats = getPieceStats(pieceId);
    _pieceStats[pieceId] = stats.copyWith(forksAchieved: stats.forksAchieved + 1);
  }
}

class PieceStats {
  final int moveCount;
  final int captureCount;
  final int forksAchieved;
  final int checksGiven;
  final int timesMoved;
  final double averageValue;

  const PieceStats({
    this.moveCount = 0,
    this.captureCount = 0,
    this.forksAchieved = 0,
    this.checksGiven = 0,
    this.timesMoved = 0,
    this.averageValue = 0.0,
  });

  PieceStats copyWith({
    int? moveCount,
    int? captureCount,
    int? forksAchieved,
    int? checksGiven,
    int? timesMoved,
    double? averageValue,
  }) {
    return PieceStats(
      moveCount: moveCount ?? this.moveCount,
      captureCount: captureCount ?? this.captureCount,
      forksAchieved: forksAchieved ?? this.forksAchieved,
      checksGiven: checksGiven ?? this.checksGiven,
      timesMoved: timesMoved ?? this.timesMoved,
      averageValue: averageValue ?? this.averageValue,
    );
  }
}