# 🔍 Clarification Report [Review Iterasi 3 — FINAL]

**Target Document**: `plan/plan-feature-micin-game-v1.0.md` (v1.3)
**Reference TDD**: `docs/tdd/TDD-sugar-sugar-clone.md`
**Date**: 2026-09-07
**Analyst**: Clarification Analyst (sdlc-clarify-reqs)

**Readiness Score: 98/100** ✅ — Status: **EXCELLENT**

| Iterasi | Pertanyaan | Score |
|---|---|---|
| Iterasi 1 | Q1–Q7 (7 resolusi awal) | 89/100 |
| Iterasi 2 | Q8–Q13 (6 resolusi REFINE) | 96/100 |
| Iterasi 3 | Q14–Q17 (4 resolusi final) | **98/100** |

**Score Breakdown (Final — Iterasi 3):**

- **Completeness (max 40):** 40 — Semua contract method lengkap (releaseAll, resetAll, gravity injection). Initialization path terdefinisi penuh. Null safety GoRouter ter-handle. Tidak ada hidden dependency gap tersisa.
- **Clarity (max 30):** 29 — Semua item bersifat konkret dan testable. AudioManager timing eksplisit. Satu-satunya 20% yang tersisa adalah detail level design JSON yang by-design iteratif.
- **Alignment (max 30):** 29 — Semua keputusan konsisten dengan TDD, SWF reference, YAGNI, dan defensive coding principles.
- **Critical Flaw Veto:** No — Tidak ada critical flaw yang memblok implementasi.

---

## 1. 🚨 Critical Findings (Blockers)

_Semua blocker telah diselesaikan dalam sesi ini. Tidak ada blocker tersisa._

- **None**

---

## 2. 🧩 Resolved Items & Agreements

### Q1 — Particle Tunneling (KRITIS)
- **Requirement:** `TASK-018` — update loop partikel tanpa batas kecepatan
- **Issue:** Partikel dengan `vy` tinggi bisa melewati hitbox cangkir dalam satu frame (discrete collision tunneling)
- **Resolution:** Tambahkan velocity clamp di `ParticleController`: `p.vy = p.vy.clamp(-kMaxSpeed, kMaxSpeed)` dan `p.vx = p.vx.clamp(-kMaxSpeed, kMaxSpeed)`. Tambahkan konstanta `kMaxSpeed = 6.0` ke `lib/core/constants.dart` (TASK-002). **Pilihan: (A)**

### Q2 — Reset Behavior (KRITIS)
- **Requirement:** `TASK-020` — method `reset()` di `GameEngine`, `TASK-029` — tombol reset di HUD
- **Issue:** Plan tidak mendefinisikan apakah reset menghapus garis yang sudah digambar atau tidak
- **Resolution:** **Reset TOTAL** — `GameEngine.reset()` memanggil `LineController.clearAll()` + `ParticleController.resetAll()` (semua partikel di-release ke pool, semua emitter kembali ke `_emitted = 0`). Layar kembali bersih seperti `initLevel()`. **Pilihan: (A)**

### Q3 — Level Complete Trigger & Ticker (KRITIS)
- **Requirement:** `TASK-050` — `LevelCompleteDialog` + `TASK-020` — `GameEngine._onTick()`
- **Issue:** Plan tidak mendefinisikan apakah Ticker berhenti saat level selesai, dan kapan tepatnya dialog di-trigger
- **Resolution:** Ticker **tetap berjalan**. `GameEngine._onTick()` set flag `_isComplete = true` sekali saja (boolean guard untuk prevent re-fire). `GameScreen` listen ke flag ini via `ChangeNotifier` dan tampilkan `LevelCompleteDialog` sebagai overlay langsung tanpa delay. **Pilihan: (A)**

### Q4 — Best Score / `hoogste` (MEDIUM)
- **Requirement:** `TASK-008` — `LevelProgress.bestScore`, `TASK-040` — `ProgressRepository.saveBestScore()`
- **Issue:** Plan tidak mendefinisikan formula score maupun UI untuk menampilkannya — dead code YAGNI violation
- **Resolution:** **Hapus `bestScore` dari scope v1.0.** `LevelProgress` hanya berisi `levelId`, `isUnlocked`, `isCompleted`. Method `saveBestScore()` tidak diimplementasi. Di-defer ke v1.1 bersama Free Play mode. Update `TASK-008` dan `TASK-040`. **Pilihan: (A)**

### Q5 — Level 30 Win Condition Edge Case (MEDIUM)
- **Requirement:** `TASK-050` — `LevelCompleteDialog` dengan tombol "Level Berikutnya" → `unlockLevel(N+1)`
- **Issue:** Level 30 adalah level terakhir — tidak ada level 31, navigasi ke `/game/31` akan crash
- **Resolution:** `LevelCompleteDialog` mendeteksi `levelId == 30` → tampilkan **ending screen khusus** "🎉 Selamat! Semua Level Selesai!" dengan tombol "Kembali ke Menu" (navigate ke `/menu`). Untuk level 1–29, tombol tetap "Level Berikutnya". Update `TASK-050`. **Pilihan: (A)**

