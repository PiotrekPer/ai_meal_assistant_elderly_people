# 🎤 Asystent Głosowy - Instrukcja Użytkowania

## ✅ Co zostało dodane:

### 1. **Pełna interakcja głosowa z AI**
- Rozmawiaj naturalnie z asystentem o planowaniu posiłków
- System "naciśnij i mów" (push-to-talk)
- Automatyczne odpowiedzi głosowe
- Historia konwersacji

### 2. **Przycisk mikrofonu w Dashboard**
- Ikona 🎤 w prawym górnym rogu (obok koszyka i ustawień)
- Otwiera ekran Voice Assistant

### 3. **Spersonalizowany asystent**
- Zna Twoje preferencje żywieniowe
- Uwzględnia alergie
- Zna Twój sklep preferowany
- Ma informacje o Twoim wzroście, wadze i aktywności

---

## 🎯 Jak używać:

### Krok 1: Otwórz Voice Assistant
1. Kliknij ikonę mikrofonu 🎤 w Dashboard
2. Poczekaj na inicjalizację (pojawi się "Ready! Tap to speak")
3. Aplikacja może poprosić o uprawnienia do mikrofonu - zaakceptuj

### Krok 2: Rozmawiaj z asystentem
1. **Naciśnij** duży okrągły przycisk mikrofonu
2. **Mów** - np. "Zaproponuj mi zdrowy obiad na dziś"
3. **Puść** przycisk (lub naciśnij ponownie aby zatrzymać nagrywanie)
4. Poczekaj na odpowiedź - asystent odpowie głosowo!

### Krok 3: Kontynuuj rozmowę
- Możesz zadawać pytania uzupełniające
- Asystent pamięta kontekst rozmowy
- Historia konwersacji jest widoczna na ekranie

---

## 💬 Przykładowe pytania do asystenta:

### Planowanie posiłków:
- "Zaproponuj mi zdrowe śniadanie"
- "Co mogę zjeść na obiad, mając 500 kalorii?"
- "Daj mi przepis na wegetariański obiad"
- "Mam kurczaka i brokuły, co mogę ugotować?"

### Porady żywieniowe:
- "Ile kalorii powinienem jeść dziennie?"
- "Jakie produkty są bogate w białko?"
- "Czy banan jest zdrowy?"
- "Jak zwiększyć spożycie błonnika?"

### Lista zakupów:
- "Co powinienem kupić w Lidlu na ten tydzień?"
- "Jakie produkty są teraz w sezonie?"
- "Czy możesz zaproponować tanie składniki?"

### Przepisy:
- "Jak ugotować kurczaka z piekarnika?"
- "Daj mi szybki przepis na 15 minut"
- "Przepis na smoothie proteinowe"
- "Jak przyrządzić quinoa?"

### Alergie i preferencje:
- "Jakie zamienniki dla produktów z glutenem?"
- "Czy ten przepis zawiera orzechy?"
- "Wersja wegańska tego dania"

---

## 🎨 Interfejs użytkownika:

### Wskaźniki statusu:
- **"Ready! Tap to speak"** - gotowy do nagrywania
- **"Listening..."** - nagrywanie w toku (czerwony przycisk)
- **"Processing..."** - przetwarzanie Twojej wiadomości
- **"Playing response..."** - odtwarzanie odpowiedzi asystenta

### Kolory przycisku:
- 🔵 **Niebieski/Zielony gradient** - gotowy do nagrania
- 🔴 **Czerwony** - nagrywanie w toku (pulsujący efekt)

### Historia konwersacji:
- 👤 **Niebieskie bąbelki** - Twoje wiadomości
- 🤖 **Szare bąbelki** - Odpowiedzi asystenta
- Ikona kosza - wyczyść historię

---

## ⚙️ Jak to działa:

### Technologia:
1. **Nagrywanie audio**: Twój głos jest nagrywany w formacie AAC
2. **Wysyłka do ElevenLabs**: Audio jest wysyłane do API Conversational AI
3. **Przetwarzanie AI**: ElevenLabs używa GPT + Text-to-Speech
4. **Odpowiedź głosowa**: Otrzymujesz naturalną odpowiedź głosową

### Kontekst użytkownika:
Asystent wie o Tobie:
```
- Preferencje żywieniowe: [Twoje ustawienia]
- Alergie: [Twoje alergie]
- Sklep: [Twój sklep]
- Waga: [Twoja waga]
- Wzrost: [Twój wzrost]
- Częstotliwość ćwiczeń: [Twoje ustawienia]
```

---

## 🔧 Konfiguracja:

