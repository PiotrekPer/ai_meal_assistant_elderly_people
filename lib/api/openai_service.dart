import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<String> generateText(String prompt) async {
    const url = 'https://api.openai.com/v1/chat/completions';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content': '''You are a helpful intelligent diet assistant.  
  Always return the output in valid JSON format with the following structure:

{
  "meal_plan": {
    "breakfast": {
      "name": "string",
      "ingredients": [
        { "item": "string", "quantity": "string" }
      ],
      "nutrition": {
        "calories": number,
        "proteins": number,
        "fiber": number,
        "fat": number,
        "carbs": number
      },
      "recipe": {
        "steps": [
          { "step_number": number, "instruction": "string" }
        ],
        "total_time_minutes": number
      }
    },
    "lunch": { ... same structure ... },
    "dinner": { ... same structure ... },
    "snack": { ... same structure ... }
  }
}'''
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'max_tokens': 2000,
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to generate text: ${response.body}');
    }
  }
}