# KitchenOS Architecture Documentation

## 📐 System Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Screens     │  │   Widgets    │  │  Providers   │      │
│  │  (UI Pages)  │  │  (Components)│  │  (Riverpod)  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                  │               │
├─────────┴─────────────────┴──────────────────┴──────────────┤
│                     DOMAIN LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Models     │  │  Services    │  │ Repositories │      │
│  │  (Entities)  │  │ (Bus. Logic) │  │ (Interfaces) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         ▲                 ▲                  ▲               │
├─────────┴─────────────────┴──────────────────┴──────────────┤
│                      DATA LAYER                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Datasources  │  │  Repository  │  │   Models     │      │
│  │   (Isar)     │  │     Impl     │  │    (DTOs)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🏢 Feature-First Structure

Each feature is a self-contained module following Clean Architecture:

```
feature_name/
├── domain/              # Business logic (pure Dart, no Flutter)
│   ├── models/          # Entities with business rules
│   ├── repositories/    # Abstract interfaces
│   └── services/        # Use cases and algorithms
│
├── data/                # Data access and implementation
│   ├── datasources/     # API, Database, JSON loaders
│   ├── models/          # DTOs (data transfer objects)
│   └── repositories_impl/ # Repository implementations
│
└── presentation/        # UI and state management
    ├── screens/         # Full-page views
    ├── widgets/         # Reusable components
    └── providers/       # Riverpod state providers
```

---

## 🎯 Core Features Architecture

### 1. Smart Unit Lab (Unit Converter)

```
unit_converter/
├── domain/
│   ├── models/
│   │   ├── ingredient.dart           # Ingredient with density
│   │   ├── measurement_unit.dart     # Units (ml, g, cup, oz)
│   │   └── conversion_result.dart    # Conversion output
│   │
│   └── services/
│       └── unit_conversion_service.dart  # ⭐ CORE ALGORITHM
│           ├── convert()             # Main conversion method
│           ├── _convertWithDensity() # Volume ↔ Weight
│           ├── calculateBakersPercentage()
│           └── scaleQuantity()
│
├── data/
│   └── datasources/
│       └── ingredient_density_loader.dart  # Loads JSON data
│
└── presentation/
    └── screens/
        └── unit_converter_screen.dart
```

**Algorithm Flow**:
```
Input: value, fromUnit, toUnit, ingredient?
  ↓
Check: Same unit? → Return as-is
  ↓
Convert: fromUnit → base unit (ml or g)
  ↓
Density: If crossing volume↔weight boundary
         → Apply density conversion
  ↓
Convert: base unit → toUnit
  ↓
Output: ConversionResult with metadata
```

---

### 2. Timeline Orchestrator (Reverse Timer)

```
timeline_orchestrator/
├── domain/
│   ├── models/
│   │   ├── cooking_task.dart         # Single task with duration
│   │   │   ├── duration              # Task length
│   │   │   ├── calculatedStartTime   # When to start
│   │   │   ├── calculatedEndTime     # When to finish
│   │   │   └── priority              # Critical/High/Normal/Low
│   │   │
│   │   └── cooking_timeline.dart     # Collection of tasks
│   │       ├── targetServingTime     # Goal time (e.g., 8:00 PM)
│   │       ├── tasks                 # List of CookingTask
│   │       └── firstTaskStartTime    # When to start cooking
│   │
│   └── services/
│       └── timeline_scheduler.dart   # ⭐ CORE ALGORITHM
│           ├── scheduleTimeline()    # Main scheduling
│           ├── _scheduleTask()       # Calculate start/end
│           ├── _optimizeParallelTasks() # Multi-task handling
│           └── validateTimeline()    # Feasibility check
│
└── presentation/
    └── screens/
        └── timeline_editor_screen.dart
```

**Scheduling Algorithm**:
```
Input: targetServingTime, List<CookingTask>
  ↓
1. Separate by dependencies
   - Independent tasks
   - Dependent tasks (require others first)
  ↓
2. Schedule backward from target time
   - Critical tasks: Sequential (no overlap)
   - Normal tasks: Parallel (up to 3 simultaneous)
  ↓
3. Handle dependencies
   - Task must start after dependencies finish
  ↓
4. Optimize for parallelization
   - Find gaps where tasks can run together
  ↓
Output: Timeline with all start/end times calculated
```

