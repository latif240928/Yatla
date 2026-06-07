# API Testing Guide — Remember iOS

Bu rehber, arkadaşının gönderdiği `openapi.json`'a göre bağlanan iOS API
katmanının gerçekten çalışıp çalışmadığını test etmek için.

## 1. Şu an uygulama hangi backend'e bağlanıyor?

`Remember/Info.plist` içinde:

```xml
<key>API_ENV</key>
<string>local</string>

<key>API_BASE_URL</key>
<string></string>
```

Debug build şu an varsayılan olarak:

```text
http://localhost:8000/api/v1
```

adresine bağlanır.

`API_BASE_URL` boş değilse `API_ENV`'i ezer. Örnek:

```xml
<key>API_BASE_URL</key>
<string>http://192.168.1.42:8000/api/v1</string>
```

## 2. Arkadaşın backend'i lokal çalıştırırsa

Arkadaşından backend'i şu şekilde başlatmasını iste:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Backend senin Mac'inde çalışıyorsa iOS Simulator için:

```text
API_ENV = local
API_BASE_URL = boş
```

Backend arkadaşının bilgisayarında çalışıyorsa aynı Wi-Fi'da onun IP'sini al:

```text
http://ARKADAS_IP:8000/api/v1
```

ve `Info.plist > API_BASE_URL` içine yaz.

## 3. Önce backend ayakta mı test et

Terminal:

```bash
curl -i http://localhost:8000/health
```

Başarılıysa 200 dönmeli.

Arkadaşının bilgisayarındaki backend:

```bash
curl -i http://192.168.1.42:8000/health
```

## 4. iOS Simulator test

1. Xcode'da scheme: `Remember`
2. Destination: herhangi bir iPhone Simulator
3. Run
4. Sağ üstte küçük debug badge görünür:
   - `LOCAL` + yeşil nokta: backend'e ulaşıyor
   - `LOCAL` + kırmızı nokta: backend'e ulaşamıyor
   - Badge'e basınca `baseURL` ve `/health` sonucu görünür

## 5. Auth test sırası

Bu sırayla test et:

1. Telefon gir → `POST /auth/send-otp`
2. SMS kodu gir → `POST /auth/verify-otp`
3. İsim + parola → `POST /auth/register`
4. iOS otomatik `GET /users/me` çağırır
5. Home açılıyorsa auth bağlantısı çalışıyor

Önemli: Backend gerçek SMS göndermiyorsa arkadaşından test OTP kodunu sor.

## 6. Task test sırası

Login/register sonrası:

1. Home/task list aç → `GET /tasks`
2. Task oluştur → `POST /tasks`
3. Status değiştir → `PATCH /tasks/{id}/status?status=inProgress`
4. Yorum ekle → `POST /tasks/{id}/comments?text=...`

## 7. Chat test sırası

1. Chat list aç → `GET /chats`
2. Bir kullanıcıyla chat aç → `POST /chats/participant/{participant_id}`
3. Mesaj gönder → `POST /chats/{chat_id}/messages`
4. Chat açılınca mesaj geçmişi → `GET /chats/{chat_id}`

## 8. En sık görülen sorunlar

### Sağ üst badge kırmızı

Olası nedenler:

- Backend çalışmıyor
- Yanlış IP / port
- Backend `/health` endpoint'i root'ta değil
- Simulator arkadaşının bilgisayarına erişemiyor
- Firewall port 8000'i kapatıyor

### `API_ENV=mock` görünürse

`Info.plist` target'a dahil değil veya `API_ENV` yanlış. Şu dosyayı kontrol et:

```text
Remember/Remember/Info.plist
```

### 401 alırsan

Access token bitmiştir veya refresh token geçersizdir. App otomatik
`/auth/refresh` dener; o da olmazsa login ekranına döner.

### Task status çalışmazsa

Backend enum değeri kesin şu olmalı:

```text
waiting | inProgress | completed | cancelled | returned
```

Özellikle `in_progress` değil, `inProgress`.

