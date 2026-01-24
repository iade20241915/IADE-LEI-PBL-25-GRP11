import 'dart:math';

/// Modelo para coordenadas GPS
class GpsCoordinate {
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime timestamp;

  GpsCoordinate({
    required this.latitude,
    required this.longitude,
    this.altitude,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
      'altitude_m': altitude,
      'recorded_at': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() => 'GpsCoordinate(lat: $latitude, lng: $longitude, alt: $altitude)';
}

/// Serviço para obter localização GPS
/// 
/// NOTA: Esta é uma implementação simplificada para Windows.
/// Em dispositivos móveis (Android/iOS), deve usar o package geolocator.
/// Para ativar GPS real em mobile, adicione ao pubspec.yaml:
///   geolocator: ^10.1.0
/// E substitua este ficheiro pela versão completa com geolocator.
class LocationService {
  static final LocationService _instance = LocationService._();
  static LocationService get instance => _instance;

  LocationService._();

  // Simular localização para Windows (Lisboa como exemplo)
  static const double _defaultLat = 38.7223;
  static const double _defaultLng = -9.1393;

  /// Verifica se o serviço de localização está ativo
  /// Em Windows, retorna sempre true (simulado)
  Future<bool> isLocationServiceEnabled() async {
    return true;
  }

  /// Verifica se tem permissão para usar localização
  /// Em Windows, retorna sempre true (simulado)
  Future<bool> hasPermission() async {
    return true;
  }

  /// Obtém a localização atual
  /// Em Windows, retorna localização simulada (Lisboa + pequena variação)
  Future<GpsCoordinate?> getCurrentLocation() async {
    try {
      // Simular delay de GPS
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Adicionar pequena variação para simular movimento
      final random = Random();
      final latVariation = (random.nextDouble() - 0.5) * 0.001;
      final lngVariation = (random.nextDouble() - 0.5) * 0.001;

      return GpsCoordinate(
        latitude: _defaultLat + latVariation,
        longitude: _defaultLng + lngVariation,
        altitude: 50.0 + random.nextDouble() * 10,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Erro ao obter localização: $e');
      return null;
    }
  }

  /// Obtém a última localização conhecida
  Future<GpsCoordinate?> getLastKnownLocation() async {
    return getCurrentLocation();
  }

  /// Calcula distância entre dois pontos em metros usando fórmula de Haversine
  double calculateDistance(GpsCoordinate start, GpsCoordinate end) {
    const double earthRadius = 6371000; // metros
    
    final lat1 = _toRadians(start.latitude);
    final lat2 = _toRadians(end.latitude);
    final deltaLat = _toRadians(end.latitude - start.latitude);
    final deltaLng = _toRadians(end.longitude - start.longitude);

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calcula distância em quilómetros
  double calculateDistanceKm(GpsCoordinate start, GpsCoordinate end) {
    return calculateDistance(start, end) / 1000;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}

/// Tipos de atividade que requerem tracking GPS
class GpsActivityTypes {
  static const List<String> trackableActivities = [
    'running',
    'walking',
    'cycling',
    'hiking',
  ];

  /// Verifica se o tipo de atividade requer GPS
  static bool requiresGps(String activityType) {
    return trackableActivities.contains(activityType.toLowerCase());
  }
}
