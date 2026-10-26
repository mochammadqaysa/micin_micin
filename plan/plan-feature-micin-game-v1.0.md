---
goal: "Micin Micin — Flutter Android Game Clone of Sugar Sugar"
version: "1.3"
date_created: "2026-09-07"
last_updated: "2026-09-07"
owner: "Dev Team"
status: "Planned"
tags: ["feature", "game", "flutter", "android"]
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-planned-blue)

**Micin, Micin** adalah Flutter clone dari game Sugar Sugar karya Bart Bonte. Game ini adalah puzzle fisika berbasis partikel di mana pemain menggambar garis bebas di layar untuk mengarahkan partikel "micin" (MSG) yang jatuh akibat gravitasi agar tepat masuk ke dalam cangkir/wadah target.

Plan ini didasarkan pada TDD yang diturunkan dari analisis binary `sugarsugar.swf` (SWF v10) dan mencakup seluruh implementasi dari foundation hingga release-ready Android build — **30 level**, **color filter system**, **gravity toggle**, dan **progressive unlock**.

> **Upstream Reference**: `docs/tdd/TDD-sugar-sugar-clone.md`
> **Target Platform**: Android (Flutter 3.44.8 / Dart 3.12.2)
> **Free Play Mode**: Deferred to v1.1

---

## 1. Requirements & Constraints

- **REQ-001**: Game harus bisa dimainkan di Android dengan performa 60fps stabil
- **REQ-002**: Total 30 level dengan layout posisi emitter, cup, dan color filter yang iteratif
- **REQ-003**: Particle rendering menggunakan `Canvas.drawPoints()` — bukan `drawCircle()` per partikel
- **REQ-004**: Object pool wajib digunakan untuk `SugarParticle` (hindari GC pressure)
- **REQ-005**: State persistence menggunakan `SharedPreferences` dengan key `sugarshared`
- **REQ-006**: Level progression: level N+1 unlock setelah level N selesai
- **REQ-007**: Color filter system: partikel berubah warna melewati zona filter; harus masuk cangkir warna yang sama
- **REQ-008**: Gravity toggle (`gravitknop`) tersedia di level tertentu — simpan sebagai `double gravityY`
- **REQ-009**: Platform target: **Android only** (v1.0)
- **REQ-010**: Free Play mode di-defer ke v1.1
- **REQ-011**: Kecepatan maksimum partikel dibatasi `kMaxSpeed = 6.0` untuk mencegah tunneling — berlaku untuk `vx` dan `vy` *(clarification Q1)*
- **REQ-012**: Reset TOTAL — `GameEngine.reset()` menghapus semua garis (`clearAll`) + mereset semua emitter dan partikel *(clarification Q2)*
- **REQ-013**: `LevelCompleteDialog` untuk Level 30 menampilkan ending screen "Selamat! Semua Level Selesai!" + tombol "Kembali ke Menu" *(clarification Q5)*
- **CON-001**: Tidak menggunakan game engine (Flame/Unity) — pure Flutter `CustomPainter` + `Ticker`
- **CON-002**: Semua koordinat level menggunakan **normalized 0.0–1.0** relatif ukuran canvas
- **CON-003**: Collision detection: geometric (bukan pixel-sampling) karena Flutter tidak expose pixel dari `CustomPainter`
- **CON-004**: `bestScore` **tidak** diimplementasi di v1.0 — `LevelProgress` hanya berisi `levelId`, `isUnlocked`, `isCompleted` *(clarification Q4)*
- **CON-005**: Ticker **tetap berjalan** saat level complete. `GameEngine` set flag `_isComplete = true` sekali (boolean guard), `GameScreen` listen dan tampilkan dialog overlay *(clarification Q3)*
- **CON-006**: `GameEngine` di-instantiate di `GameScreen.initState()` — owned eksklusif oleh widget. `LevelConfig` dikirim via GoRouter `extra`. `dispose()` memanggil `gameEngine.dispose()` → Ticker bersih *(clarification Q13 — ADR candidate)*
- **CON-007**: `emitRate` bersifat frame-based (bukan time-based). Accepted trade-off untuk v1.0 *(clarification Q12)*
- **SEC-001**: Tidak ada koneksi internet atau data user yang dikumpulkan

---

## 2. Implementation Steps

> **EXECUTION DIRECTIVE FOR AI AGENTS:**
> Eksekusi plan ini phase by phase. Jalankan task VERIFY di akhir setiap phase. Setelah phase selesai diverifikasi, **HARUS BERHENTI DAN MENUNGGU** explicit approval dari user sebelum lanjut ke phase berikutnya.

---

### Implementation Phase 1 — Foundation & Project Setup

- GOAL-001: Setup Flutter project `micin_micin`, install semua dependencies, dan buat foundation layer (constants, theme, GameState enum, core models). Semua model harus punya unit test sebelum phase ini dianggap selesai.

