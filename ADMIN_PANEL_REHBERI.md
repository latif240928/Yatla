# Remember Admin Panel — Başlangıç ve Yapım Rehberi

Bu rehber, Remember (Yatla) iOS uygulamanız için admin panelini **sıfırdan nasıl planlayıp kodlayacağınızı** adım adım anlatır.

---

## Önce şunu bil

Admin panel **iki parçadan** oluşur:

```
┌─────────────────────┐         ┌─────────────────────┐
│   Admin Web Sitesi  │  HTTP   │   Backend (FastAPI) │
│   (sen yazacaksın)  │ ──────► │   (zaten var)       │
│   React / Next.js   │  JWT    │   + eksik endpoint  │
└─────────────────────┘         └─────────────────────┘
```

- **Backend:** Kullanıcı, görev, departman, chat verilerini tutuyor. API'nin büyük kısmı hazır.
- **Admin web:** Tarayıcıda açılan yönetim arayüzü. Bunu sen sıfırdan yazacaksın.

iOS uygulaması ile admin panel **aynı API'yi** kullanır. Fark: admin panelde `is_admin: true` olan hesapla giriş yaparsın.

---

## Admin panelde ne yöneteceksin?

Uygulamana göre admin panelde olması gereken modüller:

| Modül | Ne yapacaksın | API durumu |
|-------|---------------|------------|
| **Dashboard** | Toplam kullanıcı, görev, departman; grafikler | Kısmen hazır (birleştirmen lazım) |
| **Kullanıcılar** | Gelen kayıtları gör, ara, düzenle, sil, admin yap | Çoğu hazır |
| **Departmanlar** | Oluştur, listele, sil | Hazır |
| **Görevler** | Tüm görevleri gör, durum değiştir, sil | Hazır |
| **Sohbetler** | DM ve grup mesajlarını izle | Kısmen hazır |
| **Bildirimler** | Push gönder, geçmiş | Backend TODO |
| **Ayarlar** | Sistem durumu, health check | Health hazır |

---

## Adım 0 — Ortamını hazırla

Bilgisayarında şunlar olmalı:

```bash
node -v    # v18 veya üzeri
npm -v     # veya pnpm / yarn
git --version
```

Kurulu değilse: [nodejs.org](https://nodejs.org) → LTS sürümünü indir.

**API test aracı:** Postman veya Insomnia kur. Projede `openapi.json` var — Postman'e import et.

**Backend URL (aktif):**
```
https://yatla-global.duckdns.org/api/v1
```

---

## Adım 1 — API'yi tanı (Postman ile)

Admin yazmadan önce API'yi elle test et. Bu adım çok önemli.

### 1.1 Giriş yap

```http
POST https://yatla-global.duckdns.org/api/v1/auth/login
Content-Type: application/json

{
  "phone": "+9936XXXXXXXX",
  "password": "Sifren123"
}
```

Yanıt:
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer"
}
```

### 1.2 Token ile kullanıcı listesi al

```http
GET https://yatla-global.duckdns.org/api/v1/users?skip=0&limit=50
Authorization: Bearer eyJ... (access_token)
```

### 1.3 Kendi profilini kontrol et

```http
GET https://yatla-global.duckdns.org/api/v1/users/me
Authorization: Bearer eyJ...
```

Yanıtta `"is_admin": true` olmalı. Admin panel için bu şart.

> **İlk admin hesabı:** Backend veritabanında bir kullanıcının `is_admin` alanını `true` yapman lazım. Backend koduna erişimin varsa oradan; yoksa backend geliştiriciden iste.

---

## Adım 2 — Backend'de eksik olanları tamamla

Mevcut API ile admin panelin **%70'ini** yapabilirsin. Ama production için backend'e şunlar eklenmeli:

### Zorunlu (güvenlik)

Backend geliştiriciye ver veya kendin ekle:

```python
# Örnek FastAPI dependency — admin-only endpoint'ler için
def require_admin(current_user: User = Depends(get_current_user)):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Admin required")
    return current_user
