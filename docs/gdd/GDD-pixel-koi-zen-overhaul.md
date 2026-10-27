# Game Design Document (GDD): Micin Koi Zen Edition
## Pixel-Art Zen Garden Overhaul (Sugar, Sugar Physics × Pixel UI × Procedural Koi Pond)

> **Document ID:** `GDD-20261026-PIXEL-KOI-ZEN`  
> **Status:** Draft / Proposed Specification  
> **Target Version:** 3.0.0 (Zen Koi Overhaul)  
> **Reference Mechanics:** *Sugar, Sugar* (Bart Bonte) via `docs/references/sugarsugar.swf`  
> **UI System:** `pixel_ui: ^0.5.1`  
> **Aesthetic Blueprint:** Procedural Koi Pond / Top-Down Pixel Art Zen Garden  
> **Audio Architecture:** Hierarchical Bus Mixer + Dynamic Pentatonic Vertical Stems  

---

## 1. Executive Summary & Aesthetic Vision

### 1.1 High Concept
**Micin Koi Zen** mentransposisi puzzle fisika granular klasik *Sugar, Sugar* ke dalam suasana taman kolam koi Jepang (*Zen Koi Pond*) yang tenang, meditatif, dan memukau dalam balutan seni pixel 16-bit. 

Pemain membimbing aliran butiran pakan ikan emas (*golden koi pellets*) atau embun teratai bercahaya yang jatuh dari pancuran bambu (*Shishi-Odoshi*) ke mangkuk batu zen (*Tsukubai*) dengan melukis tanggul air atau sapuan kuas kaligrafi (*Sumi-e*) di atas permukaan air kolam yang dihuni ikan koi berenang secara prosedural.

```
       [ Pancuran Bambu / Shishi-Odoshi ]
                     :  :  (Falling Koi Pellets)
                     v  v
      ═══════════════════════════════ (Sumi-e Ink / Bamboo Line drawn by Player)
                    \
                     \
                      v  [ Gerbang Torii / Color Filter Gate ]
                             : (Color Mutated to Vermilion/Gold)
                             v
                  [ Mangkuk Batu / Tsukubai Basin (Remaining: 42) ]
                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  [ Air Kolam Jernih + Ikan Koi Prosedural Berenang ]
```

### 1.2 Pilar Estetika (The Aesthetic Pillars)
1. **Pristine Pixel Water & Caustics:** Air kolam jernih bernuansa aquamarine/teal lembut (`#52B79A`, `#398C81`, `#1E3F3B`) dengan pola pantulan cahaya (*water caustics*), daun teratai bulat berurat radial (*lily pads*), dan bunga lotus mekar merah muda (`#F28BA8`).
2. **Procedural Koi Fauna (Diegetic Background Life):** Ikan koi (Kohaku, Showa, Ogon) dan gerombolan ikan kecil berenang santai di lapisan bawah canvas menggunakan simulasi pergerakan berbasis spine/boids, memberikan kehidupan visual tanpa mengganggu collision fisika gameplay.
3. **Parametric Pixel Design System (`pixel_ui`):** Seluruh HUD, dialog, dan tombol mengadopsi primitif `pixel_ui` (`PixelBox`, `PixelButton`, `PixelCorners.md`, `PixelShadow`, `PixelTexture`, dan font `PixelText.mulmaru`), menyingkirkan elemen vector arcade/glassmorphism yang tidak tematik.
4. **Organic Tactile Auditory Experience:** Audio bus mixer meditatif yang menggabungkan petikan Koto, hembusan seruling Shakuhachi, gemericik air alami, ketukan bambu (*shishi-odoshi clack*), dan resonansi mangkuk nyanyi Tibet (*Tibetan singing bowl*) berlaras pentatonik yang naik harmonis seiring terisinya mangkuk.

---

## 2. Strict Core Mechanics Invariance (Zero Gameplay Deviation)

Sesuai aturan mutlak desain, **seluruh mekanisme fisika granular dan puzzle dari *Sugar, Sugar* dipertahankan 100% identik**:

| Komponen Asli (*Sugar, Sugar*) | Komponen Transposisi Zen Koi | Status Logika Fisika / Engine |
| :--- | :--- | :--- |
| **Spout / Emitter** | Pancuran Bambu Tradisional (*Shishi-Odoshi* / *Kakehi*) | 100% Identik (Posisi virtual, interval spawn, kecepatan gravitasi $g = 0.14$, $v_{\max} = 4.8$). |
| **Granular Particles (Sugar)** | Butiran Pakan Ikan Koi / Embun Mutiara Zen (*Hikari Pellets*) | 100% Identik (Verlet integration, radius $1.1\text{ px}$, $400 \times 700$ virtual coordinates). |
| **Drawn Lines (Chalk)** | Sapuan Tinta Kuas Air (*Sumi-e Stroke*) / Pembatas Ranting Bambu | 100% Identik (Smooth segment collision, continuous detection, friction coefficient). |
| **Target Cups** | Mangkuk Batu Air Zen (*Tsukubai Basin*) / Cawan Keramik Raku | 100% Identik (Kapasitas 100, 1D discrete column heightmap, angle of repose relaxation, overflow spill). |
| **Color Filters** | Gerbang Torii Air Mini / Lentera Kaca Teratai Bercahaya | 100% Identik (AABB collision zone, mutasi warna partikel instan saat melintas). |
| **Gravity Inverter** | Jimat Pusaran Air Yin-Yang (*Zen Water Vortex*) | 100% Identik (Inversi vektor gravitasi $g_y \to -g_y$, particle flight path flip). |
| **Level Geometries / Obstacles** | Bebatuan Lumut (*Moss Stones*), Batang Kayu Hanyut (*Driftwood*) | 100% Identik (Static colliders, deflection normals). |

---

## 3. UI/UX Design System with `pixel_ui`

### 3.1 Color Palette & Tokens (`KoiZenTokens`)

```dart
abstract final class KoiZenTokens {
  // Water Canvas & Pond Depth
  static const Color pondSurface = Color(0xFF52B79A); // Mint Teal Surface
  static const Color pondMidDepth = Color(0xFF398C81); // Aquatic Mid-Tone
  static const Color pondDeep = Color(0xFF1E3F3B);     // Deep Shaded Bed
  static const Color pondCaustic = Color(0xFF8CE3D0);  // Sunlight Water Caustic

  // Flora & Vegetation
  static const Color lilyPadTop = Color(0xFF5A9451);   // Lotus Leaf Base
  static const Color lilyPadDark = Color(0xFF376332);  // Leaf Shadow / Edge
  static const Color lotusPetal = Color(0xFFF28BA8);   // Pink Lotus Bloom
  static const Color lotusPistil = Color(0xFFFFD166);  // Warm Gold Stamen

  // UI Surfaces & Paper (Washi Paper & Moss Stone)
  static const Color washiPaper = Color(0xFFFAF6E8);   // Rice Paper Cream
  static const Color washiDark = Color(0xFFE8DFCC);    // Aged Paper Border
  static const Color stoneDark = Color(0xFF263238);    // Charcoal Slate Stone
  static const Color stoneEdge = Color(0xFF37474F);    // Slate Highlight

  // Accents & Actions (PixelButton Styles)
  static const Color bambooGreen = Color(0xFF437A48);  // Primary Action / Play
  static const Color vermilionRed = Color(0xFFD9383A); // Torii Red / Reset / Alert
  static const Color imperialGold = Color(0xFFE5A93C); // Star / Coin / Progress
  static const Color indigoZen = Color(0xFF2A3D66);    // Info / Utility / Sound
}
```

### 3.2 UI Specifications (HUD, Menus, Dialogs)

#### 1. In-Game HUD (`GameHud`)
- **Top-Left (Level Badge):**
  - Menggunakan `PixelBox` berukuran logis $28 \times 12$ dengan `PixelCorners.sm`, background `washiPaper` (`#FAF6E8`), border `stoneDark` (`#263238`), dan shadow `PixelShadow.sm`.
  - Teks: `PixelText.mulmaru(text: 'TAHAP 08', fontSize: 14, color: stoneDark)`.