| Task     | Description                                                                                                                     | Ref ID  | AC Ref | Dep      | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | -------- | ----- | --------- | ---- |
| TASK-001 | `flutter create micin_micin` lalu setup `pubspec.yaml` dengan semua dependencies: riverpod, audioplayers, shared_preferences, go_router, freezed, **`google_fonts: ^6.2.1`** (DEP-011). Unduh font files `Outfit-Regular.ttf`, `Outfit-Bold.ttf`, `Outfit-SemiBold.ttf` ke `assets/fonts/`. Daftarkan di `pubspec.yaml → fonts:`. Di `main.dart` tambahkan `GoogleFonts.config.allowRuntimeFetching = false` | REQ-001 | -      | -        | 3     |           |      |
| TASK-002 | Buat `lib/core/constants.dart`: `kGravityDefault=0.2`, `kParticleRadius=2.0`, `kLineThickness=6.0`, `kPoolCapacity=500`, `kCanvasAspectRatio=9/16`, **`kMaxSpeed=6.0`** (velocity clamp anti-tunneling) | REQ-003, REQ-011 | -      | TASK-001 | 1     |           |      |
| TASK-003 | Buat `lib/core/game_state.dart`: enum `GameState` (9 nilai dari SWF binary) + `lib/core/extensions.dart` (Color hex parser) | REQ-001 | -      | TASK-001 | 2     |           |      |
| TASK-004 | Buat `lib/core/theme.dart`: `AppTheme` minimalis gelap (background hitam, aksen putih/kuning), gunakan `GoogleFonts.outfit()` dari package `google_fonts` (DEP-011). Bundle font offline via asset manifest | REQ-001 | -      | TASK-001 | 1     |           |      |
| TASK-005 | Buat `lib/models/sugar_particle.dart`: class `SugarParticle` dengan field `x, y, vx, vy, color, isActive, isCaptured` + method `reset()` | REQ-004 | -      | TASK-003 | 1     |           |      |
| TASK-006 | Buat `lib/models/emitter_config.dart`, `lib/models/cup_config.dart`, `lib/models/color_filter_config.dart` dengan `fromJson()` dan normalized coordinate | REQ-002 | -      | TASK-003 | 3     |           |      |
| TASK-007 | Buat `lib/models/level_config.dart`: class `LevelConfig` dengan `fromJson()`, field `id, name, emitters, cups, filters, totalSugar, gravity, hasGravityToggle` | REQ-002 | -      | TASK-006 | 1     |           |      |
| TASK-008 | Buat `lib/models/level_progress.dart` + `lib/models/player_progress.dart`: `LevelProgress(levelId, isUnlocked, isCompleted)` (**tanpa bestScore** — di-defer ke v1.1) + `PlayerProgress(levels)` dengan `toJson/fromJson`, `withUnlocked()`, `withCompleted()`. **`PlayerProgress.initial()` menghasilkan 30 `LevelProgress` di mana hanya `levelId=1` yang `isUnlocked=true`**, sisanya `false` | REQ-005, CON-004 | -      | TASK-003 | 2     |           |      |
| TASK-009 | Tulis unit test untuk semua models di `test/models/`: parse JSON valid, parse JSON dengan field opsional, serialisasi round-trip | REQ-001 | -      | TASK-005..TASK-008 | 4     |           |      |
| TASK-010 | **VERIFY**: Jalankan `flutter test test/models/` — semua test HARUS lulus 100%. Pastikan `flutter analyze` bersih tanpa warning | -       | -      | TASK-009 | -     |           |      |
| TASK-011 | **APPROVAL**: Tunggu explicit approval user sebelum lanjut ke Phase 2                                                           | -       | -      | TASK-010 | -     |           |      |

---

### Implementation Phase 2 — Core Game Engine

- GOAL-002: Bangun seluruh engine layer (particle pool, emitter, collision, color filter, game loop). Di akhir phase ini, sebuah prototype fungsional harus bisa: spawn partikel → jatuh → dibelokkan garis → masuk cangkir — seluruhnya dalam unit/integration test (belum ada UI).

