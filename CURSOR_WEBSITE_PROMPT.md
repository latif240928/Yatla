# Remember — Tanıtım Web Sitesi Cursor Prompt

> **Bu ne?** iOS uygulamanın **kamu tanıtım sitesi** (admin panel DEĞİL).  
> **Backend gerekmez** — statik/SSG site. İletişim formu opsiyonel.  
> **Cursor'a yapıştır:** Aşağıdaki `--- PROMPT BAŞLANGIÇ ---` ile `--- PROMPT BİTİŞ ---` arasını kopyala.

---

## Cursor'da nasıl kullanılır?

1. Remember projesinde yeni klasör: `website/`
2. Cursor Agent modunu aç
3. Ana prompt'u yapıştır → Enter
4. Bitince: `cd website && npm run dev`
5. Eksik kalırsa alttaki **Takip Prompt'ları**nı kullan

---

--- PROMPT BAŞLANGIÇ ---

Build a premium, production-quality marketing website for **Remember** — a team task management + messaging iOS app. This is a PUBLIC landing site (NOT an admin panel, NOT a web app clone). No backend API integration needed — this is a static/SSG marketing site with optional contact form.

Create the project in a new `website/` folder at the repo root using **Next.js 14+ (App Router)**, **TypeScript**, **Tailwind CSS**, and **Framer Motion** for animations.

---

## BRAND & PRODUCT

**App name:** Remember  
**Tagline (Turkmen — primary market):** "Toparyňyz üçin iş dolandyryşy we habarlaşma"  
**Tagline (Turkish):** "Ekibiniz için görev yönetimi ve mesajlaşma"  
**Tagline (English):** "Task management and messaging for your team"  
**Tagline (Russian):** "Управление задачами и общение для вашей команды"

**What Remember does:**
- Team/department-based task management (create, assign, track status)
- Integrated messaging (1-on-1 DM + department group chats)
- SMS phone registration (+993 Turkmenistan focus)
- 4 languages in app: Turkmen (tk), Turkish (tr), English (en), Russian (ru)
- Dark/light mode in app
- Free — no subscription

**Target audience:** Small teams, companies with departments, project groups in Turkmenistan and Central Asia.

**App Store status:** Not live yet — use "Yakında App Store'da" / "Coming Soon to App Store" CTA instead of real App Store link. Button should look ready but link to `#download` section or show coming soon badge.

---

## DESIGN SYSTEM — MATCH iOS APP EXACTLY

Use these exact colors from the iOS app (AppColors.swift):

### Light theme (default for marketing site)
```
background:     #FAF6EE  (warm cream parchment)
surface:        #FFFBF2  (warm white)
surfaceLight:   #F1E9D9  (honey)
surfaceAlt:       #E0EAFF  (sky tone)
textPrimary:    #1F2A4D  (night ink)
textSecondary:  #5C6378  (stone gray)
textHint:       #9CA0AE
primary:          #4F8CFF  (electric blue)
primaryLight:   #C8D9FF  (cloud blue)
secondary:      #36C5DC  (cyan accent)
success:          #3CB37A
warning:          #E89B3C
error:            #E94957
divider:          #E5DECC
```

### Dark theme (optional toggle)
```
background:     #0F172A
surface:        #1E293B
textPrimary:    #F8FAFC
primary:          #7DA8FF
```

### Gradients (use for hero, CTA buttons, accents)
```
Primary gradient: #4F8CFF → #3A78EA (topLeading to bottomTrailing)
Auth/Hero gradient: #FFFBF2 → #F4ECDA → #E0EAFF (cream to sky)
Chat gradient: #FAF6EE → #F2EAD8 → #E0EAFF
```

### Task status colors (for feature illustrations)
```
waiting:    #F59E0B (amber)
inProgress: #3B82F6 (blue)
completed:  #10B981 (green)
cancelled:  #EF4444 (red)
returned:   #EF4444 (red)
```

### Typography
- Headings: **Plus Jakarta Sans** or **Outfit** (geometric, modern — similar to iOS Aestetico feel)
- Body: **Inter** or **DM Sans**
- Load from Google Fonts
- Large hero headline: 56-72px desktop, 36-44px mobile, font-weight 700-800
- Body: 16-18px, line-height 1.6

