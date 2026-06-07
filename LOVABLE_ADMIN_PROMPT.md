# Lovable Admin Panel — Ana Prompt

Aşağıdaki metni **Lovable'a olduğu gibi yapıştır**. İngilizce yazıldı (Lovable daha iyi anlıyor).

---

## ANA PROMPT (kopyala-yapıştır)

```
Build a full admin dashboard web application called "Remember Admin" connected to an EXISTING REST API backend. Do NOT mock data — use real API calls to the backend described below.

---

## PROJECT OVERVIEW

Remember (internal name: Yatla) is a team task management + messaging iOS app. This admin panel lets administrators manage users, tasks, departments, and chats from a web browser.

Target users: admins only (users with is_admin: true).
Default language: Turkish UI labels (but code in English).
Platform: Desktop-first responsive web app.

---

## BACKEND API (REAL — USE THIS)

Base URL: https://yatla-global.duckdns.org/api/v1
Health check (no auth): GET https://yatla-global.duckdns.org/health

All protected endpoints require header:
Authorization: Bearer {access_token}

JSON fields are snake_case (department_id, created_at, is_admin, etc.)
Dates are ISO-8601 strings.

Store API base URL in environment variable: VITE_API_BASE_URL or NEXT_PUBLIC_API_BASE_URL

---

## AUTHENTICATION FLOW

1. Login page: phone number input (placeholder +993...) + password input + "Giriş Yap" button
2. POST /auth/login
   Body: { "phone": "+993...", "password": "..." }
   Response: { "access_token", "refresh_token", "token_type": "bearer" }
3. Save access_token and refresh_token in localStorage
4. Immediately call GET /users/me
   Response User object includes is_admin boolean
5. If is_admin is false → show error "Bu hesap admin yetkisine sahip değil" and do NOT enter dashboard
6. If is_admin is true → redirect to Dashboard
7. On 401 responses: try POST /auth/refresh with { "refresh_token", "token_type": "bearer" }, retry request, if fail → clear tokens and redirect to login
8. Logout: clear localStorage tokens, redirect to login
9. Protect all dashboard routes — redirect to /login if no token

---

## APP LAYOUT

Fixed left sidebar (collapsible on mobile via hamburger drawer):

- Remember Admin logo/title at top
- Navigation items with icons:
  - Dashboard (Panel)
  - Kullanıcılar (Users)
  - Görevler (Tasks)
  - Departmanlar (Departments)
  - Sohbetler (Chats)
  - Ayarlar (Settings)
- Bottom of sidebar: logged-in admin name + phone from /users/me
- "Çıkış Yap" logout button

Main content area:
- Top header bar with current page title
- Page-specific actions (search, filters, create buttons) on the right
- Content below

---

## DESIGN SYSTEM

Dark theme by default:
- Background: #0a0a0a or #18181b
- Cards/surface: #27272a
- Border: #3f3f46
- Primary accent: #3B82F6 (blue)
- Text primary: white, secondary: #a1a1aa

Task status badge colors (match exactly):
- waiting → amber #F59E0B, label "Bekliyor"
- inProgress → blue #3B82F6, label "Devam Ediyor"
- completed → green #10B981, label "Tamamlandı"
- cancelled → red #EF4444, label "İptal"
- returned → red #EF4444, label "Geri Gönderildi"

Style: modern shadcn/ui aesthetic, rounded corners (12px), subtle shadows, hover states on table rows, pill badges, toast notifications for success/error, skeleton loading states, empty states with icon + message.

Optional: light/dark toggle in Settings page.

---

## PAGE 1: DASHBOARD (/)

On load, fetch in parallel:
- GET /users?skip=0&limit=1000
- GET /tasks?skip=0&limit=1000
- GET /departments
- GET /health (no auth needed for health)

Compute and display:

TOP ROW — 4 stat cards:
1. "Toplam Kullanıcı" → users.length
2. "Toplam Görev" → tasks.length
3. "Toplam Departman" → departments.length
4. "Bugün Kayıt Olan" → users where created_at starts with today's date (YYYY-MM-DD)

SECOND ROW — two columns:

Left: "Görev Durum Dağılımı" — pie chart or bar chart grouped by task.status
Values: waiting, inProgress, completed, cancelled, returned

Right: "Son Kayıt Olan Kullanıcılar" — list last 8 users sorted by created_at desc
Show: name, phone, formatted date

THIRD ROW:
- "Son Görevler" — table of last 5 tasks: #number, title, status badge, created_at
- "Sistem Durumu" — green dot + "API Çevrimiçi" if /health returns 200, else red + "API Çevrimdışı"

Show loading skeletons while fetching. Show error toast if API fails.

---

## PAGE 2: KULLANICILAR (/users)

Fetch: GET /users?skip=0&limit=50

Table columns:
- Avatar (initials circle or avatar_url image)
- Ad (name)
- Telefon (phone)
- Departman (count of department_ids, e.g. "2 departman")
- Rol — badge "Admin" (purple) if is_admin true, else "Kullanıcı" (gray)
- Kayıt Tarihi (format created_at as DD MMM YYYY)
- İşlemler — "Detay" button + "Sil" button

Top bar:
- Search input — on submit/enter call GET /users/search?q={query}
- Pagination: Previous/Next with skip offset (50 per page)

Click "Detay" → open right-side drawer or modal:
- Show full user profile: name, phone, avatar, is_admin badge, created_at
- Fetch GET /users/{id}/stats and show 3 mini stat cards:
  - Atanan Görev (assigned_task_count)
  - Tamamlanan (completed_task_count)
  - Bekleyen (pending_task_count)
- Show department_ids list (resolve names from departments cache)
- Red "Kullanıcıyı Sil" button

Delete flow:
- Confirmation dialog: "Bu kullanıcıyı silmek istediğinize emin misiniz?"
- On confirm: DELETE /users/{id}
- Toast success, refresh list

Empty state: "Henüz kullanıcı yok"
Loading: table skeleton

---

## PAGE 3: GÖREVLER (/tasks)

Fetch: GET /tasks?skip=0&limit=50
Also fetch GET /departments and GET /users to resolve department names and creator/assignee names client-side.

Table columns:
- # (task.number)
- Başlık (title)
- Durum — colored status badge (use colors from design system)
- Departman — resolve department_id to department name
- Oluşturan — resolve creator_id to user name
- Atanan — show assignee_ids count e.g. "3 kişi"
- Bitiş Tarihi (due_date formatted, or "—" if null)
- Oluşturulma (created_at)
- İşlemler — "Detay" + "Durum" dropdown + "Sil"

Top bar filters:
- Status filter dropdown: Tümü | Bekliyor | Devam Ediyor | Tamamlandı | İptal | Geri Gönderildi
  Filter client-side or re-fetch
- Department filter dropdown from departments list

Status change:
- Dropdown on each row or in detail view
- Call PATCH /tasks/{task_id}/status?status={status}
- IMPORTANT: status values must be exact camelCase: waiting, inProgress, completed, cancelled, returned
- No request body, only query param
- Toast on success, refresh row

Task detail drawer/modal (click "Detay"):
- Title, description
- Status badge
- Department name, creator name, due date, created date
- Assignee list (resolve assignee_ids to user names)
- Comments section: GET /tasks/{task_id}/comments
  Show: user_id resolved to name, text, date
- Delete button → confirmation → DELETE /tasks/{task_id}

Empty state: "Henüz görev yok"

---

## PAGE 4: DEPARTMANLAR (/departments)

Fetch: GET /departments

Display as card grid (3 columns desktop, 1 mobile):

Each card shows:
- Department name (large)
- Created date
- User count (count users where department_ids includes this id — compute from cached users list, fetch GET /users?limit=1000 once)
- Task count (count tasks where department_id matches)
- Delete button (hide or disable for id "sahsy" — this is the personal/private department)

Top: "Yeni Departman" button → modal with single input "Departman Adı"
- On submit: POST /departments body { "name": "..." }
- Toast success, refresh list

Delete: confirmation dialog → DELETE /departments/{department_id}

Empty state: "Henüz departman yok"

---

## PAGE 5: SOHBETLER (/chats)

Two tabs: "Birebir" | "Grup"

TAB 1 — Direct chats:
Fetch GET /chats
Also fetch GET /users to resolve participant_id to user name

Table:
- Katılımcı (participant name + phone)
- Son Mesaj (last_message.text truncated)
- Okunmamış (unread_count badge)
- Sessize (is_muted → "Evet"/"Hayır")
- "Mesajları Gör" button

Click "Mesajları Gör":
- Fetch GET /chats/{chat_id}
- Show message list like chat bubbles: sender name (resolve sender_id), text, sent_at time
- Scrollable panel (drawer or split view)

TAB 2 — Group chats:
Fetch GET /chats/groups
Fetch GET /departments to resolve department_id

Table:
- Departman (department name)
- Son Mesaj
- Okunmamış
- "Mesajları Gör" button

Click → Fetch GET /chats/groups/{group_chat_id}/messages
Show message list same as direct chat

Empty states per tab.

---

## PAGE 6: AYARLAR (/settings)

Sections:

1. "Profil" — show current admin from /users/me: name, phone, admin badge

2. "API Bağlantısı"
   - Show API base URL (read-only)
   - Fetch GET /health — show status indicator green/red
   - "Bağlantıyı Test Et" button

3. "Görünüm"
   - Dark/Light theme toggle (persist in localStorage)

4. "Tehlikeli Bölge"
   - "Çıkış Yap" button (red outline)

---

## API HELPER / SERVICE LAYER

Create a centralized api.ts service with:
- getToken(), setTokens(), clearTokens()
- apiRequest(path, options) that auto-adds Authorization header
- auto refresh on 401
- typed interfaces for User, Task, Department, Chat, ChatMessage, GroupChat, UserTaskStats, LoginResponse

TypeScript interfaces:

User: { id, name, phone, avatar_url, is_admin, department_ids[], created_at }
Task: { id, title, description, status, department_id, creator_id, number, assignee_ids[], due_date, created_at, updated_at }
Department: { id, name, created_at }
UserTaskStats: { user_id, assigned_task_count, completed_task_count, pending_task_count }
Chat: { id, participant_id, is_muted, last_message, unread_count }
GroupChat: { id, department_id, last_message, unread_count }
ChatMessage: { id, sender_id, text, sent_at, is_read }

---

## ROUTING

/login — public
/ — Dashboard (protected)
/users — Users (protected)
/tasks — Tasks (protected)
/departments — Departments (protected)
/chats — Chats (protected)
/settings — Settings (protected)

Default redirect: / → login if not authenticated

---

## ERROR HANDLING

- Network errors → toast "API'ye bağlanılamadı"
- 403 → toast "Yetkiniz yok"
- 401 after refresh fail → redirect login
- 422 validation → show server error message
- All delete actions require confirmation modal
- All forms show loading state on submit button

---

## IMPORTANT TECHNICAL NOTES

1. Task status in API is camelCase "inProgress" NOT "in_progress"
2. PATCH task status uses query parameter, NOT request body
3. POST task comments uses query param ?text= NOT body
4. User/Task responses contain IDs not nested objects — resolve names client-side by caching users and departments lists
5. Do NOT use mock/fake data — connect to real API
6. CORS: backend must allow this app's origin — if CORS error occurs, note it in console
7. Phone format: +993XXXXXXXX (Turkmenistan)

Build the complete app with all 6 pages, working API integration, auth flow, and polished UI.
```

