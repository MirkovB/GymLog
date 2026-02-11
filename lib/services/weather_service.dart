import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
 
  static const String _apiKey = '25d4fdd6d295362f8f4178a5b34c98d6';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static final Map<String, _CachedWeather> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 10);


  Future<Weather> getCurrentWeather(String cityName) async {

    final cachedWeather = _getCachedWeather(cityName);
    if (cachedWeather != null) {
      return cachedWeather;
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=sr',
      );

      print('🌐 Pozivam API: $url'); 
      final response = await http.get(url);
      print('📡 Status code: ${response.statusCode}'); 
      print('📨 Response: ${response.body}'); 

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = Weather.fromJson(data);
        _cacheWeather(cityName, weather);
        return weather;
      } else if (response.statusCode == 404) {
        throw Exception('Grad "$cityName" nije pronađen. Proverite naziv.');
      } else if (response.statusCode == 429) {
        throw Exception(
          'Previše zahteva ka API-ju.\n\n'
          'Sačekajte nekoliko minuta pre novog pokušaja.',
        );
      } else if (response.statusCode == 401) {
        // Parsiramo odgovor da vidimo tačnu grešku
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Nepoznata greška';
        
        throw Exception(
          'API Key Problem:\n\n'
          'Detalji: $message\n\n'
        
        );
      } else {
  
        String errorMsg = 'Status: ${response.statusCode}\n';
        try {
          final errorData = json.decode(response.body);
          errorMsg += 'Poruka: ${errorData['message'] ?? response.body}';
        } catch (e) {
          errorMsg += 'Odgovor: ${response.body}';
        }
        throw Exception('Greška:\n$errorMsg');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Greška sa povezivanjem:\n$e');
    }
  }

  Weather? _getCachedWeather(String cityName) {
    final cached = _cache[cityName.toLowerCase()];
    if (cached != null && 
        DateTime.now().difference(cached.timestamp) < _cacheDuration) {
      return cached.weather;
    }
    return null;
  }

  void _cacheWeather(String cityName, Weather weather) {
    _cache[cityName.toLowerCase()] = _CachedWeather(
      weather: weather,
      timestamp: DateTime.now(),
    );
  }

  Future<Weather> getCurrentWeatherByCoords(
    double latitude,
    double longitude,
  ) async {
    final cacheKey = 'coords_${latitude}_$longitude';
    final cachedWeather = _getCachedWeather(cacheKey);
    if (cachedWeather != null) {
      return cachedWeather;
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=sr',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = Weather.fromJson(data);
        _cacheWeather(cacheKey, weather);
        return weather;
      } else if (response.statusCode == 429) {
        throw Exception(
          'Previše zahteva ka API-ju.\n\n'
          '💡 REŠENJE: Dobijte svoj besplatni API key:\n'
          '1. Idite na https://openweathermap.org/api\n'
          '2. Kliknite "Sign Up" i napravite nalog\n'
          '3. Kopirajte API key iz vašeg naloga\n'
          '4. Zamenite _apiKey u weather_service.dart\n\n'
          'Besplatan nalog ima 60 poziva/min!',
        );
      } else if (response.statusCode == 401) {
        throw Exception(
          'API key je nevažeći.\n'
          'Dobijte svoj besplatni key na:\n'
          'https://openweathermap.org/api',
        );
      } else {
        throw Exception('Greška pri učitavanju: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Greška sa povezivanjem: $e');
    }
  }


  static String getWorkoutRecommendation(Weather weather) {
    final temp = weather.temperature;
    final desc = weather.description.toLowerCase();

    if (desc.contains('kiša') || desc.contains('pljusak')) {
      return '☔ Kiša - najbolje trenirati unutra';
    } else if (desc.contains('sneg')) {
      return '❄️ Sneg - pažljivo ako trenirate napolju';
    } else if (temp < 0) {
      return '🥶 Hladno - obucite se toplo za outdoor trening';
    } else if (temp > 30) {
      return '🔥 Vruće - pazite na hidrataciju';
    } else if (temp >= 15 && temp <= 25 && desc.contains('vedro')) {
      return '✅ Idealno vreme za trening napolju!';
    } else {
      return '👍 Dobri uslovi za trening';
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}

class _CachedWeather {
  final Weather weather;
  final DateTime timestamp;

  _CachedWeather({
    required this.weather,
    required this.timestamp,
  });
}
