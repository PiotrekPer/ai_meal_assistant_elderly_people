# Voice Assistant - Dokumentacja Techniczna

## 📁 Struktura plików:

### Nowe pliki:
```
lib/
├── services/
│   └── voice_conversation_service.dart    # Serwis do komunikacji z ElevenLabs Conversational AI
└── screens/
    └── voice_assistant_screen.dart        # UI ekranu asystenta głosowego
```

### Zmodyfikowane pliki:
```
lib/screens/dashboard.dart                  # Dodano przycisk mikrofonu w AppBar
android/app/src/main/AndroidManifest.xml   # Uprawnienia mikrofonu dla Android
ios/Runner/Info.plist                       # Uprawnienia mikrofonu dla iOS
pubspec.yaml                                # Nowe zależności
```

---

## 📦 Nowe zależności:

```yaml
dependencies:
  record: ^5.1.2              # Nagrywanie audio z mikrofonu
  permission_handler: ^11.3.1  # Zarządzanie uprawnieniami
  web_socket_channel: ^3.0.1   # WebSocket (przyszłe użycie)
```

---

## 🔧 VoiceConversationService API:

### Metody publiczne:

#### `Future<bool> requestMicrophonePermission()`
Prosi o uprawnienia do mikrofonu.
```dart
final hasPermission = await voiceService.requestMicrophonePermission();
```

#### `Future<String?> startConversation({String agentId, Map<String, dynamic>? customPrompt})`
Rozpoczyna nową konwersację z ElevenLabs.
```dart
final conversationId = await voiceService.startConversation(
  customPrompt: {
    'system_prompt': 'You are a helpful assistant...'
  }
);
```

#### `Future<File?> recordAudio({int maxDurationSeconds = 30})`
Rozpoczyna nagrywanie audio.
```dart
await voiceService.recordAudio();
```

#### `Future<String?> stopRecording()`
Zatrzymuje nagrywanie i zwraca ścieżkę do pliku.
```dart
final audioPath = await voiceService.stopRecording();
```

#### `Future<Map<String, dynamic>> sendAudioMessage({required File audioFile, String? conversationId})`
Wysyła plik audio do ElevenLabs i otrzymuje odpowiedź.
```dart
final response = await voiceService.sendAudioMessage(
  audioFile: File(audioPath)
);
// response = { 'audio_file': File, 'success': true }
```

#### `Future<void> playAudioResponse(File audioFile)`
Odtwarza odpowiedź audio od asystenta.
```dart
await voiceService.playAudioResponse(response['audio_file']);
```

#### `Future<void> stopPlaying()`
Zatrzymuje odtwarzanie audio.
```dart
await voiceService.stopPlaying();
```

#### `Future<void> endConversation({String? conversationId})`
Kończy konwersację.
```dart
await voiceService.endConversation();
```

#### `void dispose()`
Czyści zasoby.
```dart
voiceService.dispose();
```

### Właściwości:

```dart
bool isRecording   // Czy obecnie nagrywa
bool isPlaying     // Czy obecnie odtwarza audio
```

---

## 🎨 VoiceAssistantScreen - Komponenty UI:

### Stan:
```dart
bool _isInitialized      // Czy asystent jest gotowy
bool _isRecording        // Czy nagrywa
bool _isProcessing       // Czy przetwarza
bool _hasPermission      // Czy ma uprawnienia
String _statusMessage    // Aktualny status do wyświetlenia
List<Map<String, String>> _conversationHistory  // Historia rozmowy
```

### Główne metody:

#### `_initializeAssistant()`
Inicjalizuje asystenta - prosi o uprawnienia i rozpoczyna konwersację.

#### `_toggleRecording()`
Przełącza między nagrywaniem a zatrzymaniem.

#### `_startRecording()`
Rozpoczyna nagrywanie głosu użytkownika.

#### `_stopRecordingAndSend()`
Zatrzymuje nagrywanie, wysyła do API i odtwarza odpowiedź.

---

## 🔐 Uprawnienia:

### Android (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS (Info.plist):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone...</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition...</string>
```

---

## 🌐 API Endpoints (ElevenLabs):

### Base URL:
```
https://api.elevenlabs.io/v1
```

### Endpoints używane:

1. **POST** `/convai/conversation`
   - Rozpoczyna nową konwersację
   - Headers: `xi-api-key`, `Content-Type: application/json`
   - Body: `{ agent_id, custom_llm_extra_body }`

2. **POST** `/convai/conversation/{conversation_id}/audio`
   - Wysyła audio użytkownika
   - Headers: `xi-api-key`
   - Body: MultipartFile (audio)

3. **DELETE** `/convai/conversation/{conversation_id}`
   - Kończy konwersację

---

## 🎯 Flow diagram:

```
User opens Voice Assistant
         ↓
Request microphone permission
         ↓
Initialize conversation with ElevenLabs
    (sends user context/preferences)
         ↓
User taps microphone button
         ↓
Start recording audio
         ↓
User taps button again
         ↓
Stop recording & save to file
         ↓
Send audio file to ElevenLabs API
         ↓
Receive audio response
         ↓
Play audio response
         ↓
Update conversation history
         ↓
Ready for next interaction
```

---

## 💾 Format audio:

### Nagrywanie:
- **Format**: AAC (m4a)
- **Encoder**: AudioEncoder.aacLc
- **Bitrate**: 128000
- **Sample Rate**: 44100 Hz

### Odpowiedź:
- **Format**: MP3
- **Źródło**: ElevenLabs TTS

---

## 🧪 Testowanie:

### Symulator/Emulator:
⚠️ **Uwaga**: Emulatpry mogą mieć problemy z mikrofonem.
Testuj na prawdziwym urządzeniu.

### Debug mode:
```dart
print('Recording started: ${_isRecording}');
print('Audio path: $audioPath');
print('Response received: ${response['success']}');
```

### Typowe błędy:

1. **"Microphone permission denied"**
   - Użytkownik odmówił uprawnienia
   - Sprawdź ustawienia systemowe

2. **"No active conversation"**
   - Konwersacja nie została zainicjalizowana
   - Wywołaj `startConversation()` ponownie

3. **"Error starting recording"**
   - Brak uprawnień lub mikrofon zajęty
   - Sprawdź czy inna app nie używa mikrofonu

4. **Network errors**
   - Brak internetu lub problem z API
   - Sprawdź klucz API i połączenie

---

## 🔄 Lifecycle:

```dart
initState():
  ├─ Inicjalizuj AnimationController
  ├─ Sprawdź API key
  └─ Wywołaj _initializeAssistant()

_initializeAssistant():
  ├─ Request permissions
  ├─ Start conversation
  └─ Set ready state

dispose():
  ├─ Dispose AnimationController
  └─ Dispose VoiceService
```

---

## 🎨 Animacje:

### Pulsujący przycisk:
```dart
AnimationController(
  duration: Duration(milliseconds: 1000),
)..repeat(reverse: true);
```

Efekt:
- Normalny stan: statyczny gradient
- Podczas nagrywania: pulsujący czerwony z cieniem

---

## 📈 Performance:

### Optymalizacje:
1. Audio kompresja (AAC 128kbps)
2. Reużywanie AudioPlayer instance
3. Dispose resources w dispose()
4. Async/await dla network calls

### Memory usage:
- Audio files: ~100KB per 10s recording
- Cached w temp directory
- Auto-cleanup przez system

---

## 🔮 Możliwe rozszerzenia:

1. **WebSocket dla real-time**
   ```dart
   // Już dodana zależność: web_socket_channel
   // Można dodać streaming audio
   ```

2. **Offline mode**
   - Cache common responses
   - Fallback to text input

3. **Multi-language**
   - Detect user language
   - Switch TTS voice

4. **Voice commands**
   - "Add to cart"
   - "Generate meal plan"
   - Direct actions

5. **Conversation persistence**
   - Save to SQLite
   - Resume conversations

---

## 🛠️ Maintenance:

### Update dependencies:
```bash
flutter pub upgrade
```

### Check for breaking changes:
```bash
flutter pub outdated
```

### Test on multiple devices:
- iOS 14+
- Android 6.0+
- Different screen sizes

---

## 📚 Resources:

- [ElevenLabs API Docs](https://docs.elevenlabs.io/)
- [record package](https://pub.dev/packages/record)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [audioplayers](https://pub.dev/packages/audioplayers)

---

**Ostatnia aktualizacja**: 30 października 2025