### Shape & style
- Border radius: 16-24px for cards, 32-34px for pill buttons and floating elements
- Soft shadows: `0 4px 24px rgba(31, 42, 77, 0.08)`
- Card-based layouts with subtle borders (#E5DECC)
- Gradient primary buttons with hover lift (translateY -2px)
- Smooth scroll, section fade-in on scroll (Framer Motion)
- iPhone mockup frames for app screenshots (use CSS/SVG device frames)
- Premium SaaS aesthetic — think Linear.app, Raycast, or Notion landing page quality
- Generous whitespace, not cluttered
- Subtle background patterns or gradient blobs in hero (low opacity primary blue)

---

## SITE STRUCTURE & ROUTES

```
/                    → Home (main landing)
/features            → Detailed features page
/download            → Download / App Store coming soon
/about               → About the app / mission
/contact             → Contact form
/privacy             → Privacy policy (placeholder content)
/terms               → Terms of service (placeholder content)
```

### i18n — 4 languages with URL prefix
```
/tk/...   Turkmen (DEFAULT)
/tr/...
/en/...
/ru/...
```
- Language switcher in header and footer (flags or TK | TR | EN | RU)
- All UI text, headings, descriptions translated
- Default redirect: `/` → `/tk`
- Use next-intl or similar for i18n

---

## GLOBAL LAYOUT

### Header (sticky, blur backdrop on scroll)
- Left: Remember logo (text logo "Remember" in primary blue + small icon placeholder) 
- Center nav (desktop): Ana Sayfa | Aýratynlyklar/Features | Göçürip al/Download | Biz barada/About | Habarlaş/Contact
- Right: Language switcher + "App Store" CTA button (gradient, small)
- Mobile: hamburger menu → full-screen overlay nav

### Footer
- 4 columns: Product links | Company links | Legal | Language
- Remember logo + tagline
- Social icons placeholder (Instagram, Telegram)
- "© 2026 Remember. All rights reserved."
- Made with love in Turkmenistan note (optional)

---

## PAGE 1: HOME (/)

Build these sections in order with scroll animations:

### Section 1 — HERO (full viewport height, min 90vh)
- Large gradient background (authBackgroundGradient feel)
- Left column (60%):
  - Small badge: "iOS üçin elýeterli" / "Available for iOS" with Apple icon
  - Headline (huge): "Toparyňyzy dolandyryň, habarlaşyň" (tk) — translate per locale
  - Subheadline: 2 lines explaining task management + team chat in one app
  - Two buttons:
    - Primary gradient: "App Store'dan göçürip al" → scroll to #download (with "Ýakynda" coming soon badge)
    - Secondary outline: "Aýratynlyklary gör" → /features
  - Small trust line: "SMS bilen çalt hasaba alyş • 4 dil • Mugt"
- Right column (40%):
  - iPhone 15 Pro mockup (CSS/SVG frame) showing app home screen
  - Floating UI cards around phone: mini task card, chat bubble, notification badge (decorative, animated float)
  - Subtle parallax on scroll

### Section 2 — LOGO BAR / TRUST (optional)
- "Teams trust Remember" — placeholder company logos or skip if no clients yet
- OR show stats: "5 görev statusy • 4 dil • Birebir + topar söhbet"

### Section 3 — FEATURES GRID (4 cards, 2x2 desktop, 1 col mobile)
Each card: icon (Lucide) + title + description + subtle hover lift

1. **Görev Dolandyryşy / Task Management**
   - Icon: clipboard-list
   - Create tasks, assign to team, 5 status tracking, comments, file attachments
   - Show mini status badges: Bekliyor, Devam, Tamamlandı

2. **Topar Habarlaşmasy / Team Messaging**
   - Icon: message-circle
   - 1-on-1 DM + department group chats, read receipts, mute

3. **Bölüm Dolandyryşy / Department Organization**
   - Icon: building-2
   - Organize by departments, filter tasks and users

4. **Çalt Hasaba Alyş / Quick Registration**
   - Icon: smartphone
   - SMS OTP verification, phone + password, secure JWT auth

Background: subtle #E0EAFF tint section

### Section 4 — APP SHOWCASE (iPhone carousel or 5-tab strip)
Title: "Programmanyň içinden"
Show 5 iPhone mockups side by side (scroll horizontal on mobile) representing app tabs:
1. **Ýumuşlar / Home** — task list with filters
2. **Meniň işlerim / My Tasks** — create task form
3. **Ulanyjylar / Users** — user directory
4. **Söhbetler / Chats** — chat list DM + groups
5. **Sazlamalar / Settings** — profile, stats, language, theme

Each mockup: build as styled HTML/CSS components that LOOK like the app (not real screenshots needed — recreate UI faithfully using the color system). Use realistic Turkmen/Turkish placeholder text.

### Section 5 — HOW IT WORKS (3 steps, horizontal timeline)
1. **Hasaba al** — Register with phone + SMS code (30 seconds)
2. **Görev döret** — Create task, pick department, assign team
3. **Yzarla** — Track status, comment, chat with team

Each step: numbered circle (gradient) + icon + title + short text
Connecting line between steps on desktop

### Section 6 — TASK STATUS SHOWCASE
Visual strip showing 5 task statuses with colored pills:
- Garaşylýar (waiting) #F59E0B
- Ýerine ýetirilýär (inProgress) #3B82F6
- Tamamlandy (completed) #10B981
- Ýatyryldy (cancelled) #EF4444
- Yzyna gaýtaryldy (returned) #EF4444

Short text: "Her işiň statusuny real wagtda yzarlaň"

### Section 7 — LANGUAGES
4 flag/language cards: Türkmençe | Türkçe | English | Русский
"Programma 4 dilde elýeterli"

### Section 8 — DARK MODE TEASER
Split visual: light theme phone | dark theme phone
"Siz saýlaýan tema — açyk ýa-da garaňky"

### Section 9 — FINAL CTA
Full-width gradient banner (#4F8CFF → #3A78EA)
Headline: "Toparyňyzy indi dolandyryň"
Sub: Free, no credit card
Big App Store button with "Ýakynda" badge
Background: subtle pattern

---

## PAGE 2: FEATURES (/features)

Hero: "Remember-iň aýratynlyklary"

Detailed feature sections (alternating left/right layout):

1. **Görev dolandyryşy** — large mockup + bullet list:
   - Title, description, department, assignees, due date
   - 5 status workflow
   - Comments and file attachments
   - Task numbering (#42)
   - Personal "Şahsy" department for individual tasks

2. **Habarlaşma** — mockup + bullets:
   - Direct messages between users
   - Department group chats (auto-created per department)
   - Unread counts, mute, read status
   - User public profiles

3. **Ulanyjy we bölüm dolandyryşy** — bullets:
   - User directory with search
   - Department filter
   - User stats (assigned, completed, pending tasks)

4. **Howanylandyryş we howpsuzlyk** — bullets:
   - SMS OTP registration
   - JWT authentication with token refresh
   - Keychain secure storage (iOS)
   - Push notifications (coming)

5. **Statistika paneli** — bullets:
   - Task completion rates
   - Daily/weekly charts
   - Team productivity insights

Each section: icon + heading + description + visual (CSS mockup component)

Bottom CTA: Download section repeat

---

## PAGE 3: DOWNLOAD (/download)

Centered layout:
- Large Remember logo
- Headline: "Remember-i göçürip al"
- iPhone mockup
- App Store button (disabled/coming soon style):
  - Apple logo + "Download on the" + "App Store"
  - Badge overlay: "Ýakynda / Coming Soon"
- QR code placeholder (gray, "Soon")
- System requirements: iOS 17+, iPhone
- "Android ýakynda" small note (optional, grayed out)

---

## PAGE 4: ABOUT (/about)

- Mission statement: simplifying team coordination for Turkmenistan teams
- Problem we solve: scattered WhatsApp groups + paper tasks → one organized app
- Values: Simple, Secure, Multilingual, Free
- Team section placeholder (optional avatar cards)
- Timeline: v1.0 iOS launch 2026

---

## PAGE 5: CONTACT (/contact)

- Contact form: Name, Email, Phone (optional), Message, Submit button
- For now: form submits to console.log or mailto: — no backend required
- Show: support email placeholder hello@remember.app
- Telegram link placeholder
- Office location: Ashgabat, Turkmenistan (optional)

---

## PAGE 6 & 7: PRIVACY & TERMS

Generate reasonable placeholder legal pages with sections:
- Privacy: data collected (phone, name, tasks, messages), SMS OTP, data storage, user rights
- Terms: acceptable use, account responsibility, service availability
- Professional legal tone, 4 languages

---

## ANIMATIONS & INTERACTIONS (Framer Motion)

- Hero elements: stagger fade-up on page load (0.1s delay each)
- Feature cards: fade-up on scroll into view (viewport once)
- iPhone mockup: subtle float animation (y: -10 to 10, 4s loop)
- Header: backdrop-blur + shadow on scroll > 50px
- Buttons: scale 0.98 on click, hover lift -2px
- Page transitions: smooth fade between routes
- Mobile menu: slide from right with overlay fade
- Stats/numbers: optional count-up animation on scroll

Keep animations subtle and performant — premium feel, not flashy.

---

## SEO & META

Every page needs:
```html
<title>Remember — Topar iş dolandyryşy we habarlaşma</title>
<meta name="description" content="..." />
<meta property="og:title" content="Remember" />
<meta property="og:description" content="..." />
<meta property="og:type" content="website" />
<meta name="twitter:card" content="summary_large_image" />
<link rel="alternate" hreflang="tk" href="/tk" />
<link rel="alternate" hreflang="tr" href="/tr" />
<link rel="alternate" hreflang="en" href="/en" />
<link rel="alternate" hreflang="ru" href="/ru" />
```

Add JSON-LD structured data on homepage:
```json
{
  "@context": "https://schema.org",
  "@type": "MobileApplication",
  "name": "Remember",
  "operatingSystem": "iOS",
  "applicationCategory": "BusinessApplication",
  "offers": { "@type": "Offer", "price": "0" }
}
```

---

## TECHNICAL REQUIREMENTS

```
website/
├── src/
│   ├── app/
│   │   ├── [locale]/
│   │   │   ├── page.tsx           (home)
│   │   │   ├── features/page.tsx
│   │   │   ├── download/page.tsx
│   │   │   ├── about/page.tsx
│   │   │   ├── contact/page.tsx
│   │   │   ├── privacy/page.tsx
│   │   │   └── terms/page.tsx
│   │   └── layout.tsx
│   ├── components/
│   │   ├── layout/ Header, Footer, MobileMenu
│   │   ├── sections/ Hero, Features, Showcase, HowItWorks, CTA, etc.
│   │   ├── ui/ Button, Badge, Card, LanguageSwitcher
│   │   └── mockups/ IPhoneFrame, TaskCardMock, ChatMock, AppTabMock
│   ├── lib/
│   │   └── i18n/ messages/tk.json, tr.json, en.json, ru.json
│   └── styles/
│       └── globals.css (CSS variables for color tokens)
├── public/
│   └── (logo placeholder, og-image placeholder)
├── tailwind.config.ts (extend with brand colors)
├── next.config.ts
└── package.json
```

- **No backend API calls** — pure static marketing site
- **No Supabase, no database**
- Mobile-first responsive (breakpoints: sm 640, md 768, lg 1024, xl 1280)
- Lighthouse target: 90+ performance, 100 accessibility
- Use next/image for optimized images
- Use CSS variables for theme colors in globals.css
- All components typed with TypeScript
- ESLint + Prettier configured

---

## i18n CONTENT FILES

Create complete translation files for ALL visible text. Example structure for `messages/tk.json`:

```json
{
  "nav": {
    "home": "Baş sahypa",
    "features": "Aýratynlyklar",
    "download": "Göçürip al",
    "about": "Biz barada",
    "contact": "Habarlaş"
  },
  "hero": {
    "badge": "iOS üçin elýeterli",
    "title": "Toparyňyzy dolandyryň, habarlaşyň",
    "subtitle": "Görev dolandyryşy we topar habarlaşmasy bir programmada. SMS bilen çalt hasaba alyş.",
    "ctaPrimary": "App Store'dan göçürip al",
    "ctaSecondary": "Aýratynlyklary gör",
    "trust": "SMS bilen çalt hasaba alyş • 4 dil • Mugt"
  },
  "features": { ... },
  "howItWorks": { ... },
  "cta": { ... },
  "footer": { ... }
}
```

Provide FULL translations for tk, tr, en, ru — do not leave placeholder English in non-en locales.

---

## QUALITY BAR — THIS MUST FEEL PREMIUM

- NOT a generic Bootstrap template
- NOT a basic Tailwind UI kit clone
- SHOULD feel like a real product launch page for a funded startup
- Pixel-perfect spacing (8px grid system)
- Consistent 16-24px padding in cards
- Beautiful hero that makes you want to download the app
- App mockups should look like the REAL Remember app (cream background #FAF6EE, blue primary #4F8CFF, rounded cards, bottom tab bar with 5 tabs)
- Smooth, polished, professional
- Every section should have visual interest — not just text blocks

Build ALL pages, ALL 4 languages, ALL sections. Make it complete and deploy-ready.

--- PROMPT BİTİŞ ---

---

## TAKİP PROMPT'LARI (Cursor'da eksik kalırsa)

### iPhone mockup'ları gerçekçi değilse
```
The iPhone app mockup components don't look like the real Remember app. 
Recreate them faithfully:
- Background #FAF6EE cream
- Primary blue #4F8CFF buttons and accents  
- Bottom tab bar with 5 tabs: Home, My Tasks, Users, Chats, Settings (with Turkmen labels)
- Task cards with colored status badges (waiting=#F59E0B, inProgress=#3B82F6, completed=#10B981)
- Rounded corners 22px on cards
- Floating tab bar capsule shape at bottom
Reference the iOS design: warm cream + electric blue, not generic gray/white.
```

### Animasyonlar eksikse
```
Add Framer Motion animations:
- Hero: stagger fade-up on load
- All sections: fade-up on scroll (viewport once, 0.6s duration)
- iPhone mockup: infinite float y-axis ±8px, 4s ease-in-out
- Header: add backdrop-blur-md and shadow when scrolled past 50px
- Buttons: whileHover scale 1.02 translateY -2px, whileTap scale 0.98
```

### Türkmençe çeviri eksikse
```
Complete ALL Turkmen (tk) translations in messages/tk.json. 
Every visible string must be translated — nav, hero, features, how it works, footer, contact form, download page, about page. 
Default locale is Turkmen (tk). No English fallback in tk locale.
```

### SEO eksikse
```
Add complete SEO to all pages:
- Dynamic metadata per page and locale using Next.js generateMetadata
- Open Graph tags with og:image placeholder
- hreflang alternates for tk, tr, en, ru
- JSON-LD MobileApplication schema on homepage
- sitemap.xml and robots.txt
```

### Performans
```
Optimize for Lighthouse 90+:
- Use next/image for all images with proper sizes
- Lazy load below-fold sections
- Preload Plus Jakarta Sans font
- Minimize Framer Motion bundle (use LazyMotion)
```

---

## ÖNEMLİ NOTLAR

| Soru | Cevap |
|------|-------|
| Backend gerekli mi? | **Hayır** — statik tanıtım sitesi |
| Admin panel ile karışmasın | Admin = yönetim. Bu site = tanıtım/indirme |
| App Store linki | Henüz yok → "Yakında / Coming Soon" |
| Varsayılan dil | **Türkmençe (tk)** |
| Renkler | iOS app ile birebir (#FAF6EE, #4F8CFF) |
| Proje klasörü | `website/` (repo kökünde) |

---

## Deploy (site hazır olunca)

```bash
cd website
npm run build
# Vercel: vercel.com → import repo → root directory: website
# Domain: remember.app veya remember.com
```

---

*Bu prompt Remember iOS uygulamasının gerçek tasarım sistemi ve özelliklerine göre hazırlanmıştır.*
