# 🎤 Voice Assistant - Quick Start

## ✅ Gotowe do użycia!

Twoja aplikacja ma teraz **pełną interakcję głosową** z asystentem AI do planowania posiłków!

---

## 🚀 Jak zacząć:

### 1. Otwórz aplikację
### 2. Kliknij ikonę mikrofonu 🎤 w Dashboard (prawy górny róg)
### 3. Zaakceptuj uprawnienia do mikrofonu
### 4. Naciśnij duży przycisk i mów!

---

## 💬 Przykłady pytań:

```
"Zaproponuj mi zdrowe śniadanie"
"Co mogę zjeść na obiad z kurczaka?"
"Ile kalorii powinienem jeść dziennie?"
"Daj mi przepis na smoothie proteinowe"
"Co kupić w Lidlu na ten tydzień?"
```

---

## 📁 Nowe pliki:

```
✅ lib/services/voice_conversation_service.dart
✅ lib/screens/voice_assistant_screen.dart
✅ ASYSTENT_GLOSOWY_INSTRUKCJA.md (szczegółowa instrukcja PL)
✅ VOICE_ASSISTANT_TECHNICAL.md (dokumentacja techniczna)
```

---

## 🔧 Zmiany techniczne:

### Nowe pakiety:
- `record` - nagrywanie audio
- `permission_handler` - zarządzanie uprawnieniami
- `web_socket_channel` - przyszłe rozszerzenia

### Uprawnienia:
- ✅ Android: RECORD_AUDIO
- ✅ iOS: NSMicrophoneUsageDescription

### UI:
- ✅ Przycisk mikrofonu w Dashboard AppBar
- ✅ Nowy ekran Voice Assistant z animacjami
- ✅ Historia konwersacji
- ✅ Statusy i wskaźniki postępu

---

## 🎯 Funkcje:

### ✨ Push-to-talk
Naciśnij i mów - proste i intuicyjne

### 🧠 Kontekst użytkownika
Asystent zna Twoje:
- Preferencje żywieniowe
- Alergie
- Sklep preferowany
- Wzrost, wagę, aktywność

### 🔊 Naturalne odpowiedzi
Wysokiej jakości synteza mowy od ElevenLabs

### 📝 Historia
Przeglądaj całą konwersację

---

## 📖 Dokumentacja:

1. **`ASYSTENT_GLOSOWY_INSTRUKCJA.md`**
   - Jak używać (PL)
   - Przykłady pytań
   - Rozwiązywanie problemów
   - Wskazówki

2. **`VOICE_ASSISTANT_TECHNICAL.md`**
   - Dokumentacja techniczna (EN)
   - API reference
   - Architecture
   - Debugging

3. **`ELEVENLABS_GUIDE.md`**
   - Setup ElevenLabs
   - Text-to-Speech
   - Configuration

---

## ⚙️ Konfiguracja:

### Już skonfigurowane:
✅ ElevenLabs API key w `.env`
✅ Uprawnienia dla Android/iOS
✅ Dependencies zainstalowane
✅ UI gotowe

### Wymagane:
- Działające połączenie internetowe
- Aktywny klucz API ElevenLabs
- Urządzenie z mikrofonem

---

## 🐛 Troubleshooting:

### Problem: Brak uprawnień
**Rozwiązanie**: Ustawienia → Aplikacja → Uprawnienia → Mikrofon ✅

### Problem: Brak odpowiedzi
**Rozwiązanie**: Sprawdź internet + klucz API

### Problem: Niska jakość
**Rozwiązanie**: Mów bliżej mikrofonu, ogranicz hałas

---

## 🎓 Wskazówki:

✅ Mów wyraźnie i w normalnym tempie
✅ Zadawaj konkretne pytania
✅ Podawaj szczegóły (ilość osób, kalorie, etc.)
✅ Używaj w cichym miejscu

❌ Unikaj bardzo długich monologów
❌ Nie mów zbyt cicho
❌ Nie używaj przy słabym internecie

---

## 💰 Koszty:

**ElevenLabs Free Tier:**
- 10,000 znaków/miesiąc
- Każda rozmowa: ~100-500 znaków
- = ~20-100 rozmów miesięcznie za darmo

---

## 🚀 Testuj!

1. **Otwórz Voice Assistant** (ikona 🎤)
2. **Zapytaj**: "Zaproponuj mi zdrowy lunch"
3. **Słuchaj** odpowiedzi
4. **Kontynuuj** rozmowę!

---

## 🎉 Gotowe!

Ciesz się rozmowami z AI asystentem kulinarnym! 👨‍🍳🎤

---

**Pytania?** Sprawdź:
- `ASYSTENT_GLOSOWY_INSTRUKCJA.md` - instrukcja użytkownika
- `VOICE_ASSISTANT_TECHNICAL.md` - dokumentacja techniczna
