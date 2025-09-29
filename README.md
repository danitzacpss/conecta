# Conecta App

Aplicación móvil tipo Spotify construida con Flutter (Dart + null safety) que integra música, videos, radios en vivo y mecánicas de gamificación. Incluye onboarding, autenticación Firebase, modo offline-first y diseño moderno con soporte de tema claro/oscuro.

## Arquitectura

- **Clean Architecture** con capas independientes (`data`, `domain`, `presentation`).
- **State management** con `flutter_riverpod` y navegación declarativa mediante `go_router`.
- **Offline-first**: sincronización diferida con Hive + `OfflineSyncService` y banner reactivo a la conectividad.
- **Multimedia**: audio (`just_audio`, `audio_service`) con controles en segundo plano y video (`video_player`).
- **Backend**: Firebase Auth, Firestore, Storage y Messaging (débitos stub listos para configuración con `firebase_options.dart`).
- **Notificaciones**: push (`firebase_messaging`) y locales (`flutter_local_notifications`).
- **UI**: diseño juvenil con tipografía Poppins, assets cacheados (`cached_network_image`), ilustraciones (`lottie`), soporte light/dark y componentes reutilizables.
- **Internacionalización**: strings en español/inglés con `gen-l10n` (`lib/l10n/arb`).

## Estructura principal

```
lib/
├── app/                 # bootstrap, router, theme, widgets globales
├── core/                # localization, errores, conectividad, utilidades
├── features/
│   ├── auth/            # onboarding, login, control de sesión
│   ├── home/            # home feed con playlists, videos, radios
│   ├── player/          # now playing + controles just_audio
│   ├── gamification/    # retos, puntos, leaderboard
│   ├── events/          # listado + chat grupal por evento
│   ├── search/          # búsqueda global
│   ├── library/         # favoritos, descargas, recientes
│   ├── notifications/   # centro de notificaciones
│   └── profile/         # perfil, ajustes, preferencias
├── services/            # notificacones locales, sincronización offline
└── firebase_options.dart (placeholder para configurar Firebase)
```

## Requisitos previos

- Flutter SDK 3.4.3+
- Dart 3.4+
- Cuenta Firebase con proyecto configurado

## Configuración rápida

1. Instala dependencias:
   ```bash
   flutter pub get
   flutter gen-l10n
   ```
2. Configura Firebase con FlutterFire y reemplaza los valores de `lib/firebase_options.dart`.
3. (Opcional) Registra adaptadores Hive para tus modelos persistidos.
4. Lanza la app:
   ```bash
   flutter run
   ```

## Próximos pasos sugeridos

- Conectar repositorios `data` a Firestore/REST y reemplazar los stubs de controladores.
- Implementar autenticación real (email, Google, Apple) usando `firebase_auth`.
- Configurar `audio_service` para controles en background y notificaciones del sistema.
- Añadir pruebas unitarias/widget y flujos de integración (e.g. `home_controller_test.dart`).
- Ajustar assets (lottie, íconos) y branding definitivo.

---

Proyecto generado el 24 de septiembre de 2025.