| Task     | Description                                                                                                                     | Ref ID  | AC Ref | Dep      | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | -------- | ----- | --------- | ---- |
| TASK-012 | Buat `lib/engine/particle/particle_pool.dart`: `ParticlePool` dengan `acquire()` (O(n) scan), `release(SugarParticle)`, `releaseAll()` (**iterasi internal: `for p in _pool where isActive: p.reset()`**, dipanggil oleh `ParticleController.resetAll()`), getter `activeParticles`. Capacity default 500 | REQ-004, REQ-012 | -      | TASK-005 | 1     |           |      |
| TASK-013 | Buat `lib/engine/particle/particle_emitter.dart`: `ParticleEmitter` dengan field `x, y, color, totalToEmit, emitRate, _frameCounter, _emitted`, method `tick(ParticlePool)` yang increment `_frameCounter` tiap frame dan spawn partikel saat `_frameCounter % emitRate == 0` (frame-based, CON-007), method `reset()` yang set `_frameCounter=0` dan `_emitted=0`, getter `isExhausted` | REQ-002, CON-007 | -      | TASK-012 | 1     |           |      |
| TASK-014 | Buat `lib/engine/drawing/drawn_line.dart`: `DrawnLine(points, color, thickness)` + method `toSegments() → List<LineSegment>` | REQ-001 | -      | TASK-005 | 1     |           |      |
| TASK-015 | Buat `lib/engine/collision/line_segment.dart`: `LineSegment(start, end, thickness)` dengan `distanceTo(Offset)`, getter `normal`, method `resolveCollision(SugarParticle)` menggunakan geometric distance + velocity reflection (restitution 0.3, friction 0.92) | CON-003 | -      | TASK-014 | 1     |           |      |
| TASK-016 | Buat `lib/engine/collision/cup_hitbox.dart`: `CupHitbox(bounds, color)` dengan `contains(x,y)` + `matches(SugarParticle)` — partikel putih cocok dengan semua cangkir; partikel berwarna hanya cocok dengan cangkir warna sama | REQ-007 | -      | TASK-005 | 1     |           |      |
| TASK-017 | Buat `lib/engine/color_filter/color_filter_zone.dart`: `ColorFilterZone(region, targetColor)` dengan `contains(x,y)`. Method ini dipanggil per-frame untuk mutasi `particle.color` | REQ-007 | -      | TASK-005 | 1     |           |      |
| TASK-018 | Buat `lib/engine/particle/particle_controller.dart`: `ParticleController` yang orkestrasi per-frame: (1) tick emitter, (2) terapkan gravitasi `p.vy += gravity`, **(2b) clamp: `p.vx = p.vx.clamp(-kMaxSpeed, kMaxSpeed)`, `p.vy = p.vy.clamp(-kMaxSpeed, kMaxSpeed)`**, (3) cek color filter, (4) resolve collision garis, (5) update posisi, (6) cek cup capture, (7) release partikel keluar layar. **Method `resetAll()`: `pool.releaseAll()` + `for emitter in emitters: emitter.reset()`** | REQ-003, REQ-011, REQ-012 | -      | TASK-013..TASK-017 | 1     |           |      |
| TASK-019 | Buat `lib/engine/drawing/line_controller.dart`: `LineController extends StateNotifier<List<DrawnLine>>` dengan `onPanStart()`, `onPanUpdate()`, `onPanEnd()`, `clearAll()`. Getter `allSegments → List<LineSegment>` dari semua drawn lines | REQ-001 | -      | TASK-014 | 1     |           |      |
| TASK-020 | Buat `lib/engine/game_engine.dart`: `GameEngine with ChangeNotifier` yang menerima `GameEngine({required LevelConfig levelConfig})`. **Constructor injection: `ParticleController(gravity: levelConfig.gravity, emitters: levelConfig.emitters)`**. Ticker + method `start(TickerProvider)`, `_onTick(Duration)`, `pause()`, `resume()`, `reset()`. `reset()` memanggil `lineController.clearAll()` + `particleController.resetAll()` (TOTAL). `_onTick()` set `_isComplete = true` satu kali saat level complete + `notifyListeners()`. Ticker tetap berjalan saat complete (CON-005) | REQ-001, REQ-012, CON-005, CON-006 | -      | TASK-018..TASK-019 | 1     |           |      |
| TASK-021 | Buat `lib/providers/game_state_provider.dart`: `GameStateMachine extends StateNotifier<GameState>` dengan semua transition methods. Provider `gameStateMachineProvider` | REQ-001 | -      | TASK-003 | 1     |           |      |
| TASK-022 | Tulis unit test engine di `test/engine/`: (a) ParticlePool: acquire sampai penuh, release & reacquire; (b) LineSegment: collision jika partikel lewat garis, tidak collision jika jauh; (c) CupHitbox: warna cocok/tidak cocok; (d) ColorFilterZone: mutasi warna partikel; (e) ParticleController: 10 frame simulasi — partikel harus dibelokkan garis | CON-003 | -      | TASK-012..TASK-020 | 5     |           |      |
| TASK-023 | **VERIFY**: Jalankan `flutter test test/engine/` — semua test HARUS lulus. Pastikan `flutter analyze` bersih | -       | -      | TASK-022 | -     |           |      |
| TASK-024 | **APPROVAL**: Tunggu explicit approval user sebelum lanjut ke Phase 3                                                           | -       | -      | TASK-023 | -     |           |      |

---

### Implementation Phase 3 — Rendering & Drawing System

- GOAL-003: Bangun semua `CustomPainter` dan `GameScreen` sehingga pemain dapat melihat partikel jatuh, menggambar garis dengan jari, dan melihat gula masuk cangkir secara real-time di device Android.

