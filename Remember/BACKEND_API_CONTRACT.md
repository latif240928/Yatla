# Backend API Contract — Remember (Yatla)

> **Kaynak gerçeği:** Bu doküman `openapi.json` (Yatla Backend `0.1.0`) baz
> alınarak yazılmıştır. Çelişki varsa **OpenAPI** geçerlidir; bu doküman
> sadece insan-okunur özettir. Bir endpoint değişirse iki tarafı da
> aynı PR'da güncelleyin.

## Base URL

| Ortam       | URL                                       |
|-------------|-------------------------------------------|
| development | `https://dev-api.remember.com/api/v1`     |
| staging     | `https://staging-api.remember.com/api/v1` |
| production  | `https://api.remember.com/api/v1`         |

> Tüm path'ler `/api/v1` prefix'i ile geliyor (FastAPI router'ında öyle
> tanımlı). `iOS NetworkService.baseURL` bu prefix'i baseURL'in içine alır,
> repolar yalnız `/auth/...`, `/tasks/...` gibi suffix'leri kullanır.

## Authentication

Korunan tüm endpoint'lere `Authorization: Bearer <access_token>` header'ı
gönderilir. Token'lar Keychain'de tutulur; iOS tarafı 401 alırsa otomatik
olarak `/auth/refresh` çağırır, başarısız olursa session-expired
notification'ı yayınlar.

```
Authorization: Bearer <jwt_access_token>
```

---

## 1. Authentication

> İstemci akışı: **send-otp → verify-otp → register** (yeni hesap için)
> veya **login** (mevcut hesap için). Token yenileme `refresh`
> endpoint'inden yapılır.

### POST `/auth/send-otp`
Telefon numarasına SMS kodu gönderir.

**Request:**
```json
{ "phone": "+99361000001" }
```

**Response (`SendOTPResponse`):**
```json
{ "message": "OTP sent successfully" }
```

### POST `/auth/verify-otp`
Telefon ve kodu doğrular; **geçici** bir token döner. Bu token sadece
`/auth/register`'a yetki verir, asla erişim token'ı olarak kullanılmaz.

**Request:**
```json
{ "phone": "+99361000001", "code": "1234" }
```

**Response (`VerifyOTPResponse`):**
```json
{ "temp_token": "eyJhbGciOi..." }
```

### POST `/auth/register`
Verify-OTP'den gelen `temp_token` ile yeni kullanıcı oluşturur ve kalıcı
access/refresh token çiftini döner.

**Request:**
```json
{
  "name": "Jane Doe",
  "password": "secret123",
  "temp_token": "<verify-otp adımından>"
}
```

**Response (`LoginResponse`):**
```json
{
  "access_token": "eyJhbGciOi...",
  "refresh_token": "eyJhbGciOi...",
  "token_type": "bearer"
}
```

> ⚠️ Yanıtta **kullanıcı objesi yok**. Kayıt sonrası iOS hemen
> `GET /users/me` çağırarak mevcut kullanıcıyı yükler.

### POST `/auth/login`
Telefon + parola ile giriş.

**Request:** `{ "phone": "+99361000001", "password": "secret123" }`
**Response:** `LoginResponse` (yukarıdaki ile aynı)

### POST `/auth/refresh`
Refresh token'ı yeni bir access/refresh çiftiyle değiş tokuş eder.
İstemci 401 alırsa kendiliğinden tetikler.

**Request:**
```json
{ "refresh_token": "<refresh-token>", "token_type": "bearer" }
```

**Response:** `LoginResponse`

---

## 2. Users

### GET `/users` *(auth)*
Tüm kullanıcılar.

Query: `skip` (default 0), `limit` (default 50).
Response: `UserResponse[]`

### GET `/users/search?q=` *(auth)*
İsim/telefonla arama.

### GET `/users/department/{department_id}` *(auth)*
Bir departmana ait kullanıcılar.

### GET `/users/me` *(auth)*
Aktif oturumdaki kullanıcı. Login/Register sonrası ilk çağrı bu olmalı.

### GET `/users/me/stats` *(auth)*
Aktif kullanıcının görev istatistikleri.

### GET `/users/{user_id}` *(auth)*

### GET `/users/{user_id}/stats` *(auth)*

### PUT `/users/{user_id}` *(auth)*
**Request (`UserUpdate`):**
```json
{ "name": "Yeni Ad", "avatar_url": "https://..." }
```
Her iki alan da opsiyonel.

### DELETE `/users/{user_id}` *(auth)*