```

**Eklenmesi gereken endpoint'ler:**

| Endpoint | Açıklama |
|----------|----------|
| `PATCH /users/{id}/admin` | `{ "is_admin": true/false }` — admin yetkisi ver/al |
| `GET /admin/stats` | Dashboard için toplu istatistik |
| `GET /admin/chats` | Tüm sohbetleri listele (admin-only) |
| `GET /admin/chats/{id}/messages` | Herhangi bir sohbetin mesajları |
| `DELETE /admin/messages/{id}` | Mesaj sil (moderasyon) |

### `GET /admin/stats` örnek yanıt

Backend'de böyle bir endpoint olmalı (şu an yok, iOS mock kullanıyor):

```json
{
  "total_users": 142,
  "total_tasks": 890,
  "total_departments": 12,
  "tasks_by_status": {
    "waiting": 120,
    "inProgress": 45,
    "completed": 680,
    "cancelled": 30,
    "returned": 15
  },
  "new_users_today": 5,
  "new_users_this_week": 23,
  "tasks_created_today": 18,
  "tasks_completed_today": 12,
  "active_chats": 34
}
```

> **Pratik yol:** Backend endpoint'leri hazır olana kadar admin panelde mevcut API'lerden veriyi birleştir (`GET /users` + `GET /tasks` + `GET /departments`). Yavaş ama çalışır.

Detaylı backend spec için: `ADMIN_BACKEND_SPEC.md` dosyasına bak.

---

## Adım 3 — Proje oluştur (Next.js)

Admin panel için **Next.js + TypeScript + Tailwind** öneriyorum. Sebebi: hızlı başlangıç, hazır UI kütüphaneleri, kolay deploy.

### 3.1 Projeyi oluştur

Terminalde Remember klasörünün **dışında** veya içinde `admin/` alt klasöründe:

```bash
cd /Users/latif/Desktop/Latif/Remember