| Task     | Description                                                                                                                     | Ref ID  | AC Ref | Dep      | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | -------- | ----- | --------- | ---- |
| TASK-025 | Buat `lib/screens/game/painters/particle_painter.dart`: `ParticlePainter extends CustomPainter`. Batch render partikel per warna menggunakan `canvas.drawPoints(PointMode.points, offsets, paint)`. Jangan gunakan `drawCircle()` | REQ-003 | -      | TASK-018 | 1     |           |      |
| TASK-026 | Buat `lib/screens/game/painters/line_painter.dart`: `LinePainter extends CustomPainter`. Render semua `DrawnLine` menggunakan `canvas.drawPath()` dengan stroke rounded join | REQ-001 | -      | TASK-014 | 1     |           |      |
| TASK-027 | Buat `lib/screens/game/painters/level_painter.dart`: `LevelPainter extends CustomPainter`. Render cangkir (filled rect + outline), emitter (lingkaran beranimasi kecil), dan zona color filter (rect semi-transparan berwarna) dari `LevelConfig` | REQ-002 | -      | TASK-007 | 1     |           |      |
| TASK-028 | Buat `lib/screens/game/painters/background_painter.dart`: `BackgroundPainter extends CustomPainter`. Background gelap bertekstur pasir (noise pattern atau solid dengan subtle grain) | REQ-001 | -      | TASK-004 | 1     |           |      |
| TASK-029 | Buat `lib/screens/game/game_hud.dart`: `GameHud` widget dengan row tombol: pause `Icons.pause_circle`, reset `Icons.refresh`, music `Icons.music_note_rounded`. Counter `Text('$captured / $total')` dan `Text('Level $id')`. Gravity toggle button muncul hanya jika `hasGravityToggle == true` | REQ-008 | -      | TASK-004 | 1     |           |      |
| TASK-030 | Buat `lib/screens/game/game_screen.dart`: `GameScreen extends StatefulWidget with SingleTickerProviderStateMixin`. Di `initState()`: ambil `LevelConfig` dari GoRouter `extra` — **jika `extra == null`, fallback ke `await LevelRepository.loadLevel(levelId)` (null safety)**. Buat `GameEngine(levelConfig: levelConfig)` (constructor injection, CON-006). Stack: `[BackgroundPainter, RepaintBoundary(LevelPainter), RepaintBoundary(ParticlePainter), RepaintBoundary(LinePainter), PopScope(canPop:false, ...), GestureDetector, GameHud]`. `PopScope` intercept back → `GameEngine.pause()` + tampilkan `PauseOverlay`. `gameEngine.dispose()` di `dispose()` | REQ-001, CON-006 | -      | TASK-025..TASK-029, TASK-031 | 1     |           |      |
| TASK-031 | Buat `lib/data/level_repository.dart`: `LevelRepository` dengan method `loadLevel(int id) async → LevelConfig` yang membaca `assets/levels/level_XX.json` menggunakan `rootBundle.loadString()` + `LevelConfig.fromJson()` | REQ-002 | -      | TASK-007 | 1     |           |      |
| TASK-032 | Buat `assets/levels/level_01.json` s/d `level_10.json` — **Level 1–10**: emitter tunggal di atas tengah (x:0.5, y:0.05), cangkir tunggal di bawah (posisi bervariasi). Tidak ada color filter. Kesulitan meningkat dari posisi cup yang semakin ke tepi | REQ-002 | -      | TASK-031 | 10    |           |      |
| TASK-033 | Tulis widget test untuk `GameScreen` di `test/screens/`: (a) GameScreen bisa di-render tanpa error untuk Level 1; (b) GestureDetector `onPanStart` menambah 1 DrawnLine ke LineController; (c) HUD menampilkan "0 / 100" saat game dimulai | REQ-001 | -      | TASK-030..TASK-032 | 2     |           |      |
| TASK-034 | **VERIFY**: Jalankan `flutter test test/screens/`. Lalu **run di Android device/emulator**: buka Level 1, gambar garis, verifikasi partikel dibelokkan dan masuk cangkir secara visual | -       | -      | TASK-033 | -     |           |      |
| TASK-035 | **APPROVAL**: Tunggu explicit approval user sebelum lanjut ke Phase 4                                                           | -       | -      | TASK-034 | -     |           |      |

---

### Implementation Phase 4 — Level System: Color Filter & Advanced Levels

- GOAL-004: Implementasi color filter system dan rancang semua 30 level JSON secara iteratif. Di akhir phase ini, pemain bisa memainkan semua 30 level dari level select screen.

