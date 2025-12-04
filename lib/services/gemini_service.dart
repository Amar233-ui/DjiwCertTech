import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class GeminiService {
  final String _apiKey = AppConstants.geminiApiKey;
  final String _baseUrl = AppConstants.geminiBaseUrl;

  Future<String> sendMessage(String message, {String? context}) async {
    final url = '$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey';
    
    final systemPrompt = '''
Tu es un assistant agricole intelligent et bienveillant. Tu aides les agriculteurs et les personnes intéressées par l'agriculture avec:
- Des conseils sur les cultures et les semences
- Des informations sur les techniques agricoles
- Des explications sur la météo et son impact sur l'agriculture
- Des recommandations personnalisées
- Des réponses dans un langage simple et accessible

Réponds toujours de manière concise, pratique et encourageante.
${context != null ? 'Contexte supplémentaire: $context' : ''}
''';

    final body = {
      'contents': [
        {
          'parts': [
            {'text': '$systemPrompt\n\nQuestion de l\'utilisateur: $message'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text ?? 'Désolé, je n\'ai pas pu générer une réponse.';
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      return 'Désolé, une erreur s\'est produite. Veuillez réessayer.';
    }
  }

  Future<String> analyzeWeather({
    required double temperature,
    required int humidity,
    required String description,
    required double windSpeed,
    String? userContext,
  }) async {
    final weatherContext = '''
Données météo actuelles:
- Température: ${temperature.round()}°C
- Humidité: $humidity%
- Conditions: $description
- Vent: ${windSpeed.round()} km/h
${userContext != null ? '\nContexte utilisateur: $userContext' : ''}
''';

    final message = '''
En tant qu'expert agricole, analyse ces conditions météo et donne:
1. Un résumé simple des conditions actuelles
2. L'impact sur les cultures
3. Des conseils pratiques pour aujourd'hui
Sois concis et pratique (max 150 mots).
''';

    return await sendMessage(message, context: weatherContext);
  }
}
