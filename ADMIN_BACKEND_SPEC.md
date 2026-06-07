# Admin Panel — Backend Gereksinimleri (Spec)

Bu doküman, Remember admin panelinin tam çalışması için **FastAPI backend'e eklenmesi gereken** endpoint ve güvenlik kurallarını tanımlar.

Backend geliştiriciye veya kendin backend yazıyorsan bu spec'i uygula.

---

## 1. Admin Yetkilendirme

### Mevcut durum
- `UserResponse.is_admin` alanı var
- **Hiçbir endpoint admin kontrolü yapmıyor** — her giriş yapmış kullanıcı her şeyi yapabilir

### Yapılması gereken

```python
# dependencies.py
from fastapi import Depends, HTTPException, status

async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    # mevcut JWT decode logic
    ...

async def require_admin(user: User = Depends(get_current_user)) -> User:
    if not user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return user
```

Tüm `/admin/*` endpoint'leri `require_admin` dependency kullanmalı.

---

## 2. Yeni Endpoint'ler

### 2.1 Dashboard istatistikleri

```
GET /api/v1/admin/stats
Authorization: Bearer <admin_token>
```

**Response 200:**
```json
{
  "total_users": 142,
  "total_tasks": 890,
  "total_departments": 12,
  "total_chats": 56,
  "total_group_chats": 12,
  "new_users_today": 5,
  "new_users_this_week": 23,
  "new_users_this_month": 67,
  "tasks_created_today": 18,
  "tasks_completed_today": 12,
  "tasks_by_status": {
    "waiting": 120,
    "inProgress": 45,
    "completed": 680,
    "cancelled": 30,
    "returned": 15
  },
  "users_by_department": [
    { "department_id": "dept-1", "department_name": "Satış", "user_count": 24 }
  ],
  "daily_registrations": [
    { "date": "2026-05-18", "count": 3 },
    { "date": "2026-05-19", "count": 7 }
  ],
  "daily_task_completions": [
    { "date": "2026-05-18", "count": 12 }
  ]
}
```

**SQL ipuçları:**
```sql
-- new_users_today
SELECT COUNT(*) FROM users WHERE DATE(created_at) = CURRENT_DATE;

-- tasks_by_status
SELECT status, COUNT(*) FROM tasks GROUP BY status;
```

---

### 2.2 Admin kullanıcı yönetimi

#### Admin yetkisi ver/al

```
PATCH /api/v1/admin/users/{user_id}/admin
Authorization: Bearer <admin_token>
Content-Type: application/json

{ "is_admin": true }
```

**Response 200:** Güncellenmiş `UserResponse`

**Kurallar:**
- Kendi admin yetkini kaldıramazsın
- En az 1 admin kalmalı

#### Tüm kullanıcılar (admin view — pagination + filtre)

```
GET /api/v1/admin/users?skip=0&limit=50&is_admin=false&department_id=dept-1&sort=created_at&order=desc
```

Mevcut `GET /users` genişletilebilir veya admin-only duplicate yapılabilir.

---

### 2.3 Sohbet moderasyonu

#### Tüm birebir sohbetler

```
GET /api/v1/admin/chats?skip=0&limit=50
Authorization: Bearer <admin_token>
```

**Response:**
```json
[
  {
    "id": "chat-1",
    "participant_ids": ["user-1", "user-2"],
    "participants": [
      { "id": "user-1", "name": "Ali", "phone": "+993..." },
      { "id": "user-2", "name": "Veli", "phone": "+993..." }
    ],
    "last_message": { "text": "...", "sent_at": "..." },
    "message_count": 45,
    "created_at": "2026-01-01T00:00:00Z"
  }
]
```

#### Tüm grup sohbetler

```
GET /api/v1/admin/chats/groups?skip=0&limit=50
```

#### Herhangi bir sohbetin mesajları

```
GET /api/v1/admin/chats/{chat_id}/messages?skip=0&limit=100
GET /api/v1/admin/chats/groups/{group_id}/messages?skip=0&limit=100
```

