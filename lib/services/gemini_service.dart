import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../config/regions_constants.dart';

class GeminiService {
  final String _apiKey = AppConstants.geminiApiKey;
  final String _baseUrl = AppConstants.geminiBaseUrl;

  Future<String> sendMessage(String message, {String? context}) async {
    final url = '$_baseUrl/models/gemini-2.0-flash:generateContent';
    
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
      final uri = Uri.parse(url).replace(queryParameters: {'key': _apiKey});
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text ?? 'Désolé, je n\'ai pas pu générer une réponse.';
        } else {
          debugPrint('Gemini response structure: ${data.toString()}');
          return 'Désolé, le format de réponse est inattendu.';
        }
      } else {
        final errorBody = response.body;
        debugPrint('Gemini API error ${response.statusCode}: $errorBody');
        throw Exception('Erreur API: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      debugPrint('Gemini service error: $e');
      return 'Désolé, une erreur s\'est produite: ${e.toString()}';
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

  // Recommandations de semences intelligentes selon zone et saison
  Future<List<String>> recommendSeeds({
    required String region,
    required String agroEcologicalZone,
    required String season,
    String? userPreferences,
  }) async {
    final prompt = '''
En tant qu'expert en agriculture sénégalaise, recommande les meilleures semences pour:
- Région: $region
- Zone agro-écologique: $agroEcologicalZone
- Saison: $season
${userPreferences != null ? '\nPréférences utilisateur: $userPreferences' : ''}

Donne une liste de 5-7 recommandations de semences avec:
1. Nom de la semence
2. Pourquoi elle est adaptée
3. Période de plantation optimale
4. Rendement attendu

Format: Liste numérotée, concise et pratique.
''';

    final response = await sendMessage(prompt);
    // Parser la réponse pour extraire les recommandations
    final lines = response.split('\n');
    return lines.where((line) {
      final trimmed = line.trim();
      return trimmed.isNotEmpty && 
             (RegExp(r'^\d+').hasMatch(trimmed) || 
              trimmed.startsWith('-') || 
              trimmed.startsWith('•'));
    }).toList();
  }

  // Calcul intelligent de quantité selon superficie
  Future<Map<String, dynamic>> calculateSeedQuantity({
    required String seedName,
    required double areaHectares,
    required String region,
    required String season,
  }) async {
    final prompt = '''
Calcule la quantité de semences nécessaire pour:
- Semence: $seedName
- Superficie: ${areaHectares.toStringAsFixed(2)} hectares
- Région: $region
- Saison: $season

Donne:
1. Quantité totale en kg
2. Densité de semis recommandée (kg/hectare)
3. Nombre de plants attendus
4. Espacement recommandé entre les rangs
5. Conseils de plantation

Format JSON: {"quantity": nombre, "density": nombre, "expectedPlants": nombre, "spacing": "texte", "advice": "texte"}
''';

    final response = await sendMessage(prompt);
    try {
      // Extraire JSON de la réponse
      final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(response);
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!);
      }
    } catch (e) {
      // Si parsing JSON échoue, retourner des valeurs par défaut
    }
    
    // Valeurs par défaut basées sur des moyennes
    final defaultDensity = 20.0; // kg/hectare moyenne
    return {
      'quantity': (areaHectares * defaultDensity).toStringAsFixed(2),
      'density': defaultDensity.toStringAsFixed(2),
      'expectedPlants': (areaHectares * 50000).toStringAsFixed(0), // Estimation
      'spacing': '40-50 cm entre rangs',
      'advice': response,
    };
  }

  // Recommandations de formations adaptées
  Future<List<Map<String, String>>> recommendTraining({
    required String userRegion,
    required String agroEcologicalZone,
    required List<String> userInterests,
    String? currentCrops,
  }) async {
    final prompt = '''
Recommandez des formations agricoles pour un agriculteur:
- Région: $userRegion
- Zone: $agroEcologicalZone
- Intérêts: ${userInterests.join(', ')}
${currentCrops != null ? '\nCultures actuelles: $currentCrops' : ''}

Donne 5-7 recommandations de formations avec:
1. Titre de la formation
2. Description courte
3. Pourquoi elle est pertinente
4. Durée estimée

Format: Liste structurée et concise.
''';

    final response = await sendMessage(prompt);
    // Parser et structurer les recommandations
    final lines = response.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final recommendations = <Map<String, String>>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (RegExp(r'^\d+').hasMatch(line) || line.startsWith('-') || line.startsWith('•')) {
        final title = line.replaceFirst(RegExp(r'^[\d\-\•\.]\s*'), '').trim();
        if (title.isNotEmpty) {
          final description = i + 1 < lines.length && 
                             !RegExp(r'^\d+').hasMatch(lines[i + 1].trim()) &&
                             !lines[i + 1].trim().startsWith('-') &&
                             !lines[i + 1].trim().startsWith('•')
              ? lines[i + 1].trim() 
              : '';
          recommendations.add({
            'title': title,
            'description': description,
          });
        }
      }
    }
    
    return recommendations;
  }

  // Conseils de gestion de champs et clôtures
  Future<String> getFieldManagementAdvice({
    required String region,
    required double areaHectares,
    String? cropType,
    String? soilType,
  }) async {
    final prompt = '''
Donne des conseils pratiques pour la gestion de champs:
- Région: $region
- Superficie: ${areaHectares.toStringAsFixed(2)} hectares
${cropType != null ? '\nType de culture: $cropType' : ''}
${soilType != null ? '\nType de sol: $soilType' : ''}

Couvre:
1. Gestion des clôtures et protection
2. Rotation des cultures
3. Gestion de l'eau
4. Protection contre les animaux
5. Optimisation de l'espace

Sois pratique et adapté au contexte sénégalais (max 200 mots).
''';

    return await sendMessage(prompt);
  }

  // Analyse de traçabilité et recommandations
  Future<String> analyzeTraceability({
    required String productName,
    required String origin,
    required String certification,
    String? producerInfo,
  }) async {
    final prompt = '''
Analyse la traçabilité de cette semence:
- Produit: $productName
- Origine: $origin
- Certification: $certification
${producerInfo != null ? '\nInfo producteur: $producerInfo' : ''}

Donne:
1. Évaluation de la qualité de traçabilité
2. Points forts
3. Points d'attention
4. Recommandations

Sois concis et pratique.
''';

    return await sendMessage(prompt);
  }
}
