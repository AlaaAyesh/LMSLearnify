# Flutter Performance Guide — Learnify

This guide focuses on **zero lag**, **smooth 60/120 FPS**, and **minimal memory** for Learnify, using Clean Architecture and high-performance patterns.

---

## 1. State Management: Bloc (Cubit) — Why It Fits

**Choice: Bloc (flutter_bloc)** — already used in the project.

| Criteria | Bloc/Cubit | Provider | Riverpod |
|----------|------------|----------|----------|
| Rebuild scope | **Precise** (BlocBuilder only rebuilds when state changes) | Can over-rebuild if not careful | Precise |
| Equatable | **Built-in** — states are compared by value; no rebuild if state equals previous | Manual | Manual |
| Testability | **Excellent** — pure events → states | Good | Good |
| Main isolate | **No heavy work in build** — logic in bloc, UI only reads state | Same | Same |

**Best practices already in use:**

- **Equatable on states** — e.g. `HomeState` with `props` so `BlocBuilder` only rebuilds when state actually changes.
- **BlocProvider above the tab** — HomeBloc is provided at navigation level so it isn’t recreated on every banner `setState`.
- **themeAnimationDuration: Duration.zero** — avoids theme transition work on every theme read.

**Avoid:**

- Creating `BlocProvider(create: ...)` inside `build()` of a widget that calls `setState` — that creates a new bloc on every rebuild and loses state.

---

## 2. Avoiding Unnecessary Rebuilds

### 2.1 Const everywhere possible

```dart
// Good
const SizedBox(height: 16)
const Text('Title', style: AppTextStyles.h1)
const CircularProgressIndicator(color: AppColors.primary)

// In lists, use const for static children
ListView.builder(
  itemBuilder: (context, index) => RepaintBoundary(
    child: CategoryItem(category: categories[index], onTap: onTap),
  ),
)
```

- Use **const** for widgets that don’t depend on runtime state (SizedBox, Icon, static Text, padding).
- Enables the compiler to reuse the same widget instance and reduces rebuild cost.

### 2.2 Split widgets

- Extract list **item** into a **StatelessWidget** (e.g. `CategoryItem`, `CourseGridCard`) so only that item rebuilds when its data changes.
- Keep **list/grid** as a separate widget; avoid huge `build()` methods that build many children inline.

### 2.3 BlocBuilder buildWhen

```dart
BlocBuilder<HomeBloc, HomeState>(
  buildWhen: (previous, current) => previous != current,
  builder: (context, state) => ...,
)
```

- With **Equatable** states, `previous != current` is value-based; combined with `buildWhen` you avoid redundant rebuilds when the emitted state is equal to the previous one.

---

## 3. UI Rendering

### 3.1 Use ListView.builder / GridView.builder

- **ListView.builder** and **GridView.builder** build only visible items (+ cache), so list size doesn’t affect initial layout cost.
- **Avoid** `ListView(children: list.map(...).toList())` for long lists — it builds every item at once.

```dart
ListView.builder(
  itemCount: courses.length,
  itemBuilder: (context, index) => RepaintBoundary(
    child: CourseGridCard(course: courses[index], onTap: onTap),
  ),
)
```

### 3.2 RepaintBoundary for expensive tiles

- Wrap **each list/grid item** (or each “row” of items) in **RepaintBoundary** so Flutter can repaint only that region when the item changes.
- Use for: course cards, reels tiles, category items, any widget with images or complex paint.

### 3.3 No heavy work in build()

- **Never** do async I/O, parsing, or heavy computation inside `build()`.
- Do it in **bloc/cubit**, **initState**, or **after first frame** (e.g. `WidgetsBinding.instance.addPostFrameCallback`).

---

## 4. Startup Speed

### 4.1 Critical path only before runApp()