### Wymagania:
1. ✅ **Klucz API ElevenLabs** - już skonfigurowany w `.env`
2. ✅ **Uprawnienia mikrofonu** - aplikacja poprosi automatycznie
3. ✅ **Połączenie internetowe** - wymagane do działania

### Uprawnienia (automatyczne):
- **Android**: RECORD_AUDIO, INTERNET
- **iOS**: NSMicrophoneUsageDescription, NSSpeechRecognitionUsageDescription

---

## 💡 Zaawansowane funkcje:

### 1. Planowanie całego dnia:
```
Ty: "Zaplanuj mi cały dzień posiłków"
Asystent: "Oczywiście! Mając na uwadze że..."
```

### 2. Kalorie i makra:
```
Ty: "Ile kalorii ma omlet z 3 jajek?"
Asystent: "Omlet z 3 jajek ma około..."
```

### 3. Zamienniki produktów:
```
Ty: "Czym mogę zastąpić mleko krowie?"
Asystent: "Możesz użyć mleka migdałowego..."
```

### 4. Porady dla treningujących:
```
Ty: "Co jeść przed treningiem?"
Asystent: "Przed treningiem dobrze jest zjeść..."
```

---

## 🐛 Rozwiązywanie problemów:

### Problem: "Microphone permission denied"
**Rozwiązanie:**
1. Przejdź do Ustawień telefonu
2. Znajdź aplikację
3. Włącz uprawnienia do mikrofonu

### Problem: "No active conversation"
**Rozwiązanie:**
1. Zamknij i otwórz ponownie Voice Assistant
2. Poczekaj na "Ready! Tap to speak"

### Problem: Brak odpowiedzi
**Rozwiązanie:**
1. Sprawdź połączenie internetowe
2. Upewnij się że mówiłeś wyraźnie
3. Sprawdź czy klucz API jest ważny

### Problem: "Error starting recording"
**Rozwiązanie:**
1. Sprawdź czy inna aplikacja nie używa mikrofonu
2. Zrestartuj aplikację
3. Sprawdź uprawnienia

### Problem: Niska jakość audio
**Rozwiązanie:**
1. Mów bliżej mikrofonu
2. Ogranicz hałas w tle
3. Sprawdź głośność urządzenia

---

## 📊 Limity i koszty:

### ElevenLabs Free Tier:
- **10,000 znaków/miesiąc** dla Text-to-Speech
- **Conversational AI** - sprawdź plan na elevenlabs.io
- Każda rozmowa ~ 100-500 znaków (w zależności od długości)

### Optymalizacja użycia:
- Mów zwięźle i konkretnie
- Zadawaj jedno pytanie na raz
- Używaj gdy naprawdę potrzebujesz pomocy AI

---

## 🎓 Wskazówki dla najlepszych rezultatów:

### ✅ Dobre praktyki:
- Mów wyraźnie i w normalnym tempie
- Unikaj hałasu w tle
- Formułuj pytania konkretnie
- Podawaj szczegóły (np. "na 2 osoby", "na 400 kalorii")

### ❌ Unikaj:
- Mówienia zbyt cicho
- Bardzo długich monologów
- Pytań nie związanych z jedzeniem
- Używania gdy jest słabe połączenie

---

## 🚀 Przyszłe funkcje (pomysły):

1. **Tryb hands-free** - ciągła konwersacja bez przycisków
2. **Rozpoznawanie intencji** - automatyczne dodawanie do planu
3. **Personalizowane sugestie** - na podstawie historii
4. **Wsparcie dla wielu języków** - polski, angielski, etc.
5. **Integracja z bazą przepisów** - bezpośrednie dodawanie
6. **Analiza tonu głosu** - wykrywanie preferencji

---

## 📱 Skróty klawiszowe:

- **Naciśnij mikrofon** - zacznij mówić
- **Naciśnij ponownie** - zatrzymaj nagrywanie
- **Ikona kosza** - wyczyść historię
- **Strzałka wstecz** - wyjdź z asystenta

---

## ✨ Gotowe!

Twoja aplikacja ma teraz pełną funkcję głosowego asystenta AI!

**Użyj go do:**
- ✅ Szybkiego planowania posiłków
- ✅ Uzyskania porad żywieniowych
- ✅ Znalezienia przepisów
- ✅ Pomocy z listą zakupów
- ✅ Odpowiedzi na pytania o zdrowie

---

## 📞 Wsparcie:

Jeśli masz problemy:
1. Sprawdź czy klucz API jest ważny
2. Zweryfikuj uprawnienia mikrofonu
3. Sprawdź połączenie internetowe
4. Przeczytaj sekcję "Rozwiązywanie problemów" powyżej

**Miłego gotowania z asystentem głosowym! 🎉👨‍🍳**
