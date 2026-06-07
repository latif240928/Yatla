# Remember (Yatla) — iOS Uygulaması

**GitHub:** [latif240928/Yatla](https://github.com/latif240928/Yatla)  
**Geliştirici:** Latif  
**Platform:** iOS (SwiftUI)  
**Versiyon:** 1.0  
**Son güncelleme:** Haziran 2026

---

## İçindekiler

1. [Uygulama Hakkında](#1-uygulama-hakkında)
2. [Hedef Kitle](#2-hedef-kitle)
3. [Ana Özellikler](#3-ana-özellikler)
4. [Ekranlar ve Kullanım Kılavuzu](#4-ekranlar-ve-kullanım-kılavuzu)
5. [Bildirim Sistemi](#5-bildirim-sistemi)
6. [Çok Dilli Destek (4 Dil)](#6-çok-dilli-destek-4-dil)
7. [Mimari (Clean Architecture)](#7-mimari-clean-architecture)
8. [Proje Yapısı](#8-proje-yapısı)
9. [Teknik Altyapı](#9-teknik-altyapı)
10. [Backend API Entegrasyonu](#10-backend-api-entegrasyonu)
11. [Kurulum ve Çalıştırma](#11-kurulum-ve-çalıştırma)
12. [Yapılan Değişiklikler (Changelog)](#12-yapılan-değişiklikler-changelog)
13. [Bilinen Sınırlamalar](#13-bilinen-sınırlamalar)
14. [İlgili Dokümanlar](#14-i̇lgili-dokümanlar)

---

## 1. Uygulama Hakkında

**Remember** (iç kod adı: **Yatla**, Türkmence: **Ýatla**), ekip ve departman bazlı **görev yönetimi + anlık mesajlaşma** uygulamasıdır.

Kısaca:
- Şirketler ve ekipler **departmanlara** ayrılır (Satış, IT, İnsan Kaynakları vb.)
- Yöneticiler ve ekip üyeleri **görev oluşturur**, kişilere atar, durum takibi yapar
- Ekip üyeleri **birebir** veya **departman grup sohbetinde** mesajlaşır
- Kayıt **telefon numarası + SMS doğrulama** ile yapılır (Türkmenistan odaklı: +993)
- **4 dil** desteği: Türkmence, Türkçe, İngilizce, Rusça

**Abonelik / ödeme:** Yok. Ücretsiz ekip aracı olarak konumlanır.

---

## 2. Hedef Kitle

| Özellik | Detay |
|---------|-------|
| **Ana pazar** | Türkmenistan (+993 telefon kaydı) |
| **Kullanıcı tipi** | KOBİ'ler, departmanlı şirketler, proje ekipleri |
| **Dil desteği** | Türkmence (varsayılan), Türkçe, İngilizce, Rusça |
| **Cihaz** | iPhone (mobil-first), iPad uyumlu |
| **Konumlandırma** | Slack/Asana/Trello karışımı — daha basit, SMS ile hızlı kayıt |

---

## 3. Ana Özellikler

### 3.1 Görev Yönetimi

| Özellik | Açıklama |
|---------|----------|
| Görev oluşturma | Başlık, açıklama, departman, atanan kişiler, bitiş tarihi, dosya |
| 5 durum takibi | Bekliyor, Devam ediyor, Tamamlandı, İptal, Geri gönderildi |
| Filtreleme | Departman ve duruma göre filtre |
| Görev detayı | Yorum, dosya, atanan kişi yönetimi, durum güncelleme |
| My Work sekmesi | Kullanıcının oluşturduğu görevler + yeni görev FAB |

**Görev durumları:**

| API değeri | Renk | Anlam |
|------------|------|-------|
| `waiting` | Turuncu | Bekliyor |
| `inProgress` | Mavi | Devam ediyor |
| `completed` | Yeşil | Tamamlandı |
| `cancelled` | Kırmızı | İptal edildi |
| `returned` | Kırmızı | Geri gönderildi |

> API'de durum değerleri **camelCase** (`inProgress`) formatındadır.

### 3.2 Kullanıcı Yönetimi

- Departman bazlı kullanıcı listesi
- Kullanıcı arama
- Davet gönderme (task offer)
- Gelen davetleri kabul / reddetme
- Kullanıcı silme (yetkili kullanıcılar için)

### 3.3 Mesajlaşma (Chat)

- **Birebir (Private)** sohbetler
- **Grup (Groups)** sohbetleri — departman bazlı
- Mesaj gönderme, medya paylaşımı
- Departman filtresi ve arama
- Sohbet detayında sekme çubuğu otomatik gizlenir (tam ekran deneyim)

### 3.4 Bildirimler

- Uygulama içi bildirim listesi
- Zil ikonu + okunmamış rozeti (Görevler sekmesi)
- Ayarlar → Bildirimler menüsü
- Bildirim türüne göre açma/kapama
- Push bildirim desteği (APNs)
- 4 dilde bildirim metinleri

### 3.5 Ayarlar

| Alt ekran | Özellikler |
|-----------|------------|
| **Profil** | Ad/avatar düzenleme, telefon (salt okunur), biyometrik şifre gösterme |
| **İstatistikler** | Gerçek görev verilerinden tamamlanma oranı, günlük/haftalık grafikler |
| **Dil** | 4 dil seçimi (Türkmence, Türkçe, İngilizce, Rusça) |
| **Tema** | Karanlık / aydınlık mod |
| **Bildirimler** | Bildirim listesi + ayar toggles |
| **Çıkış** | Oturumu kapat |

### 3.6 Kimlik Doğrulama

```
Splash → Kayıt (telefon + OTP) → Hesap kurulumu → Ana ekran
       → Giriş (telefon + şifre) → Ana ekran
```

- SMS ile 4 haneli OTP doğrulama
- JWT token (Keychain'de saklanır)
- Otomatik token yenileme (401 → refresh)
- Gizlilik politikası onayı (4 dilde)

---

## 4. Ekranlar ve Kullanım Kılavuzu

### 4.1 Uygulama Akışı

```
┌─────────┐     ┌──────────────┐     ┌─────────────┐
│ Splash  │ ──► │ Auth Stack   │ ──► │  Home (5 tab)│
│ (0.8 sn)│     │ veya direkt  │     │             │
└─────────┘     └──────────────┘     └─────────────┘
                      ▲
                      │ Token varsa (Keychain)
```

### 4.2 Alt Sekmeler (5 Tab)

| Sekme | İkon | Ekran | Ne yapılır? |
|-------|------|-------|-------------|
| **Görevler** | clipboard | Ana görev listesi | Tüm görevleri gör, filtrele, detaya git, bildirim zili |
| **My Work** | plus.square | Oluşturduğun görevler | Kendi görevlerini gör, + ile yeni görev oluştur |
| **Users** | person.2 | Kullanıcılar + Davetler | Ekip üyelerini gör, davet gönder, davetleri yönet |
| **Chats** | bubbles | Sohbetler | Birebir ve grup mesajlaşma |
| **Settings** | gear | Ayarlar | Profil, istatistik, dil, tema, bildirimler, çıkış |

### 4.3 Görev Oluşturma (My Work → +)

1. **My Work** sekmesine git
2. Sağ alttaki **+** butonuna bas
3. Formu doldur:
   - Görev adı (zorunlu)
   - Açıklama (isteğe bağlı)
   - Departman seç (zorunlu)
   - Atanan kişiler (departmana göre zorunlu/isteğe bağlı)
   - Bitiş tarihi ve saati (isteğe bağlı)
   - Dosya ekle (isteğe bağlı)
4. **Gönder** — görev oluşturulur ve bildirim gelir

### 4.4 Kullanıcı Davet Etme

1. **Users** sekmesine git
2. **Invitations** alt sekmesine geç
3. Kullanıcı seç → **Davet gönder**
4. Karşı tarafa bildirim gider

### 4.5 Sohbet Başlatma

1. **Chats** sekmesine git
2. **Private** veya **Groups** alt sekmesini seç
3. Departman filtresi veya arama ile kişi/grup bul
4. Sohbete tıkla → mesaj yaz

### 4.6 Dil Değiştirme

1. **Settings** → **Language**
2. TM / TR / EN / RU seç
3. Tüm uygulama anında seçilen dile geçer

---

## 5. Bildirim Sistemi

### 5.1 Bildirimlere Nereden Ulaşılır?

| Yer | Açıklama |
|-----|----------|
| **Görevler sekmesi — sağ üst zil** | Okunmamış sayı rozeti ile bildirim listesi (sheet) |
| **Settings → Bildirimler** | Aynı bildirim listesi + ayarlar |

### 5.2 Bildirim Türleri

| Tür | Ne zaman? | Örnek (TR) |
|-----|-----------|------------|
| `task_created` | Görev oluşturuldu | "Görev oluşturuldu" |
| `task_sent` | Görev gönderildi/atandı | "Görev gönderildi" |
| `task_assigned` | Size görev atandı | "Size yeni görev atandı" |
| `task_accepted` | Göreviniz kabul edildi | "Göreviniz kabul edildi" |
| `task_status_changed` | Durum güncellendi | "Görev durumu değişti" |
| `invitation_sent` | Davet gönderildi | "Davet gönderildi" |
| `offer_received` | Size davet geldi | "Yeni davet" |
| `task_comment_added` | Yorum eklendi | API'den |
| `task_file_uploaded` | Dosya yüklendi | API'den |
| `task_due_soon` / `task_overdue` | Hatırlatma | API'den |
| `chat_message` | Yeni mesaj | API'den |

### 5.3 Bildirim Ayarları

Settings → Bildirimler → ⚙️ menüsünden açılır/kapanır:

- Yeni görevler
- Görev durumu
- Yorumlar
- Dosya yüklemeleri
- Hatırlatmalar
- Davetler
- Sohbet mesajları

### 5.4 Mimari

```
Olay (görev oluştur, davet gönder, vb.)
    ↓
CreateInAppNotificationUseCase
    ↓ (ayar kontrolü)
HybridNotificationRepository
    ├── LocalNotificationRepository (UserDefaults — offline)
    └── APINotificationRepository (sunucu — hazır olduğunda)
    ↓
NotificationsBadgeStore (okunmamış sayı)
    ↓
NotificationService (sistem banner'ı)
```

### 5.5 Otomatik Tetiklenen Bildirimler

| Olay | Dosya |
|------|-------|
| Görev oluşturma / gönderme | `CreateTaskViewModel.swift` |
| Davet gönderme | `UsersViewModel.swift` |
| Teklif kabul | `UsersViewModel.swift` |
| Görev durumu değişimi | `HomeViewModel.swift` |

---

## 6. Çok Dilli Destek (4 Dil)

| Kod | Dil | Bayrak | Varsayılan |
|-----|-----|--------|------------|
| `tk` | Türkmence | 🇹🇲 | **Evet** |
| `tr` | Türkçe | 🇹🇷 | |
| `en` | İngilizce | 🇬🇧 | |
| `ru` | Rusça | 🇷🇺 | |

### Nasıl çalışır?

- Merkezi `L10n.swift` dosyasında **~150+ anahtar**, her biri 4 dilde
- `.strings` dosyası **kullanılmaz** — tüm çeviriler Swift enum içinde
- Kullanım: `L10n.string(.tabHome, language: lang)`
- Bildirim metinleri: `NotificationTexts.swift` helper'ı
- Dil adları seçili dile göre gösterilir (`localizedDisplayName(in:)`)
- İlk açılış dili: **Türkmence**
- Dil `UserDefaults` ile kalıcı saklanır

### Yeni metin ekleme

```swift
// 1. L10n.Key enum'a ekle
case myNewKey

// 2. table sözlüğüne 4 çeviri ekle
.myNewKey: [
    .turkmen: "Türkmen metin",
    .turkish: "Türkçe metin",
    .english: "English text",
    .russian: "Русский текст"
]

// 3. View'da kullan
Text(L10n.string(.myNewKey, language: lang))
```

---

## 7. Mimari (Clean Architecture)

```
┌─────────────────────────────────────────┐
│              UI Layer                    │
│  SwiftUI Views + ViewModels (MVVM)       │
│  HomeView, ChatsView, SettingsView...    │
└─────────────────┬───────────────────────┘
                  │ use cases çağırır
┌─────────────────▼───────────────────────┐
│            Domain Layer                  │
│  Entities, Repository Protocols,         │
│  Use Cases (iş kuralları)                │
└─────────────────┬───────────────────────┘
                  │ protocol implementasyonu
┌─────────────────▼───────────────────────┐
│             Data Layer                   │
│  DTOs, Mappers, NetworkService,          │
│  *RepositoryAPI, Local repos             │
└─────────────────────────────────────────┘
```

### Bağımlılık Enjeksiyonu

- `DIContainer.shared` — tek DI merkezi (`@MainActor ObservableObject`)
- `.environmentObject(container)` ile tüm view'lara enjekte edilir
- ViewModel'ler use case'leri `DIContainer.shared` üzerinden çağırır

### Katman detayları

| Katman | İçerik |
|--------|--------|
| **Domain/Entities** | `TaskItem`, `User`, `Department`, `ChatMessage`, `AppNotification`, `Language` |
| **Domain/Repositories** | `AuthRepository`, `TaskRepository`, `UserRepository`, `ChatRepository`, `NotificationRepository` |
| **Domain/UseCases** | `LoginUseCase`, `CreateTaskUseCase`, `GetChatsUseCase`, `CreateInAppNotificationUseCase` |
| **Data/Network** | `NetworkService` (JWT, auto-refresh, 401 handling) |
| **Data/RepositoryImpl** | `*RepositoryAPI.swift`, `HybridNotificationRepository`, `LocalSettingsRepository` |
| **UI/Features** | Auth, Home (5 tab), Settings, Notifications |
| **UI/Components** | ~35 yeniden kullanılabilir bileşen |
| **UI/DesignSystem** | `AppColors`, `AppFonts`, `AppShape` |

---

## 8. Proje Yapısı

```
remember-iOS/
├── Remember.xcodeproj/              # Xcode projesi
├── Remember/Remember/               # Ana uygulama kaynak kodu
│   ├── App/
│   │   └── RememberApp.swift        # @main YatlaApp + AppDelegate
│   ├── Core/
│   │   ├── DI/DIContainer.swift
│   │   ├── Router/AppRouter.swift, RootView.swift
│   │   ├── Localization/L10n.swift, NotificationTexts.swift
│   │   ├── Services/BiometricAuthService, NotificationsBadgeStore
│   │   └── Utils/LocalImageCache, StatsBuilder
│   ├── Domain/
│   │   ├── Entities/
│   │   ├── Repositories/
│   │   └── UseCases/
│   ├── Data/
│   │   ├── Network/NetworkService.swift
│   │   ├── DTO/
│   │   ├── Mappers/
│   │   └── RepositoryImpl/
│   ├── UI/
│   │   ├── DesignSystem/
│   │   ├── Components/
│   │   └── Features/
│   │       ├── Auth/                  # Splash, Registration, SMS, SignIn
│   │       └── Home/                  # 5 tab + alt ekranlar
│   └── Info.plist
├── docs/                              # Backend API dokümanları
│   ├── BACKEND_API_CONTRACT.md
│   ├── BACKEND_DEVELOPER_README.md
│   └── API_TESTING.md
├── README.md                          # Bu dosya
└── (diğer brifing dosyaları)
```

---

## 9. Teknik Altyapı

| Kategori | Teknoloji |
|----------|-----------|
| Dil | Swift 5.0 |
| UI Framework | SwiftUI |
| Mimari | Clean Architecture + MVVM |
| DI | Manuel singleton (`DIContainer`) |
| Networking | URLSession (`NetworkService`) |
| Auth depolama | Keychain (`KeychainService`) |
| Yerel ayarlar | UserDefaults (tema, dil) |
| Push bildirim | UserNotifications + APNs |
| Biyometrik | LocalAuthentication (Face ID / Touch ID) |
| Görsel önbellek | `LocalImageCache` (NSCache + arka plan decode) |
| Backend | FastAPI REST API (`/api/v1`) |
| JSON | snake_case → camelCase otomatik dönüşüm |
| Responsive | `LayoutReader` / `LayoutMetrics` |
| Font | Aestetico (özel font) |
| Bundle ID | `Latif.Remember` |

---

## 10. Backend API Entegrasyonu

### Ortam yapılandırması (`Info.plist`)

```xml
<key>API_ENV</key>
<string>remote</string>   <!-- local | remote | development | staging | production -->

<key>API_BASE_URL</key>
<string>https://yatla-global.duckdns.org/api/v1</string>
```

### Ortamlar

| Ortam | Base URL |
|-------|----------|
| local | `http://localhost:8000/api/v1` |
| remote | `https://yatla-global.duckdns.org/api/v1` |
| development | `https://dev-api.remember.com/api/v1` |
| staging | `https://staging-api.remember.com/api/v1` |
| production | `https://api.remember.com/api/v1` |

### Auth akışı

```
POST /auth/send-otp
  → POST /auth/verify-otp (temp token)
    → POST /auth/register (yeni kullanıcı)
    → POST /auth/login (mevcut kullanıcı)
      → GET /users/me
Token yenileme: POST /auth/refresh (401 durumunda otomatik)
```

### Ana API grupları

| Domain | Endpoint'ler |
|--------|-------------|
| **Auth** | send-otp, verify-otp, register, login, refresh |
| **Users** | list, me, search, stats, update, delete |
| **Tasks** | CRUD, status, assignees, comments, files |
| **Departments** | list, create, get, delete |
| **Chats** | direct, group, messages, read/mute |
| **Notifications** | Hybrid (local + API stub) |
| **WebSocket** | `wss://…/ws/chat/{chat_id}` (planlanan) |

### Debug aracı

DEBUG build'lerde sağ üstte **DebugAPIBadge** görünür:
- Ortam adı (LOCAL / REMOTE)
- Yeşil/kırmızı sağlık noktası (`/health` kontrolü)
- Tıklayınca base URL detayı

---

## 11. Kurulum ve Çalıştırma

### Gereksinimler

- macOS + **Xcode** (iOS SDK)
- iPhone Simulator veya fiziksel cihaz
- İsteğe bağlı: yerel FastAPI backend (port 8000)

### Adımlar

```bash
# 1. Repoyu klonla
git clone https://github.com/latif240928/Yatla.git
cd Yatla

# 2. Xcode'da aç
open Remember.xcodeproj

# 3. Scheme: "Remember" seç
# 4. Destination: iPhone Simulator
# 5. Run (⌘R)
```

### Backend sağlık kontrolü

```bash
# Uzak sunucu
curl -i https://yatla-global.duckdns.org/health

# Yerel backend
curl -i http://localhost:8000/health
```

### Yerel backend için

`Remember/Remember/Info.plist` içinde:
- `API_ENV` = `local`
- Veya `API_BASE_URL` = arkadaşının LAN IP'si

---

## 12. Yapılan Değişiklikler (Changelog)

### Bildirim Sistemi (Haziran 2026)

- Uygulama içi bildirim altyapısı eklendi (Clean Architecture uyumlu)
- `HybridNotificationRepository` — API + yerel depo birleşimi
- `CreateInAppNotificationUseCase` — olay bazlı bildirim oluşturma
- `NotificationsBadgeStore` — okunmamış sayı rozeti
- `NotificationTexts.swift` — 4 dilde bildirim metinleri
- UI: `NotificationsView`, `NotificationRow`, `NotificationBellButton`
- Görevler sekmesi app bar'a zil ikonu + kırmızı rozet
- Settings'e "Bildirimler" navigasyon linki
- Bildirim ayarları (tür bazlı açma/kapama)
- Otomatik tetikleyiciler: görev oluşturma, gönderme, kabul, davet, durum değişimi

### UI/UX İyileştirmeleri

**CreateTask / My Work:**
- Atanan kişiler ve tarih/saat alanları mavi tint kaldırıldı — diğer alanlarla uyumlu
- Tarih/saat picker'ları yuvarlatılmış kart içine alındı
- Departman sheet arama alanı stili düzeltildi

**Users:**
- "Ähli bölümler" → 4 dilde lokalize (`L10n.chatsAllDepartments`)
- Arama bug'ı düzeltildi (`searchText` → `viewModel.searchQuery`)
- Departman seçimi Chats ile birleştirildi (`Department?` binding)

**Chats:**
- Çift sheet bug'ı düzeltildi (sheet `NavigationStack` dışına taşındı)
- `.medium` detent, Users ile aynı pattern
- Departman→kullanıcı haritası önbelleklendi
- Paralel `loadAll()` — daha hızlı yükleme

**Settings:**
- Profil: biyometrik şifre gösterme (`BiometricAuthService`)
- İstatistikler: gerçek görev verilerinden hesaplanır (`StatsBuilder`)
- Dil adları seçili dile göre gösterilir
- Kart köşe yarıçapları modernleştirildi (`AppShape.tabBar`)

**Auth:**
- Splash süresi 2s → 0.8s
- Gizlilik politikası sheet'i (4 dilde)
- Tüm auth ekranları paylaşımlı `AuthScreenScaffold`

**Home:**
- Tab bar `safeAreaInset` ile — sohbet detayında siyah şerit sorunu çözüldü
- `LazyVStack` / `LazyVGrid` ile performanslı liste

### Performans Optimizasyonları

| Optimizasyon | Uygulama |
|-------------|----------|
| Avatar yükleme | `LocalImageCache` + `CachedAvatarView` — arka plan I/O, NSCache |
| Settings profil | Senkron `Data(contentsOf:)` kaldırıldı |
| Users sekmesi | Paralel dept/user/offer yükleme; stats prefetch |
| Chats sekmesi | `usersByDepartmentId` önbellek |
| İstatistikler | `StatsBuilder` — sahte veri yok |
| Splash | 0.8s minimum gösterim |

### Temizlik

- Gereksiz dosyalar silindi (DerivedData, boş test scaffold'ları, ölü Swift stub'ları)
- App içi `.md` dosyaları `docs/` klasörüne taşındı
- `Info.plist` duplicate bundle hatası düzeltildi

---

## 13. Bilinen Sınırlamalar

| Konu | Durum |
|------|-------|
| Bildirim API endpoint'leri | Backend'de henüz OpenAPI'de yok — hybrid local+stub |
| WebSocket chat | URL tanımlı, backend entegrasyonu bekliyor |
| Task offer API | Client-side repo var, backend endpoint eksik |
| Sohbet mesajı bildirimi | Henüz otomatik tetiklenmiyor |
| Görev hatırlatmaları | `scheduleTaskReminder` var ama görev oluşturmaya bağlı değil |
| Eski bildirimler | Dil değişince eski bildirimler eski dilde kalır |
| Push navigation | Bildirime tıklayınca görev detayına yönlendirme TODO |

---

## 14. İlgili Dokümanlar

| Dosya | Açıklama |
|-------|----------|
| [`docs/BACKEND_API_CONTRACT.md`](docs/BACKEND_API_CONTRACT.md) | REST API sözleşmesi (auth, users, tasks, chats) |
| [`docs/BACKEND_DEVELOPER_README.md`](docs/BACKEND_DEVELOPER_README.md) | Backend geliştirici rehberi |
| [`docs/API_TESTING.md`](docs/API_TESTING.md) | iOS simulator API test kılavuzu |
| [`WEB_DEVELOPER_BRIEF.md`](WEB_DEVELOPER_BRIEF.md) | Tanıtım sitesi + admin panel brifingi |
| [`ADMIN_BACKEND_SPEC.md`](ADMIN_BACKEND_SPEC.md) | Admin panel backend spesifikasyonu |
| [`ADMIN_PANEL_REHBERI.md`](ADMIN_PANEL_REHBERI.md) | Admin panel rehberi (TR) |

---

## Lisans

Bu proje şu an özel geliştirme aşamasındadır. Lisans bilgisi eklenecektir.

---

**Remember (Yatla)** — Ekip görev yönetimi ve mesajlaşma, 4 dilde, iOS native.
