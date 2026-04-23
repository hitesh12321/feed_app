# 📸 Feed App — High-Performance Flutter Feed

A high-performance, infinite-scrolling social feed built with Flutter and Supabase, focused on GPU optimization, memory management, and optimistic UI state.

> **Assignment:** Flutter Engineering Assignment — High-Performance Feed  
> **Author:** [hitesh12321](https://github.com/hitesh12321)  
> **Repo:** https://github.com/hitesh12321/feed_app

---

## 📱 Demo

> 🎥 Screen recording coming soon — will demonstrate infinite scroll, Hero transition, and optimistic like with offline revert.

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| State Management | Riverpod (`StateNotifierProvider`) |
| Backend | Supabase (Database, Storage, RPC) |
| Image Loading | `Image.network` with `cacheWidth` |
| Download | Dio (HTTP client) + Gal (Gallery save) |
| Env Config | `flutter_dotenv` |

---

## 🚀 Features

- **Infinite Scroll Feed** — Paginated REST API (10 posts per page), pull-to-refresh
- **GPU Protection** — `RepaintBoundary` on every post card to prevent shadow re-rasterization during fast scroll
- **RAM Protection** — `cacheWidth` set to physical pixel size (`screenWidth × devicePixelRatio`) to prevent OOM
- **Hero Animation** — Smooth thumb → detail screen transition using cached image
- **Tiered Image Loading** — Thumbnail in feed → Mobile (1080p) fade-in on detail → Raw only on download request
- **Optimistic Like UI** — Instant heart animation, debounced RPC sync, offline revert with SnackBar
- **Offline Detection** — Real DNS lookup via `InternetAddress.lookup` (not just connectivity status)

---

## 📐 Riverpod State Management Approach

### 1. Feed State — `feedProvider` (StateNotifierProvider)

`FeedNotifier` manages pagination state including the post list, current page, loading flags, and `hasMore`. On scroll end (200px before bottom), `fetchMore()` is called. Pull-to-refresh calls `fetchInitial()` which resets state and re-fetches from page 0.

### 2. Like State — `likeProvider` (StateNotifierProvider.family)

Each post card gets its own isolated `LikeNotifier` instance via `.family`, keyed by a Record tuple `(postId, userId, initialIsLiked, initialLikeCount)`.

**Optimistic flow:**
1. UI updates instantly on tap (heart turns red, count changes)
2. A debounce timer (800ms) resets on every tap
3. After the last tap, one single RPC call fires
4. On success — `_serverIsLiked` and `_serverLikeCount` are updated
5. On failure or no internet — state reverts to last confirmed server values + SnackBar shown

This ensures the database is never desynced even with spam clicking (15 taps in 2 seconds = 1 RPC call).

### 3. User Liked Posts — `userLikedProvider` (FutureProvider.family)

Fetches all post IDs liked by the current user from `user_likes` table in a single query. The result is passed as `initialIsLiked` to each `PostCard` — this avoids making N individual network calls per card.

```dart
final userLiked = ref.watch(userLikedProvider(kUserId));
final likedIds = userLiked.asData?.value ?? [];
// then per card:
initialIsLiked: likedIds.contains(post.id)
```

### 4. Liked Page URLs — `LikedPostsurlProvider` (FutureProvider.family)

Takes the full list of liked post IDs and fetches all their `media_thumb_url` values in one batch query using `.inFilter()` — instead of N individual queries per liked post.

### Why FutureProvider for 3 & 4, not StateNotifier?

`FutureProvider` is the right fit here because these are **read-only, one-time async fetches** with no local mutation needed. The `.when(data, loading, error)` API gives clean handling of all three states out of the box. Using `StateNotifier` would be unnecessary complexity for data that doesn't need to be mutated locally.

---

## ✅ RepaintBoundary Verification

Every `PostCard` is wrapped in `RepaintBoundary`:

```dart
return RepaintBoundary(
  child: Container(
    decoration: BoxDecoration(
      boxShadow: [BoxShadow(blurRadius: 20, spreadRadius: 5, ...)],
    ),
    ...
  ),
);
```

**How verified:** Opened Flutter DevTools → Navigate to **Rendering** tab → Enabled **Highlight Repaints**. During fast scrolling, only the `ListView` viewport repaints — individual cards do not flash, confirming they are promoted to their own compositing layer and the shadow math is not recalculated per frame.

---

## ✅ cacheWidth / memCacheWidth Verification

```dart
final screenWidth = MediaQuery.of(context).size.width;
final dpr = MediaQuery.of(context).devicePixelRatio;
final cacheW = (screenWidth * dpr).toInt();

Image.network(
  url,
  cacheWidth: cacheW,
  ...
)
```

**Why:** Without `cacheWidth`, Flutter decodes images at their native resolution into RAM then downscales on GPU — wasting memory. By setting `cacheWidth` to the exact physical pixel width of the display area, the decoded bitmap footprint matches the rendered size precisely.

**How verified:** Opened Flutter DevTools → **Memory** tab → Monitored heap while scrolling. Image memory stayed bounded instead of growing unbounded with each new card loaded.

---

## 🗄️ Backend — Supabase Setup

### Tables

```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  media_thumb_url TEXT,
  media_mobile_url TEXT,
  media_raw_url TEXT,
  like_count INT DEFAULT 0
);

CREATE TABLE user_likes (
  user_id TEXT,
  post_id UUID REFERENCES posts(id),
  PRIMARY KEY (user_id, post_id)
);
```

### toggle_like RPC

A custom PostgreSQL function handles like/unlike atomically with race condition protection. It first attempts a DELETE — if a row existed, it decrements `like_count`. If no row existed, it INSERTs and increments. A `EXCEPTION WHEN unique_violation` block handles concurrent simultaneous likes gracefully.

---

## 🖼️ Image Pipeline (3-Tier)

Each image is seeded in 3 versions via a Python script:

| Version | Max Size | Format | Usage |
|---|---|---|---|
| Thumbnail | 300×300 | WebP 70% | Feed cards (RAM optimized) |
| Mobile | 1080×1080 | WebP 80% | Detail screen (fade-in) |
| Raw | Original | Original | Download only (on demand) |

---

## ⚙️ Setup & Run

### 1. Clone

```bash
git clone https://github.com/hitesh12321/feed_app.git
cd feed_app
```

### 2. Create `.env` file

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
USER_ID=user_123
```

### 3. Run Supabase SQL

Run the table creation and `toggle_like` RPC SQL in your Supabase SQL Editor (see Backend section above).

### 4. Seed Data

```bash
pip install supabase Pillow
# Add 4K images to input_images/
python seed.py
```

### 5. Run App

```bash
flutter pub get
flutter run
```

---

## 📂 Project Structure

```
lib/
├── main.dart
├── Models/
│   ├── post.dart
│   └── user_like_model.dart
├── Providers/
│   ├── posts_provider.dart
│   ├── like_provider.dart
│   ├── liked_posts_provider.dart
│   └── user_provider.dart
├── Screens/
│   ├── feed_screen.dart
│   ├── details_screen.dart
│   └── LikedPage.dart
├── Widgets/
│   └── post_card.dart
└── utils/
    └── check_internet.dart
```

---

## 🧪 Edge Cases Handled

| Scenario | Handling |
|---|---|
| Spam clicking Like (15 taps/2s) | Debounce — only 1 RPC fires after last tap |
| Fast scrolling jank | `RepaintBoundary` prevents shadow re-rasterization |
| Offline like | Optimistic update → DNS check fails → UI reverts → SnackBar shown |
| OOM on image-heavy scroll | `cacheWidth` bounds decoded bitmap to display size |
| Concurrent likes (race condition) | PostgreSQL atomic RPC with `unique_violation` guard |