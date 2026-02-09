# Rešavanje Recaptcha problema

Ako dobijate grešku:
```
E/RecaptchaCallWrapper: Initial task failed for action RecaptchaAction(action=signUpPassword)
with exception - An internal error has occurred. [ CONFIGURATION_NOT_FOUND ]
```

## Brzo rešenje za testiranje:

1. U fajlu `lib/main.dart`, odkomentirajte liniju:
```dart
FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
```

## Trajno rešenje (za produkciju):

### Metoda 1: Dodavanje SHA-1 fingerprint-a

1. Generišite debug SHA-1:
```bash
cd android
./gradlew signingReport
```

2. Kopirajte SHA-1 i SHA-256 ključeve

3. Idite na Firebase Console → Project Settings → Your apps
4. Dodajte SHA fingerprint-ove
5. Preuzmite novi `google-services.json`
6. Zamenite stari `android/app/google-services.json` sa novim

### Metoda 2: Omogućavanje Email/Password providera

1. Idite na Firebase Console
2. Authentication → Sign-in method
3. Omogućite Email/Password providera
4. Sačuvajte promene

## Napomena za korišćenje "fejk" email-a

Firebase Auth zahteva validne email formate. Možete koristiti:
- `test@test.com`
- `user123@example.com`
- `anything@gmail.com` (ne mora biti pravi)

Email ne mora postojati, ali mora biti u validnom formatu!
