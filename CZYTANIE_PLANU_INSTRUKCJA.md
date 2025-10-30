# 🎙️ Instrukcja - Czytanie Planu Posiłków

## ✅ Co zostało dodane:

### 1. **Przycisk "Read Meal Plan Aloud" na Dashboard**
- Pojawia się automatycznie gdy masz skonfigurowany klucz API ElevenLabs
- Znajduje się między przyciskiem "Add All Ingredients to Cart" a przyciskami "Reprompt Plan" / "Save Plan"
- Niebieski kolor = gotowy do odczytania
- Czerwony kolor = obecnie czyta (kliknij aby zatrzymać)

### 2. **Przycisk czytania przepisu w szczegółach posiłku**
- W prawym górnym rogu ekranu szczegółów posiłku (MealCard)
- Obok przycisku koszyka
- Ikona mikrofonu = gotowy do odczytania
- Ikona stop = obecnie czyta

---

## 🎯 Jak używać:

### Czytanie całego planu:
1. Wygeneruj plan posiłków (kliknij "Let's plan it!")
2. Poczekaj aż plan się załaduje
3. Kliknij niebieski przycisk **"Read Meal Plan Aloud"**
4. Aplikacja przeczyta:
   - Liczbę posiłków
   - Sumę kalorii i makroskładników
   - Nazwę każdego posiłku
   - Kalorie w każdym posiłku

### Czytanie pojedynczego przepisu:
1. Kliknij na dowolny posiłek z listy (strzałka →)
2. Otworzą się szczegóły posiłku
3. Kliknij ikonę mikrofonu w prawym górnym rogu
4. Aplikacja przeczyta:
   - Nazwę posiłku
   - Czas przygotowania
   - Wszystkie kroki przepisu po kolei

### Zatrzymanie czytania:
- Kliknij przycisk ponownie (zmieni kolor na czerwony ze słowem "Stop")
- Lub przejdź do innego ekranu

---

## 🎨 Przykład użycia:

**Odczytany tekst może brzmieć tak:**
> "Here is your meal plan for today. You have 4 meals planned. Total nutrition: 2000 calories, 150 grams of protein, 200 grams of carbs, and 67 grams of fat. For breakfast, you will have Oatmeal with Berries. This meal contains 450 calories. For lunch, you will have Grilled Chicken Salad. This meal contains 520 calories..."

---

## ⚙️ Konfiguracja:

Twój klucz API ElevenLabs jest już skonfigurowany w pliku `.env`:
```
ELEVENLABS_API_KEY=sk_f3aa55a51e9dfbeca06166077f0ef84eb2da884b8a3b8233
```

Jeśli klucz nie działa:
1. Sprawdź czy masz aktywne konto na [elevenlabs.io](https://elevenlabs.io/)
2. Upewnij się że nie przekroczyłeś limitu znaków (free tier = 10,000 znaków/miesiąc)
3. Wygeneruj nowy klucz API i zaktualizuj plik `.env`

---

## 🔧 Dostosowanie:

### Zmiana głosu:
W pliku `lib/services/elevenlabs_service.dart`, zmień domyślny `voiceId`:

```dart
String voiceId = 'EXAVITQu4vr4xnSDxMaL',  // Domyślny głos (Bella)
```

**Popularne głosy:**
- `21m00Tcm4TlvDq8ikWAM` - Rachel (spokojny, przyjazny)
- `EXAVITQu4vr4xnSDxMaL` - Bella (miękki, ekspresyjny)
- `ErXwobaYiN019PkySvjV` - Antoni (zrównoważony męski)
- `TxGEqnHWrfWFTfGW9XjX` - Josh (głęboki, profesjonalny)

### Zmiana języka tekstu:
Obecnie tekst jest po angielsku. Aby zmienić na polski, edytuj metody:
- `_generateMealPlanSpeechText()` w `dashboard.dart`
- `_generateRecipeSpeechText()` w `meal_card.dart`

Przykład:
```dart
String text = 'Oto Twój plan posiłków na dziś. ';
text += 'Masz zaplanowanych ${mealPlan.length} posiłków. ';
// itd.
```

---

## 💡 Dodatkowe pomysły:

1. **Czytanie listy zakupów** - dodaj podobną funkcję do `cart_screen.dart`
2. **Czytanie składników** - przeczytaj listę składników zamiast przepisu
3. **Personalizowane powitanie** - "Dzień dobry [imię], oto Twój plan..."
4. **Przypomnienia głosowe** - "Za 10 minut zacznij gotować obiad"
5. **Tryb gotowania** - czytaj przepis krok po kroku na komendę

---

## 🐛 Rozwiązywanie problemów:

**Problem:** Przycisk nie pojawia się
- **Rozwiązanie:** Sprawdź czy plik `.env` zawiera prawidłowy klucz API

**Problem:** Błąd "Failed to generate speech"
- **Rozwiązanie:** 
  - Sprawdź połączenie internetowe
  - Zweryfikuj czy klucz API jest aktywny
  - Sprawdź czy nie przekroczyłeś limitu

**Problem:** Dźwięk nie gra
- **Rozwiązanie:**
  - Sprawdź głośność urządzenia
  - Wyłącz tryb cichy
  - Zrestartuj aplikację

**Problem:** Czytanie nie zatrzymuje się
- **Rozwiązanie:**
  - Kliknij przycisk Stop
  - Zamknij i otwórz ponownie aplikację
  - Zrestartuj aplikację: `flutter run`

---

## 📊 Zużycie znaków:

- Czytanie całego planu (4 posiłki): ~200-400 znaków
- Czytanie przepisu: ~100-300 znaków
- Free tier pozwala na ~30-50 odczytań dziennie

---

## ✨ Gotowe!

Twoja aplikacja jest teraz wyposażona w funkcję text-to-speech! 

Testuj i ciesz się głosowym czytaniem planów posiłków! 🎉
