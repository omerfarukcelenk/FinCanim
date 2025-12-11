# falcim_benim

Kısa açıklama
---------------

`falcim_benim` Türk kahvesi fincanı fotoğrafı üzerinden AI destekli fal okuması yapan bir Flutter uygulamasıdır. Uygulama telefon numarası + SMS OTP tabanlı kimlik doğrulama (phone-first), kullanıcı profili saklama (Firestore), çoklu dil desteği (Türkçe / İngilizce) ve mobil/masaüstü platformlarında çalışma desteği içerir.

Öne çıkan özellikler
-------------------

- **Telefon-tabanlı kimlik doğrulama:** E-posta/şifre yerine telefon + SMS OTP akışı kullanılır. Yeniden gönderme için cooldown (örn. 60s) uygulanmıştır.
- **AI destekli fal okuma:** Kullanıcı fincan fotoğrafı yükler ve arka uç/AI modelinden alınan sonuç gösterilir.
- **Kullanıcı profili:** Firestore'da `Users/{uid}` altında profil ve premium/ hak bilgileri saklanır.
- **Yerelleştirme:** `lib/l10n/` altında İngilizce ve Türkçe çeviriler bulunur (`AppLocalizations`).
- **Çoklu platform:** Android, iOS, web, Windows, macOS ve Linux hedefleri için yapılandırılmış örnekler içerir.

Temel dosyalar ve mimari notları
--------------------------------

- `lib/view/otp/`  OTP ekranı ve `OtpViewModel` (SMS gönderme / doğrulama mantığı).
- `lib/view/register/`, `lib/view/login/`  Kayıt ve giriş ekranları (telefon odaklı).
- `lib/services/firebase_auth_service.dart`  Firebase ile düşük seviyeli etkileşimler.
- `lib/services/premium_service.dart`  Premium ve kullanım hakları ile ilgili mantık.
- `lib/l10n/`  `AppLocalizations` abstract ve diller (`app_localizations_en.dart`, `app_localizations_tr.dart`).

Kurulum (hızlı)
----------------

1. Flutter ortamınızı kurun: https://docs.flutter.dev/get-started/install
2. Depoyu klonlayın ve bağımlılıkları yükleyin:

```powershell
cd e:\projects\falcim_benim
flutter pub get
```

3. Firebase yapılandırması (platforma özel):

- Android: `android/app/google-services.json` dosyasını ekleyin ve Gradle plugin'i uygulayın.
- iOS/macOS: `ios/Runner/GoogleService-Info.plist` (ve macOS için `macos/Runner`) ekleyin.
- İsterseniz FlutterFire CLI ile `firebase_options.dart` oluşturun ve `main.dart` içinde kullanın.

Örnek başlatma (PowerShell):

```powershell
flutter clean; flutter pub get; flutter run
```

Auth ve OTP ile ilgili notlar
---------------------------

- OTP mantığı `OtpViewModel` içinde toplanmıştır; UI katmanı Firebase çağrılarını doğrudan yapmaz.
- Telefon numarası `Users/{uid}` belgesinde saklanır; kayıt sırasında OTP doğrulaması başarılı olduğunda kullanıcı dokümanı oluşturulur/güncellenir.
- Yeniden gönderme için `resendToken` kullanılır; uygulamada yeniden gönderme için zamanlayıcı (ör. 60s) uygulanmıştır.

Yerelleştirme (i18n)
--------------------

- Çeviriler `lib/l10n/app_localizations*.dart` içinde yer alır. Yeni metin eklemek için önce `app_localizations.dart` abstract sınıfına getter ekleyin, ardından `app_localizations_en.dart` ve `app_localizations_tr.dart` içine karşılıklarını yazın.

Geliştirme ipuçları
-------------------

- Kod analizi: `flutter analyze` komutunu çalıştırın ve çıkan uyarıları düzeltin.
- Mevcut görevler/öneriler:
  - `MAX_FORTUNE_SLOTS` gibi sabitleri lowerCamelCase'e çevirme.
  - `print(...)` çağrılarını kaldırma veya uygun log/Toast yöntemi ile değiştirme.
  - Gereksiz import'ları temizleme.
- Önemli: `OtpViewModel` ve Bloc/Emitter API sürüm uyumluluğunu kontrol edin; `emit` kullanımı ilgili paketin sürümüne göre değişebilir.

Katkıda bulunma
----------------

Projeye katkı yapmak isterseniz, yeni bir branch oluşturup değişikliklerinizi PR ile gönderin. Kod stili mevcut proje düzenine uyumlu olmalıdır.

İletişim / Lisans
-----------------

Bu depo örnek amaçlıdır; özel lisans bilgisi yoksa varsayılan olarak açık kaynak katkı kuralları uygulanır. Lisans eklemek isterseniz `LICENSE` dosyası ekleyin.

---

Eğer README'de eklemek istediğiniz özel bir bölüm (ör. test çalıştırma, CI, debug ipuçları) varsa söyleyin; hemen ekleyeyim.