| Task     | Description                                                                                                                     | Ref ID  | AC Ref | Dep      | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | -------- | ----- | --------- | ---- |
| TASK-036 | Pastikan `ColorFilterZone` sudah termuat dari `level_config.fromJson()`. Update `LevelPainter` untuk render zona filter sebagai colored rect semi-transparan (opacity 0.4) dengan label warna | REQ-007 | -      | TASK-027 | 2     | [x]       | 2026-09-07 |
| TASK-037 | Buat `assets/levels/level_11.json` s/d `level_20.json` — **Level 11–20**: Tambahkan color filter (1–2 zona). Gula harus berubah warna dan masuk ke cangkir warna yang sesuai. Multi-cup mulai dari level 15 | REQ-007 | -      | TASK-036 | 10    | [x]       | 2026-09-07 |
| TASK-038 | Buat `assets/levels/level_21.json` s/d `level_30.json` — **Level 21–30**: Tambahkan `hasGravityToggle: true` di beberapa level (21, 24, 27, 30). Multi-emitter dari level 25. Layout semakin kompleks | REQ-008 | -      | TASK-037 | 10    | [x]       | 2026-09-07 |
| TASK-039 | Implementasi gravity toggle behavior di `GameEngine`: method `toggleGravity()` yang flips `particleController.gravity` antara `+kGravityDefault` dan `-kGravityDefault`. HUD button di `GameHud` memanggil method ini | REQ-008 | -      | TASK-020 | 2     | [x]       | 2026-09-07 |
| TASK-040 | Buat `lib/data/progress_repository.dart`: `ProgressRepository` dengan `load()`, `save()`, `unlockLevel(id)`, `markCompleted(id)`. **Tidak ada `saveBestScore()` — di-defer ke v1.1** (CON-004). Key SharedPreferences: `sugarshared` | REQ-005, CON-004 | -      | TASK-008 | 1     | [x]       | 2026-09-07 |
| TASK-041 | Buat `lib/providers/player_progress_provider.dart` + `lib/providers/level_config_provider.dart`: Riverpod `AsyncNotifierProvider` untuk load level config, `StateNotifierProvider` untuk progress | REQ-005 | -      | TASK-040 | 2     | [x]       | 2026-09-07 |
| TASK-042 | Tulis integration test level system di `test/integration/`: (a) Level 11 — partikel melewati filter berubah merah, masuk cup merah dihitung; (b) Level 11 — partikel merah masuk cup putih TIDAK dihitung; (c) Level 21 — gravity toggle mengubah arah partikel | REQ-007 | -      | TASK-036..TASK-039 | 2     | [x]       | 2026-09-07 |
| TASK-043 | **VERIFY**: Jalankan `flutter test test/integration/`. Lalu manual: mainkan Level 11 — verifikasi color filter berfungsi. Mainkan Level 21 — tekan gravity toggle, verifikasi partikel naik | -       | -      | TASK-042 | -     | [x]       | 2026-09-07 |
| TASK-044 | **APPROVAL**: Tunggu explicit approval user sebelum lanjut ke Phase 5                                                           | -       | -      | TASK-043 | -     |           |      |

---

### Implementation Phase 5 — UI/UX & Full Navigation Flow

- GOAL-005: Bangun semua screen (Splash, Menu, Level Select, Level Complete, Pause) dan sambungkan dengan GoRouter sehingga game memiliki full navigation flow yang bisa dimainkan end-to-end dari install hingga Level 30.

| Task     | Description                                                                                                                     | Ref ID  | AC Ref | Dep      | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | -------- | ----- | --------- | ---- |
| TASK-045 | Buat `lib/app.dart`: `MaterialApp.router` dengan `GoRouter`. Definisikan routes: `/` (Splash), `/menu`, `/levels`, `/game/:id`. Setup `ProviderScope` di `main.dart` | REQ-001 | -      | TASK-003 | 2     | [x]       | 2026-09-07 |
| TASK-046 | Buat `lib/screens/splash/splash_screen.dart`: Animasi "Micin, Micin" dengan fade-in teks + partikel kecil jatuh. Durasi 2.5 detik. **Di `initState()`: panggil `ref.read(audioManagerProvider).init()` untuk preload audio (satu kali)**, lalu setelah 2.5 detik redirect ke `/menu` | REQ-001 | -      | TASK-045, TASK-057 | 1     | [x]       | 2026-09-07 |
| TASK-047 | Buat `lib/screens/menu/menu_screen.dart`: Tampilkan judul "Micin, Micin" + 2 tombol — `PLAY` (→ `/levels`) + `CREDITS` (→ overlay). Background animasi partikel jatuh perlahan (dekoratif, tidak pakai game engine) | REQ-001 | -      | TASK-045 | 1     | [x]       | 2026-09-07 |
| TASK-048 | Buat `lib/widgets/lock_badge.dart`: Widget kecil gembok di atas level button jika `isUnlocked == false`. Buat `lib/screens/level_select/level_button.dart`: button level (nomor, thumbnail state selesai/belum, lock badge) | REQ-006 | -      | TASK-041 | 2     | [x]       | 2026-09-07 |
| TASK-049 | Buat `lib/screens/level_select/level_select_screen.dart`: Grid 5×6 = 30 level buttons. Baca state `playerProgressProvider` — tampilkan status unlock. Tap level yang terkunci: tidak ada navigasi (tampilkan `SnackBar` "Selesaikan level sebelumnya dulu!") | REQ-006 | -      | TASK-048 | 1     | [x]       | 2026-09-07 |
| TASK-050 | Buat `lib/widgets/level_complete_dialog.dart`: `GameScreen` listen ke `GameEngine._isComplete` flag. Dialog overlay tampil langsung (tanpa delay, Ticker tetap jalan). **Untuk level 1–29**: Tampilkan "Level N Selesai!", animasi confetti, tombol "Level Berikutnya" → `markCompleted()` + `unlockLevel(N+1)` + navigate ke `/game/N+1`. **Untuk level 30**: Tampilkan ending screen "🎉 Selamat! Semua Level Selesai!" + tombol "Kembali ke Menu" → navigate ke `/menu` | REQ-006, REQ-013, CON-005 | -      | TASK-041 | 1     | [x]       | 2026-09-07 |
| TASK-051 | Buat `lib/widgets/pause_overlay.dart`: Overlay semi-transparan saat pause. Tombol "Lanjutkan" (resume Ticker) + "Kembali ke Menu" (navigate ke `/menu`). **Juga berfungsi sebagai target `PopScope` intercept di `GameScreen` — back gesture → `GameEngine.pause()` → `PauseOverlay` tampil** | REQ-001 | -      | TASK-020 | 1     | [x]       | 2026-09-07 |
| TASK-052 | Buat `lib/screens/menu/credits_screen.dart`: Halaman credits sederhana: nama original (Bart Bonte), link web, nama developer clone | REQ-001 | -      | TASK-045 | 1     | [x]       | 2026-09-07 |
| TASK-053 | Tulis widget test navigasi di `test/screens/navigation_test.dart`: (a) Tap PLAY dari MenuScreen → LevelSelectScreen terender; (b) Tap Level 1 → GameScreen terender; (c) Tap Level 2 (terkunci) → SnackBar muncul | REQ-006 | -      | TASK-045..TASK-052 | 1     | [x]       | 2026-09-07 |
| TASK-054 | **VERIFY**: Jalankan `flutter test test/screens/`. Lalu manual end-to-end di Android: Install → Splash → Menu → Level Select → Level 1 → Selesaikan → Dialog Complete → Level 2 Unlock → Level 2 Playable | -       | -      | TASK-053 | -     | [x]       | 2026-09-07 |
| TASK-055 | **APPROVAL**: Tunggu explicit approval user sebelum lanjut ke Phase 6                                                           | -       | -      | TASK-054 | -     |           |      |