### Q6 — Missing Dependency: `google_fonts` (LOW)
- **Requirement:** `TASK-004` — `AppTheme` menggunakan Google Font `Outfit`
- **Issue:** `google_fonts` tidak ada di daftar DEP-001..DEP-010 di plan — dependency hilang, akan gagal compile
- **Resolution:** Tambahkan `google_fonts: ^6.2.1` sebagai **DEP-011** di `pubspec.yaml`. Font di-bundle offline via `google_fonts` asset manifest. Update `TASK-001` dan `TASK-004`. **Pilihan: (A)**

### Q7 — Git Repository Setup (LOW)
- **Requirement:** Section 9 Rollback — "commit per-task ke Git, branch `feature/phase-N`"
- **Issue:** Tidak ada task eksplisit untuk `git init` di TASK-001 — rollback strategy bergantung pada Git history yang belum tentu ada
- **Resolution:** **Git setup dianggap implisit** — developer bertanggung jawab sendiri. Tidak ada perubahan di plan. **Pilihan: (B)**

---

## 3. ⚠️ Assumed / Auto-Resolved / Out of Scope (The 20% we skip)

- **Scenario:** ASSUMPTION-001 — Sumber audio assets (bgm.mp3, ok.mp3, click.mp3)
  - **Handling:** `[Assumed / Out of Scope]` — Audio assets akan dibuat/dicari secara terpisah oleh developer. Plan hanya menyediakan struktur file dan integrasi code. Tidak diinterogasi lebih lanjut karena bukan keputusan teknis yang bisa diputuskan sekarang.

- **Scenario:** ASSUMPTION-002 — Detail layout 30 level (posisi cup, emitter, filter) bersifat iteratif
  - **Handling:** `[Assumed / Out of Scope]` — Layout akan di-playtest dan di-adjust secara iteratif saat Phase 4. Tidak diinterogasi karena user sudah konfirmasi pendekatan iteratif di sesi perencanaan.

- **Scenario:** Behavior partikel saat ada di batas `kMaxSpeed` persis (edge of clamp)
  - **Handling:** `[Assumed / Auto-Resolved]` — `clamp()` adalah operasi deterministik, tidak ada efek samping. Partikel akan bergerak di kecepatan maksimum `6.0` hingga bertabrakan dengan garis atau cangkir.

- **Scenario:** Behavior `LevelCompleteDialog` jika pemain menekan tombol Back (Android hardware back button) saat dialog tampil
  - **Handling:** `[Assumed / Auto-Resolved]` — Android back button akan diabaikan saat dialog tampil (WillPopScope/PopScope untuk block back gesture). Pemain harus memilih salah satu tombol di dialog.

---

## 4. 📝 Next Steps

### Perubahan yang Harus Diterapkan ke Plan

Plan `plan/plan-feature-micin-game-v1.0.md` harus di-update oleh `/sdlc-plan-tasks` dengan resolusi berikut:

| Perubahan | Task Terdampak | Detail |
|---|---|---|
| Tambah `kMaxSpeed = 6.0` + velocity clamp | TASK-002, TASK-018 | Tambahkan ke constants.dart, terapkan di particle_controller.dart |
| Klarifikasi `reset()` = TOTAL | TASK-020 | Tambahkan: `LineController.clearAll()` + `ParticleController.resetAll()` |
| Tambah `_isComplete` boolean guard | TASK-020, TASK-050 | Guard di `_onTick()`, listener di `GameScreen` |
| Hapus `bestScore` dari `LevelProgress` | TASK-008, TASK-040 | Simplify model, hapus `saveBestScore()` |
| Tambah Level 30 ending screen logic | TASK-050 | `if (levelId == 30)` → ending screen |
| Tambah `google_fonts: ^6.2.1` sebagai DEP-011 | TASK-001, TASK-004 | Tambahkan ke pubspec.yaml dan dependencies list |

### Domain Glossary
- Tidak ada domain term baru yang perlu di-canonicalize dalam sesi ini.

### ADR
- **ADR dipertimbangkan:** Keputusan "geometric collision vs pixel-sampling" (CON-003 di plan) memenuhi Triple Gate: (1) Hard to reverse — mengubah collision approach di tengah pengembangan akan membutuhkan rewrite engine, (2) Surprising without context — developer Flutter biasanya expect pixel collision untuk game, (3) Real trade-off — performa vs akurasi. **→ Direkomendasikan untuk dibuat ADR** saat `/sdlc-write-code` Phase 2 dimulai.

---

> **User Decision Prompt:**
> Plan `plan-feature-micin-game-v1.0.md` telah mencapai Readiness Score **89/100**. Dokumen siap untuk fase eksekusi.
> Apakah Anda ingin **PROCEED** ke `/sdlc-write-code` untuk mulai implementasi Phase 1, atau ingin **REFINE** lebih lanjut?
