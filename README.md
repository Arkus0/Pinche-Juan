# Pinche Juan - KitchenOS

> **The Ultimate Kitchen Utility App for Expert Home Cooks**

A production-grade Flutter application that provides high-precision tools for the *execution* phase of cooking. This is NOT a recipe discovery app—it's a **Kitchen Operating System** designed for power users who need professional-grade tools.

---

## 🎯 Project Vision

**Target User**: Expert home cooks and tech-savvy users who treat cooking as a technical craft.

**Core Philosophy**:
- Precision over discovery
- Execution over inspiration
- Tools over content
- Offline-first architecture
- Combat-ready UI for active cooking

---

## ⚡ Tech Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| **Framework** | Flutter (Latest stable) | Cross-platform mobile development |
| **State Management** | Riverpod (with code generation) | Reactive state management |
| **Local Database** | Isar | Offline-first, high-performance NoSQL DB |
| **Code Generation** | Freezed + JSON Serializable | Immutable data classes |
| **Device Features** | Wakelock Plus | Screen always-on for Combat Mode |
| | Vibration | Haptic feedback |
| | Flutter Local Notifications | Timer alerts |
| **UI/UX** | Material 3 | High-contrast modifications for distance readability |

---

## 🏗️ Architecture

### Feature-First Clean Architecture

```
lib/
├── core/                           # Shared utilities and configurations
│   ├── constants/                  # App-wide constants
│   ├── theme/                      # Theme definitions (Combat Mode theme)
│   │   └── app_theme.dart         # Neon-on-dark high-contrast theme
│   ├── utils/                      # Helper functions
│   ├── extensions/                 # Dart extensions
│   └── database/                   # Database initialization
│
├── features/                       # Feature modules (independently testable)
│   │
│   ├── unit_converter/            # Smart Unit Lab
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── ingredient.dart              # Ingredient with density
│   │   │   │   ├── measurement_unit.dart        # Unit enums and conversions
│   │   │   │   └── conversion_result.dart       # Conversion output
│   │   │   └── services/
│   │   │       └── unit_conversion_service.dart # DENSITY ALGORITHM
│   │   │
│   │   ├── data/
│   │   │   ├── datasources/       # JSON loading, database access
│   │   │   ├── models/            # Data transfer objects
│   │   │   └── repositories_impl/ # Repository implementations
│   │   │
│   │   └── presentation/
│   │       ├── screens/           # UI screens
│   │       ├── widgets/           # Reusable widgets
│   │       └── providers/         # Riverpod providers
│   │
│   ├── timeline_orchestrator/     # Reverse Timer
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── cooking_task.dart            # Task with duration
│   │   │   │   └── cooking_timeline.dart        # Timeline with target time
│   │   │   └── services/
│   │   │       └── timeline_scheduler.dart      # REVERSE TIME ALGORITHM
│   │   │
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── combat_mode/               # Active Cooking Dashboard
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── combat_mode_dashboard.dart   # Main UI
│   │       ├── widgets/
│   │       │   ├── active_timer_card.dart       # Live countdown cards
│   │       │   ├── next_task_card.dart          # Next task preview
│   │       │   └── critical_alert_banner.dart   # Flashing alerts
│   │       └── providers/
│   │           └── combat_mode_provider.dart    # Wakelock + state
│   │
│   └── substitution_db/           # Emergency Substitution Database
│       ├── domain/
│       │   └── models/
│       │       └── ingredient_substitution.dart
│       ├── data/
│       └── presentation/
│
└── main.dart                      # App entry point

assets/
└── data/
    ├── ingredient_densities.json       # 25+ ingredients with g/ml values
    └── ingredient_substitutions.json   # Emergency substitutes with ratios

test/
├── unit/                          # Unit tests
├── widget/                        # Widget tests
└── integration/                   # Integration tests
```

---

## 🚀 Core Features (MVP)

### 1. Smart Unit Lab (Advanced Converter)

**The Problem**: Traditional converters can't convert volume to weight without knowing ingredient density.

**The Solution**: Density-aware unit conversion.

#### Algorithm (`lib/features/unit_converter/domain/services/unit_conversion_service.dart:27`)

```dart
// Example: Convert 1 cup of flour to grams
// 1. Convert cup to base unit (milliliters)
//    1 cup = 236.588 ml
// 2. Apply density conversion
//    236.588 ml × 0.59 g/ml = 139.59 g
// 3. Result: 1 cup flour ≈ 140g
```

**Density Formula**:
- **Volume → Weight**: `weight(g) = volume(ml) × density(g/ml)`
- **Weight → Volume**: `volume(ml) = weight(g) ÷ density(g/ml)`

**Data Source**: `assets/data/ingredient_densities.json`
- 25+ common ingredients with scientifically accurate densities
- Categories: Flours, Sugars, Liquids, Fats, Seasonings, Grains
- Aliases for search (e.g., "AP flour", "plain flour" → "All-Purpose Flour")

**Bonus**: Baker's Math
- Calculate baker's percentages (flour = 100%, others relative)
- Example: 70% hydration = 350g water for 500g flour