**Example**:
```
Target: 8:00 PM
Tasks:
  - Roast chicken: 90 min (critical)
  - Rest meat: 15 min (critical)
  - Boil potatoes: 20 min (normal)
  - Make salad: 10 min (low)

Scheduled:
  6:15 PM → Start roast chicken (90 min)
  7:40 PM → Start potatoes (20 min) [parallel with roast]
  7:45 PM → Remove chicken, start rest (15 min)
  7:50 PM → Make salad (10 min) [parallel with rest]
  8:00 PM → SERVE
```

---

### 3. Combat Mode (Active Cooking Dashboard)

```
combat_mode/
└── presentation/
    ├── providers/
    │   └── combat_mode_provider.dart     # State + Wakelock
    │       ├── activate()                # Enable always-on
    │       ├── deactivate()              # Disable wakelock
    │       └── completeTask()            # Mark task done
    │
    ├── screens/
    │   └── combat_mode_dashboard.dart    # ⭐ MAIN UI
    │       ├── _buildActiveTimersSection()  # Live countdowns
    │       ├── _buildNextTaskSection()      # Upcoming preview
    │       └── _buildControlBar()           # Emergency controls
    │
    └── widgets/
        ├── active_timer_card.dart        # Individual timer
        │   ├── Live countdown (updates every second)
        │   ├── Progress bar
        │   └── Complete button (80×120dp)
        │
        ├── next_task_card.dart           # Next task preview
        │   └── Time until start
        │
        └── critical_alert_banner.dart    # Flashing alerts
            └── Animated opacity (pulse effect)
```

**UI Architecture**:
```
CombatModeDashboard
├─ CriticalAlertBanner (if any critical tasks)
├─ Row (main content)
│  ├─ ActiveTimersSection (left 60%)
│  │  └─ ListView of ActiveTimerCard
│  │     ├─ Task name (48sp)
│  │     ├─ Countdown (96sp neon green)
│  │     ├─ Progress bar
│  │     └─ Complete button (80×120dp)
│  │
│  └─ NextTaskSection (right 40%)
│     └─ NextTaskCard
│        ├─ Task icon
│        ├─ Task name
│        ├─ "Starts in" countdown
│        └─ Duration info
│
└─ ControlBar (bottom)
   ├─ PAUSE button (yellow)
   ├─ SKIP button (orange)
   └─ END SESSION button (red)
```

**Design Constraints**:
- Minimum tap target: 80×80dp (knuckle-friendly)
- Timer font size: 96sp (readable from 6 feet)
- High contrast ratio: 21:1 (neon on dark)
- Always-on display: Wakelock enabled
- Landscape orientation: Locked during session

---

### 4. Emergency Substitution Database

```
substitution_db/
├── domain/
│   └── models/
│       └── ingredient_substitution.dart
│           ├── originalIngredient
│           └── substitutes: List<SubstituteOption>
│               ├── ingredient       # Replacement
│               ├── ratio            # 1.0 = 1:1, 0.5 = half
│               ├── preparation      # Instructions
│               ├── quality          # excellent/good/fair/emergency
│               └── calculateAmount() # Ratio calculation
│
├── data/
│   └── datasources/
│       └── substitution_loader.dart
│           └── Loads assets/data/ingredient_substitutions.json
│
└── presentation/
    └── screens/
        └── substitution_search_screen.dart
```

---

## 🎨 Theme Architecture

```
core/theme/app_theme.dart
├── combatModeTheme              # High-contrast tactical UI
│   ├── Color Scheme
│   │   ├── primary: neonGreen    (#00FF41)
│   │   ├── error: neonRed        (#FF0055)
│   │   ├── warning: neonYellow   (#FFED00)
│   │   └── info: neonBlue        (#00D9FF)
│   │
│   ├── Typography
│   │   ├── displayLarge: 96sp    (Timers)
│   │   ├── displayMedium: 72sp   (Section headers)
│   │   ├── headlineLarge: 48sp   (Task names)
│   │   └── bodyLarge: 24sp       (Details)
│   │
│   └── Component Themes
│       ├── ElevatedButton: 120×80dp min
│       ├── Card: 2dp neon border
│       └── ProgressIndicator: 12dp height
│
└── standardTheme                # Normal UI (settings, editing)
    └── Material 3 with dark mode
```