- **Top-Right (Action Buttons):**
  - Menggunakan 3 buah `PixelButton` berturut-turut:
    1. **Audio Toggle:** `PixelButton` ($14 \times 14$ logical), icon pixel speaker/bell, warna `indigoZen`.
    2. **Reset Level:** `PixelButton` ($14 \times 14$ logical), icon pixel rewind spiral, warna `vermilionRed`.
    3. **Pause Menu:** `PixelButton` ($14 \times 14$ logical), icon dua bilah bambu pause, warna `stoneDark`.
  - Memiliki `pressChildOffset: Offset(0, 1)` untuk tactile feedback instan saat ditekan.
- **Bottom-Center (Gravity Switcher):**
  - Jika level memiliki mekanik gravitasi (`hasGravityToggle: true`), tampilkan kapsul horizontal `PixelBox` berlambang Yin-Yang pixel dengan panah arus air dinamis yang berdenyut lembut.

#### 2. Main Menu (`MenuScreen`)
- **Background:** Air kolam animasi dengan gerombolan ikan koi berenang santai di latar belakang dan daun teratai mengambang.
- **Logo Title:** Pixel Art kaligrafi "MICIN KOI ZEN" (atau "TAMAN KOI") dengan aksen bayangan pixel solid dan riak air.
- **Navigation Buttons:** `PixelButton` berukuran logis $54 \times 16$ (`MAIN`, `PILIH TAHAP`, `SUARA`) dengan gaya balok kayu/bambu halus dan font `PixelText.mulmaru`.

#### 3. Level Select (`LevelSelectScreen`)
- **Act Navigation:** 4 Babak Zen bertema 4 Musim:
  - **Babak I: Musim Semi (Haru)** — Tahap 1–7 (Dasar aliran & tanggul air).
  - **Babak II: Musim Panas (Natsu)** — Tahap 8–15 (Gerbang Torii & spektrum warna).
  - **Babak III: Musim Gugur (Aki)** — Tahap 16–22 (Pusaran arus & inversi gravitasi).
  - **Babak IV: Musim Dingin (Fuyu)** — Tahap 23–30 (Taman zen master & teka-teki majemuk).
- **Stage Grid:** Menggunakan `PixelGrid` dengan ubin $16 \times 16$ bernomor pixel, bintang ikan mas emas untuk tahap terselesaikan, dan gembok batu untuk tahap terkunci.

#### 4. Overlays & Dialogs (Pause, Victory)
- **Pause Overlay:** Frame `PixelBox` berasas tekstur kertas washi (`PixelTexture(density: 0.12, seed: 108)`), sudut tangga `PixelCorners.md`, berisi tombol: Lanjutkan (`bambooGreen`), Ulangi (`vermilionRed`), dan Menu (`stoneDark`).
- **Level Complete Dialog:** Animasi daun teratai merekah dan ikan koi emas melompat kecil, menampilkan 3 bintang teratai emas, durasi penyelesaian, dan tombol `Tahap Berikutnya`.

---

## 4. Audio Design & Dynamic Music Architecture

Mengacu pada arsitektur skill `audio-design`, seluruh output audio dikelola melalui hierarki bus desibel terpusat (`MasterBus` $\to$ `[MusicBus, AmbienceBus, SfxBus, InteractionBus]`):

### 4.1 Bus Architecture & Headroom Targets
- **Master Bus:** Target loudness $-14\text{ LUFS}$, peak limiter pada $-1.0\text{ dBFS}$.
- **Ambience Bus ($-6.0\text{ dB}$):**
  - Loop gemericik air alami yang mengalir tenang (*babbling brook / gentle water trickle*).
  - Suara hembusan angin sepoi-sepoi dan gemerincing lembut lonceng angin kaca/bambu (*Fūrin*).
- **Music Bus ($-4.0\text{ dB}$):**
  - **Adaptive Dynamic Music via Vertical Layering:**
    - *Stem 1 (Meditation Base):* Pad sintetis hangat dipadu petikan drone Koto lembut (selalu bermain).
    - *Stem 2 (Drawing Activity):* Arpeggio melodi Koto dan seruling Shakuhachi yang memudar masuk (*fade-in* $0.5\text{s}$) begitu jari pemain menyentuh layar menggambar garis.
    - *Stem 3 (Tension & Fulfillment):* Resonansi genta mangkuk Tibet (*Tibetan Singing Bowl*) yang bertambah intens saat kapasitas mangkuk mencapai $\ge 70\%$.
