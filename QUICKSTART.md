# 🚀 Quick Start - Pinche Juan KitchenOS

## ¡La app está lista para ejecutarse!

### Requisitos Previos
- Flutter SDK instalado (versión 3.2.0 o superior)
- Un dispositivo Android/iOS o emulador configurado

### Ejecutar la App (3 pasos)

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar la app
flutter run

# ¡Eso es todo! 🎉
```

### Lo que verás

La app se abrirá directamente en **Combat Mode** con una demostración interactiva:

```
┌─────────────────────────────────────────────────────────┐
│ 🚨 CRITICAL ALERT: Remove chicken from oven             │
├────────────────────────────┬────────────────────────────┤
│  ACTIVE TIMERS             │  NEXT UP                   │
│  ┌──────────────────────┐  │  ┌──────────────────────┐ │
│  │ ROAST CHICKEN        │  │  │ 🍽️  REST MEAT        │ │
│  │ 45:30 (countdown)    │  │  │ Starts in 10:30      │ │
│  │ [████████░░] 80%     │  │  │ Duration: 15m        │ │
│  │ [✓ COMPLETE] button  │  │  └──────────────────────┘ │
│  └──────────────────────┘  │                            │
│                            │                            │
│  │ BOIL POTATOES        │  │                            │
│  │ 12:45 (countdown)    │  │                            │
│  │ [█████░░░░░] 50%     │  │                            │
│  │ [✓ COMPLETE] button  │  │                            │
│  └──────────────────────┘  │                            │
├────────────────────────────┴────────────────────────────┤
│ [PAUSE] [SKIP] [END SESSION] (control buttons)          │
└─────────────────────────────────────────────────────────┘
```

### Características de la Demo

✅ **Timers en Vivo**: Los contadores disminuyen cada segundo
✅ **High Contrast UI**: Tema neon-on-dark para visibilidad
✅ **Landscape Mode**: Automáticamente gira a horizontal
✅ **Large Tap Targets**: Botones de 80×80dp mínimo
✅ **Critical Alerts**: Banner rojo pulsante para tareas urgentes
✅ **Next Task Preview**: Muestra qué viene después

### Probando la UI

La app está en modo demostración con datos de ejemplo:

- **Timer 1**: Roast Chicken (45:30 restantes)
- **Timer 2**: Boil Potatoes (12:45 restantes)
- **Next Task**: Rest Meat (comienza en 10:30)
- **Critical Alert**: Remove chicken from oven

Los timers son funcionales y cuentan hacia atrás en tiempo real.

### Plataformas Soportadas

| Plataforma | Estado | Comando |
|------------|--------|---------|
| Android | ✅ Listo | `flutter run -d android` |
| iOS | ✅ Listo | `flutter run -d ios` |
| Web | ✅ Listo | `flutter run -d chrome` |
| Linux | ⚠️ Experimental | `flutter run -d linux` |
| macOS | ⚠️ Experimental | `flutter run -d macos` |
| Windows | ⚠️ Experimental | `flutter run -d windows` |

### Estructura del Proyecto

```
lib/
├── main.dart                 # ← Punto de entrada (versión demo)
├── main_full.dart.bak        # Versión completa con Riverpod
├── core/theme/
│   └── app_theme.dart        # Tema Combat Mode
└── features/
    ├── unit_converter/       # Smart Unit Lab
    ├── timeline_orchestrator/# Reverse Timer
    ├── combat_mode/          # Active Cooking UI
    └── substitution_db/      # Emergency Substitutions
```

### Próximos Pasos

Para habilitar la versión completa con Riverpod y todas las funcionalidades:

```bash
# 1. Generar código (freezed, json_serializable, riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# 2. Restaurar el main completo
mv lib/main_full.dart.bak lib/main_full.dart

# 3. Ejecutar
flutter run
```

### Comandos Útiles

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en modo release (más rápido)
flutter run --release

# Hot reload durante desarrollo
# Presiona 'r' en la terminal mientras la app corre

# Hot restart
# Presiona 'R' en la terminal

# Limpiar build
flutter clean && flutter pub get
```

### Solución de Problemas

**Error: "No devices found"**
```bash
# Android: Inicia un emulador o conecta un dispositivo
flutter emulators --launch <emulator_id>

# iOS: Abre Simulator.app
open -a Simulator
```

**Error: "SDK not found"**
```bash
# Verifica la instalación de Flutter
flutter doctor -v
```

**App no se ve bien en portrait**
- La app está diseñada para **landscape mode**
- Rota tu dispositivo horizontalmente 🔄

### Personalización Rápida

Modifica los colores en `lib/core/theme/app_theme.dart`:

```dart
const neonGreen = Color(0xFF00FF41);   // Color principal
const neonRed = Color(0xFFFF0055);     // Alertas críticas
const neonYellow = Color(0xFFFFED00);  // Warnings
```

### Demo Video

La app incluye:
- 2 timers activos con countdown animado
- 1 tarea próxima con preview
- 1 alerta crítica pulsante
- 3 botones de control (PAUSE, SKIP, END)

Todo funcional y listo para demostrar. 🔥

### Documentación Completa

- `README.md` - Documentación completa del proyecto
- `ARCHITECTURE.md` - Arquitectura detallada
- `QUICKSTART.md` - Este archivo (inicio rápido)

---

**¿Preguntas?** Revisa la documentación completa en `README.md`

**¡Disfruta cocinando con precisión profesional! 👨‍🍳🔥**
