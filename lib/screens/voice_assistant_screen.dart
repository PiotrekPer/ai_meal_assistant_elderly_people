import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/voice_conversation_service.dart';

class VoiceAssistantScreen extends StatefulWidget {
  final Map<String, dynamic>? userContext;

  const VoiceAssistantScreen({
    Key? key,
    this.userContext,
  }) : super(key: key);

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> with SingleTickerProviderStateMixin {
  late final VoiceConversationService _voiceService;
  late AnimationController _animationController;
  
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _hasPermission = false;
  String _statusMessage = 'Tap the microphone to start talking';
  List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    final apiKey = dotenv.env['ELEVENLABS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_elevenlabs_api_key_here') {
      setState(() {
        _statusMessage = 'ElevenLabs API key not configured';
      });
      return;
    }
    
    _voiceService = VoiceConversationService(apiKey);
    _initializeAssistant();
  }

  Future<void> _initializeAssistant() async {
    setState(() {
      _statusMessage = 'Initializing assistant...';
      _isProcessing = true;
    });

    try {
      final hasPermission = await _voiceService.requestMicrophonePermission();
      
      if (!hasPermission) {
        setState(() {
          _statusMessage = 'Microphone permission required';
          _hasPermission = false;
          _isProcessing = false;
        });
        return;
      }

      final customPrompt = {
        'system_prompt': '''You are a helpful meal planning and nutrition assistant. 
The user has the following preferences:
- Food preferences: ${widget.userContext?['food_preferences'] ?? 'Not specified'}
- Allergies: ${widget.userContext?['allergies'] ?? 'None'}
- Preferred shop: ${widget.userContext?['shop_preference'] ?? 'Any'}
- Weight: ${widget.userContext?['weight'] ?? 'Unknown'}
- Height: ${widget.userContext?['height'] ?? 'Unknown'}
- Workout frequency: ${widget.userContext?['workout_frequency'] ?? 'Unknown'}

Help the user with meal planning, recipe suggestions, nutrition advice, and shopping tips.
Keep your responses concise and friendly. Speak naturally as if having a conversation.'''
      };

      await _voiceService.startConversation(customPrompt: customPrompt);

      setState(() {
        _isInitialized = true;
        _hasPermission = true;
        _statusMessage = 'Ready! Tap to speak';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecordingAndSend();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || !_hasPermission) {
      _showSnackBar('Assistant not ready');
      return;
    }

    setState(() {
      _isRecording = true;
      _statusMessage = 'Listening...';
    });

    try {
      await _voiceService.recordAudio();
    } catch (e) {
      setState(() {
        _isRecording = false;
        _statusMessage = 'Error starting recording: $e';
      });
    }
  }

  Future<void> _stopRecordingAndSend() async {
    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _statusMessage = 'Processing...';
    });

    try {
      final audioPath = await _voiceService.stopRecording();
      
      if (audioPath == null) {
        setState(() {
          _statusMessage = 'No audio recorded';
          _isProcessing = false;
        });
        return;
      }

      setState(() {
        _conversationHistory.add({
          'role': 'user',
          'message': '[Voice message]',
        });
      });

      final audioFile = File(audioPath);
      final response = await _voiceService.sendAudioMessage(audioFile: audioFile);

      if (response['success'] == true && response['audio_file'] != null) {
        setState(() {
          _statusMessage = 'Playing response...';
          _conversationHistory.add({
            'role': 'assistant',
            'message': '[Voice response]',
          });
        });

        await _voiceService.playAudioResponse(response['audio_file']);
        
        setState(() {
          _statusMessage = 'Ready! Tap to speak';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
        _isProcessing = false;
      });
      _showSnackBar('Error processing audio: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear conversation',
            onPressed: _conversationHistory.isEmpty
                ? null
                : () {
                    setState(() {
                      _conversationHistory.clear();
                    });
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _conversationHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic_none,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversation yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the microphone to start',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversationHistory.length,
                    itemBuilder: (context, index) {
                      final message = _conversationHistory[index];
                      final isUser = message['role'] == 'user';
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUser ? Icons.person : Icons.smart_toy,
                                size: 16,
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                message['message'] ?? '',
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _isProcessing
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _isProcessing ? null : _toggleRecording,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isRecording
                                ? [
                                    Colors.red,
                                    Colors.red[700]!,
                                  ]
                                : [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : Theme.of(context).colorScheme.primary)
                                  .withOpacity(_isRecording ? 0.5 * _animationController.value : 0.3),
                              blurRadius: _isRecording ? 20 + (20 * _animationController.value) : 15,
                              spreadRadius: _isRecording ? 5 * _animationController.value : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 50,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isRecording ? 'Tap to stop' : 'Tap to speak',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
