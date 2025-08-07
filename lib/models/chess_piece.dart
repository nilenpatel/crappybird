import 'package:flutter/material.dart';

enum PieceType {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
  // Unique evolved pieces
  superPawn,
  megaRook,
  knightRider,
  archbishop,
  chancellor,
  emperor,
}

enum PieceColor {
  white,
  black,
}

enum WeatherEffect {
  none,
  rain,     // Reduces movement range
  storm,    // Random teleportation chance
  fog,      // Limited visibility
  ice,      // Pieces can slip
  fire,     // Increased attack power
  wind,     // Diagonal movement boost
}

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  final String id;
  
  // Unique features
  int evolutionPoints;
  int level;
  List<String> abilities;
  WeatherEffect currentWeatherEffect;
  DateTime lastMoveTime;
  int consecutiveMoves;
  
  // Visual customization
  String? customSkin;
  Color? customColor;
  List<String> particleEffects;

  ChessPiece({
    required this.type,
    required this.color,
    required this.id,
    this.evolutionPoints = 0,
    this.level = 1,
    this.abilities = const [],
    this.currentWeatherEffect = WeatherEffect.none,
    DateTime? lastMoveTime,
    this.consecutiveMoves = 0,
    this.customSkin,
    this.customColor,
    this.particleEffects = const [],
  }) : lastMoveTime = lastMoveTime ?? DateTime.now();

  // Evolution system
  bool canEvolve() {
    return evolutionPoints >= getEvolutionThreshold() && level < 5;
  }

  int getEvolutionThreshold() {
    return level * 10;
  }

  ChessPiece evolve() {
    if (!canEvolve()) return this;
    
    final newType = getEvolvedType();
    final newAbilities = List<String>.from(abilities);
    
    // Add new abilities based on evolution
    switch (newType) {
      case PieceType.superPawn:
        newAbilities.add('double_jump');
        newAbilities.add('diagonal_capture_boost');
        break;
      case PieceType.megaRook:
        newAbilities.add('pierce_through');
        newAbilities.add('castle_anywhere');
        break;
      case PieceType.knightRider:
        newAbilities.add('extended_l_moves');
        newAbilities.add('jump_over_pieces');
        break;
      case PieceType.archbishop:
        newAbilities.add('bishop_knight_hybrid');
        newAbilities.add('holy_protection');
        break;
      case PieceType.chancellor:
        newAbilities.add('rook_knight_hybrid');
        newAbilities.add('command_boost');
        break;
      case PieceType.emperor:
        newAbilities.add('omnidirectional');
        newAbilities.add('time_manipulation');
        break;
      default:
        break;
    }

    return ChessPiece(
      type: newType,
      color: color,
      id: id,
      evolutionPoints: 0,
      level: level + 1,
      abilities: newAbilities,
      currentWeatherEffect: currentWeatherEffect,
      lastMoveTime: lastMoveTime,
      consecutiveMoves: consecutiveMoves,
      customSkin: customSkin,
      customColor: customColor,
      particleEffects: List.from(particleEffects)..add('evolution_glow'),
    );
  }

  PieceType getEvolvedType() {
    switch (type) {
      case PieceType.pawn:
        return PieceType.superPawn;
      case PieceType.rook:
        return PieceType.megaRook;
      case PieceType.knight:
        return PieceType.knightRider;
      case PieceType.bishop:
        return level >= 3 ? PieceType.archbishop : type;
      case PieceType.queen:
        return PieceType.emperor;
      default:
        return type;
    }
  }

  // Weather interaction
  void applyWeatherEffect(WeatherEffect effect) {
    currentWeatherEffect = effect;
    
    // Add temporary abilities or modifications
    switch (effect) {
      case WeatherEffect.storm:
        if (!abilities.contains('teleport_chance')) {
          abilities.add('teleport_chance');
        }
        break;
      case WeatherEffect.fire:
        if (!abilities.contains('fire_boost')) {
          abilities.add('fire_boost');
        }
        break;
      case WeatherEffect.ice:
        if (!abilities.contains('slip_risk')) {
          abilities.add('slip_risk');
        }
        break;
      default:
        break;
    }
  }

  // Get possible moves based on type and abilities
  List<Position> getPossibleMoves(Position currentPos, List<List<ChessPiece?>> board) {
    List<Position> moves = [];
    
    switch (type) {
      case PieceType.pawn:
      case PieceType.superPawn:
        moves = _getPawnMoves(currentPos, board);
        break;
      case PieceType.rook:
      case PieceType.megaRook:
        moves = _getRookMoves(currentPos, board);
        break;
      case PieceType.knight:
      case PieceType.knightRider:
        moves = _getKnightMoves(currentPos, board);
        break;
      case PieceType.bishop:
        moves = _getBishopMoves(currentPos, board);
        break;
      case PieceType.queen:
        moves = _getQueenMoves(currentPos, board);
        break;
      case PieceType.king:
      case PieceType.emperor:
        moves = _getKingMoves(currentPos, board);
        break;
      case PieceType.archbishop:
        moves = [..._getBishopMoves(currentPos, board), ..._getKnightMoves(currentPos, board)];
        break;
      case PieceType.chancellor:
        moves = [..._getRookMoves(currentPos, board), ..._getKnightMoves(currentPos, board)];
        break;
    }

    // Apply ability modifications
    moves = _applyAbilityModifications(moves, currentPos, board);
    
    // Apply weather effects
    moves = _applyWeatherModifications(moves, currentPos);
    
    return moves;
  }

  List<Position> _getPawnMoves(Position pos, List<List<ChessPiece?>> board) {
    List<Position> moves = [];
    int direction = color == PieceColor.white ? -1 : 1;
    
    // Forward move
    if (_isValidPosition(pos.row + direction, pos.col) && 
        board[pos.row + direction][pos.col] == null) {
      moves.add(Position(pos.row + direction, pos.col));
      
      // Double move from starting position or with super pawn ability
      if ((pos.row == (color == PieceColor.white ? 6 : 1)) || 
          abilities.contains('double_jump')) {
        if (pos.row + 2 * direction >= 0 && pos.row + 2 * direction < 8 &&
            board[pos.row + 2 * direction][pos.col] == null) {
          moves.add(Position(pos.row + 2 * direction, pos.col));
        }
      }
    }
    
    // Diagonal captures
    for (int colOffset in [-1, 1]) {
      if (_isValidPosition(pos.row + direction, pos.col + colOffset)) {
        ChessPiece? target = board[pos.row + direction][pos.col + colOffset];
        if (target != null && target.color != color) {
          moves.add(Position(pos.row + direction, pos.col + colOffset));
        }
      }
    }
    
    return moves;
  }

  List<Position> _getRookMoves(Position pos, List<List<ChessPiece?>> board) {
    List<Position> moves = [];
    
    // Horizontal and vertical moves
    List<List<int>> directions = [[0, 1], [0, -1], [1, 0], [-1, 0]];
    
    for (List<int> direction in directions) {
      for (int i = 1; i < 8; i++) {
        int newRow = pos.row + direction[0] * i;
        int newCol = pos.col + direction[1] * i;
        
        if (!_isValidPosition(newRow, newCol)) break;
        
        ChessPiece? target = board[newRow][newCol];
        if (target == null) {
          moves.add(Position(newRow, newCol));
        } else {
          if (target.color != color) {
            moves.add(Position(newRow, newCol));
          }
          if (!abilities.contains('pierce_through')) break;
        }
      }
    }
    
    return moves;
  }

  List<Position> _getKnightMoves(Position pos, List<List<ChessPiece?>> board) {
    List<Position> moves = [];
    
    List<List<int>> knightMoves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    
    // Extended moves for knight rider
    if (type == PieceType.knightRider) {
      knightMoves.addAll([
        [-3, -1], [-3, 1], [-1, -3], [-1, 3],
        [1, -3], [1, 3], [3, -1], [3, 1]
      ]);
    }
    
    for (List<int> move in knightMoves) {
      int newRow = pos.row + move[0];
      int newCol = pos.col + move[1];
      
      if (_isValidPosition(newRow, newCol)) {
        ChessPiece? target = board[newRow][newCol];
        if (target == null || target.color != color) {
          moves.add(Position(newRow, newCol));
        }
      }
    }
    
    return moves;
  }

  List<Position> _getBishopMoves(Position pos, List<List<ChessPiece?>> board) {
    List<Position> moves = [];
    
    // Diagonal moves
    List<List<int>> directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
    
    for (List<int> direction in directions) {
      for (int i = 1; i < 8; i++) {
        int newRow = pos.row + direction[0] * i;
        int newCol = pos.col + direction[1] * i;
        
        if (!_isValidPosition(newRow, newCol)) break;
        
        ChessPiece? target = board[newRow][newCol];
        if (target == null) {
          moves.add(Position(newRow, newCol));
        } else {
          if (target.color != color) {
            moves.add(Position(newRow, newCol));
          }
          break;
        }
      }
    }
    
    return moves;
  }

  List<Position> _getQueenMoves(Position pos, List<List<ChessPiece?>> board) {
    return [..._getRookMoves(pos, board), ..._getBishopMoves(pos, board)];
  }

  List<Position> _getKingMoves(Position pos, List<List<ChessPiece?>> board) {
    List<Position> moves = [];
    
    for (int rowOffset = -1; rowOffset <= 1; rowOffset++) {
      for (int colOffset = -1; colOffset <= 1; colOffset++) {
        if (rowOffset == 0 && colOffset == 0) continue;
        
        int newRow = pos.row + rowOffset;
        int newCol = pos.col + colOffset;
        
        if (_isValidPosition(newRow, newCol)) {
          ChessPiece? target = board[newRow][newCol];
          if (target == null || target.color != color) {
            moves.add(Position(newRow, newCol));
          }
        }
      }
    }
    
    // Emperor has extended range
    if (type == PieceType.emperor) {
      for (int i = 2; i <= 3; i++) {
        for (int rowOffset = -i; rowOffset <= i; rowOffset++) {
          for (int colOffset = -i; colOffset <= i; colOffset++) {
            if (rowOffset == 0 && colOffset == 0) continue;
            
            int newRow = pos.row + rowOffset;
            int newCol = pos.col + colOffset;
            
            if (_isValidPosition(newRow, newCol)) {
              ChessPiece? target = board[newRow][newCol];
              if (target == null || target.color != color) {
                moves.add(Position(newRow, newCol));
              }
            }
          }
        }
      }
    }
    
    return moves;
  }

  List<Position> _applyAbilityModifications(List<Position> moves, Position currentPos, List<List<ChessPiece?>> board) {
    // Apply various ability modifications
    if (abilities.contains('teleport_chance') && currentWeatherEffect == WeatherEffect.storm) {
      // Add random teleport positions
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          if (board[i][j] == null && (i != currentPos.row || j != currentPos.col)) {
            moves.add(Position(i, j));
          }
        }
      }
    }
    
    return moves;
  }

  List<Position> _applyWeatherModifications(List<Position> moves, Position currentPos) {
    switch (currentWeatherEffect) {
      case WeatherEffect.rain:
        // Reduce movement range by half
        return moves.take((moves.length / 2).ceil()).toList();
      case WeatherEffect.fog:
        // Limit to adjacent squares only
        return moves.where((pos) => 
          (pos.row - currentPos.row).abs() <= 1 && 
          (pos.col - currentPos.col).abs() <= 1
        ).toList();
      case WeatherEffect.wind:
        // Boost diagonal movements
        if (type == PieceType.bishop || abilities.contains('diagonal_boost')) {
          // Add extra diagonal moves
        }
        break;
      default:
        break;
    }
    
    return moves;
  }

  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  // Piece value calculation including evolution and abilities
  int getValue() {
    int baseValue = _getBaseValue();
    int evolutionBonus = level * 2;
    int abilityBonus = abilities.length * 1;
    
    return baseValue + evolutionBonus + abilityBonus;
  }

  int _getBaseValue() {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 1000;
      case PieceType.superPawn:
        return 3;
      case PieceType.megaRook:
        return 8;
      case PieceType.knightRider:
        return 6;
      case PieceType.archbishop:
        return 7;
      case PieceType.chancellor:
        return 8;
      case PieceType.emperor:
        return 1200;
    }
  }

  ChessPiece copyWith({
    PieceType? type,
    PieceColor? color,
    String? id,
    int? evolutionPoints,
    int? level,
    List<String>? abilities,
    WeatherEffect? currentWeatherEffect,
    DateTime? lastMoveTime,
    int? consecutiveMoves,
    String? customSkin,
    Color? customColor,
    List<String>? particleEffects,
  }) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      id: id ?? this.id,
      evolutionPoints: evolutionPoints ?? this.evolutionPoints,
      level: level ?? this.level,
      abilities: abilities ?? this.abilities,
      currentWeatherEffect: currentWeatherEffect ?? this.currentWeatherEffect,
      lastMoveTime: lastMoveTime ?? this.lastMoveTime,
      consecutiveMoves: consecutiveMoves ?? this.consecutiveMoves,
      customSkin: customSkin ?? this.customSkin,
      customColor: customColor ?? this.customColor,
      particleEffects: particleEffects ?? this.particleEffects,
    );
  }
}

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($row, $col)';
}