### Şemalar

`UserResponse`
```json
{
  "id": "...",
  "name": "...",
  "phone": "+99361000001",
  "avatar_url": null,
  "is_admin": false,
  "department_ids": ["dept-1"],
  "created_at": "2024-01-01T10:00:00Z"
}
```

`UserTaskStats`
```json
{
  "user_id": "...",
  "assigned_task_count": 7,
  "completed_task_count": 3,
  "pending_task_count": 4
}
```

---

## 3. Tasks

### GET `/tasks` *(auth)*
Aktif kullanıcıyla ilgili görevler.

Query: `skip`, `limit`. Response: `TaskResponse[]`

### POST `/tasks` *(auth)*
Görev oluşturur.

**Request (`TaskCreate`):**
```json
{
  "title": "UI yenileme",
  "description": "Login ekranı",
  "department_id": "dept-1",
  "due_date": "2026-05-15T17:00:00Z",
  "assignee_ids": ["user-1", "user-2"],
  "start_date": "2026-05-10T09:00:00Z"
}
```
Yalnızca `title` zorunlu; diğerleri opsiyonel.

### GET `/tasks/department/{department_id}` *(auth)*
Bir departmanın görevleri.

### GET / PUT / DELETE `/tasks/{task_id}` *(auth)*
- `PUT` body (`TaskUpdate`) tüm alanlar opsiyonel:
  ```json
  { "title": "...", "description": "...", "status": "completed",
    "department_id": "...", "due_date": "..." }
  ```

### PATCH `/tasks/{task_id}/status?status=…` *(auth)*
> ⚠️ **Body yok!** Status query parametresi olarak gönderilir.
> Geçerli değerler: `waiting`, `inProgress`, `completed`, `cancelled`,
> `returned` (camelCase!).

Response: güncellenmiş `TaskResponse`.

### POST `/tasks/{task_id}/assignees/{user_id}` *(auth)*
Atayıcı ekler — body yok, iki ID URL'de.

### DELETE `/tasks/{task_id}/assignees/{user_id}` *(auth)*

### GET `/tasks/{task_id}/comments` *(auth)*
Response: `TaskCommentResponse[]`

### POST `/tasks/{task_id}/comments?text=…` *(auth)*
> ⚠️ Yorum metni **query** olarak gönderilir, body yok.

### POST `/tasks/{task_id}/files?name=&format=&url=` *(auth)*
> ⚠️ Multipart yok. Backend yalnız URL kaydeder; binary upload'ı
> frontend kendi object-storage'ına yapıp ardından bu endpoint'i
> çağırmalı.

### Şemalar

`TaskResponse`
```json
{
  "id": "task-1",
  "title": "...",
  "description": null,
  "department_id": "dept-1",
  "due_date": "2026-05-15T17:00:00Z",
  "status": "inProgress",
  "creator_id": "user-1",
  "number": 42,
  "assignee_ids": ["user-2"],
  "created_at": "2026-05-10T09:00:00Z",
  "updated_at": "2026-05-10T11:30:00Z"
}
```

> Önemli farklar (eski sözleşmeye göre):
> - `start_date` artık dönmüyor (yalnız oluşturulurken alınıyor).
> - `assignees` (User listesi) yok; yalnız `assignee_ids`.
> - `department` (string) yok; yalnız `department_id`.
> - `files` ve `comments` task üzerinde gömülü değil — ayrı endpoint.
> - `TaskStatus` enum'u **camelCase** (`inProgress`).

`TaskCommentResponse`
```json
{ "id": "...", "user_id": "...", "text": "...", "date": "..." }
```
> User objesi yok; istemci `user_id`'yi `UserRepository`'den hidrate eder.

`TaskFileResponse`
```json
{ "id": "...", "name": "...", "format": "pdf", "url": "https://..." }
```

---

## 4. Departments

### GET `/departments` *(auth)*
### POST `/departments` *(auth)*
Body: `{ "name": "..." }`
### GET `/departments/{department_id}` *(auth)*
### DELETE `/departments/{department_id}` *(auth)*

`DepartmentResponse`
```json
{ "id": "...", "name": "...", "created_at": "..." }
```

---

## 5. Chats

### Direct chats