---

### Implementation Phase 6 — Audio & Release Polish

- GOAL-006: Tambahkan audio system (BGM + SFX), lakukan full test suite, dan build release APK yang siap diinstall.

| Task     | Description                                                                                                                     | Ref ID  | AC Ref | Dep      | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | -------- | ----- | --------- | ---- |
| TASK-056 | Siapkan audio assets: `assets/audio/bgm.mp3` (loopable), `assets/audio/ok.mp3` (level complete), `assets/audio/click.mp3` (button). Register di `pubspec.yaml` | REQ-001 | -      | TASK-001 | 4     |           |      |
| TASK-057 | Buat `lib/audio/audio_manager.dart`: `AudioManager` dengan `init()`, `playBgm()`, `stopBgm()`, `playSfx(SoundType)`, `toggleMusic()`. Gunakan `AudioPlayer` dari `audioplayers` package. BGM loop dengan `ReleaseMode.loop` | REQ-001 | -      | TASK-056 | 1     |           |      |
| TASK-058 | Buat `lib/providers/audio_provider.dart`: `audioManagerProvider` (global singleton). **`AudioManager.init()` dipanggil di `SplashScreen.initState()` — bukan di `MenuScreen`**. `MenuScreen.initState()` hanya memanggil `audioManager.playBgm()`. Integrate SFX `levelComplete` ke `LevelCompleteDialog`. Integrate SFX `buttonClick` ke semua tombol HUD | REQ-001 | -      | TASK-057 | 1     |           |      |
| TASK-059 | Pastikan tombol music toggle di `GameHud` memanggil `AudioManager.toggleMusic()` dan icon berubah antara `Icons.music_note_rounded` ↔ `Icons.music_off` | REQ-001 | -      | TASK-058 | 1     |           |      |
| TASK-060 | Full test suite: jalankan `flutter test --coverage`. Pastikan coverage ≥ 70% untuk `lib/engine/` dan `lib/models/`. Fix semua failing test | REQ-001 | -      | Semua    | -     |           |      |
| TASK-061 | `flutter analyze` clean: tidak ada `error`, tidak ada `warning`. Fix semua lint issue. Pastikan tidak ada `// ignore:` yang ditambahkan untuk cheat | REQ-001 | -      | TASK-060 | -     |           |      |
| TASK-062 | Build release APK: `flutter build apk --release`. Verifikasi APK < 50MB. Install di physical Android device, mainkan Level 1 → Level 5 tanpa crash | REQ-009 | -      | TASK-061 | -     |           |      |
| TASK-063 | **VERIFY**: (a) `flutter test` → 100% pass; (b) `flutter analyze` → bersih; (c) `flutter build apk` → sukses; (d) Manual play Level 1 hingga Level 5 di device → tidak crash, 60fps | -       | -      | TASK-062 | -     |           |      |
| TASK-064 | **APPROVAL**: Plan selesai. Game siap untuk distribusi atau iterasi v1.1 (Free Play Mode)                                       | -       | -      | TASK-063 | -     |           |      |

---

## 3. Alternatives

- **ALT-001**: Menggunakan **Flame game engine** — Ditolak. Flame memberikan abstraksi yang tidak diperlukan untuk game sesederhana ini dan menambah ukuran APK secara signifikan. Pure `CustomPainter` + `Ticker` lebih ringan dan memberi kontrol penuh.
- **ALT-002**: Menggunakan **pixel-sampling collision** (seperti SWF original) dengan `Picture` + `toImage()` — Ditolak. Terlalu lambat di Flutter (bloking main thread), tidak deterministic, dan sulit di-test. Geometric segment distance lebih cepat dan testable.
- **ALT-003**: Menggunakan **Bloc** sebagai state management — Ditolak. Riverpod 2.x lebih ergonomis untuk use case ini dan tidak memerlukan boilerplate `Event/State` yang berlebihan.
- **ALT-004**: Menggunakan **Hive** untuk persistence — Ditolak. `SharedPreferences` sudah cukup untuk data progress yang sederhana (JSON string). Hive menambah dependency yang tidak perlu (YAGNI).

