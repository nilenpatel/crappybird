import 'chess_piece.dart';

enum GameMode {
  classic,
  evolution,
  weather,
  timeAttack,
  puzzle,
  ar3d,
  multiplayer,
  campaign,
}

enum GameStatus {
  waiting,
  playing,
  paused,
  checkmate,
  stalemate,
  draw,
  resignation,
}

enum CheckStatus {
  none,
  check,
  checkmate,
}

class Move {
  final Position from;
  final Position to;
  final ChessPiece piece;
  final ChessPiece? capturedPiece;
  final DateTime timestamp;
  final bool isEvolution;
  final bool isCastling;
  final bool isEnPassant;
  final WeatherEffect weatherAtMove;
  final List<String> specialEffects;

  const Move({
    required this.from,
    required this.to,
    required this.piece,
    this.capturedPiece,
    required this.timestamp,
    this.isEvolution = false,
    this.isCastling = false,
    this.isEnPassant = false,
    this.weatherAtMove = WeatherEffect.none,
    this.specialEffects = const [],
  });

  @override
  String toString() {
    String notation = '${_positionToAlgebraic(from)}${_positionToAlgebraic(to)}';
    if (isEvolution) notation += '=E';
    if (isCastling) notation += ' O-O';
    return notation;
  }

  String _positionToAlgebraic(Position pos) {
    return '${String.fromCharCode(97 + pos.col)}${8 - pos.row}';
  }
}

class GameState {
  final List<List<ChessPiece?>> board;
  final PieceColor currentPlayer;
  final GameMode gameMode;
  final GameStatus gameStatus;
  final List<Move> moveHistory;
  final CheckStatus checkStatus;
  final WeatherEffect currentWeather;
  final DateTime weatherChangeTime;
  final int turnNumber;
  
  // Evolution system
  final Map<String, int> pieceEvolutionPoints;
  final List<String> availableEvolutions;
  
  // Special game states
  final bool canCastleKingSide;
  final bool canCastleQueenSide;
  final Position? enPassantTarget;
  final int halfMoveClock;
  final int fullMoveNumber;
  