npx create-next-app@latest admin \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*"
```

Sorular gelirse:
- Would you like to use Turbopack? → **No** (başlangıçta)
- Would you like to customize the import alias? → **No** (default `@/*`)

### 3.2 UI kütüphanesi ekle (shadcn/ui)

Admin panellerde tablo, dialog, form için en pratik seçenek:

```bash
cd admin
npx shadcn@latest init
```

Sorular:
- Style: **Default**
- Base color: **Slate** veya **Zinc**
- CSS variables: **Yes**

Sonra sık kullanılan bileşenleri ekle:

```bash
npx shadcn@latest add button card table input label dialog badge avatar dropdown-menu sidebar sheet toast
```

### 3.3 Ortam değişkenleri

`admin/.env.local` dosyası oluştur:

```env
NEXT_PUBLIC_API_BASE_URL=https://yatla-global.duckdns.org/api/v1
```

Local backend test için:
```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api/v1
```

### 3.4 Klasör yapısı (hedef)

```
admin/
├── src/
│   ├── app/
│   │   ├── layout.tsx          # Ana layout (sidebar)
│   │   ├── page.tsx            # Dashboard
│   │   ├── login/
│   │   │   └── page.tsx        # Giriş ekranı
│   │   ├── users/
│   │   │   ├── page.tsx        # Kullanıcı listesi
│   │   │   └── [id]/page.tsx   # Kullanıcı detay
│   │   ├── tasks/
│   │   │   ├── page.tsx
│   │   │   └── [id]/page.tsx
│   │   ├── departments/
│   │   │   └── page.tsx
│   │   └── chats/
│   │       └── page.tsx
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Sidebar.tsx
│   │   │   └── Header.tsx
│   │   └── ui/                 # shadcn bileşenleri
│   ├── lib/
│   │   ├── api.ts              # HTTP client
│   │   ├── auth.ts             # Token yönetimi
│   │   └── types.ts            # TypeScript tipleri
│   └── hooks/
│       └── useAuth.ts
├── .env.local
└── package.json
```

---

## Adım 4 — API client yaz

`src/lib/types.ts`:

```typescript
export interface User {
  id: string;
  name: string;
  phone: string;
  avatar_url: string | null;
  is_admin: boolean;
  department_ids: string[];
  created_at: string;
}

export interface Task {
  id: string;
  title: string;
  description: string | null;
  status: 'waiting' | 'inProgress' | 'completed' | 'cancelled' | 'returned';
  department_id: string | null;
  creator_id: string;
  number: number;
  assignee_ids: string[];
  due_date: string | null;
  created_at: string;
  updated_at: string | null;
}

export interface Department {
  id: string;
  name: string;
  created_at: string;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
}

export interface UserTaskStats {
  user_id: string;
  assigned_task_count: number;
  completed_task_count: number;
  pending_task_count: number;
}
```

`src/lib/auth.ts`:

```typescript
const ACCESS_KEY = 'remember_admin_access';
const REFRESH_KEY = 'remember_admin_refresh';

export function saveTokens(access: string, refresh: string) {
  if (typeof window === 'undefined') return;
  localStorage.setItem(ACCESS_KEY, access);
  localStorage.setItem(REFRESH_KEY, refresh);
}

export function getAccessToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(ACCESS_KEY);
}

export function clearTokens() {
  if (typeof window === 'undefined') return;
  localStorage.removeItem(ACCESS_KEY);
  localStorage.removeItem(REFRESH_KEY);
}

export function isLoggedIn(): boolean {
  return !!getAccessToken();
}
```

`src/lib/api.ts`:

```typescript
import { getAccessToken, clearTokens, saveTokens } from './auth';
import type { User, Task, Department, LoginResponse, UserTaskStats } from './types';

const BASE = process.env.NEXT_PUBLIC_API_BASE_URL!;

async function request<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const token = getAccessToken();
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...options.headers,
  };

  let res = await fetch(`${BASE}${path}`, { ...options, headers });

  // 401 → token yenile
  if (res.status === 401 && token) {
    const refreshed = await refreshToken();
    if (refreshed) {
      headers.Authorization = `Bearer ${getAccessToken()}`;
      res = await fetch(`${BASE}${path}`, { ...options, headers });
    } else {
      clearTokens();
      window.location.href = '/login';
      throw new Error('Session expired');
    }
  }

  if (!res.ok) {
    const err = await res.text();
    throw new Error(err || `HTTP ${res.status}`);
  }

  if (res.status === 204) return {} as T;
  return res.json();
}

async function refreshToken(): Promise<boolean> {
  const refresh = localStorage.getItem('remember_admin_refresh');
  if (!refresh) return false;
  try {
    const res = await fetch(`${BASE}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: refresh, token_type: 'bearer' }),
    });
    if (!res.ok) return false;
    const data: LoginResponse = await res.json();
    saveTokens(data.access_token, data.refresh_token);
    return true;
  } catch {
    return false;
  }
}

// ── Auth ──
export async function login(phone: string, password: string) {
  const data = await request<LoginResponse>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ phone, password }),
  });
  saveTokens(data.access_token, data.refresh_token);
  return data;
}

export async function getMe(): Promise<User> {
  return request<User>('/users/me');
}

// ── Users ──
export async function getUsers(skip = 0, limit = 50): Promise<User[]> {
  return request<User[]>(`/users?skip=${skip}&limit=${limit}`);
}

export async function searchUsers(q: string): Promise<User[]> {
  return request<User[]>(`/users/search?q=${encodeURIComponent(q)}`);
}

export async function deleteUser(id: string): Promise<void> {
  await request(`/users/${id}`, { method: 'DELETE' });
}

export async function getUserStats(id: string): Promise<UserTaskStats> {
  return request<UserTaskStats>(`/users/${id}/stats`);
}

// ── Tasks ──
export async function getTasks(skip = 0, limit = 50): Promise<Task[]> {
  return request<Task[]>(`/tasks?skip=${skip}&limit=${limit}`);
}

export async function updateTaskStatus(taskId: string, status: Task['status']) {
  return request<Task>(`/tasks/${taskId}/status?status=${status}`, {
    method: 'PATCH',
  });
}

export async function deleteTask(id: string): Promise<void> {
  await request(`/tasks/${id}`, { method: 'DELETE' });
}

// ── Departments ──
export async function getDepartments(): Promise<Department[]> {
  return request<Department[]>('/departments');
}

export async function createDepartment(name: string): Promise<Department> {
  return request<Department>('/departments', {
    method: 'POST',
    body: JSON.stringify({ name }),
  });
}

export async function deleteDepartment(id: string): Promise<void> {
  await request(`/departments/${id}`, { method: 'DELETE' });
}

// ── Dashboard (mevcut API'den türet — geçici) ──
export async function getDashboardStats() {
  const [users, tasks, departments] = await Promise.all([
    getUsers(0, 1000),
    getTasks(0, 1000),
    getDepartments(),
  ]);

  const today = new Date().toISOString().slice(0, 10);
  const newUsersToday = users.filter(u => u.created_at.startsWith(today)).length;

  const byStatus = tasks.reduce(
    (acc, t) => {
      acc[t.status] = (acc[t.status] || 0) + 1;
      return acc;
    },
    {} as Record<string, number>
  );

  return {
    total_users: users.length,
    total_tasks: tasks.length,
    total_departments: departments.length,
    new_users_today: newUsersToday,
    tasks_by_status: byStatus,
  };
}
```

---

## Adım 5 — Giriş sayfası

`src/app/login/page.tsx` (basit örnek):

```tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { login, getMe } from '@/lib/api';

export default function LoginPage() {
  const router = useRouter();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(phone, password);
      const me = await getMe();
      if (!me.is_admin) {
        setError('Bu hesap admin yetkisine sahip değil.');
        return;
      }
      router.push('/');
    } catch {
      setError('Telefon veya şifre hatalı.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-zinc-950">
      <form onSubmit={handleSubmit} className="w-full max-w-sm space-y-4 p-8 bg-zinc-900 rounded-xl border border-zinc-800">
        <h1 className="text-2xl font-bold text-white">Remember Admin</h1>
        <input
          type="tel"
          placeholder="+9936..."
          value={phone}
          onChange={e => setPhone(e.target.value)}
          className="w-full px-4 py-2 rounded-lg bg-zinc-800 text-white border border-zinc-700"
          required
        />
        <input
          type="password"
          placeholder="Şifre"
          value={password}
          onChange={e => setPassword(e.target.value)}
          className="w-full px-4 py-2 rounded-lg bg-zinc-800 text-white border border-zinc-700"
          required
        />
        {error && <p className="text-red-400 text-sm">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full py-2 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-500 disabled:opacity-50"
        >
          {loading ? 'Giriş yapılıyor...' : 'Giriş Yap'}
        </button>
      </form>
    </div>
  );
}
```

---

## Adım 6 — Route koruması (admin guard)

Giriş yapmadan dashboard'a gidilmesin diye `src/middleware.ts`:

```typescript
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const isLoginPage = request.nextUrl.pathname === '/login';
  const token = request.cookies.get('admin_token')?.value;

  // Not: localStorage middleware'de okunamaz.
  // İlk aşamada client-side guard yeterli; production'da httpOnly cookie kullan.
  if (!isLoginPage && !token) {
    // Client-side redirect için login'e yönlendir
    // Gelişmiş versiyonda token'ı cookie'ye yaz
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
```

> **Not:** Başlangıçta her sayfada `useEffect` ile `getMe()` + `is_admin` kontrolü yapmak daha kolay. Cookie tabanlı auth'u ikinci aşamada ekle.

---

## Adım 7 — Modülleri sırayla yap

Aşağıdaki sırayı takip et. Her modül bitince bir sonrakine geç.

### Hafta 1 — Temel iskelet

| Gün | İş |
|-----|-----|
| 1 | Postman'de API test, admin hesabı oluştur |
| 2 | Next.js projesi kur, shadcn ekle |
| 3 | `api.ts` + `types.ts` + login sayfası |
| 4 | Sidebar layout + dashboard boş sayfa |
| 5 | Dashboard istatistik kartları |

**Dashboard kartları:**
- Toplam kullanıcı
- Toplam görev
- Toplam departman
- Bugün kayıt olan kullanıcı
- Görev durum dağılımı (pasta grafik — recharts kütüphanesi)

```bash
npm install recharts
```

### Hafta 2 — Kullanıcı yönetimi

**`/users` sayfası:**
- Tablo: ad, telefon, departman sayısı, admin mi, kayıt tarihi
- Arama kutusu → `GET /users/search?q=`
- Satıra tıkla → detay sayfası
- Sil butonu → onay dialog → `DELETE /users/{id}`
- Admin badge (is_admin true ise)

**`/users/[id]` detay:**
- Profil bilgileri
- Görev istatistikleri (`GET /users/{id}/stats`)
- Son görevleri (tasks listesinden filtrele)

### Hafta 3 — Görev ve departman

**`/tasks` sayfası:**
- Tablo: #numara, başlık, durum (renkli badge), departman, oluşturan, tarih
- Durum filtresi (5 durum — iOS'taki renklerle aynı)
- Durum değiştir dropdown → `PATCH /tasks/{id}/status?status=`
- Sil butonu

**Durum renkleri (iOS ile aynı tut):**
| Durum | Renk |
|-------|------|
| waiting | #F59E0B |
| inProgress | #3B82F6 |
| completed | #10B981 |
| cancelled / returned | #EF4444 |

**`/departments` sayfası:**
- Liste + yeni departman formu
- Sil (dikkat: bağlı kullanıcı/görev varsa backend hata verebilir)

### Hafta 4 — Sohbetler ve cilalama

**`/chats` sayfası:**
- Birebir + grup sekmeleri
- `GET /chats` ve `GET /chats/groups`
- Sohbete tıkla → mesaj geçmişi

> Tüm sohbetleri görmek için backend'de admin endpoint lazım. Şimdilik kendi token'ınla erişebildiğin sohbetleri göster.

**Cilalama:**
- Loading skeleton
- Hata mesajları (toast)
- Boş durum illüstrasyonları
- Responsive sidebar (mobilde drawer)

---

## Adım 8 — Sidebar menü

```
📊 Dashboard        → /
👥 Kullanıcılar     → /users
📋 Görevler         → /tasks
🏢 Departmanlar     → /departments
💬 Sohbetler        → /chats
🔔 Bildirimler      → /notifications (backend hazır olunca)
⚙️  Ayarlar          → /settings
🚪 Çıkış
```

---

## Adım 9 — Deploy (yayına al)

### Vercel (en kolay)

```bash
cd admin
npm run build   # hata var mı kontrol et
```

1. [vercel.com](https://vercel.com) → GitHub repo bağla
2. Root directory: `admin`
3. Environment variable: `NEXT_PUBLIC_API_BASE_URL`
4. Deploy

Admin URL örneği: `https://admin.remember.com` veya `https://remember-admin.vercel.app`

### Güvenlik (production)

- [ ] Admin paneli sadece HTTPS
- [ ] Backend'de `is_admin` kontrolü tüm admin endpoint'lerde
- [ ] Rate limiting (brute force login koruması)
- [ ] Admin panel URL'sini gizli tut (robots.txt: Disallow)
- [ ] İleride: 2FA ekle

---

## Sık yapılan hatalar

| Hata | Çözüm |
|------|-------|
| CORS hatası | Backend'e admin domain'ini `allow_origins`'e ekle |
| 401 sürekli | Token refresh logic kontrol et |
| `is_admin: false` | DB'de kullanıcıyı admin yap |
| Boş kullanıcı listesi | Token doğru mu, limit parametresi var mı |
| Task status hata | `inProgress` camelCase — `in_progress` değil |

---

## CORS — Backend'de yapılması gereken

Admin panel farklı domain'den API'ye istek atınca CORS hatası alırsın. FastAPI'de:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",           # local dev
        "https://admin.remember.com",      # production
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## Özet: Bugün ne yap?

1. **Postman kur** → `openapi.json` import et → login test et
2. **Admin hesabı** al (backend'de `is_admin = true`)
3. **Terminalde:**
   ```bash
   cd /Users/latif/Desktop/Latif/Remember
   npx create-next-app@latest admin --typescript --tailwind --eslint --app --src-dir
   cd admin && npx shadcn@latest init
   ```
4. **`src/lib/api.ts`** dosyasını yukarıdaki kodla oluştur
5. **Login sayfasını** yaz ve test et
6. **Dashboard'a** 4 istatistik kartı koy

Bu 6 adımı bitirdiğinde admin panelinin temeli hazır. Sonra modül modül devam edersin.

---

## Yardımcı dosyalar

| Dosya | İçerik |
|-------|--------|
| `WEB_DEVELOPER_BRIEF.md` | Uygulamanın genel tanımı |
| `ADMIN_BACKEND_SPEC.md` | Backend'e eklenecek endpoint spec |
| `openapi.json` | API sözleşmesi (Postman import) |
| `Remember/Remember/BACKEND_API_CONTRACT.md` | Türkçe API özeti |

---

*Soruların olursa veya bir sonraki adımda admin projesini birlikte scaffold etmemi istersen söyle — login + dashboard + users sayfasını kod olarak başlatabilirim.*