- **Before `runApp()`:** only what’s needed for the first frame (e.g. `WidgetsBinding.ensureInitialized()`, Hive if splash needs it, system UI).
- **After first frame or in parallel:** CacheService, non-critical singletons, analytics.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    HiveService.init(),
    SystemChrome.setPreferredOrientations([...]),
    _setSystemUI(),
  ]);
  // Defer CacheService and DI so first paint isn't blocked
  unawaited(_deferredInit());
  runApp(const LearnifyApp());
}

Future<void> _deferredInit() async {
  await CacheService.init();
  await initDependencies();
}
```

- Optionally show splash, then call `_deferredInit()` in a post-frame callback so the first paint is as fast as possible.

### 4.2 Lazy feature loading

- Register feature dependencies in GetIt as **lazy singletons** or **factory** so they’re created only when first used (already done for blocs as `registerFactory`).

### 4.3 Route-level BlocProvider

- Provide blocs at the **route/screen** level (e.g. when opening Reels, Subscriptions), not at app root, so only the current feature pays the cost.

---

## 5. Network & Data

### 5.1 Caching

- **dio_cache_interceptor** + **MemCacheStore** (as in `CacheService`) for HTTP cache.
- Use **CachePolicy.request** (or **refresh**) and **maxStale** so repeated requests are served from memory when valid.

### 5.2 Pagination & lazy loading

- Use **page + perPage** for lists (e.g. reels, courses). Load next page when the user nears the end (e.g. `ScrollController` or `ScrollNotification`).
- Don’t fetch full list upfront; keep **pageSize** small (e.g. 10–20).

### 5.3 Avoid unnecessary data

- Prefer API endpoints that return only needed fields; avoid loading full entities when only id/name/thumbnail are needed for list items.

---

## 6. Images & Assets

### 6.1 CachedNetworkImage

- Use **cached_network_image** for all network images (already used in course cards, reels, etc.).
- Set **memCacheWidth** / **memCacheHeight** to the display size (e.g. 2x resolution) to limit memory:

```dart
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: (200 * MediaQuery.of(context).devicePixelRatio).round(),
  memCacheHeight: (200 * MediaQuery.of(context).devicePixelRatio).round(),
  ...
)
```

### 6.2 Asset size

- Compress PNGs (e.g. with `flutter_launcher_icons` or external tools); avoid oversized images in `assets/`.

---

## 7. Animations

- Prefer **lightweight** animations: **opacity**, **transform** (scale, offset). Avoid animating many layout-affecting properties at once.
- Use **AnimationController** in **State** and **dispose** it in `dispose()`.
- For simple fade/slide, **Duration.zero** or very short durations where appropriate (e.g. theme already uses `themeAnimationDuration: Duration.zero`).

---

## 8. Background Work (Isolates)

- For **heavy parsing** or **CPU-heavy algorithms**, use **isolates** so the UI thread stays free.
- Use the project’s **IsolateRunner** (`runInIsolate`) or **compute()** for top-level or static functions.

```dart
// Heavy parsing
final list = await runInIsolate(() => parseLargeJson(responseBody));
```

- Don’t use isolates for trivial work; the spawn cost (~50–100ms) isn’t worth it.

---

## 9. Checklist Summary

| Area | Do | Don’t |
|------|----|--------|
| State | Bloc + Equatable, BlocProvider at route/tab level | BlocProvider inside build() of a widget that setState’s |
| Build | const, split widgets, buildWhen | Heavy logic or async in build() |
| Lists | ListView.builder, GridView.builder, RepaintBoundary per item | ListView(children: longList) |
| Startup | Minimal work before runApp, defer CacheService/DI if possible | Block runApp on all init |
| Network | Cache, pagination, minimal payloads | Fetch all data upfront |
| Images | CachedNetworkImage, memCacheWidth/Height | Large unconstrained images |
| Animations | Short, opacity/transform | Many layout animations |
| CPU | Isolates for heavy work | Heavy work on main isolate |

Following this keeps the app **fast to open**, **smooth to scroll**, and **light on memory** on low-end devices.
