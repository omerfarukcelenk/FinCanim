# OneSignal Entegrasyonu - Kurulum Özeti

## ✅ Tamamlanan Adımlar

### 1. **Paket Eklendi**
   - `onesignal_flutter: ^5.0.0` → pubspec.yaml

### 2. **Android Konfigürasyonu**
   - ✅ AndroidManifest.xml'e `POST_NOTIFICATIONS` izni eklendi
   - ✅ Firebase google-services.json aynı kurulum ile çalışıyor

### 3. **iOS Konfigürasyonu**
   - ✅ Automatic entegrasyon ile kuruldu
   - ℹ️ Push sertifikası yapılandırması OneSignal dashboardında gerekli

### 4. **Flutter Kodları**
   - ✅ OneSignal service: `lib/services/onesignal_service.dart`
   - ✅ Main.dart'da initialize fonksiyonu
   - ✅ Firebase Auth Service'de auto-linking

### 5. **Özellikleri Otomasyonu**
   - ✅ Firebase UID ile OneSignal user ID'sini otomatik bağla
   - ✅ Sign-up sırasında OneSignal ID set etme
   - ✅ Sign-in sırasında OneSignal ID set etme
   - ✅ Sign-out sırasında OneSignal ID temizleme
   - ✅ Bildirim handler'ları (foreground & click)

---

## 🔧 Sonraki Adımlar (GEREKLI)

### 1. **OneSignal App ID Alın**
   ```
   1. https://onesignal.com adresine gidin
   2. Free hesap oluşturun
   3. Yeni app ekleyin
   4. Settings → Keys & IDs → ONE_SIGNAL_APP_ID'yi kopyalayın
   ```

### 2. **Main.dart'da App ID'yi Değiştirin**
   **File:** `lib/main.dart` (Satır ~56)
   ```dart
   const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
   // ↓ Değiştirin:
   const String oneSignalAppId = '12345678-1234-1234-1234-123456789012'; // Gerçek ID
   ```

### 3. **Android: Google Services Ayarı**
   ```
   1. Zaten Firebase kurulumunda var (google-services.json)
   2. OneSignal otomatik olarak aynı kurulum kullanıyor
   3. Herhangi bir ek adım YOK
   ```

### 4. **iOS: Push Sertifikası Yapılandırması**
   ```
   1. OneSignal dashboard → Platforms → iOS
   2. Apple Push Notification Sertifikası yükle
   3. İOS'ta Push capability enable et
   ```

### 5. **Test Edin**
   ```bash
   flutter pub get
   flutter run
   ```

---

## 📚 Kullanım Örnekleri

### Temel Kullanım
```dart
final oneSignalService = OneSignalService();

// Kullanıcı etiketleme (segment)
await oneSignalService.addUserTags({
  'premium': true,
  'fortune_count': 5,
  'language': 'tr',
});

// Bildirim izni kontrol
bool isSubscribed = await oneSignalService.isPushSubscribed();

// Haberden çıkma
await oneSignalService.optOutPushNotifications();

// Haberolup etiketi kaldırma
await oneSignalService.removeUserTags(['old_tag']);
```

---

## 🎯 Entegre Olmuş Sistemler

### Firebase Auth ↔ OneSignal Bağlantı
- **Sign-up** → Firebase UID'yi OneSignal'a bağla
- **Sign-in** → Firebase UID'yi OneSignal'a bağla (Google/Email)
- **Sign-out** → OneSignal ID'yi temizle

### Bildirim Handler'ları
```dart
// Ön plandaki bildirim
OneSignal.Notifications.addForegroundWillDisplayListener((event) {
  event.notification.display();
});

// Bildirime tıklandığında
OneSignal.Notifications.addClickListener((event) {
  // Tıklama işlemi burada ele alınabilir
});
```

---

## 📊 Dosyalar Değiştirildi

| Dosya | Değişiklik |
|-------|-----------|
| `pubspec.yaml` | onesignal_flutter eklendi |
| `lib/main.dart` | OneSignal initialize kodu |
| `android/app/src/main/AndroidManifest.xml` | POST_NOTIFICATIONS izni |
| `lib/services/firebase_auth_service.dart` | OneSignal bağlama kodları |
| `lib/services/onesignal_service.dart` | YENİ - OneSignal service sınıfı |

---

## ⚠️ Uyarılar

1. **App ID Değiştirmeyi Unutmayın!**
   - Şu anda `YOUR_ONESIGNAL_APP_ID` placeholder kullanıyor
   - Gerçek ID'yi eklemezseniz bildirimler çalışmaz

2. **Debug Build İçin**
   ```dart
   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
   ```
   - Tüm debug logları görünür

3. **Notification Permission (iOS)**
   - İlk başta izin istemesi otomatik
   - User `Always Allow` seçerse her zaman bildirim alır

---

## 🐛 Sorun Giderme

### Bildirimler Gelmiyorsa
```
1. OneSignal App ID doğru mu? (main.dart)
2. google-services.json android/app'te var mı?
3. AndroidManifest.xml'de POST_NOTIFICATIONS izni var mı?
4. Debug loglarında "OneSignal initialized successfully" yazıyor mu?
5. Cihazda bildirimler açık mı? (Settings → Notifications)
```

### iOS'ta Çalışmıyorsa
```
1. Push sertifikası OneSignal'da yüklü mü?
2. Xcode'da Push Capability enable mi?
3. Provisioning profile güncel mi?
4. iOS 13+ cihaz mı test ediliyor?
```

### Android Emülatör Hatası
```
- Emülatör Play Services desteğine sahip olmalı
- API 31+ kullanın
```

---

## 📞 OneSignal Yardım

- **Resmi Doküman:** https://documentation.onesignal.com/docs/flutter-sdk-setup
- **Flutter SDK:** https://pub.dev/packages/onesignal_flutter
- **Dashboard:** https://app.onesignal.com

---

## 🚀 Sonraki Aşama (Phase 2)

- Push notification templates (şablon) oluştur
- Firebase Cloud Messaging entegrasyonu
- Bildirim analytics
- Deep linking (bildirime tıklanınca app içinde yönlendir)