**Color Semantics**:
| Color | Hex | Usage |
|-------|-----|-------|
| Neon Green | #00FF41 | Success, active timers, primary actions |
| Neon Red | #FF0055 | Critical alerts, overtime, danger |
| Neon Yellow | #FFED00 | Warnings, "start soon" notifications |
| Neon Blue | #00D9FF | Next task, information, secondary |
| Neon Orange | #FF6B00 | Skip actions, non-critical warnings |

---

## 📊 Data Flow

### Unit Conversion Flow

```
User Input
   ↓
ConversionScreen (Presentation)
   ↓
UnitConverterProvider (Riverpod)
   ↓
UnitConversionService (Domain)
   ├─ Validate inputs
   ├─ Convert to base units
   ├─ Apply density (if needed)
   └─ Convert to target units
   ↓
ConversionResult (Domain Model)
   ↓
Display on UI
```

### Timeline Execution Flow

```
User Creates Timeline
   ↓
TimelineEditor (Presentation)
   ↓
TimelineProvider (Riverpod)
   ↓
TimelineScheduler (Domain)
   └─ scheduleTimeline()
      ├─ Calculate all start times
      ├─ Optimize parallel tasks
      └─ Validate feasibility
   ↓
CookingTimeline (Domain Model)
   ↓
Save to Isar Database (Data)
```

### Combat Mode Execution Flow

```
User Starts Timeline
   ↓
CombatModeProvider.activate()
   ├─ Enable wakelock
   ├─ Set active timeline
   └─ Initialize timer updates
   ↓
CombatModeDashboard (Presentation)
   ├─ ActiveTimerCard (updates every 1s)
   │  └─ Timer.periodic → setState()
   ├─ NextTaskCard (monitors start time)
   └─ CriticalAlertBanner (if critical task)
   ↓
User Completes Task
   ↓
CombatModeProvider.completeTask()
   ├─ Update task status
   ├─ Trigger haptic feedback
   └─ Show completion snackbar
```

---

## 🔌 State Management (Riverpod)

### Provider Types

```dart
// Code-generated providers (@riverpod annotation)

@riverpod
class CombatMode extends _$CombatMode {
  // State provider with methods
  // Manages: wakelock, active timeline, current tasks
}

@riverpod
CookingTask? nextTask(NextTaskRef ref) {
  // Computed provider (auto-updates when dependencies change)
  // Watches: combatModeProvider
  // Returns: Next task to start
}

@riverpod
List<CookingTask> criticalTasks(CriticalTasksRef ref) {
  // Computed provider
  // Filters: Critical priority tasks that need attention
}
```

### Provider Dependency Graph

```
combatModeProvider (root state)
   ├─→ nextTaskProvider (computed)
   └─→ criticalTasksProvider (computed)

timelineProvider
   ├─→ activeTimelineProvider (current)
   └─→ timelineListProvider (all saved)

unitConverterProvider
   └─→ ingredientListProvider (density database)
```

---

## 🗄️ Database Schema (Isar)

```dart
@collection
class IngredientEntity {
  Id id = Isar.autoIncrement;
  String name;
  double densityGramsPerMl;
  String? category;
  List<String>? aliases;
}

@collection
class TimelineEntity {
  Id id = Isar.autoIncrement;
  String name;
  DateTime targetServingTime;
  List<CookingTaskEntity> tasks;
  DateTime createdAt;
  DateTime updatedAt;
}

@collection
class CookingTaskEntity {
  Id id = Isar.autoIncrement;
  String name;
  int durationMinutes;
  String priority;  // critical, high, normal, low
  String? notes;
}
```

---

## 🧪 Testing Architecture

### Test Pyramid