| Method | Path                                      | Açıklama                       |
|--------|-------------------------------------------|--------------------------------|
| GET    | `/chats`                                  | Liste (`ChatResponse[]`)        |
| POST   | `/chats/participant/{participant_id}`     | Aç/oluştur (`ChatResponse`)     |
| GET    | `/chats/{chat_id}`                        | Mesajlar (`ChatMessageResponse[]`) |
| POST   | `/chats/{chat_id}/messages`               | Body `{ "text": "..." }`         |
| POST   | `/chats/{chat_id}/read`                   | Okundu olarak işaretle           |
| POST   | `/chats/{chat_id}/mute`                   | Sessize al                       |
| POST   | `/chats/{chat_id}/unmute`                 | Sessizden çıkar                  |
| DELETE | `/chats/{chat_id}`                        | Sohbeti sil                      |

`ChatResponse`
```json
{
  "id": "chat-1",
  "participant_id": "user-2",
  "is_muted": false,
  "last_message": { ...ChatMessageResponse },
  "unread_count": 3
}
```

> İstemci tarafı: liste dönüşünde `participant_id`'yi
> `UserRepository.user(byId:)` ile hidrate eder. Mesaj geçmişi `GET
> /chats/{chat_id}` ile ayrı yüklenir.

### Group chats

| Method | Path                                                    | Açıklama                  |
|--------|---------------------------------------------------------|---------------------------|
| GET    | `/chats/groups`                                         | `GroupChatResponse[]`     |
| GET    | `/chats/groups/department/{department_id}`              | Departmana göre grup      |
| GET    | `/chats/groups/{group_chat_id}/messages`                | Mesaj geçmişi             |
| POST   | `/chats/groups/{group_chat_id}/messages`                | Body `{ "text": "..." }`  |

`GroupChatResponse`
```json
{
  "id": "g1",
  "department_id": "dept-1",
  "last_message": { ...ChatMessageResponse },
  "unread_count": 0
}
```

`ChatMessageResponse`
```json
{
  "id": "msg-1",
  "sender_id": "user-2",
  "text": "Hello!",
  "sent_at": "2026-05-10T18:30:00Z",
  "is_read": false
}
```

> `sender` artık tam `User` değil, sadece `sender_id`. İstemci tarafı
> `UserRepository`'den hidrate eder.

---

## 6. Henüz OpenAPI'de OLMAYAN şeyler

Aşağıdaki kısımlar eski sözleşmede vardı ama yeni `openapi.json`'da yok.
Backend ile aramızda ayrı PR ile karara bağlanmadan iOS bunlara
dokunmuyor (mock'larda yaşıyorlar):

- **Task offers** (`/offers`, `/offers/incoming`, accept/reject)
- **Notifications** (`/notifications`, push registration, settings)
- **WebSocket** realtime (`ws://.../ws`)
- **Multipart file upload** — şu an URL referansıyla kaydediyoruz;
  binary upload akışı (S3 / pre-signed URL) ayrı bir contract gerektirir.

> Backend tarafı bunları eklediğinde:
> 1. `openapi.json`'u güncelle ve PR aç.
> 2. Bu dokümana karşılık gelen `## 7. Notifications` / `## 8. Offers`
>    bölümlerini ekle.
> 3. iOS tarafı Mock repolarını gerçek API repolarıyla değiştirir.

---

## 7. Hata formatı

FastAPI varsayılan hata formatı (`HTTPValidationError`) 422'lerde geliyor:

```json
{
  "detail": [
    { "loc": ["body", "phone"], "msg": "field required", "type": "value_error.missing" }
  ]
}
```

İstemci bunu `NetworkError.serverError(statusCode: data:)` ile yakalar.
401 alındığında `NetworkService` otomatik refresh dener, başarısız
olursa `Notification.Name.yatlaSessionExpired` yayınlar (router/UI bunu
dinleyip logout flow'una sokmalı).

---

## 8. iOS tarafı önemli notlar

| Konu                | Davranış                                                                                       |
|---------------------|------------------------------------------------------------------------------------------------|
| Token saklama        | `KeychainService` → `access`, `refresh`, `temp` token slotları ayrı.                          |
| Snake/Camel          | `JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase` — tüm DTO'lar Swift camelCase.       |
| Tarihler            | ISO‑8601 (`2026-05-10T18:30:00Z`); decoder/encoder otomatik dönüştürür.                        |
| 401                  | Sessiz refresh → tekrar dene → başarısızsa session-expired notification.                       |
| `inProgress`         | Backend wire değeri **camelCase** (`inProgress`). UI `displayName` Türkmençe gösterir.         |
| Mock vs Real         | `Info.plist > API_ENV` (`mock` / `development` / `staging` / `production`).                    |