- **SFX & Interaction Bus ($-2.0\text{ dB}$):**
  - Menggunakan variasi acak (*pitch wobble* $\pm 5\%$) untuk mencegah efek berulang mekanis (*machine-gun effect*):
    - **Particle Drop / Bouncing on Line:** Suara ketukan kayu bambu halus (*soft bamboo click*).
    - **Particle Passing Filter:** Suara gesekan lonceng angin peri air (*chime sparkle*).
    - **Particle Settling in Cup:** Suara tetesan air bergaung (*resonant water drop plop*) dengan frekuensi pentatonik (C4 $\to$ D4 $\to$ E4 $\to$ G4 $\to$ A4 $\to$ C5) yang naik berurutan setiap $15\%$ pengisian.
    - **Gravity Toggle:** Suara dengungan hembusan angin spiritual (*zen whoosh*).
    - **Level Complete:** Dentang genta kuil (*temple bell gong*) yang bergaung khidmat diiringi riak air.

---

## 5. Visual Rendering Pipeline & Asset Manifest

### 5.1 Flame Scene Graph Layering (Priority Stack)

| Priority | Component | Deskripsi Visual & Rendering |
| :---: | :--- | :--- |
| **-20** | `WaterBedFlameComponent` | Lapisan dasar kolam, pasir dasar, dan tekstur caustics air dinamis. |
| **-15** | `ProceduralKoiFlameComponent` | Ikan koi prosedural (Kohaku, Sanke, Guppies) berenang mandiri dengan navigasi boids santai. |
| **-10** | `LilyPadFoliageComponent` | Daun teratai mengapung, bunga lotus mekar, bayangan daun jatuh ke dasar air. |
| **10** | `ZenLevelGeometryComponent` | Pancuran bambu (*Shishi-Odoshi*), Gerbang Torii (*Color Filter*), dan Mangkuk Tsukubai. |
| **20** | `ParticleSystemFlameComponent` | Butiran pakan koi persegi/pixelated (`drawPoints` batch, zero-allocation). |
| **30** | `ZenLineDrawingComponent` | Garis goresan kuas tinta Sumi-e dengan tepian bertekstur pixel halus. |
| **40+** | Flutter Overlays (`GameHud`, Overlays) | UI berbasis `pixel_ui` yang di-render di atas Flame canvas. |

### 5.2 Asset Production Matrix (Gemini & Pixel Art Generation Prompts)

Seluruh sprite game di-generate dengan palet terkunci, sudut pandang *pure top-down orthographic*, dan isolasi latar hitam padat untuk ekstraksi alpha transparan:

```text
[PROMPT TEMPLATE]
Pure top-down orthographic 16-bit pixel art [SUBJECT], Japanese zen garden koi pond theme, [PALETTE: mint teal #52B79A, bamboo green #437A48, lotus pink #F28BA8, vermilion red #D9383A, rice paper cream #FAF6E8], crisp pixel clusters, clean outlines, no anti-aliasing blur, retro GBA game aesthetic, isolated on pure solid black background (#000000), no shadows on background --ar 1:1
```

---

## 6. Verification & Quality Gates

1. **Deterministic Physics Validation:**
   - Seluruh 30 level harus dapat diselesaikan dengan kurva kesulitan dan solusi fisika yang identik seperti pada versi asli *Sugar, Sugar*.
   - Virtual coordinate space $400 \times 700$ dan letterboxing wajib dipertahankan 100%.
2. **Performance Budget (Mobile 60/120 FPS):**
   - Zero allocation pada update loop Flame (`render` dan `update`).
   - Ikan koi prosedural menggunakan pre-allocated spine arrays (maksimal 14–20 ikan).
   - `pixel_ui` dirender tanpa GPU shader blur runtime pada gameplay hot path.
3. **Auditory Harmony:**
   - Sidechain ducking bekerja mulus saat tombol di-tap atau saat genta kemenangan berbunyi.
   - Variasi pitch SFX mencegah kelelahan dengar (*auditory fatigue*).