```
        ┌────────────┐
        │ Integration│  ← 10%: Full user flows
        │   Tests    │
        ├────────────┤
       │   Widget     │  ← 20%: UI components
       │    Tests     │
       ├──────────────┤
      │   Unit Tests   │  ← 70%: Business logic
      │                │
      └────────────────┘
```

### What to Test

**Unit Tests** (`test/unit/`):
- ✅ `unit_conversion_service_test.dart`: All conversion paths
- ✅ `timeline_scheduler_test.dart`: Scheduling algorithm
- ✅ Domain model methods (calculations, validations)

**Widget Tests** (`test/widget/`):
- ✅ `active_timer_card_test.dart`: Countdown updates
- ✅ `critical_alert_banner_test.dart`: Animation
- ✅ Button interactions, state changes

**Integration Tests** (`test/integration/`):
- ✅ Complete cooking session flow
- ✅ Timeline creation → Combat Mode → Task completion
- ✅ Database persistence

---

## 📦 Build Process

### Code Generation Pipeline

```
1. Edit source files
   ├─ *.dart files with annotations
   │  ├─ @freezed
   │  ├─ @JsonSerializable()
   │  └─ @riverpod
   ↓
2. Run build_runner
   $ flutter pub run build_runner build
   ↓
3. Generated files created
   ├─ *.freezed.dart    (immutable models)
   ├─ *.g.dart          (JSON + providers)
   └─ *.riverpod.dart   (provider state)
   ↓
4. Flutter build
   $ flutter build apk/ios/web
```

### Build Flavors (Future)

```
Development:   flutter run --flavor dev
Staging:       flutter run --flavor staging
Production:    flutter run --flavor prod
```

---

## 🔒 Error Handling Strategy

### Domain Layer

```dart
// Custom exceptions for domain logic
class ConversionException implements Exception {
  final String message;
  final MeasurementUnit? fromUnit;
  final MeasurementUnit? toUnit;
}

class TimelineValidationException implements Exception {
  final List<String> issues;
}
```

### Presentation Layer

```dart
// User-friendly error display
try {
  result = conversionService.convert(...);
} on ConversionException catch (e) {
  showSnackBar('Cannot convert: ${e.message}');
} catch (e) {
  showSnackBar('Unexpected error occurred');
}
```

---

## 🚀 Performance Considerations

### Optimization Strategies

1. **Combat Mode**:
   - Timer updates: `setState()` only on visible widgets
   - Isolates for background calculations (future)
   - Minimal rebuilds using Riverpod selectors

2. **Database**:
   - Isar indexes on frequently queried fields
   - Lazy loading for large lists
   - Batch operations for multiple updates

3. **UI**:
   - `const` constructors everywhere possible
   - RepaintBoundary for complex animations
   - Cached network images (future: cloud sync)

### Memory Management

```dart
// Timers must be disposed
class _ActiveTimerCardState extends State<ActiveTimerCard> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();  // ← Critical
    super.dispose();
  }
}
```

---

## 📱 Platform-Specific Features

### Android
- Wakelock: Keep screen on during Combat Mode
- Haptic feedback: Vibration on button press
- Background notifications: Timer completion alerts

### iOS
- Wakelock: Prevent auto-lock during sessions
- Haptic feedback: UIImpactFeedbackGenerator
- Background timers: Local notifications

### Future: Web
- Service Worker: Offline-first PWA
- Web Notifications API: Browser alerts
- IndexedDB: Client-side storage

---

## 🔐 Security & Privacy

### Data Storage
- ✅ All data stored locally (Isar database)
- ✅ No telemetry or analytics
- ✅ No network requests (except future cloud sync, opt-in)
- ✅ No personal information collected

### Permissions Required
- ⚠️ Wakelock: Keep screen on
- ⚠️ Vibration: Haptic feedback
- ⚠️ Notifications: Timer alerts

---

## 📚 References

**Flutter Documentation**:
- [Riverpod Guide](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Isar Database](https://isar.dev/)

**Design Inspiration**:
- ThermoWorks Timer (professional kitchen tools)
- Aviation HUD displays (high-stress UI)
- Military tactical interfaces (glanceable info)

---

**Last Updated**: 2026-01-15
**Architecture Version**: 1.0.0
**Status**: MVP Complete ✅
