# Remember (Yatla) — Web Geliştirici Proje Brifingi

**Hazırlayan:** Latif  
**Tarih:** 24 Mayıs 2026  
**Amaç:** Bu doküman, Remember iOS uygulamasının tanıtım web sitesi ve admin panelinin geliştirilmesi için hazırlanmıştır.

---

## İçindekiler

1. [Uygulama Nedir?](#1-uygulama-nedir)
2. [Hedef Kitle ve Konumlandırma](#2-hedef-kitle-ve-konumlandırma)
3. [Ana Özellikler (Detaylı)](#3-ana-özellikler-detaylı)
4. [Kullanıcı Akışları](#4-kullanıcı-akışları)
5. [Uygulama Ekranları ve Sekmeler](#5-uygulama-ekranları-ve-sekmeler)
6. [Veri Modelleri](#6-veri-modelleri)
7. [Kimlik Doğrulama (Auth)](#7-kimlik-doğrulama-auth)
8. [Backend API Özeti](#8-backend-api-özeti)
9. [Admin Panel — Ne Yapılmalı?](#9-admin-panel--ne-yapılmalı)
10. [Tanıtım Web Sitesi — Ne Yapılmalı?](#10-tanıtım-web-sitesi--ne-yapılmalı)
11. [Teknik Altyapı](#11-teknik-altyapı)
12. [Tasarım ve Marka Notları](#12-tasarım-ve-marka-notları)
13. [Hazır Olan vs Planlanan](#13-hazır-olan-vs-planlanan)
14. [Referans Dosyalar](#14-referans-dosyalar)
15. [Sık Sorulan Sorular](#15-sık-sorulan-sorular)

---

## 1. Uygulama Nedir?

**Remember** (iç kod adı: **Yatla**), ekip ve departman bazlı **görev yönetimi + anlık mesajlaşma** uygulamasıdır.

Kısaca:
- Bir şirket veya ekip, departmanlara ayrılır (ör. Satış, IT, İnsan Kaynakları).
- Yöneticiler veya ekip üyeleri görev oluşturur, kişilere atar, durum takibi yapar.
- Ekip üyeleri birbirleriyle birebir veya departman grup sohbetinde mesajlaşır.
- Kayıt telefon numarası + SMS doğrulama ile yapılır (Türkmenistan odaklı: +993).

**Platform:** Şu an yalnızca **iOS native** (SwiftUI). Web sitesi ve admin paneli sıfırdan geliştirilecek; backend REST API zaten mevcut.

**Abonelik / ödeme:** Yok. Uygulama ücretsiz ekip aracı olarak konumlanıyor.

---

## 2. Hedef Kitle ve Konumlandırma

| Özellik | Detay |
|---------|-------|
| **Ana pazar** | Türkmenistan (telefon kaydı +993 ile başlar) |
| **Kullanıcı tipi** | KOBİ'ler, departmanlı şirketler, proje ekipleri |
| **Dil desteği** | Türkmence (ana), Türkçe, İngilizce, Rusça |
| **Cihaz** | iPhone (mobil-first) |
| **Rakip konumlandırma** | Slack/Asana/Trello karışımı ama daha basit, SMS ile hızlı kayıt |

### Tanıtım sitesinde vurgulanacak mesajlar

1. **Ekip görev yönetimi** — departman bazlı atama, 5 durum takibi, yorum ve dosya ekleme
2. **Entegre mesajlaşma** — birebir DM + departman grup chat
3. **SMS ile hızlı kayıt** — telefon doğrulama, şifreli giriş
4. **Çok dilli** — 4 dil desteği
5. **Karanlık / aydınlık mod**
6. **Mobil-first** — iOS native deneyim

---

## 3. Ana Özellikler (Detaylı)

### 3.1 Görev Yönetimi

Görevler uygulamanın çekirdeğidir.

**Görev oluşturma alanları:**
| Alan | Zorunlu | Açıklama |
|------|---------|----------|
| Başlık (title) | Evet | Görev adı |
| Açıklama (description / mazmuny) | Hayır | Detaylı içerik |
| Departman | Evet | Hangi departmana ait |
| Atanan kişiler (assignees) | Şartlı | "Şahsy" (kişisel) departmanında zorunlu değil; diğerlerinde zorunlu |
| Bitiş tarihi ve saati | Hayır | Due date |
| Dosyalar | Hayır | PDF, resim vb. (URL olarak kaydedilir) |

**Görev durumları (5 adet):**

| API değeri | Türkmence | Renk (hex) | Anlam |
|------------|-----------|------------|-------|
| `waiting` | Garaşylýar | #F59E0B (turuncu) | Bekliyor |
| `inProgress` | Ýerine ýetirilýär | #3B82F6 (mavi) | Devam ediyor |
| `completed` | Tamamlandy | #10B981 (yeşil) | Tamamlandı |
| `cancelled` | Ýatyryldy | #EF4444 (kırmızı) | İptal edildi |
| `returned` | Yzyna gaýtaryldy | #EF4444 (kırmızı) | Geri gönderildi |

> **Önemli:** API'de durum değerleri **camelCase** (`inProgress`), snake_case değil.

**Görev detay ekranında yapılabilenler:**
- Durum güncelleme
- Yorum ekleme / okuma
- Dosya ekleme / görüntüleme
- Atanan kişi ekleme / çıkarma
- Görevi geri gönderme (returned) — yorum zorunlu
- Görev numarası (#42 gibi) otomatik atanır

**Filtreleme:**
- Departmana göre
- Duruma göre
- Ana sayfada kullanıcının oluşturduğu veya atandığı görevler listelenir

---

### 3.2 Departmanlar

Departmanlar organizasyon yapısını temsil eder.

| Özellik | Detay |
|---------|-------|
| CRUD | Oluştur, listele, sil (API mevcut) |
| Özel departman | `"sahsy"` (id) = **Şahsy** (Kişisel) — bireysel görevler için |
| Grup sohbet | Her departmanın otomatik bir grup sohbeti vardır |
| Kullanıcı bağlantısı | Kullanıcılar bir veya birden fazla departmana bağlı olabilir |

---

### 3.3 Kullanıcı Yönetimi

| Özellik | Detay |
|---------|-------|
| Kayıt | SMS OTP → ad + şifre |
| Giriş | Telefon + şifre |
| Profil | Ad, telefon, avatar URL, departmanlar |
| Arama | İsim veya telefon ile |
| Filtre | Departmana göre kullanıcı listesi |
| Silme | Kullanıcı silinebilir (onay dialogu ile) |
| Admin flag | `is_admin: true/false` — backend'de var, iOS'ta henüz kullanılmıyor |

**Parola kuralları (kayıt):**
- Minimum 8 karakter
- En az 1 büyük harf
- En az 2 rakam

---

### 3.4 Mesajlaşma (Chat)

#### Birebir (Direct Message)
- Kullanıcı listesinden veya profilden DM başlatılır
- Mesaj geçmişi, okundu bilgisi, okunmamış sayacı
- Sessize alma (mute) / sessizden çıkarma
- Sohbet silme

#### Grup Sohbeti (Departman)
- Her departmanın bir grup sohbeti vardır
- Departman üyeleri grup mesajlarını görür
- Son mesaj önizlemesi ve okunmamış sayacı

#### UI'da var, backend'de sınırlı olanlar
- Fotoğraf / dosya eki (UI hazır, API yalnızca `text` kabul ediyor)
- Medya galerisi görünümü
- Sesli/görüntülü arama overlay (sadece UI mock, gerçek VoIP yok)
- WebSocket realtime (planlanmış, henüz bağlanmamış)

**Mesaj limiti:** Maksimum 5000 karakter.

---

### 3.5 Görev Teklifleri (Task Offers)

Bir kullanıcı başka birine görev teklif edebilir; alıcı kabul veya red eder.

| Durum | Açıklama |
|-------|----------|
| `pending` | Bekliyor |
| `accepted` | Kabul edildi → görev listesine eklenir |
| `rejected` | Reddedildi |

> **Durum:** iOS UI tamamen hazır. Backend API henüz yok (mock/stub). Admin paneli ve web sitesi için "yakında" veya gizlenebilir.

---

### 3.6 Bildirimler (Push Notifications)

iOS tarafında Apple Push Notification (APNs) altyapısı hazır.

**Bildirim tipleri:**
- Görev atandı
- Görev durumu değişti
- Göreve yorum eklendi
- Göreve dosya yüklendi
- Görev süresi yaklaşıyor
- Görev süresi geçti
- Görev teklifi alındı / kabul / red
- Chat mesajı

**Kullanıcı tercihleri:** Her bildirim tipi ayrı ayrı açılıp kapatılabilir.

> **Durum:** iOS endpoint'leri kodda var; OpenAPI spec'te henüz tanımlı değil. Backend eklenince admin panelden yönetilebilir.

---

### 3.7 İstatistik Panosu (Stats)

Ayarlar bölümünde zengin bir dashboard var:

| Metrik | Açıklama |
|--------|----------|
| Toplam görev | |
| Tamamlanan / devam eden / iptal / geri gönderilen | |
| Başarı oranı (%) | |
| Toplam kullanıcı | |
| Günlük tamamlanan görevler | Grafik |
| Saatlik verimlilik | En verimli saatler |
| Haftanın günleri | Hangi gün daha çok iş bitiriliyor |
| Haftalık karşılaştırma | Bu hafta vs geçen hafta |
| Uzun bekleyen görevler | 7+ gün bekleyenler |

> **Durum:** iOS'ta UI hazır ama veriler şu an **mock (sahte)**. Admin paneli için backend'de global stats API'si tasarlanmalı.

---

### 3.8 Ayarlar

| Bölüm | Detay |
|-------|-------|
| Profil düzenleme | Ad, telefon, avatar (avatar upload TODO) |
| İstatistikler | Dashboard (mock) |
| Dil seçimi | tk / tr / en / ru |
| Tema | Karanlık / aydınlık mod |
| Çıkış | Token temizleme + auth ekranına dönüş |

---

## 4. Kullanıcı Akışları

### 4.1 İlk Kayıt (Yeni Kullanıcı)

```
Splash (2 sn logo)
  → Telefon numarası gir (+993...)
  → SMS kodu gönder (POST /auth/send-otp)
  → 4 haneli OTP gir (120 sn geri sayım, yeniden gönder)
  → OTP doğrula (POST /auth/verify-otp) → geçici token
  → Ad + şifre belirle (min 8, 1 büyük harf, 2 rakam)
  → Kayıt ol (POST /auth/register) → access + refresh token
  → Profil yükle (GET /users/me)
  → Ana sayfa (Home)
```

### 4.2 Giriş (Mevcut Kullanıcı)

```
Splash
  → "Hesabım var" → Telefon + şifre
  → Giriş (POST /auth/login) → tokenlar
  → GET /users/me → Ana sayfa
```

### 4.3 Otomatik Giriş

```
Splash → Keychain'de access token var mı?
  → Evet → direkt Ana sayfa
  → Hayır → Kayıt ekranı
```

### 4.4 Görev Oluşturma

```
"Görevlerim" sekmesi → Yeni görev (+)
  → Departman seç
  → Başlık + açıklama yaz
  → Atanan kişileri seç (Şahsy hariç zorunlu)
  → Bitiş tarihi/saati seç
  → Dosya ekle (opsiyonel)
  → Kaydet (POST /tasks)
  → Ana sayfaya yönlendir
```

### 4.5 Görev Takibi

```
Ana sayfa → Görev kartına tıkla
  → Detay sheet açılır
  → Durum değiştir / yorum ekle / dosya ekle
  → Atanan kişi onay akışı ("Barlanmaly işler" bölümü)
```

### 4.6 Mesajlaşma

```
Sohbetler sekmesi
  → Birebir: Kullanıcı seç → DM başlat
  → Grup: Departman seç → grup sohbeti aç
  → Mesaj yaz → gönder
  → Mute / sil / profil görüntüle
```

---

## 5. Uygulama Ekranları ve Sekmeler

Alt navigasyon 5 sekmeden oluşur:

| # | Sekme | İkon | Türkmence | İşlev |
|---|-------|------|-----------|-------|
| 0 | Ana Sayfa | list.clipboard | Ýumuşlar | Görev listesi + filtreler |
| 1 | Görevlerim | plus.square | Meniň işlerim | Görev oluşturma + kendi görevlerin |
| 2 | Kullanıcılar | person.2 | Ulanyjylar | Kullanıcı dizini + davetler |
| 3 | Sohbetler | bubble | Söhbetler | DM + grup chat |
| 4 | Ayarlar | gearshape | Sazlamalar | Profil, dil, tema, istatistik, çıkış |

### Auth ekranları (giriş öncesi)
- Splash (logo animasyonu)
- Kayıt (telefon + ülke kodu seçici)
- SMS doğrulama (4 haneli kod)
- Hesap kurulumu (ad + şifre)
- Giriş (telefon + şifre)

---

## 6. Veri Modelleri

### User (Kullanıcı)
```json
{
  "id": "uuid",
  "name": "Jane Doe",
  "phone": "+99361000001",
  "avatar_url": "https://...",
  "is_admin": false,
  "department_ids": ["dept-1", "sahsy"],
  "created_at": "2024-01-01T10:00:00Z"
}
```

### TaskItem (Görev)
```json
{
  "id": "uuid",
  "title": "UI yenileme",
  "description": "Login ekranı",
  "status": "inProgress",
  "department_id": "dept-1",
  "creator_id": "user-1",
  "number": 42,
  "assignee_ids": ["user-2", "user-3"],
  "due_date": "2026-05-15T17:00:00Z",
  "created_at": "2026-05-10T09:00:00Z",
  "updated_at": "2026-05-10T11:30:00Z"
}
```

### Department (Departman)
```json
{
  "id": "dept-1",
  "name": "Satış",
  "created_at": "2024-01-01T10:00:00Z"
}
```

### Chat (Birebir Sohbet)
```json
{
  "id": "chat-1",
  "participant_id": "user-2",
  "is_muted": false,
  "last_message": { "id": "...", "sender_id": "...", "text": "Merhaba", "sent_at": "...", "is_read": false },
  "unread_count": 3
}
```

### GroupChat (Grup Sohbet)
```json
{
  "id": "g1",
  "department_id": "dept-1",
  "last_message": { ... },
  "unread_count": 0
}
```

### ChatMessage (Mesaj)
```json
{
  "id": "msg-1",
  "sender_id": "user-2",
  "text": "Hello!",
  "sent_at": "2026-05-10T18:30:00Z",
  "is_read": false
}
```

### UserTaskStats (Kullanıcı İstatistikleri)
```json
{
  "user_id": "...",
  "assigned_task_count": 7,
  "completed_task_count": 3,
  "pending_task_count": 4
}
```

---

## 7. Kimlik Doğrulama (Auth)

### Akış özeti

| Adım | Endpoint | Auth gerekli? |
|------|----------|---------------|
| OTP gönder | `POST /auth/send-otp` | Hayır |
| OTP doğrula | `POST /auth/verify-otp` | Hayır → `temp_token` döner |
| Kayıt | `POST /auth/register` | Hayır → `temp_token` gerekli |
| Giriş | `POST /auth/login` | Hayır |
| Token yenile | `POST /auth/refresh` | Hayır → `refresh_token` gerekli |
| Profil | `GET /users/me` | Evet (Bearer JWT) |

### Token yönetimi
- **access_token:** Tüm korumalı API çağrılarında `Authorization: Bearer <token>`
- **refresh_token:** access_token süresi dolunca yenileme
- **temp_token:** Sadece kayıt adımında kullanılır, kalıcı token değildir
- 401 hatası → otomatik refresh → başarısızsa logout

### Admin paneli auth önerisi
- Aynı `/auth/login` endpoint'i kullanılabilir
- Giriş sonrası `GET /users/me` → `is_admin: true` kontrolü
- Admin olmayan kullanıcılar panele erişememeli
- Backend'de admin-only endpoint'ler ayrıca korunmalı (henüz yok, tasarlanmalı)

---

## 8. Backend API Özeti

### Base URL'ler

| Ortam | URL |
|-------|-----|
| **Aktif (remote)** | `https://yatla-global.duckdns.org/api/v1` |
| Local | `http://localhost:8000/api/v1` |
| Development | `https://dev-api.remember.com/api/v1` |
| Staging | `https://staging-api.remember.com/api/v1` |
| Production | `https://api.remember.com/api/v1` |

**Health check:** `GET /health` (prefix dışında)

**Backend:** FastAPI (Python), OpenAPI 3.1 spec mevcut.

### Endpoint grupları

#### Auth (5 endpoint)
`send-otp`, `verify-otp`, `register`, `login`, `refresh`

#### Users (9 endpoint)
Listele, ara, departmana göre, me, stats, CRUD

#### Tasks (12 endpoint)
CRUD, durum güncelle, assignee ekle/çıkar, yorum, dosya

#### Departments (4 endpoint)
Listele, oluştur, getir, sil

#### Chats (12 endpoint)
Birebir + grup: listele, mesaj gönder/al, okundu, mute, sil

### API konvansiyonları
- JSON alan adları: **snake_case** (`department_id`, `created_at`)
- Tarihler: ISO-8601 (`2026-05-10T18:30:00Z`)
- Task status: **camelCase** (`inProgress`)
- Hata formatı: FastAPI `HTTPValidationError` (422)
- Pagination: `skip` + `limit` query parametreleri (default: 0, 50)

### OpenAPI'de OLMAYAN ama iOS'ta kodlanmış endpoint'ler

| Endpoint | Durum |
|----------|-------|
| `/notifications/*` | iOS hazır, backend TODO |
| `/devices/register` | Push token kaydı, backend TODO |
| `/users/{id}/notification-settings` | Bildirim tercihleri, backend TODO |
| `/task-offers/*` | Görev teklifleri, backend TODO |
| WebSocket `wss://.../ws/chat/{id}` | Realtime chat, planlanmış |

---

## 9. Admin Panel — Ne Yapılmalı?

Admin paneli sıfırdan geliştirilecek. Mevcut backend API'leri kullanılabilir; bazı yeni endpoint'ler gerekebilir.

### Önerilen modüller

#### 9.1 Dashboard (Ana Sayfa)
- Toplam kullanıcı, görev, departman sayıları
- Bugün oluşturulan / tamamlanan görevler
- Aktif sohbet sayısı
- Sistem sağlığı (`GET /health`)
- Grafikler: günlük görev trendi, durum dağılımı

> **Not:** Global stats API backend'de henüz yok. Admin panel için tasarlanmalı veya mevcut endpoint'lerden türetilmeli.

#### 9.2 Kullanıcı Yönetimi
| İşlem | API | Durum |
|-------|-----|-------|
| Kullanıcı listesi | `GET /users?skip&limit` | Hazır |
| Kullanıcı ara | `GET /users/search?q=` | Hazır |
| Kullanıcı detay | `GET /users/{id}` | Hazır |
| Kullanıcı düzenle | `PUT /users/{id}` | Hazır |
| Kullanıcı sil | `DELETE /users/{id}` | Hazır |
| Admin yap/çıkar | — | **Tasarlanmalı** |
| Kullanıcı istatistikleri | `GET /users/{id}/stats` | Hazır |
| Departmana göre filtre | `GET /users/department/{id}` | Hazır |

#### 9.3 Departman Yönetimi
| İşlem | API | Durum |
|-------|-----|-------|
| Listele | `GET /departments` | Hazır |
| Oluştur | `POST /departments` | Hazır |
| Detay | `GET /departments/{id}` | Hazır |
| Sil | `DELETE /departments/{id}` | Hazır |

#### 9.4 Görev Yönetimi
| İşlem | API | Durum |
|-------|-----|-------|
| Tüm görevler | `GET /tasks?skip&limit` | Hazır |
| Departmana göre | `GET /tasks/department/{id}` | Hazır |
| Detay | `GET /tasks/{id}` | Hazır |
| Düzenle | `PUT /tasks/{id}` | Hazır |
| Durum değiştir | `PATCH /tasks/{id}/status?status=` | Hazır |
| Sil | `DELETE /tasks/{id}` | Hazır |
| Yorumlar | `GET /tasks/{id}/comments` | Hazır |
| Dosyalar | `POST /tasks/{id}/files` | Hazır (URL referansı) |

#### 9.5 Sohbet Moderasyonu
| İşlem | API | Durum |
|-------|-----|-------|
| Birebir sohbet listesi | `GET /chats` | Hazır (kullanıcı bazlı) |
| Grup sohbet listesi | `GET /chats/groups` | Hazır |
| Mesaj geçmişi | `GET /chats/{id}` | Hazır |
| Sohbet sil | `DELETE /chats/{id}` | Hazır |
| Mesaj sil | — | **Tasarlanmalı** |
| Tüm sohbetleri admin görme | — | **Tasarlanmalı** (admin-only endpoint) |

#### 9.6 Bildirim Yönetimi (gelecek)
- Toplu bildirim gönderme
- Bildirim geçmişi
- Kullanıcı bildirim tercihlerini görme

#### 9.7 Sistem Ayarları (gelecek)
- API ortam durumu
- SMS gateway durumu
- Depolama kullanımı

### Admin panel teknik öneriler
- **Framework:** React/Next.js veya Vue/Nuxt (tercihe göre)
- **Auth:** JWT Bearer (aynı backend)
- **Admin guard:** `is_admin === true` kontrolü
- **API client:** `openapi.json`'dan otomatik client üretilebilir
- **Responsive:** Masaüstü öncelikli, tablet uyumlu

---

## 10. Tanıtım Web Sitesi — Ne Yapılmalı?

### Önerilen sayfa yapısı

```
/                    → Ana sayfa (hero, özellikler, ekran görüntüleri, CTA)
/features            → Detaylı özellik listesi
/pricing             → Ücretsiz (şimdilik tek plan)
/download            → App Store linki (henüz yayında değilse "yakında")
/about               → Hakkında / ekip
/contact             → İletişim formu
/privacy             → Gizlilik politikası
/terms               → Kullanım şartları
/[lang]              → Çok dilli routing (tk, tr, en, ru)
```

### Ana sayfa bölümleri

1. **Hero:** "Ekibiniz için görev yönetimi ve mesajlaşma" + App Store butonu
2. **Özellikler grid (3-4 kart):**
   - Görev yönetimi (departman, durum, atama)
   - Mesajlaşma (DM + grup)
   - SMS ile hızlı kayıt
   - Çok dilli destek
3. **Ekran görüntüleri:** iPhone mockup'ları (5 sekme)
4. **Nasıl çalışır:** 3 adım (Kayıt ol → Görev oluştur → Takip et)
5. **İstatistikler / sosyal kanıt:** (henüz veri yoksa atlanabilir)
6. **CTA:** "Hemen indir" veya "Yakında App Store'da"
7. **Footer:** Dil seçici, sosyal medya, yasal linkler

### Teknik öneriler
- **Framework:** Next.js (SSR/SSG, i18n kolay)
- **Diller:** tk (default), tr, en, ru
- **SEO:** Meta tags, Open Graph, structured data
- **Responsive:** Mobil-first
- **Hosting:** Vercel / Netlify

---

## 11. Teknik Altyapı

### iOS Uygulama
| Bileşen | Teknoloji |
|---------|-----------|
| Dil | Swift 5 |
| UI | SwiftUI |
| Mimari | Clean Architecture + MVVM |
| DI | DIContainer (manual) |
| Ağ | URLSession + REST JSON |
| Token | iOS Keychain |
| Min iOS | 26.2 (deployment target) |
| 3rd party | Yok (native only) |

### Backend
| Bileşen | Teknoloji |
|---------|-----------|
| Framework | FastAPI (Python) |
| API versiyon | v0.1.0 |
| Auth | JWT Bearer |
| Spec | OpenAPI 3.1 (`openapi.json`) |
| Realtime | WebSocket (planlanmış) |
| Push | APNs (iOS tarafı hazır) |
| Dosya | URL referansı (object storage ayrı) |

### Dış servisler
| Servis | Kullanım |
|--------|----------|
| DuckDNS | Dev/staging host |
| APNs | iOS push bildirimleri |
| SMS gateway | OTP gönderimi (backend tarafında) |
| Object storage | Dosya upload (henüz entegre değil) |

### Olmayan entegrasyonlar
Firebase, Supabase, Google/Apple OAuth, Stripe/IAP, Analytics SDK — hiçbiri yok.

---

## 12. Tasarım ve Marka Notları

### Renk paleti (iOS Design System'den)
- **Primary:** Uygulamanın ana rengi (gradient butonlarda kullanılıyor)
- **Background / Surface:** Karanlık/aydınlık mod destekli
- **Durum renkleri:**
  - Bekliyor: #F59E0B (amber)
  - Devam ediyor: #3B82F6 (mavi)
  - Tamamlandı: #10B981 (yeşil)
  - İptal/Geri: #EF4444 (kırmızı)

### Tipografi
- **Font:** Aestetico (custom font, iOS bundle'da)
- Web sitesi için benzer bir font veya Inter/SF Pro alternatifi kullanılabilir

### UI stili
- Yuvarlatılmış köşeler (22-34px radius)
- Kart tabanlı layout
- Alt navigasyon bar (floating, capsule shape)
- Gradient primary butonlar
- SF Symbols ikonları (iOS)

### Marka isimleri
- **Kullanıcıya görünen:** Remember
- **İç kod / backend:** Yatla
- Web sitesinde hangisinin kullanılacağına karar verilmeli (muhtemelen "Remember")

---

## 13. Hazır Olan vs Planlanan

### Tamamen hazır (backend + iOS)
- [x] SMS OTP kayıt ve giriş
- [x] JWT auth + token refresh
- [x] Kullanıcı CRUD
- [x] Departman CRUD
- [x] Görev CRUD + durum + yorum + dosya
- [x] Birebir chat
- [x] Grup chat (departman)
- [x] Mute/unmute/read
- [x] 4 dil desteği (iOS)
- [x] Karanlık/aydınlık mod

### iOS hazır, backend eksik
- [ ] Görev teklifleri (Task Offers)
- [ ] Push bildirimleri (notifications API)
- [ ] Bildirim tercihleri
- [ ] Global istatistik dashboard verisi
- [ ] Avatar upload (profil fotoğrafı)
- [ ] Chat medya/dosya eki
- [ ] WebSocket realtime

### Sadece UI mock
- [ ] Sesli/görüntülü arama
- [ ] İstatistik panosu (mock veri)

### Admin / web için tasarlanması gereken
- [ ] Admin-only API endpoint'leri
- [ ] `is_admin` backend enforcement
- [ ] Global stats API
- [ ] Mesaj silme / moderasyon
- [ ] Toplu bildirim gönderme
- [ ] Audit log
- [ ] Dosya upload stratejisi (pre-signed URL veya multipart)

---

## 14. Referans Dosyalar

Projede web geliştirici için doğrudan kullanılabilecek dosyalar:

| Dosya | Konum | Açıklama |
|-------|-------|----------|
| **OpenAPI Spec** | `openapi.json` (proje kökü) | Tüm API endpoint'leri, şemalar — Postman/Swagger import |
| **API Contract (Türkçe)** | `Remember/Remember/BACKEND_API_CONTRACT.md` | İnsan-okunur API özeti |
| **Postman workspace** | `.postman/resources.yaml` | OpenAPI referansı (collection henüz boş) |
| **iOS Info.plist** | `Remember/Remember/Info.plist` | Aktif API URL config |

### API'yi test etmek için

1. `openapi.json` dosyasını Postman veya Swagger UI'ya import et
2. Auth flow:
   ```
   POST /auth/send-otp     → { "phone": "+99361000001" }
   POST /auth/verify-otp   → { "phone": "...", "code": "1234" }
   POST /auth/register     → { "name": "...", "password": "...", "temp_token": "..." }
   ```
   veya mevcut hesapla:
   ```
   POST /auth/login        → { "phone": "...", "password": "..." }
   ```
3. Dönen `access_token`'ı `Authorization: Bearer <token>` header'ına ekle
4. Diğer endpoint'leri test et

---

## 15. Sık Sorulan Sorular

**S: Web uygulaması (mobil web) da yapılacak mı?**  
C: Şu an plan sadece tanıtım sitesi + admin panel. Mobil web veya PWA planlanmıyor.

**S: Backend'e erişim var mı?**  
C: Evet. Aktif API: `https://yatla-global.duckdns.org/api/v1`. Test hesabı için Latif'ten istenebilir.

**S: Admin panel aynı backend'i mi kullanacak?**  
C: Evet. Aynı REST API + JWT auth. Admin-only endpoint'ler backend ekibince eklenecek.

**S: Tasarım dosyası (Figma) var mı?**  
C: Hayır. iOS uygulaması referans alınabilir. Ekran görüntüleri paylaşılabilir.

**S: App Store'da yayında mı?**  
C: Henüz değil (v1.0, build 1). Web sitesinde "yakında" mesajı kullanılabilir.

**S: Kaç dil desteklenecek?**  
C: Web sitesi ve admin panel için minimum Türkmence + Türkçe + İngilizce. Rusça opsiyonel.

**S: Ödeme/abonelik sistemi gelecek mi?**  
C: Şu an plan yok. İleride eklenirse web sitesine pricing sayfası güncellenir.

---

## İletişim

Sorular için: **Latif** (proje sahibi)

Backend API değişiklikleri ve yeni admin endpoint'leri için backend geliştirici ile koordinasyon gerekebilir.

---

*Bu doküman Remember iOS uygulamasının mevcut kod tabanından (Mayıs 2026) otomatik analiz edilerek hazırlanmıştır.*