---

## 4. Dependencies

- **DEP-001**: `flutter_riverpod: ^2.6.1` — State management untuk GameStateMachine, PlayerProgress, LevelConfig
- **DEP-002**: `riverpod_annotation: ^2.3.5` + `riverpod_generator: ^2.4.3` (dev) — Code generation provider
- **DEP-003**: `audioplayers: ^6.1.0` — BGM loop + SFX playback
- **DEP-004**: `shared_preferences: ^2.3.2` — Persistence key `sugarshared`
- **DEP-005**: `go_router: ^14.6.0` — Deklaratif navigation
- **DEP-006**: `freezed_annotation: ^2.4.4` + `freezed: ^2.5.7` (dev) — Immutable model classes
- **DEP-007**: `json_serializable: ^6.8.0` (dev) — JSON serialization code gen
- **DEP-008**: `build_runner: ^2.4.13` (dev) — Code generation runner
- **DEP-009**: `mocktail: ^1.0.4` (dev) — Mocking untuk unit test
- **DEP-010**: `flutter_lints: ^5.0.0` (dev) — Lint rules
- **DEP-011**: `google_fonts: ^6.2.1` — Font Outfit untuk AppTheme, di-bundle offline *(added: clarification Q6)*

---

## 5. Files

### Phase 1 Files
- **FILE-001**: `micin_micin/pubspec.yaml` — Dependencies manifest
- **FILE-002**: `lib/main.dart` — Entry point + ProviderScope
- **FILE-003**: `lib/app.dart` — MaterialApp.router + GoRouter
- **FILE-004**: `lib/core/constants.dart` — Game constants
- **FILE-005**: `lib/core/game_state.dart` — GameState enum
- **FILE-006**: `lib/core/extensions.dart` — Color hex parser extension
- **FILE-007**: `lib/core/theme.dart` — AppTheme (dark minimalist)
- **FILE-008**: `lib/models/sugar_particle.dart`
- **FILE-009**: `lib/models/emitter_config.dart`
- **FILE-010**: `lib/models/cup_config.dart`
- **FILE-011**: `lib/models/color_filter_config.dart`
- **FILE-012**: `lib/models/level_config.dart`
- **FILE-013**: `lib/models/level_progress.dart`
- **FILE-014**: `lib/models/player_progress.dart`

### Phase 2 Files
- **FILE-015**: `lib/engine/particle/particle_pool.dart`
- **FILE-016**: `lib/engine/particle/particle_emitter.dart`
- **FILE-017**: `lib/engine/particle/particle_controller.dart`
- **FILE-018**: `lib/engine/drawing/drawn_line.dart`
- **FILE-019**: `lib/engine/drawing/line_segment.dart`
- **FILE-020**: `lib/engine/drawing/line_controller.dart`
- **FILE-021**: `lib/engine/collision/cup_hitbox.dart`
- **FILE-022**: `lib/engine/color_filter/color_filter_zone.dart`
- **FILE-023**: `lib/engine/game_engine.dart`
- **FILE-024**: `lib/providers/game_state_provider.dart`

### Phase 3 Files
- **FILE-025**: `lib/screens/game/painters/particle_painter.dart`
- **FILE-026**: `lib/screens/game/painters/line_painter.dart`
- **FILE-027**: `lib/screens/game/painters/level_painter.dart`
- **FILE-028**: `lib/screens/game/painters/background_painter.dart`
- **FILE-029**: `lib/screens/game/game_hud.dart`
- **FILE-030**: `lib/screens/game/game_screen.dart`
- **FILE-031**: `lib/data/level_repository.dart`
- **FILE-032**: `assets/levels/level_01.json` → `level_10.json`

### Phase 4 Files
- **FILE-033**: `assets/levels/level_11.json` → `level_20.json`
- **FILE-034**: `assets/levels/level_21.json` → `level_30.json`
- **FILE-035**: `lib/data/progress_repository.dart`
- **FILE-036**: `lib/providers/player_progress_provider.dart`
- **FILE-037**: `lib/providers/level_config_provider.dart`

### Phase 5 Files
- **FILE-038**: `lib/screens/splash/splash_screen.dart`
- **FILE-039**: `lib/screens/menu/menu_screen.dart`
- **FILE-040**: `lib/screens/menu/credits_screen.dart`
- **FILE-041**: `lib/screens/level_select/level_select_screen.dart`
- **FILE-042**: `lib/screens/level_select/level_button.dart`
- **FILE-043**: `lib/widgets/lock_badge.dart`
- **FILE-044**: `lib/widgets/level_complete_dialog.dart`
- **FILE-045**: `lib/widgets/pause_overlay.dart`

### Phase 6 Files
- **FILE-046**: `lib/audio/audio_manager.dart`
- **FILE-047**: `lib/providers/audio_provider.dart`
- **FILE-048**: `assets/audio/bgm.mp3`
- **FILE-049**: `assets/audio/ok.mp3`
- **FILE-050**: `assets/audio/click.mp3`

