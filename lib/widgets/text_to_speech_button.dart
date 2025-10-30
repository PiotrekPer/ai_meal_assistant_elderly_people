import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/elevenlabs_service.dart';

class TextToSpeechButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final String? buttonText;
  final Color? backgroundColor;

  const TextToSpeechButton({
    Key? key,
    required this.text,
    this.icon = Icons.volume_up,
    this.buttonText,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<TextToSpeechButton> createState() => _TextToSpeechButtonState();
}

class _TextToSpeechButtonState extends State<TextToSpeechButton> {
  late final ElevenLabsService _elevenLabsService;
  bool _isSpeaking = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['ELEVENLABS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_elevenlabs_api_key_here') {
      return;
    }
    _elevenLabsService = ElevenLabsService(apiKey);
  }

  @override
  void dispose() {
    _elevenLabsService.dispose();
    super.dispose();
  }

  Future<void> _toggleSpeech() async {
    if (_isSpeaking) {
      await _elevenLabsService.stopSpeaking();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isLoading = true);
      try {
        await _elevenLabsService.speakText(text: widget.text);
        setState(() {
          _isSpeaking = true;
          _isLoading = false;
        });
        
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() => _isSpeaking = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['ELEVENLABS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_elevenlabs_api_key_here') {
      return const SizedBox.shrink();
    }

    if (widget.buttonText != null) {
      return ElevatedButton.icon(
        onPressed: _isLoading ? null : _toggleSpeech,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(_isSpeaking ? Icons.stop : widget.icon),
        label: Text(widget.buttonText!),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      );
    }

    return IconButton(
      onPressed: _isLoading ? null : _toggleSpeech,
      icon: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_isSpeaking ? Icons.stop : widget.icon),
      color: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
    );
  }
}