---

## TAKİP PROMPT'LARI (bir şey eksik kalırsa)

### CORS hatası alırsan
```
The admin app gets CORS errors when calling https://yatla-global.duckdns.org/api/v1. 
Configure all API calls to go through a server-side proxy route /api/proxy/* that forwards requests to the backend with Authorization header. Do not call the backend directly from browser.
```

### Login çalışmıyorsa
```
Fix the login flow: POST to /auth/login with { phone, password }, save tokens to localStorage, then GET /users/me and check is_admin === true before allowing dashboard access. Show Turkish error messages.
```

### Grafik eksikse
```
Add a pie chart on the Dashboard showing task status breakdown (waiting, inProgress, completed, cancelled, returned) using recharts or similar. Use the exact status colors: waiting=#F59E0B, inProgress=#3B82F6, completed=#10B981, cancelled=#EF4444, returned=#EF4444.
```

### Türkçe etiketler eksikse
```
Change all UI labels to Turkish: Dashboard=Panel, Users=Kullanıcılar, Tasks=Görevler, Departments=Departmanlar, Chats=Sohbetler, Settings=Ayarlar, Login=Giriş Yap, Logout=Çıkış Yap, Search=Ara, Delete=Sil, Cancel=İptal, Confirm=Onayla, Save=Kaydet, Loading=Yükleniyor...
```

---

## KULLANIM

1. Lovable'da yeni proje aç
2. Ana prompt'u yapıştır → Generate
3. Test için admin hesap bilgilerini gir (is_admin: true olan)
4. Hata alırsan yukarıdaki takip prompt'larından uygun olanı kullan

**Admin hesabın yoksa:** Backend'de bir kullanıcıya `is_admin = true` yapılması şart.