#### Mesaj sil (moderasyon)

```
DELETE /api/v1/admin/messages/{message_id}
DELETE /api/v1/admin/group-messages/{message_id}
```

---

### 2.4 Görev yönetimi (admin)

Mevcut task endpoint'leri admin için yeterli, ama şunlar eklenebilir:

```
GET /api/v1/admin/tasks?skip=0&limit=50&status=inProgress&department_id=dept-1&creator_id=user-1
```

Tüm görevleri filtreli listele (normal `GET /tasks` kullanıcıya özel dönebilir).

---

### 2.5 Bildirim yönetimi

```
GET /api/v1/admin/notifications?skip=0&limit=50
POST /api/v1/admin/notifications/broadcast
```

**Broadcast body:**
```json
{
  "title": "Sistem bakımı",
  "message": "Yarın 02:00-04:00 arası bakım yapılacak",
  "target": "all"
}
```

`target` değerleri: `"all"` | `"department:{id}"` | `"user:{id}"`

---

### 2.6 Sistem

```
GET /api/v1/admin/health
```

**Response:**
```json
{
  "api": "ok",
  "database": "ok",
  "redis": "ok",
  "sms_gateway": "ok",
  "uptime_seconds": 864000,
  "version": "0.1.0"
}
```

---

## 3. CORS

Admin panel domain'i eklenmeli:

```python
allow_origins=[
    "http://localhost:3000",
    "https://admin.remember.com",
    "https://remember-admin.vercel.app",
]
```

---

## 4. İlk admin kullanıcısı

Veritabanında manuel veya migration ile:

```sql
UPDATE users SET is_admin = true WHERE phone = '+9936XXXXXXXX' LIMIT 1;
```

Veya seed script:

```python
# scripts/create_admin.py
async def create_first_admin(phone: str, password: str, name: str):
    user = await get_user_by_phone(phone)
    if user:
        user.is_admin = True
        await db.commit()
    else:
        # register flow + is_admin=True
        ...
```

---

## 5. OpenAPI güncelleme

Her yeni endpoint eklendiğinde:
1. FastAPI otomatik OpenAPI üretir
2. `openapi.json` export et
3. iOS repo'daki `openapi.json`'u güncelle
4. `BACKEND_API_CONTRACT.md`'ye yeni bölüm ekle

---

## 6. Öncelik sırası

| Öncelik | Endpoint | Neden |
|---------|----------|-------|
| P0 | `require_admin` dependency | Güvenlik |
| P0 | CORS admin domain | Admin panel çalışsın |
| P0 | İlk admin kullanıcısı | Giriş yapabilsin |
| P1 | `GET /admin/stats` | Dashboard |
| P1 | `PATCH /admin/users/{id}/admin` | Admin yönetimi |
| P2 | `GET /admin/chats` + messages | Sohbet moderasyonu |
| P2 | `DELETE /admin/messages/{id}` | Mesaj silme |
| P3 | Notifications broadcast | Push yönetimi |

---

## 7. Mevcut endpoint'ler (admin panel şimdilik bunları kullanabilir)

Admin endpoint'leri hazır olana kadar normal endpoint'ler yeterli:

| İşlem | Endpoint |
|-------|----------|
| Giriş | `POST /auth/login` |
| Profil | `GET /users/me` |
| Kullanıcı listesi | `GET /users` |
| Kullanıcı ara | `GET /users/search?q=` |
| Kullanıcı sil | `DELETE /users/{id}` |
| Kullanıcı stats | `GET /users/{id}/stats` |
| Görev listesi | `GET /tasks` |
| Görev durum | `PATCH /tasks/{id}/status?status=` |
| Görev sil | `DELETE /tasks/{id}` |
| Departman CRUD | `GET/POST/DELETE /departments` |
| Chat listesi | `GET /chats`, `GET /chats/groups` |
| Health | `GET /health` |
