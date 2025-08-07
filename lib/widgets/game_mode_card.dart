import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameModeCard extends StatelessWidget {
  final GameMode mode;
  final String title;
  final String description;
  final List<String> features;
  final VoidCallback onTap;
  final bool isSelected;

  const GameModeCard({
    super.key,
    required this.mode,
    required this.title,
    required this.description,
    required this.features,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
          ? BorderSide(color: theme.primaryColor, width: 2)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(0.1),
                    theme.primaryColor.withOpacity(0.05),
                  ],
                )
              : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getModeIcon(),
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.primaryColor : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: features.take(2).map((feature) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    feature.replaceAll('_', ' '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModeIcon() {
    switch (mode) {
      case GameMode.classic:
        return Icons.grid_4x4;
      case GameMode.evolution:
        return Icons.trending_up;
      case GameMode.weather:
        return Icons.wb_cloudy;
      case GameMode.timeAttack:
        return Icons.timer;
      case GameMode.ar3d:
        return Icons.view_in_ar;
      case GameMode.multiplayer:
        return Icons.people;
      case GameMode.puzzle:
        return Icons.extension;
      case GameMode.campaign:
        return Icons.map;
    }
  }
}