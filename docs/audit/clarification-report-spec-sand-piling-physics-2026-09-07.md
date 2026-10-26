# 🔍 Clarification Report [Review Iteration 1 - FINAL]

**Readiness Score:** 100/100  
**Status:** Good Enough (Viable for Implementation Planning)

**Score Breakdown:**

- **Completeness (max 40):** 40/40 - Comprehensive coverage of granular particle physics constants, discrete column heightmap algorithms, Angle of Repose relaxation, overflow spilling, countdown display, Option A color membrane, and gravity toggle edge cases.
- **Clarity (max 30):** 30/30 - Unambiguous mathematical boundaries ($\Delta H_{\max} = 1.4\text{ px}$, $g = 0.14$, $v_{\max} = 4.8$, $r = 1.1$), concrete data contracts (`CupHitbox` Float64List heightmap), pseudo-code implementation, and zero subjective language.
- **Alignment (max 30):** 30/30 - 100% aligned with Approved PRD [docs/prd-20260907-sand-piling-physics.md](file:///d:/kayzz/flutter/micin/docs/prd-20260907-sand-piling-physics.md), ADR [docs/adr/0003-discrete-column-heightmap-sand-piling.md](file:///d:/kayzz/flutter/micin/docs/adr/0003-discrete-column-heightmap-sand-piling.md), and Domain Glossary [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md).
- **Critical Flaw Veto:** None

---

## 1. 🚨 Critical Findings (Blockers)

_None. All physics models, heightmap data structures, overflow mechanics, and edge cases are strictly defined and validated._

---

## 2. 🧩 Resolved Items & Agreements

- **Gravity Inversion & Settled Sand Stability (Level 21, 24, 27, 30):**
  - **Context:** On levels featuring Gravity Toggle portals, gravity can be reversed upward. How should settled sand inside a Target Cup behave when gravity inverts?
  - **Resolution:** **Option A Selected (Locked Settled Sand)**. Particles that have settled into the `CupHitbox` heightmap remain locked inside the cup and are immune to gravitational inversion. The heightmap columns and settled sand points do not float or dislodge, ensuring achieved cup progress is protected, respecting classic *Sugar, Sugar* puzzle conventions, and preserving deterministic $O(1)$ performance without reverse dynamic physics.
- **Color Selective Membrane (Option A):**
  - **Resolution:** Target Cup mouth apertures admit only particles of matching color. Non-matching particles are deflected upward and outward ($v_y = -v_y \times 0.3, v_x \pm 0.5$).
- **Pure Countdown Target Display:**
  - **Resolution:** Synthetic liquid fill rectangle (`fluidPaint`) is completely deleted. The cup renders a clean countdown integer $\text{remaining} = \max(0, \text{target} - \text{settledCount})$, turning amber/gold at 0.
- **1D Discrete Column Heightmap & Angle of Repose:**
  - **Resolution:** Width is divided into $2.0$ virtual px bins. When height difference between adjacent bins exceeds $\Delta H_{\max} = 1.4\text{ px}$ ($\tan(35^\circ) \times 2.0$), the incoming particle rolls to the lowest adjacent bin, forming an authentic conical Sand Mound.
- **Overflow Spill Mechanics:**
  - **Resolution:** When a Sand Mound reaches the cup rim ($H \ge \text{bounds.height}$), excess particles rolling off the cone are ejected over the rim with active world velocities ($v_x = \pm 1.0, v_y = 0.5$) back into free-fall.
- **Quota Formula Migration:**
  - **Resolution:** Particle supply across all 30 levels is migrated to $\text{Total Sugar} = 150 \times N_{\text{cups}}$.

---

## 3. ⚠️ Assumed / Auto-Resolved / Out of Scope (The 20% we skip)

- **Settled Sand Point Batch Rendering:**
  - `[Assumed / Auto-Resolved]` - Settled particles in `CupHitbox.settledParticleOffsets` are rendered in bulk via `Canvas.drawPoints(PointMode.points)` within `ParticlePainter`, reusing existing GPU batching pipelines.
- **Particle Pool Garbage Collection Protection:**
  - `[Assumed / Auto-Resolved]` - Settled particles in cups are marked `isCaptured = true` without heap deallocation churn during the active level loop, preventing garbage collection stutter.
- **Multi-Emitter Equal Partitioning:**
  - `[Assumed / Auto-Resolved]` - In multi-emitter levels, total quota $150 \times N_{\text{cups}}$ is evenly divided between active emitters.

---

## 4. 📝 Next Steps

- Upstream Technical Specification [spec/spec-architecture-sand-piling-physics.md](file:///d:/kayzz/flutter/micin/spec/spec-architecture-sand-piling-physics.md) updated with Option A Gravity Toggle specification and marked ready.
- Architecture Decision Record [docs/adr/0003-discrete-column-heightmap-sand-piling.md](file:///d:/kayzz/flutter/micin/docs/adr/0003-discrete-column-heightmap-sand-piling.md) verified and active.
- Direct user to invoke `/sdlc-plan-tasks` to author the Tracer Bullet Implementation Plan in `/plan/`.

---

> **User Decision Prompt:**  
> The document has achieved a Readiness Score of **100/100**. It is ready for the next phase. Do you want to **PROCEED** to the next phase, or do you want to **REFINE** and clarify further?
