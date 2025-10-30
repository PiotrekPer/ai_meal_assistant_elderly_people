import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class ElevenLabsService {
  final String apiKey;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  static const String baseUrl = 'https://api.elevenlabs.io/v1';
  
  ElevenLabsService(this.apiKey);

  Future<List<Map<String, dynamic>>> getVoices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/voices'),
      headers: {
        'xi-api-key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['voices']);
    } else {
      throw Exception('Failed to fetch voices: ${response.statusCode}');
    }
  }

  Future<File> textToSpeech({
    required String text,
    String voiceId = 'EXAVITQu4vr4xnSDxMaL',
    String? modelId,
    double stability = 0.5,
    double similarityBoost = 0.75,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/text-to-speech/$voiceId'),
      headers: {
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'model_id': modelId ?? 'eleven_monolingual_v1',
        'voice_settings': {
          'stability': stability,
          'similarity_boost': similarityBoost,
        },
      }),
    );

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/speech_$timestamp.mp3');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to generate speech: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> speakText({
    required String text,
    String voiceId = 'EXAVITQu4vr4xnSDxMaL',
    double stability = 0.5,
    double similarityBoost = 0.75,
  }) async {
    final audioFile = await textToSpeech(
      text: text,
      voiceId: voiceId,
      stability: stability,
      similarityBoost: similarityBoost,
    );
    
    await _audioPlayer.play(DeviceFileSource(audioFile.path));
  }

  Future<void> stopSpeaking() async {
    await _audioPlayer.stop();
  }

  Future<void> pauseSpeaking() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeSpeaking() async {
    await _audioPlayer.resume();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
