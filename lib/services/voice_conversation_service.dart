import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceConversationService {
  final String apiKey;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  static const String baseUrl = 'https://api.elevenlabs.io/v1';
  
  String? _conversationId;
  bool _isRecording = false;
  bool _isPlaying = false;
  
  VoiceConversationService(this.apiKey);

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String?> startConversation({
    String agentId = 'default',
    Map<String, dynamic>? customPrompt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/convai/conversation'),
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'agent_id': agentId,
          if (customPrompt != null) 'custom_llm_extra_body': customPrompt,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _conversationId = data['conversation_id'];
        return _conversationId;
      } else {
        throw Exception('Failed to start conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error starting conversation: $e');
    }
  }

  Future<File?> recordAudio({int maxDurationSeconds = 30}) async {
    if (_isRecording) {
      throw Exception('Already recording');
    }

    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/voice_input_$timestamp.m4a';

      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        
        _isRecording = true;
        return File(filePath);
      } else {
        throw Exception('No microphone permission');
      }
    } catch (e) {
      _isRecording = false;
      throw Exception('Error starting recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      _isRecording = false;
      throw Exception('Error stopping recording: $e');
    }
  }

  Future<Map<String, dynamic>> sendAudioMessage({
    required File audioFile,
    String? conversationId,
  }) async {
    final convId = conversationId ?? _conversationId;
    
    if (convId == null) {
      throw Exception('No active conversation. Start a conversation first.');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/convai/conversation/$convId/audio'),
      );

      request.headers['xi-api-key'] = apiKey;
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final responseAudioFile = File('${tempDir.path}/response_$timestamp.mp3');
        await responseAudioFile.writeAsBytes(response.bodyBytes);

        return {
          'audio_file': responseAudioFile,
          'success': true,
        };
      } else {
        throw Exception('Failed to send audio: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending audio message: $e');
    }
  }

  Future<String> sendTextMessage({
    required String text,
    String? conversationId,
  }) async {
    final convId = conversationId ?? _conversationId;
    
    if (convId == null) {
      throw Exception('No active conversation. Start a conversation first.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/convai/conversation/$convId/message'),
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response_text'] ?? '';
      } else {
        throw Exception('Failed to send text: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending text message: $e');
    }
  }

  Future<void> playAudioResponse(File audioFile) async {
    try {
      _isPlaying = true;
      await _audioPlayer.play(DeviceFileSource(audioFile.path));
      
      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      throw Exception('Error playing audio: $e');
    }
  }

  Future<void> stopPlaying() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  Future<void> endConversation({String? conversationId}) async {
    final convId = conversationId ?? _conversationId;
    
    if (convId == null) return;

    try {
      await http.delete(
        Uri.parse('$baseUrl/convai/conversation/$convId'),
        headers: {
          'xi-api-key': apiKey,
        },
      );
      
      _conversationId = null;
    } catch (e) {
      throw Exception('Error ending conversation: $e');
    }
  }

  void dispose() {
    _recorder.dispose();
    _audioPlayer.dispose();
  }
}
