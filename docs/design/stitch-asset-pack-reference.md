# Stitch Asset Pack Reference: Chunky Arcade (v2.0)

**Stitch Project ID:** `3096952998039927940`  
**Screen Name:** `projects/3096952998039927940/screens/a550d5df72884907bd938730e6009117`  
**Screen Title:** Micin Micin — Chunky Arcade UI & Asset Pack  
**Device Target:** Mobile ($400 \times 700$ Virtual Canvas)  
**Status:** Approved & Synchronized  

---

## 1. Overview & Verification

This asset pack defines the visual component catalog for **Micin Micin**, fully adhering to the **Chunky Arcade** aesthetic (`CartoonTokens`). All legacy minimalist, glassmorphic, and clinical slate designs have been replaced with tactile 3D candy slabs, 4px solid drop shadows (`box-shadow: 0 4px 0 #...`), specular gloss highlights, and diegetic game elements.

- **Stitch Screenshot URL:** [View Screenshot](https://lh3.googleusercontent.com/aida/AEtjO1Vy3G4QNUu5mzbh8zTcqJEvPfswGsoxHgNlHK_lJsq1j5n3Vc2JvuREwuL1NpqDPIXG415x8M58FO6kskkEQNDWq2ntAH9LGXq7ahZ3fXCAk-BamgCG-GTd2m0AUE7YDTq-TUKBKwJLYAHmAIPwBUBfR1lk2c4BjOn87YwK2exy-5CotmfZ7ab6m_x30etq1Kvxlz-iQT0MdfUYdLX5d_AqTvZKWD8n7Oyto3QiXOrQMq1R27K_i4CQFV4)
- **Stitch HTML Bundle:** [Download HTML](https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzE2ZWVjNTcxZjBkOTQzODJhMWVkOWU0Yjk0MWQ5YTkzEgsSBxDm7OPejg0YAZIBIwoKcHJvamVjdF9pZBIVQhMzMDk2OTUyOTk4MDM5OTI3OTQw&filename=&opi=96797242)

---

## 2. Design Tokens Mapping (Flutter & Web)

| Role | Flutter Token (`CartoonTokens`) | Hex Top / Base | Hex Bottom | Solid Drop Shadow |
|---|---|---|---|---|
| **Canvas Gradient** | `canvasTop` / `canvasBottom` | `#1E1645` | `#110C29` | N/A |
| **Panel Surface** | `panelBg` / `panelBorder` | `#241C52` | Border `#45368E` | `#120D2C` (5px) |
| **Cream Card** | `panelCreamBg` / `Border` | `#FFF9E8` | Border `#E8C888` | `#2B1842` (6px) |
| **Green CTA (Play/Next)** | `greenTop` / `greenBottom` | `#4ADE80` | `#16A34A` | `#15803D` (4px) |
| **Amber (Levels/Coins)** | `amberTop` / `amberBottom` | `#FBBF24` | `#D97706` | `#B45309` (4px) |
| **Cyan (Reset/Utility)** | `cyanTop` / `cyanBottom` | `#38BDF8` | `#0284C7` | `#0369A1` (4px) |
| **Coral (Pause/Danger)** | `coralTop` / `coralBottom` | `#FB7185` | `#E11D48` | `#BE123C` (4px) |
| **Purple (Gravity/Magic)** | `purpleTop` / `purpleBottom`| `#C084FC` | `#9333EA` | `#7E22CE` (4px) |

---

## 3. Catalog of Components in Asset Pack

1. **Section 1: 3D Extruded Candy Action Buttons**
   - Full button hierarchy (Play Game, Level Select, Reset Stage, Retry Level, Gravity Invert).
   - 48px tactile circular icon buttons for Sound, Pause, Reload, Gravity-Rev, and Hint.
   - Micro-interaction: `translateY(4px)` with zero shadow on `:active` (tactile press).
2. **Section 2: Diegetic In-Game Arcade Coin HUD**
   - Solid `#241C52` dock anchored to the safe area.
   - Golden embossed coin badge with 3D coin icon and tabular numeral counter (`1,450`).
   - Stage progress indicator (`STAGE 14 • ACT II`).
3. **Section 3: Chunky Target Cups & Granular Physics**
   - U-shaped cup silhouette with 4px border, rounded bottom corners, and distinct color rims.
   - Centered Outfit Bold countdown numeral (e.g., active filling cup with count `18`).
   - Saturated cup with count `0` glowing in radiant gold (`#FBBF24`) with emerald checkmark badge.
   - Realistic settled sugar sand mound inside cup cavity.
4. **Section 4: Color Filter Gates & Collision Dynamics**
   - Beveled conduit brackets for Coral (`#FB7185`), Cyan (`#38BDF8`), Amber (`#FBBF24`), and Emerald (`#4ADE80`).
   - Top funnel emitter nozzle dropping 60 grains/second.
   - Rigid 4px white player-drawn chalk stroke deflecting sugar particle streams.
5. **Section 5: 3D Beveled Level Progression Grid**
   - 4 Act milestone cards with star completion progress bars (`ACT I The Basin`, `ACT II Prism Gates`, `ACT III Inverters`, `ACT IV The Lab`).
   - Level select nodes (Stages 9 to 16) displaying Completed (3 stars), Current Active Stage 14 (pulsing amber ring), and Locked (indigo slab with padlock).
6. **Section 6: Pop-Scale Victory Modal**
   - Cream celebration face (`#FFF9E8`) with 3D folded ribbon banner (`★ STAGE CLEARED! ★`).
   - Extruded golden 3-star rating with specular reflections.
   - Reward pill (`+50 COINS EARNED`) and side-by-side Replay & Next buttons.
