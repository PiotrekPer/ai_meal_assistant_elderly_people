# ElevenLabs Integration Guide

## ✅ Setup Complete!

### What Was Added:

1. **Dependencies** (in `pubspec.yaml`):
   - `audioplayers: ^6.1.0` - To play audio files
   - `path_provider: ^2.1.4` - To save temporary audio files

2. **ElevenLabs Service** (`lib/services/elevenlabs_service.dart`):
   - Text-to-speech conversion
   - Voice management
   - Audio playback controls (play, pause, stop, resume)

3. **Reusable Widget** (`lib/widgets/text_to_speech_button.dart`):
   - Ready-to-use button component
   - Supports both icon and text button styles
   - Loading states and error handling

4. **Environment Variable** (`.env`):
   - `ELEVENLABS_API_KEY` placeholder added

---

## 🔑 Getting Your API Key

1. Go to [ElevenLabs](https://elevenlabs.io/)
2. Sign up for a free account
3. Navigate to Profile Settings → API Keys
4. Copy your API key
5. Replace `your_elevenlabs_api_key_here` in `.env` with your actual key

---

## 🎯 Usage Examples

### Example 1: Add to Recipe Instructions (Meal Card)

In `lib/screens/dashboard/meal_card.dart`, add a "Read Recipe" button:

```dart
import '../../widgets/text_to_speech_button.dart';

// Inside the recipe section, add:
Row(
  children: [
    Text('Recipe Instructions', style: ...),
    const Spacer(),
    TextToSpeechButton(
      text: steps.map((s) => s['instruction']).join('. '),
      buttonText: 'Read Recipe',
      icon: Icons.record_voice_over,
    ),
  ],
),
```

### Example 2: Read Individual Recipe Steps

```dart
TextToSpeechButton(
  text: step['instruction'],
  icon: Icons.play_circle_outline,
)
```

### Example 3: Read Meal Summary

In `lib/screens/dashboard.dart`, add to daily stats:

```dart
import '../widgets/text_to_speech_button.dart';

TextToSpeechButton(
  text: 'Your daily meal plan includes ${mealPlan.length} meals with $totalCalories calories',
  buttonText: 'Hear Summary',
  backgroundColor: Colors.blue,
)
```

### Example 4: Programmatic Usage

For more control, use the service directly:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/services/elevenlabs_service.dart';

final elevenLabs = ElevenLabsService(dotenv.env['ELEVENLABS_API_KEY']!);

// Simple speak
await elevenLabs.speakText(text: 'Hello, world!');

// With custom voice
await elevenLabs.speakText(
  text: 'Your recipe is ready',
  voiceId: 'EXAVITQu4vr4xnSDxMaL',
  stability: 0.7,
  similarityBoost: 0.8,
);

// Get available voices
final voices = await elevenLabs.getVoices();
for (var voice in voices) {
  print('Voice: ${voice['name']}, ID: ${voice['voice_id']}');
}

// Download audio file (without playing)
final audioFile = await elevenLabs.textToSpeech(
  text: 'Save this for later',
);

// Control playback
await elevenLabs.pauseSpeaking();
await elevenLabs.resumeSpeaking();
await elevenLabs.stopSpeaking();

// Clean up
elevenLabs.dispose();
```

---

## 🎨 Customization

### Available Voice IDs (Popular Choices):
- `21m00Tcm4TlvDq8ikWAM` - Rachel (calm, friendly)
- `EXAVITQu4vr4xnSDxMaL` - Bella (soft, expressive)
- `ErXwobaYiN019PkySvjV` - Antoni (well-rounded male)
- `MF3mGyEYCl7XYWbV9V6O` - Elli (emotional, young)
- `TxGEqnHWrfWFTfGW9XjX` - Josh (deep, professional)

### Voice Settings:
- **stability** (0.0-1.0): Higher = more consistent, lower = more expressive
- **similarity_boost** (0.0-1.0): How closely to match the voice sample

---

## 🚀 Feature Ideas for Your Meal App

1. **Recipe Narration**: Read cooking steps aloud while user cooks
2. **Meal Plan Summary**: Daily nutrition summary as audio
3. **Shopping List Reader**: Read shopping list items
4. **Cooking Timer Audio**: Voice announcements for timers
5. **Personalized Greetings**: "Good morning [Name], here's your meal plan"
6. **Multilingual Support**: Different voices for different languages
7. **Accessibility**: Help visually impaired users navigate the app
8. **Cooking Mode**: Hands-free voice instructions

---

## 📱 Platform Considerations

### iOS:
- Audio should work out of the box
- May need background audio permissions for longer playback

### Android:
- May need permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

---

## 💰 Pricing (as of 2025)

- **Free Tier**: 10,000 characters/month
- **Starter**: $5/month for 30,000 characters
- **Creator**: $22/month for 100,000 characters
- Each recipe instruction is ~50-200 characters

---

## 🐛 Troubleshooting

**Error: "API key not found"**
- Make sure `.env` file is in the root directory
- Restart your app after updating `.env`
- Verify the key doesn't have extra spaces

**Error: "Failed to generate speech"**
- Check your API key is valid
- Ensure you haven't exceeded your character limit
- Verify internet connection

**Audio not playing**
- Check device volume
- Ensure device isn't in silent mode
- Try a different voice ID

**Build errors**
- Run `flutter clean && flutter pub get`
- Restart VS Code
- Check that all packages installed correctly

---

## 📚 Additional Resources

- [ElevenLabs API Documentation](https://docs.elevenlabs.io/)
- [audioplayers Package](https://pub.dev/packages/audioplayers)
- [Voice Library](https://elevenlabs.io/voice-library)

---

## ✨ Next Steps

1. Get your ElevenLabs API key
2. Update `.env` with your actual key
3. Test the `TextToSpeechButton` widget in your app
4. Customize voice settings and voice IDs
5. Add voice features to enhance user experience!
