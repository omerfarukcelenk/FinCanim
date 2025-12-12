# falcim_benim

Kısa açıklama
# falcim_benim

`falcim_benim` Türk kahvesi fincanı fotoğrafı üzerinden AI destekli fal okuması yapan bir Flutter uygulamasıdır.

## Özet

- Platform: Flutter (Android, iOS, web, Windows, macOS, Linux)
- Kimlik doğrulama: Telefon numarası + SMS OTP (phone-first)
- Backend: Firebase Auth (OTP), Cloud Firestore (kullanıcı profili ve premium hakları)
- Yerelleştirme: İngilizce ve Türkçe (`lib/l10n/`)

## Öne çıkan özellikler

- Telefon-tabanlı kimlik doğrulama ve OTP akışı (yeniden gönderme cooldown'u mevcut)
- Kullanıcı profili ve premium/hak yönetimi Firestore'da saklanır
- AI destekli fal okuma (kullanıcı fincan fotoğrafı yükler, sonuç gösterilir)

## Temel mimari ve dosyalar

- `lib/view/otp/` — OTP ekranı ve `OtpViewModel` (SMS gönderme/doğrulama mantığı)
- `lib/view/register/`, `lib/view/login/` — Kayıt ve giriş ekranları
- `lib/services/firebase_auth_service.dart` — Firebase entegrasyonu
- `lib/services/premium_service.dart` — Premium/hak yönetimi
- `lib/l10n/` — `AppLocalizations` ve dil dosyaları (`app_localizations_en.dart`, `app_localizations_tr.dart`)

## Hızlı kurulum

1. Flutter ortamını kurun: https://docs.flutter.dev/get-started/install
2. Depoyu klonlayın ve bağımlılıkları yükleyin:

```powershell
cd e:\projects\falcim_benim
flutter pub get
```

3. Firebase yapılandırması (platforma özel):

- Android: `android/app/google-services.json` ekleyin ve Gradle plugin'ini uygulayın.
- iOS/macOS: `ios/Runner/GoogleService-Info.plist` (ve macOS için `macos/Runner`) ekleyin.
- İsterseniz FlutterFire CLI (`flutterfire configure`) ile `firebase_options.dart` oluşturun.

Uygulamayı çalıştırma örneği (PowerShell):

```powershell
flutter clean; flutter pub get; flutter run
```

## Firebase Phone Auth Konfigürasyonu (SMS Verification)

### Firebase Console'da Yapılacaklar

1. **Authentication etkinleştirin:**
   - Firebase Console → Authentication → Enable it
   - Sign-in method → Phone → Enable

2. **Test telefon numarası ekleyin (önemli):**
   - Firebase Console → Authentication → Sign-in method → Phone
   - **Phone numbers for testing** bölümüne test numarası ekleyin:
     - Telefon: `+905551234567` (veya tercih ettiğiniz numara)
     - Doğrulama kodu: `123456` (sabit bir kod seçin)
   - Bu sayede gerçek SMS gönderimi olmadan OTP akışını test edebilirsiniz

3. **Proje ayarlarını kontrol edin:**
   - Firebase Console → Project settings → Billing
   - Faturalandırma açık olduğundan emin olun (Blaze planı)
   - Gerçek SMS göndermek için gerekli

### Firebase Auth Emulator Kullanımı (Önerilen - Geliştirme)

Firebase Auth Emulator, lokal geliştirmede SMS gönderimi gerektirmeden OTP akışını simüle etmenizi sağlar. Rate limiting olmaz, tamamen ücretsizdir.

#### Emulator Kurulumu

1. Firebase CLI kurun (varsa güncelle):
```powershell
npm install -g firebase-tools
firebase --version
```

2. Emulator'ü başlatın:
```powershell
cd e:\projects\falcim_benim
firebase emulators:start --only auth
```

3. Emulator başladığında şunu göreceksiniz:
```
✔  auth: listening on http://localhost:9099
```

#### Flutter'da Emulator'e Bağlanma

Proje şimdiden `main.dart` içinde emulator konfigürasyonu barındırır. Debug modda otomatik olarak emulator'e bağlanacaktır:

```dart
// main.dart içinde _configureAuthEmulator() fonksiyonu otomatik çalışır
// Android emulator: 10.0.2.2:9099 (varsayılan)
// Physical device / iOS: localhost:9099
```

#### Emulator ile Test

1. Emulator çalışırken uygulamayı açın
2. OTP ekranında test telefon numarası girin (ör. +905551234567)
3. "Send Code" tuşuna basın
4. Emulator, otomatik olarak test kodunu (123456) sağlayacak
5. Kodunuzu girin ve doğrulayın

### SMS Rate Limiting ("We have blocked all requests...")

Ekranda "We have blocked all requests from this device due to unusual activity" hatası alırsanız:
- **Geçici çözüm:** Farklı bir test telefon numarası kullanın veya birkaç saat bekleyin (blok otomatik kaldırılır)
- **Kalıcı çözüm:** Firebase Emulator'ü kullanın (rate limiting yok)

### Ülkeye / İşletmeci Kısıtlamaları

Bazı ülkelerde Firebase Phone Auth sınırlı olabilir. Eğer şu hatayı alırsanız:
- "This country is not currently supported"
- Firebase Console → Project settings → Location değiştirmeyi deneyin
- Veya test numarası ekleyip emulator kullanın

## Auth / OTP notları ve sık karşılaşılan hata: `BILLING_NOT_ENABLED`

`BILLING_NOT_ENABLED` hatası şu durumlarda alınır:
- Firebase projesinde faturalandırma etkin değil
- Test numarası tanımlanmamış
- Firebase Auth Emulator kullanılmıyor

**Hızlı çözümler:**
1. **En pratik:** Firebase Console'da test telefon numarası ekleyin
2. **Önerilen:** Firebase Auth Emulator'ü kullanın (geliştirme için ideal)
3. **Gerçek SMS:** Blaze planına geçin ve faturalandırmayı etkinleştirin

### Hata Mesajları ve Anlamları

Proje içinde hata kodları yerelleştirilmiş (Türkçe) olarak gösterilir:

| Kod | Anlamı | Çözüm |
|-----|--------|-------|
| `BILLING_NOT_ENABLED` | SMS servisi etkin değil | Test numarası ekle veya emulator kullan |
| `TOO_MANY_REQUESTS` | Çok fazla deneme | Birkaç dakika bekle |
| `SESSION_EXPIRED` | Oturum süresi doldu | Kodu yeniden gönder |
| `INVALID_VERIFICATION_CODE` | Yanlış kod | Kodu kontrol et ve yeniden dene |
| `NETWORK_REQUEST_FAILED` | İnternet bağlantısı yok | Bağlantıyı kontrol et |

## Yerelleştirme (i18n)

- Tüm kullanıcı metinleri `lib/l10n/app_localizations*.dart` içinde yönetilir. Yeni bir metin eklerken önce `app_localizations.dart` abstract sınıfına getter ekleyin, sonra `app_localizations_en.dart` ve `app_localizations_tr.dart` içine çevirisini ekleyin.

## Geliştirme ipuçları

- Kod analizi: `flutter analyze` ile statik analiz çalıştırın.
- Yaygın temizlemeler: sabitlerin lowerCamelCase yapılması, `print` çağrılarının kaldırılması veya uygun log/Toast ile değiştirilmesi, kullanılmayan import'ların temizlenmesi.
- **OTP geliştirmesi:** Firebase Emulator ile geliştirin; rate limiting kaygısı olmadan test edin.

## Katkıda bulunma

Projeye katkı yapmak isterseniz yeni bir branch oluşturup PR gönderin. Kod stili mevcut düzenle uyumlu olmalıdır.

## İletişim / Lisans

Varsa buraya proje lisansını ekleyin (örn. `LICENSE`).

---

Daha fazla yardıma ihtiyaç varsa, Firebase Emulator kurulum detayları veya OTP akışının debug edilmesi konusunda soru sorun.
