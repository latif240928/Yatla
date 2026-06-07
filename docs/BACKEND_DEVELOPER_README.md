# Remember App — Frontend ↔ Backend Workflow

Bu doküman, **iOS frontend (Latif)** ve **backend developer (arkadaşın)** arasında
kesintisiz çalışmak için ortak kuralları tanımlar. Tek dil/Türkçe-İngilizce
karışık olabilir, kısa tutuldu.

---

## 1) Sözleşme (Contract) Önce, Kod Sonra

> **Kural:** Yeni bir endpoint planlanmadan önce `BACKEND_API_CONTRACT.md` güncellenir.

- Frontend bir `/foo` endpoint'i bekliyorsa → contract'a yazar → PR açar → backend onaylar/değiştirir → birleştirilir → **ikisi de ona göre kodlar.**
- Sözleşme değişirse: **breaking değişikliği** ana branch'e direkt push'lamayın.
  Contract PR'ında `BREAKING:` etiketi olmalı, frontend bilmeden sahaya gitmemeli.

---

## 2) iOS Tarafı Mock vs API Anahtarı

`Info.plist` altında:

```xml
<key>API_ENV</key>
<string>mock</string>     <!-- mock | development | staging | production -->
```

| Değer         | Anlamı                                              |
|---------------|-----------------------------------------------------|
| `mock`        | Hiçbir endpoint çalışmaz, in-memory mock'lar        |
| `development` | `https://dev-api.remember.com/v1`                   |
| `staging`     | `https://staging-api.remember.com/v1`               |
| `production`  | `https://api.remember.com/v1`                       |

Kod akışı: `APIEnvironment.current` → `DIContainer` → tüm repo'lar.
Bir bayrağı çevirip `mock` ↔ `development` arası geçilebilir.

> **Backend developer:** "API_ENV mock olduğunda" bug raporu açma — bu kasıtlı
> offline modu. Test için `development` build kullan.

---

## 3) Branch Stratejisi (Trunk-based, Light)

```
main          ← stable, herkesin pull ettiği
  ├─ ios/feat/* ← iOS feature branchleri  (örn. ios/feat/chat-search)
  ├─ ios/fix/*  ← iOS hotfix
  ├─ api/feat/* ← Backend feature
  └─ api/fix/*  ← Backend hotfix
```

- **Direkt `main`'e push yok.** Her şey PR.
- iOS PR'ı backend'siz mergeable olmalı (mock veriyle çalışmalı).
- Backend PR'ı iOS'siz mergeable olmalı (Postman / curl ile test edilebilmeli).
- **Ortak değişiklikler:** `BACKEND_API_CONTRACT.md` PR'ı önce gider, sonra her
  iki taraf kendi tarafını PR'lar.

---

## 4) DTO Adlandırma Senkron'u

Backend `snake_case`, iOS Swift `camelCase`. Bu projede `JSONDecoder` zaten
`.convertFromSnakeCase` yapıyor — yani backend `created_at` döndürür, iOS `createdAt`
olarak alır. **Backend developer'ın bilmesi gereken:**

| Frontend bekler | Backend gönderir       |
|-----------------|------------------------|
| `createdAt`     | `created_at`           |
| `dueDate`       | `due_date`             |
| `assigneeIds`   | `assignee_ids`         |
| `isRead`        | `is_read`              |
| `unreadCount`   | `unread_count`         |

`Date` alanları **mutlaka ISO-8601** ("2026-04-15T14:35:00Z").

---

## 5) Auth Flow (Beraber Test Edilmesi Gereken)

```
iOS                                                      Backend
  │  POST /auth/send-otp { phone }                          │
  │ ──────────────────────────────────────────────────────► │
  │                                       OTP gönderir SMS  │
  │  POST /auth/verify-otp { phone, code }                  │
  │ ──────────────────────────────────────────────────────► │
  │ ◄──────────── { token: "<JWT>", user: {...} }           │
  │                                                         │
  │  Tüm sonraki istekler → Authorization: Bearer <JWT>     │
```

iOS, `KeychainService` üzerinden token'ı saklıyor. `NetworkService` her isteğe
otomatik `Authorization: Bearer <token>` ekliyor (`requiresAuth: false` denmediği
sürece).

**Backend kontratı:** Token süresi dolduğunda **401** dönmeli, iOS bu cevabı
yakalayıp logout flow'una sokar (TODO: henüz iOS tarafında implement edilmedi).

---

## 6) WebSocket / Realtime

Şimdilik `BACKEND_API_CONTRACT.md` §8 yeterli. iOS tarafında henüz WebSocket
client yok. **Backend hazır olduğunda:**

1. Backend bir minimal echo endpoint açar (`ws://.../v1/ws`)
2. Frontend `URLSessionWebSocketTask` ile bağlanan bir `ChatRealtimeService`
   yazar.
3. Test: SignIn → Connect → "ping" gönder → "pong" gelmesi.

---

## 7) Hata Formatı

Tüm error response'lar **aynı zarfta** olmalı:

```json
{ "error": { "code": "INVALID_REQUEST", "message": "phone is required" } }
```

iOS bunu `NetworkError.serverError(statusCode:data:)` ile yakalar.

---

## 8) Çalışma Ritmi (Önerim)

| Aralık     | Toplantı                                                    |
|------------|-------------------------------------------------------------|
| Pzt sabah  | 30 dk: hafta planı + bloker'lar + contract değişiklikleri   |
| Salı–Cuma  | Async: PR review'lar, kısa Slack / Discord mesajları        |
| Cuma akşam | 15 dk demo: iki taraf da haftada ne çıkardı                 |

Her iki taraf da **Postman / Insomnia collection**'ı paylaşıyor ki diğer
taraf endpoint'i kendi başına test edebilsin.

---

## 9) Acil Durum Kuralları

- **Production'da bug:** önce iOS hotfix branch (`ios/fix/<issue>`),
  paralel olarak backend gerekirse (`api/fix/<issue>`). İki PR aynı issue ID'sini
  taşımalı.
- **Backward incompatible API değişikliği:** **mümkünse yeni endpoint** açın
  (örn. `/v2/tasks`), eskiyi 30 gün koruyun. Doğrudan `/tasks`'i kırmak iOS
  store onayını bozar.

---

## 10) Hazır Olunca İlk Endpoint Sırası

1. `POST /auth/send-otp` ✅
2. `POST /auth/verify-otp` ✅
3. `POST /auth/login`
4. `GET /users` (token gerekli)
5. `GET /departments`
6. `GET /tasks`
7. Devamı → `BACKEND_API_CONTRACT.md`

Her endpoint biter bitmez `staging`'e deploy edilsin, frontend `API_ENV=staging`
ile QA yapsın.

---

## 11) Frontend Tarafı `TODO`'lar (Backend ile Karşılıklı)

iOS kodunda `TODO: Backend integration` aramak yeterli — yapılacaklar listesi:

- `HomeView.onAppear` → ilk yüklemeyi tetikle
- `CreateTasksView.onRefresh` → swipe-to-refresh
- `HomeView.DepartmentSheet.onCreateDepartment` → `createDepartmentUseCase` çağır
- 401 yakalanınca `AppRouter.logout()` çağır

---

**Bu doküman canlı.** Bir şey eklemek/değiştirmek istersen aynı PR akışında
güncelle.