---

### 2. Timeline Orchestrator (Reverse Timer)

**The Problem**: Traditional timers count down individually. You don't know when to START each task.

**The Solution**: Backward scheduling from target serving time.

#### Algorithm (`lib/features/timeline_orchestrator/domain/services/timeline_scheduler.dart:17`)

**Input**:
- Target serving time: 8:00 PM
- Tasks:
  - Roast chicken: 90 min
  - Rest meat: 15 min
  - Boil potatoes: 20 min
  - Make gravy: 10 min

**Algorithm**:
1. Start from 8:00 PM (target)
2. Schedule backward:
   - 8:00 PM - 15m = **7:45 PM** (Rest meat START)
   - 7:45 PM - 90m = **6:15 PM** (Roast chicken START)
   - 8:00 PM - 10m = **7:50 PM** (Gravy START)
   - 8:00 PM - 20m = **7:40 PM** (Potatoes START)

**Output**: Gantt-chart style timeline showing:
- When to start each task
- Which tasks run in parallel
- Critical path visualization

**Smart Features**:
- Detects parallel tasks (normal priority)
- Protects critical tasks (no parallelization)
- Buffer time recommendations
- Timeline validation (warns if unrealistic)

---

### 3. Combat Mode (Active Cooking Dashboard)

**The Problem**: Normal UIs are unusable when hands are wet, steamy, or you're across the kitchen.

**The Solution**: Military-grade tactical interface.

#### Design Constraints (`lib/features/combat_mode/presentation/screens/combat_mode_dashboard.dart:27`)