---

## 6. Testing

- **TEST-001**: `test/models/` — Unit test semua model: JSON parse, serialization round-trip, edge case field opsional
- **TEST-002**: `test/engine/particle_pool_test.dart` — acquire/release/exhausted behavior
- **TEST-003**: `test/engine/line_segment_test.dart` — geometric collision: hit, miss, normal vector
- **TEST-004**: `test/engine/cup_hitbox_test.dart` — color match / mismatch logic
- **TEST-005**: `test/engine/color_filter_zone_test.dart` — partikel warna berubah melewati zona
- **TEST-006**: `test/engine/particle_controller_test.dart` — integration: 10 frame simulasi partikel jatuh + dibelokkan
- **TEST-007**: `test/screens/game_screen_test.dart` — widget test: render, gesture pan, HUD counter
- **TEST-008**: `test/screens/navigation_test.dart` — GoRouter navigation flow
- **TEST-009**: `test/integration/color_filter_integration_test.dart` — partikel merah masuk cup merah ✓, cup putih ✗
- **TEST-010**: `test/integration/gravity_toggle_test.dart` — gravity direction flip
- **TEST-011**: Coverage target: ≥ 70% untuk `lib/engine/` dan `lib/models/`

---

## 7. Risks & Assumptions

- **RISK-001**: [HIGH] Performance partikel di low-end Android — `Canvas.drawPoints()` batch render sudah dipilih, tetapi perlu profiling di device nyata. Mitigasi: Kurangi `kPoolCapacity` dari 500 ke 200 jika terjadi frame drop.
- **RISK-002**: [MEDIUM] Collision detection tidak akurat untuk garis yang sangat pendek (panjang < 5px) — Mitigasi: Skip segment dengan panjang < 5px di `toSegments()`.
- **RISK-003**: [LOW] Level design iteratif bisa menyebabkan beberapa level terlalu mudah/sulit — Mitigasi: Playtest setiap level sebelum finalize JSON, adjust `totalSugar` dan posisi cup.
- **RISK-004**: [LOW] `audioplayers` di Android bisa ada delay saat cold start — Mitigasi: Preload audio asset di `AudioManager.init()` yang dipanggil di `SplashScreen`.
- **RISK-005**: [LOW] Gameplay speed bervariasi di device < 60fps karena `emitRate` frame-based (CON-007) — Mitigasi: Target device midrange Android (≥30fps), acceptable untuk v1.0.
- **ASSUMPTION-001**: Audio assets (bgm.mp3, ok.mp3, click.mp3) akan dibuat/dicari secara terpisah oleh developer — plan ini hanya menyediakan struktur file dan integrasi code.
- **ASSUMPTION-002**: Level 1–10 menggunakan single cup + single emitter. Level 11–20 mulai gunakan color filter. Level 21–30 mulai gunakan gravity toggle + multi-emitter. Layout detail diiterasi saat coding Phase 4.
- **ASSUMPTION-003**: Tidak ada backend/server — game sepenuhnya offline.

> **Clarification Session Iter-1 (2026-09-07) — v1.1:** 7 resolusi awal diterapkan.
> **Clarification Session Iter-2 (2026-09-07) — v1.2:** 6 resolusi REFINE diterapkan. Score: 96/100.
> **Clarification Session Iter-3 (2026-09-07) — v1.3:** 4 resolusi final diterapkan. Score: 98/100.
> Lihat laporan lengkap: `docs/audit/clarification-report-micin-game-2026-09-07.md`

---

## 8. Related Specifications / Further Reading

- [TDD-sugar-sugar-clone.md](../docs/tdd/TDD-sugar-sugar-clone.md) — Technical Design Document lengkap (upstream spec)
- [sugarsugar.swf](../docs/references/sugarsugar.swf) — File referensi SWF asli
- [Flutter CustomPainter docs](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
- [Riverpod 2.x docs](https://riverpod.dev)
- [audioplayers package](https://pub.dev/packages/audioplayers)

---

## 9. Rollback / Recovery Plan

- **Phase 1 Rollback**: Tidak ada state permanen. Hapus direktori `micin_micin/` dan ulangi `flutter create`.
- **Phase 2–3 Rollback**: Gunakan `git revert` ke commit terakhir yang passing test. Semua engine code murni Dart tanpa side effect eksternal.
- **Phase 4 Rollback**: Level JSON files bisa di-edit atau dihapus tanpa mempengaruhi engine. Jika `ProgressRepository` korup: hapus data SharedPreferences dengan `prefs.clear()` di debug mode.
- **Phase 5 Rollback**: GoRouter routes bisa dinonaktifkan satu per satu. Revert ke `Navigator.push()` vanilla jika GoRouter bermasalah.
- **Phase 6 Rollback**: Jika audio menyebabkan crash: set `isMusicEnabled = false` secara default dan skip `AudioManager.init()`. Game tetap bisa dimainkan tanpa audio.
- **General**: Semua perubahan harus di-commit per-task ke Git. Gunakan branch `feature/phase-N` per phase. Merge ke `main` hanya setelah APPROVAL checkpoint.
