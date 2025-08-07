import 'package:flutter/material.dart';
import '../models/chess_piece.dart';

class WeatherWidget extends StatelessWidget {
  final WeatherEffect weather;
  final double intensity;

  const WeatherWidget({
    super.key,
    required this.weather,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    if (weather == WeatherEffect.none) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _getWeatherColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getWeatherColor().withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getWeatherIcon(),
            size: 16,
            color: _getWeatherColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getWeatherName(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getWeatherColor(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    switch (weather) {
      case WeatherEffect.rain:
        return Icons.water_drop;
      case WeatherEffect.storm:
        return Icons.flash_on;
      case WeatherEffect.fog:
        return Icons.cloud;
      case WeatherEffect.ice:
        return Icons.ac_unit;
      case WeatherEffect.fire:
        return Icons.local_fire_department;
      case WeatherEffect.wind:
        return Icons.air;
      case WeatherEffect.none:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherColor() {
    switch (weather) {
      case WeatherEffect.rain:
        return Colors.blue;
      case WeatherEffect.storm:
        return Colors.purple;
      case WeatherEffect.fog:
        return Colors.grey;
      case WeatherEffect.ice:
        return Colors.lightBlue;
      case WeatherEffect.fire:
        return Colors.orange;
      case WeatherEffect.wind:
        return Colors.teal;
      case WeatherEffect.none:
        return Colors.yellow;
    }
  }

  String _getWeatherName() {
    switch (weather) {
      case WeatherEffect.rain:
        return 'Rain';
      case WeatherEffect.storm:
        return 'Storm';
      case WeatherEffect.fog:
        return 'Fog';
      case WeatherEffect.ice:
        return 'Ice';
      case WeatherEffect.fire:
        return 'Fire';
      case WeatherEffect.wind:
        return 'Wind';
      case WeatherEffect.none:
        return 'Clear';
    }
  }
}