  // Unique features
  final Map<Position, List<String>> activeEffects;
  final List<String> globalEffects;
  final Map<String, dynamic> campaignData;
  final double weatherIntensity;
  final DateTime gameStartTime;
  final Duration timePerPlayer;
  final Duration remainingTimeWhite;
  final Duration remainingTimeBlack;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.gameMode,
    required this.gameStatus,
    required this.moveHistory,
    required this.checkStatus,
    required this.currentWeather,
    required this.weatherChangeTime,
    required this.turnNumber,
    required this.pieceEvolutionPoints,
    required this.availableEvolutions,
    required this.canCastleKingSide,
    required this.canCastleQueenSide,
    this.enPassantTarget,
    required this.halfMoveClock,
    required this.fullMoveNumber,
    required this.activeEffects,
    required this.globalEffects,
    required this.campaignData,
    required this.weatherIntensity,
    required this.gameStartTime,
    required this.timePerPlayer,
    required this.remainingTimeWhite,
    required this.remainingTimeBlack,
  });

  // Factory constructor for new game
  factory GameState.newGame({
    GameMode gameMode = GameMode.classic,
    Duration? timeLimit,
  }) {
    final board = _initializeBoard();
    final now = DateTime.now();
    final defaultTime = timeLimit ?? const Duration(minutes: 10);

    return GameState(
      board: board,
      currentPlayer: PieceColor.white,
      gameMode: gameMode,
      gameStatus: GameStatus.waiting,
      moveHistory: [],
      checkStatus: CheckStatus.none,
      currentWeather: WeatherEffect.none,
      weatherChangeTime: now,
      turnNumber: 1,
      pieceEvolutionPoints: {},
      availableEvolutions: [],
      canCastleKingSide: true,
      canCastleQueenSide: true,
      halfMoveClock: 0,
      fullMoveNumber: 1,
      activeEffects: {},
      globalEffects: [],
      campaignData: {},
      weatherIntensity: 0.0,
      gameStartTime: now,
      timePerPlayer: defaultTime,
      remainingTimeWhite: defaultTime,
      remainingTimeBlack: defaultTime,
    );
  }

  static List<List<ChessPiece?>> _initializeBoard() {
    List<List<ChessPiece?>> board = List.generate(8, (_) => List.filled(8, null));

    // Initialize white pieces
    board[7][0] = ChessPiece(type: PieceType.rook, color: PieceColor.white, id: 'w_rook_1');
    board[7][1] = ChessPiece(type: PieceType.knight, color: PieceColor.white, id: 'w_knight_1');
    board[7][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.white, id: 'w_bishop_1');
    board[7][3] = ChessPiece(type: PieceType.queen, color: PieceColor.white, id: 'w_queen');
    board[7][4] = ChessPiece(type: PieceType.king, color: PieceColor.white, id: 'w_king');
    board[7][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.white, id: 'w_bishop_2');
    board[7][6] = ChessPiece(type: PieceType.knight, color: PieceColor.white, id: 'w_knight_2');
    board[7][7] = ChessPiece(type: PieceType.rook, color: PieceColor.white, id: 'w_rook_2');

    for (int i = 0; i < 8; i++) {
      board[6][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.white, id: 'w_pawn_$i');
    }

    // Initialize black pieces
    board[0][0] = ChessPiece(type: PieceType.rook, color: PieceColor.black, id: 'b_rook_1');
    board[0][1] = ChessPiece(type: PieceType.knight, color: PieceColor.black, id: 'b_knight_1');
    board[0][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.black, id: 'b_bishop_1');
    board[0][3] = ChessPiece(type: PieceType.queen, color: PieceColor.black, id: 'b_queen');
    board[0][4] = ChessPiece(type: PieceType.king, color: PieceColor.black, id: 'b_king');
    board[0][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.black, id: 'b_bishop_2');
    board[0][6] = ChessPiece(type: PieceType.knight, color: PieceColor.black, id: 'b_knight_2');
    board[0][7] = ChessPiece(type: PieceType.rook, color: PieceColor.black, id: 'b_rook_2');

    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.black, id: 'b_pawn_$i');
    }

    return board;
  }

  // Make a move and return new game state
  GameState makeMove(Move move) {
    final newBoard = _copyBoard();
    final newMoveHistory = List<Move>.from(moveHistory)..add(move);
    final newPieceEvolutionPoints = Map<String, int>.from(pieceEvolutionPoints);
    
    // Execute the move
    newBoard[move.to.row][move.to.col] = move.piece;
    newBoard[move.from.row][move.from.col] = null;
    
    // Update evolution points
    newPieceEvolutionPoints[move.piece.id] = 
        (newPieceEvolutionPoints[move.piece.id] ?? 0) + 1;
    
    // Handle captures
    if (move.capturedPiece != null) {
      newPieceEvolutionPoints[move.piece.id] = 
          (newPieceEvolutionPoints[move.piece.id] ?? 0) + 3;
    }
    
    // Handle special moves
    if (move.isCastling) {
      _handleCastling(newBoard, move);
    }
    
    if (move.isEnPassant) {
      _handleEnPassant(newBoard, move);
    }
    
    // Check for evolution
    final piece = newBoard[move.to.row][move.to.col]!;
    if (piece.canEvolve() && gameMode == GameMode.evolution) {
      final evolvedPiece = piece.evolve();
      newBoard[move.to.row][move.to.col] = evolvedPiece;
    }
    
    // Apply weather effects
    final newWeather = _updateWeather();
    _applyWeatherEffects(newBoard, newWeather);
    
    // Check game status
    final newCheckStatus = _calculateCheckStatus(newBoard, _getOppositeColor(currentPlayer));
    final newGameStatus = _calculateGameStatus(newBoard, newCheckStatus);
    
    // Update time
    final now = DateTime.now();
    final timeSpent = now.difference(gameStartTime);
    final newRemainingTimeWhite = currentPlayer == PieceColor.white
        ? remainingTimeWhite - timeSpent
        : remainingTimeWhite;
    final newRemainingTimeBlack = currentPlayer == PieceColor.black
        ? remainingTimeBlack - timeSpent
        : remainingTimeBlack;

    return GameState(
      board: newBoard,
      currentPlayer: _getOppositeColor(currentPlayer),
      gameMode: gameMode,
      gameStatus: newGameStatus,
      moveHistory: newMoveHistory,
      checkStatus: newCheckStatus,
      currentWeather: newWeather,
      weatherChangeTime: _shouldChangeWeather() ? now : weatherChangeTime,
      turnNumber: turnNumber + 1,
      pieceEvolutionPoints: newPieceEvolutionPoints,
      availableEvolutions: _calculateAvailableEvolutions(newBoard),
      canCastleKingSide: _updateCastlingRights(true, move),
      canCastleQueenSide: _updateCastlingRights(false, move),
      enPassantTarget: _calculateEnPassantTarget(move),
      halfMoveClock: _updateHalfMoveClock(move),
      fullMoveNumber: currentPlayer == PieceColor.black ? fullMoveNumber + 1 : fullMoveNumber,
      activeEffects: Map.from(activeEffects),
      globalEffects: List.from(globalEffects),
      campaignData: Map.from(campaignData),
      weatherIntensity: _calculateWeatherIntensity(),
      gameStartTime: gameStartTime,
      timePerPlayer: timePerPlayer,
      remainingTimeWhite: newRemainingTimeWhite,
      remainingTimeBlack: newRemainingTimeBlack,
    );
  }

  List<List<ChessPiece?>> _copyBoard() {
    return board.map((row) => List<ChessPiece?>.from(row)).toList();
  }

  void _handleCastling(List<List<ChessPiece?>> newBoard, Move move) {
    // Implement castling logic
    if (move.to.col > move.from.col) {
      // King side castling
      final rook = newBoard[move.from.row][7];
      newBoard[move.from.row][5] = rook;
      newBoard[move.from.row][7] = null;
    } else {
      // Queen side castling
      final rook = newBoard[move.from.row][0];
      newBoard[move.from.row][3] = rook;
      newBoard[move.from.row][0] = null;
    }
  }

  void _handleEnPassant(List<List<ChessPiece?>> newBoard, Move move) {
    // Remove the captured pawn
    final capturedPawnRow = move.from.row;
    newBoard[capturedPawnRow][move.to.col] = null;
  }

  WeatherEffect _updateWeather() {
    if (gameMode != GameMode.weather) return WeatherEffect.none;
    
    final timeSinceChange = DateTime.now().difference(weatherChangeTime);
    if (timeSinceChange.inMinutes >= 2) {
      // Change weather every 2 minutes
      final effects = WeatherEffect.values.where((e) => e != WeatherEffect.none).toList();
      return effects[(turnNumber ~/ 10) % effects.length];
    }
    return currentWeather;
  }

  bool _shouldChangeWeather() {
    return gameMode == GameMode.weather && 
           DateTime.now().difference(weatherChangeTime).inMinutes >= 2;
  }

  void _applyWeatherEffects(List<List<ChessPiece?>> newBoard, WeatherEffect weather) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = newBoard[row][col];
        if (piece != null) {
          piece.applyWeatherEffect(weather);
        }
      }
    }
  }

  CheckStatus _calculateCheckStatus(List<List<ChessPiece?>> board, PieceColor playerColor) {
    final kingPosition = _findKing(board, playerColor);
    if (kingPosition == null) return CheckStatus.none;

    final isInCheck = _isPositionUnderAttack(board, kingPosition, _getOppositeColor(playerColor));
    if (!isInCheck) return CheckStatus.none;

    // Check if it's checkmate
    if (_isCheckmate(board, playerColor)) {
      return CheckStatus.checkmate;
    }

    return CheckStatus.check;
  }

  GameStatus _calculateGameStatus(List<List<ChessPiece?>> board, CheckStatus checkStatus) {
    if (checkStatus == CheckStatus.checkmate) {
      return GameStatus.checkmate;
    }

    if (_isStalemate(board, currentPlayer)) {
      return GameStatus.stalemate;
    }

    if (_isDraw()) {
      return GameStatus.draw;
    }

    return GameStatus.playing;
  }

  Position? _findKing(List<List<ChessPiece?>> board, PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && 
            (piece.type == PieceType.king || piece.type == PieceType.emperor) && 
            piece.color == color) {
          return Position(row, col);
        }
      }
    }
    return null;
  }

  bool _isPositionUnderAttack(List<List<ChessPiece?>> board, Position position, PieceColor attackingColor) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == attackingColor) {
          final moves = piece.getPossibleMoves(Position(row, col), board);
          if (moves.contains(position)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _isCheckmate(List<List<ChessPiece?>> board, PieceColor playerColor) {
    // Try all possible moves to see if any gets out of check
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == playerColor) {
          final moves = piece.getPossibleMoves(Position(row, col), board);
          for (final move in moves) {
            // Simulate the move
            final testBoard = _copyBoard();
            testBoard[move.row][move.col] = piece;
            testBoard[row][col] = null;
            
            final kingPos = _findKing(testBoard, playerColor);
            if (kingPos != null && 
                !_isPositionUnderAttack(testBoard, kingPos, _getOppositeColor(playerColor))) {
              return false; // Found a move that gets out of check
            }
          }
        }
      }
    }
    return true; // No moves found that get out of check
  }

  bool _isStalemate(List<List<ChessPiece?>> board, PieceColor playerColor) {
    // Check if player has any legal moves
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == playerColor) {
          final moves = piece.getPossibleMoves(Position(row, col), board);
          if (moves.isNotEmpty) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool _isDraw() {
    // Check for insufficient material, 50-move rule, etc.
    return halfMoveClock >= 50 || _isInsufficientMaterial();
  }

  bool _isInsufficientMaterial() {
    final pieces = <ChessPiece>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null) pieces.add(piece);
      }
    }

    // King vs King
    if (pieces.length == 2) return true;

    // King + minor piece vs King
    if (pieces.length == 3) {
      final nonKings = pieces.where((p) => p.type != PieceType.king).toList();
      if (nonKings.length == 1) {
        final piece = nonKings.first;
        return piece.type == PieceType.bishop || piece.type == PieceType.knight;
      }
    }

    return false;
  }

  List<String> _calculateAvailableEvolutions(List<List<ChessPiece?>> board) {
    final evolutions = <String>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.canEvolve()) {
          evolutions.add('${piece.id}_evolution');
        }
      }
    }
    return evolutions;
  }

  bool _updateCastlingRights(bool kingSide, Move move) {
    // Update castling rights based on the move
    if (move.piece.type == PieceType.king) return false;
    if (move.piece.type == PieceType.rook) {
      if (kingSide && move.from.col == 7) return false;
      if (!kingSide && move.from.col == 0) return false;
    }
    return kingSide ? canCastleKingSide : canCastleQueenSide;
  }

  Position? _calculateEnPassantTarget(Move move) {
    if (move.piece.type == PieceType.pawn && 
        (move.to.row - move.from.row).abs() == 2) {
      return Position((move.from.row + move.to.row) ~/ 2, move.from.col);
    }
    return null;
  }

  int _updateHalfMoveClock(Move move) {
    if (move.piece.type == PieceType.pawn || move.capturedPiece != null) {
      return 0;
    }
    return halfMoveClock + 1;
  }

  double _calculateWeatherIntensity() {
    switch (currentWeather) {
      case WeatherEffect.storm:
        return 1.0;
      case WeatherEffect.rain:
        return 0.7;
      case WeatherEffect.wind:
        return 0.5;
      case WeatherEffect.fog:
        return 0.8;
      case WeatherEffect.ice:
        return 0.6;
      case WeatherEffect.fire:
        return 0.9;
      default:
        return 0.0;
    }
  }

  PieceColor _getOppositeColor(PieceColor color) {
    return color == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  // Get all legal moves for the current player
  List<Move> getLegalMoves() {
    final moves = <Move>[];
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == currentPlayer) {
          final possibleMoves = piece.getPossibleMoves(Position(row, col), board);
          
          for (final movePos in possibleMoves) {
            final move = Move(
              from: Position(row, col),
              to: movePos,
              piece: piece,
              capturedPiece: board[movePos.row][movePos.col],
              timestamp: DateTime.now(),
              weatherAtMove: currentWeather,
            );
            
            // Verify the move doesn't leave king in check
            if (_isLegalMove(move)) {
              moves.add(move);
            }
          }
        }
      }
    }
    
    return moves;
  }

  bool _isLegalMove(Move move) {
    // Simulate the move
    final testBoard = _copyBoard();
    testBoard[move.to.row][move.to.col] = move.piece;
    testBoard[move.from.row][move.from.col] = null;
    
    // Check if king is in check after the move
    final kingPos = _findKing(testBoard, currentPlayer);
    if (kingPos == null) return false;
    
    return !_isPositionUnderAttack(testBoard, kingPos, _getOppositeColor(currentPlayer));
  }

  GameState copyWith({
    List<List<ChessPiece?>>? board,
    PieceColor? currentPlayer,
    GameMode? gameMode,
    GameStatus? gameStatus,
    List<Move>? moveHistory,
    CheckStatus? checkStatus,
    WeatherEffect? currentWeather,
    DateTime? weatherChangeTime,
    int? turnNumber,
    Map<String, int>? pieceEvolutionPoints,
    List<String>? availableEvolutions,
    bool? canCastleKingSide,
    bool? canCastleQueenSide,
    Position? enPassantTarget,
    int? halfMoveClock,
    int? fullMoveNumber,
    Map<Position, List<String>>? activeEffects,
    List<String>? globalEffects,
    Map<String, dynamic>? campaignData,
    double? weatherIntensity,
    DateTime? gameStartTime,
    Duration? timePerPlayer,
    Duration? remainingTimeWhite,
    Duration? remainingTimeBlack,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      gameMode: gameMode ?? this.gameMode,
      gameStatus: gameStatus ?? this.gameStatus,
      moveHistory: moveHistory ?? this.moveHistory,
      checkStatus: checkStatus ?? this.checkStatus,
      currentWeather: currentWeather ?? this.currentWeather,
      weatherChangeTime: weatherChangeTime ?? this.weatherChangeTime,
      turnNumber: turnNumber ?? this.turnNumber,
      pieceEvolutionPoints: pieceEvolutionPoints ?? this.pieceEvolutionPoints,
      availableEvolutions: availableEvolutions ?? this.availableEvolutions,
      canCastleKingSide: canCastleKingSide ?? this.canCastleKingSide,
      canCastleQueenSide: canCastleQueenSide ?? this.canCastleQueenSide,
      enPassantTarget: enPassantTarget ?? this.enPassantTarget,
      halfMoveClock: halfMoveClock ?? this.halfMoveClock,
      fullMoveNumber: fullMoveNumber ?? this.fullMoveNumber,
      activeEffects: activeEffects ?? this.activeEffects,
      globalEffects: globalEffects ?? this.globalEffects,
      campaignData: campaignData ?? this.campaignData,
      weatherIntensity: weatherIntensity ?? this.weatherIntensity,
      gameStartTime: gameStartTime ?? this.gameStartTime,
      timePerPlayer: timePerPlayer ?? this.timePerPlayer,
      remainingTimeWhite: remainingTimeWhite ?? this.remainingTimeWhite,
      remainingTimeBlack: remainingTimeBlack ?? this.remainingTimeBlack,
    );
  }
}