**UI Requirements**:
- ✅ **Always-On Display**: Wakelock prevents screen sleep
- ✅ **Knuckle-Tap Buttons**: Minimum 80×80dp tap targets
- ✅ **Distance Readability**: 96sp font for timers, neon colors
- ✅ **High Contrast**: Dark background (#0A0E27) with neon accents (#00FF41)
- ✅ **Haptic Feedback**: Physical confirmation for actions
- ✅ **Landscape Mode**: Optimized for counter/tablet use

**Theme** (`lib/core/theme/app_theme.dart:11`):
```dart
// Neon colors designed to cut through kitchen steam
static const Color neonGreen = Color(0xFF00FF41);    // Primary
static const Color neonRed = Color(0xFFFF0055);      // Critical alerts
static const Color neonYellow = Color(0xFFFFED00);   // Warnings
static const Color neonBlue = Color(0xFF00D9FF);     // Next task
```

**Layout**:
```
┌─────────────────────────────────────────────────────┐
│ [CRITICAL ALERT BANNER] (if critical tasks active)  │
├────────────────────────────┬────────────────────────┤
│  ACTIVE TIMERS             │  NEXT UP               │
│  ┌──────────────────────┐  │  ┌──────────────────┐ │
│  │ ROAST CHICKEN        │  │  │ 🥔                │ │
│  │ 45:30 (huge timer)   │  │  │ BOIL POTATOES    │ │
│  │ [████████░░] 80%     │  │  │ Starts in 10:00  │ │
│  │ [✓ COMPLETE] button  │  │  │ Duration: 20m    │ │
│  └──────────────────────┘  │  └──────────────────┘ │
│                            │                        │
├────────────────────────────┴────────────────────────┤
│ [PAUSE] [SKIP] [END SESSION] (large control buttons)│
└─────────────────────────────────────────────────────┘
```

---

### 4. Emergency Substitution Database

**The Problem**: You're mid-recipe and realize you're missing buttermilk.

**The Solution**: Quick-lookup substitution guide with ratios.

**Data Source**: `assets/data/ingredient_substitutions.json`

**Example Entry**:
```json
{
  "originalIngredient": "Buttermilk",
  "substitutes": [
    {
      "ingredient": "Milk + Lemon Juice",
      "ratio": 1.0,
      "preparation": "1 cup milk + 1 tbsp lemon juice, let sit 5 min",
      "quality": "excellent"
    }
  ]
}
```

**Quality Ratings**:
- ⭐ **Excellent**: Nearly identical result
- ✅ **Good**: Minor differences
- ⚠️ **Fair**: Noticeable change
- 🆘 **Emergency**: Last resort

**Calculation**:
```dart
// Need 1 cup buttermilk, have milk + lemon juice
// Ratio: 1.0 (1:1 replacement)
// Result: Use 1 cup milk + 1 tbsp lemon juice
```

---

## 📐 Mathematical Foundations

### Density Conversion

**Density** = Mass / Volume
**Rearranged**:
- Mass = Density × Volume
- Volume = Mass / Density

**Units**:
- Density in g/ml (grams per milliliter)
- All volume conversions go through ml base unit
- All weight conversions go through g base unit

**Example Calculation**:
```dart
// Convert 2 cups of water to grams
// Step 1: cups → ml
//   2 cups × 236.588 ml/cup = 473.176 ml
// Step 2: Apply density (water = 1.0 g/ml)
//   473.176 ml × 1.0 g/ml = 473.176 g
// Step 3: ml → g (direct for weight)
//   Result: 473.18g
```

### Reverse Timeline Scheduling

**Algorithm Type**: Backward scheduling with critical path analysis

**Steps**:
1. Topological sort by dependencies
2. Calculate latest start time for each task
3. Identify parallel execution opportunities
4. Apply constraints (max concurrent tasks)

**Constraint**: Maximum 2-3 simultaneous tasks (human limit)

---

## 🎨 Design System

### Combat Mode Typography

| Element | Font Size | Weight | Color | Use Case |
|---------|-----------|--------|-------|----------|
| Timer Display | 96sp | Bold | Neon Green | Active countdown |
| Task Name | 48sp | Bold | White | Current task |
| Next Task | 32sp | Semibold | Neon Blue | Upcoming |
| Body Text | 24sp | Regular | White 70% | Details |
| Labels | 20sp | Bold | White 60% | Small info |

### Color Semantics

```dart
Neon Green  (#00FF41) → Success, Primary, Active timers
Neon Red    (#FF0055) → Critical alerts, Overtime
Neon Yellow (#FFED00) → Warnings, Start soon
Neon Blue   (#00D9FF) → Next task, Information
Neon Orange (#FF6B00) → Secondary actions
```

---

## 🧪 Testing Strategy

```bash
# Run all tests
flutter test

# Unit tests (business logic)
flutter test test/unit/

# Widget tests (UI components)
flutter test test/widget/

# Integration tests (end-to-end)
flutter test test/integration/
```

**Test Coverage Goals**:
- Unit tests: 80%+ (domain logic, algorithms)
- Widget tests: 60%+ (critical UI paths)
- Integration tests: Key user flows

---

## 🔧 Code Generation

This project uses code generation for:
- Freezed (immutable models)
- JSON Serializable (JSON parsing)
- Riverpod (providers)

**Run code generation**:
```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (during development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

**Generated files** (DO NOT edit manually):
- `*.freezed.dart` - Freezed models
- `*.g.dart` - JSON serialization + Riverpod providers

---

## 📦 Project Setup

### Prerequisites
- Flutter SDK ≥ 3.2.0
- Dart SDK ≥ 3.2.0
- Android Studio / VS Code with Flutter extensions

### Installation

```bash
# 1. Clone repository
git clone <repository-url>
cd pinche-juan

# 2. Install dependencies
flutter pub get

# 3. Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run
```

---

## 🚧 Development Roadmap

### Phase 1: MVP ✅ (Current)
- [x] Project structure
- [x] Domain models (Ingredient, CookingTask, Timeline)
- [x] Density conversion algorithm
- [x] Reverse time scheduling algorithm
- [x] Combat Mode UI prototype
- [x] Ingredient density database (25+ items)
- [x] Substitution database

### Phase 2: Core Features 🔄
- [ ] Unit Converter UI (numpad, dropdowns)
- [ ] Timeline Editor UI (task entry, serving time picker)
- [ ] Isar database integration
- [ ] Local notifications for task alerts
- [ ] Settings screen

### Phase 3: Polish
- [ ] Onboarding flow
- [ ] Tutorial mode
- [ ] Custom ingredient density entry
- [ ] Timeline templates
- [ ] Export/import timelines

### Phase 4: Advanced
- [ ] Voice commands (hands-free timer control)
- [ ] Apple Watch / Wear OS companion
- [ ] Cloud sync (optional)
- [ ] Collaborative cooking (multiple devices)

---

## 📖 Key Files Reference

| File | Line | What It Does |
|------|------|-------------|
| `unit_conversion_service.dart` | 27 | Main density conversion algorithm |
| `timeline_scheduler.dart` | 17 | Backward scheduling algorithm |
| `combat_mode_dashboard.dart` | 27 | Combat Mode main UI |
| `app_theme.dart` | 11 | High-contrast theme definition |
| `cooking_task.dart` | 18 | Task model with timing logic |
| `cooking_timeline.dart` | 11 | Timeline with task orchestration |
| `ingredient.dart` | 13 | Ingredient with density property |
| `measurement_unit.dart` | 8 | Unit definitions and conversions |

---

## 🤝 Contributing

This is a production-grade architecture. When contributing:

1. **Follow Clean Architecture**: Domain logic stays pure, no Flutter imports
2. **Use Code Generation**: Don't write boilerplate manually
3. **Write Tests**: New features require unit tests
4. **Combat Mode First**: If it's not usable with wet hands, redesign it
5. **Performance Matters**: This app runs during time-critical cooking

---

## 📄 License

[Add your license here]

---

## 🙏 Acknowledgments

**Design Philosophy Inspired By**:
- Professional kitchen timers (Thermapen, ThermoWorks)
- Aviation cockpit UI (high-stress, glanceable design)
- Military tactical displays (night vision compatibility)

**For**: Expert home cooks who deserve professional-grade tools.

---

**Built with 🔥 for cooks who code and coders who cook.**
