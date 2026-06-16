<h1 align="center">FollowRoom - Aplicación Móvil de Gestión de Eventos en Hoteles</h1>

<p align="center">
  <img src="followroom_flutter/assets/images/followroom_logo.png" alt="FollowRoom" width="200"/>
</p>

## Tabla de contenidos

- [Descripción y contexto](#descripción-y-contexto)
- [Guía de usuario](#guía-de-usuario)
- [Guía de instalación](#guía-de-instalación)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Cómo contribuir](#cómo-contribuir)
- [Autor/es](#autores)
- [Información adicional](#información-adicional)
- [Limitaciones del sistema](#limitaciones-del-sistema)

## Descripción y contexto

**FollowRoom** es la aplicación móvil complementaria del sistema **BookingRoom**, desarrollada en **Flutter** para la gestión y administración de eventos en salones de un hotel.

Mientras que BookingRoom (versión web) está orientada a la gestión administrativa desde un panel de control, FollowRoom permite a los **clientes**, **coordinadores** y **almacenistas** interactuar con el sistema desde sus dispositivos móviles para realizar reservaciones, dar seguimiento a eventos y gestionar inventarios en tiempo real.

La aplicación se conecta mediante una API REST al backend desarrollado en Django, utilizando **Firebase Authentication** para la autenticación de usuarios.

## Guía de usuario

Las funcionalidades de la aplicación están divididas en 3 roles: **cliente**, **coordinador** (administrador/recepcionista) y **almacenista**.

### 1. Cliente

El cliente puede explorar paquetes de eventos, realizar reservaciones y dar seguimiento a sus solicitudes desde la aplicación.

**Funcionalidades principales:**

- **Exploración de Paquetes:** Visualizar paquetes de eventos disponibles con precios, descripciones e ítems incluidos mediante un carrusel interactivo.
- **Proceso de Reservación:** Crear una reservación en múltiples pasos: selección de salón, fecha y hora, datos del cliente, servicios, equipamiento, tipo de montaje y mobiliario.
- **Historial de Reservaciones:** Consultar reservaciones en proceso, aceptadas, concluidas y canceladas.
- **Solicitudes Extra:** Solicitar servicios o equipamiento adicional para una reservación existente.
- **Perfil:** Actualizar foto de perfil (cámara/galería), nombre, correo y contraseña.

**Pasos básicos:**

1. Inicie sesión o regístrese en la aplicación con su correo electrónico.
2. En la pantalla de inicio, explore los paquetes disponibles en el carrusel.
3. Presione "Reservar ahora" e ingrese los detalles del evento: salón, fecha, servicios, equipamiento y mobiliario.
4. Revise el resumen y confirme la reservación.
5. Dé seguimiento al estado de su reservación en la pestaña de historial.

### 2. Coordinador (Administrador / Recepcionista)

El coordinador supervisa todas las solicitudes de los clientes, administra los salones y da seguimiento a los eventos.

**Funcionalidades principales:**

- **Panel Principal:** Vista general de todas las solicitudes de clientes y estado de los salones.
- **Gestión de Solicitudes:** Aprobar, rechazar o dar seguimiento a las reservaciones solicitadas por los clientes.
- **Estado de Salones:** Consultar y actualizar el estado operativo de cada salón (Disponible, Reservado, En Mantenimiento, Inactivo).
- **Listas de Verificación:** Gestionar listas de verificación para el progreso de cada evento.
- **Herramientas de Seguridad:** Acceso a linterna y sensor de luz ambiental para entornos oscuros.

**Pasos básicos:**

1. Inicie sesión con credenciales de administrador o recepcionista.
2. Acceda al panel principal para ver las solicitudes entrantes.
3. Seleccione una reservación para ver sus detalles, aprobarla o gestionar su progreso.
4. Consulte el estado de los salones desde la sección correspondiente.

### 3. Almacenista

El almacenista se encarga de la preparación física de los eventos y el control del inventario.

**Funcionalidades principales:**

- **Gestión de Montaje:** Consultar los detalles de montaje y equipamiento requerido para cada evento próximo.
- **Listas de Verificación:** Marcar elementos preparados y dar seguimiento al progreso logístico.
- **Inventario:** Actualizar el estado del mobiliario y equipamiento.
- **Solicitudes Extra:** Gestionar solicitudes adicionales de materiales para eventos.
- **Alerta de Luz Ambiente:** El sensor de luz ambiental detecta entornos oscuros y ofrece activar la linterna automáticamente.

**Pasos básicos:**

1. Inicie sesión con credenciales de almacenista.
2. Visualice los eventos próximos y los recursos asignados a cada salón.
3. Revise los detalles de montaje y marque los elementos preparados.
4. Actualice el estado del inventario según sea necesario.

## Guía de instalación

### Requisitos previos

- **Flutter SDK** 3.10.4+
- **Dart SDK** 3.10.4+
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Cuenta de Google** (para Firebase)
- **Backend BookingRoom** corriendo (Django REST API)

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/FollowRoom.git
cd FollowRoom/followroom_flutter
```

### 2. Obtener las dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

La aplicación usa Firebase Authentication. El proyecto ya incluye configuraciones para múltiples plataformas.

#### 3.1. Web

El archivo `web/index.html` ya incluye la configuración de Firebase. Verifica que los valores de `firebaseConfig` coincidan con los de tu proyecto.

#### 3.2. Android

El archivo `android/app/google-services.json` contiene las credenciales de Firebase para Android. Si usas tu propio proyecto de Firebase:

1. Ve a https://console.firebase.google.com/
2. Selecciona tu proyecto o crea uno nuevo
3. Agrega una app Android con el paquete `com.example.followroom_flutter`
4. Descarga el archivo `google-services.json` y colócalo en `android/app/`

#### 3.3. iOS / macOS

Las configuraciones de Firebase para iOS y macOS están definidas en `lib/firebase_options.dart`. Si usas tu propio proyecto:

1. En Firebase Console, agrega una app iOS con el bundle ID correspondiente
2. Descarga el archivo `GoogleService-Info.plist` y agrégalo al proyecto Xcode
3. Actualiza `lib/firebase_options.dart` si es necesario

### 4. Configurar la IP del backend

La aplicación se conecta a la API REST de BookingRoom. La IP del servidor está definida en `lib/services/ip_config.dart`:

```dart
class IpConfig {
  static const String ip = '192.168.100.10:8000';
}
```

Cambia esta IP por la dirección de tu servidor Django.

### 5. Ejecutar la aplicación

```bash
# Para web
flutter run -d chrome

# Para Android (dispositivo conectado o emulador)
flutter run

# Compilar APK
flutter build apk

# Compilar para web
flutter build web
```

### Solución de problemas comunes

| Problema | Solución |
|----------|----------|
| `flutter pub get` falla | Verifica tu conexión a internet y ejecuta `flutter clean && flutter pub get` |
| Error de Firebase | Asegúrate de que `google-services.json` esté presente en `android/app/` |
| No se conecta al backend | Verifica que la IP en `ip_config.dart` sea correcta y que el servidor Django esté corriendo |
| Error de compilación web | Ejecuta `flutter clean` y luego `flutter build web` |

## Estructura del proyecto

```
followroom_flutter/
├── android/                    # Configuración nativa de Android
├── ios/                        # Configuración nativa de iOS
├── web/                        # Configuración para web
├── macos/                      # Configuración nativa de macOS
├── linux/                      # Configuración nativa de Linux
├── assets/
│   └── images/                 # Imágenes y recursos gráficos
├── lib/
│   ├── main.dart               # Punto de entrada de la aplicación
│   ├── firebase_options.dart   # Configuración de Firebase
│   ├── core/                   # Estilos y temas
│   │   ├── colores.dart
│   │   ├── texto_styles.dart
│   │   ├── boton_styles.dart
│   │   ├── input_styles.dart
│   │   ├── container_styles.dart
│   │   └── estados_widgets.dart
│   ├── components/             # Widgets reutilizables
│   │   ├── card_reservacion.dart
│   │   ├── widget_cantidades_elementos.dart
│   │   └── widget_seccion_busqueda.dart
│   ├── screens/                # Pantallas por rol
│   │   ├── cliente_screens/    # Pantallas del cliente
│   │   ├── coordinador_screens/# Pantallas del coordinador
│   │   ├── almacenista_screens/# Pantallas del almacenista
│   │   └── screens_for_all.dart/# Pantallas compartidas (perfil, manual)
│   ├── features/
│   │   └── auth/               # Autenticación (login, registro)
│   └── services/               # Servicios de API (22 servicios)
└── pubspec.yaml                # Dependencias del proyecto
```

## Cómo contribuir

Si deseas contribuir al proyecto:

1. Haz un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Realiza tus cambios y haz commit (`git commit -m 'Agrega nueva funcionalidad'`)
4. Haz push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

> [!IMPORTANT]
> **Código por terminar:** Debido a la metodología de trabajo en la UTT, el proyecto no logró concretarse por completo. Sin embargo, quedó en una etapa muy avanzada.

## Autor/es

- **Gallardo Ramirez Luis David** — luisd.gramirez@gmail.com — Desarrollador front-end
- De La Torre Garcia Ricardo Daniel
- Gonzalez De La Mora Jose Jonathan
- Flores Gomez Kent

## Información adicional

Esta aplicación es el **cliente móvil** del sistema **BookingRoom** (repositorio web Django). Ambos proyectos fueron desarrollados como parte del proyecto integrador de la **Universidad Tecnológica de Tula-Tepeji (UTT)**.

La aplicación consume la API REST del backend BookingRoom y utiliza **Firebase Authentication** para la autenticación de usuarios.



## Limitaciones del sistema

- La aplicación requiere conexión constante al backend de BookingRoom para la mayoría de sus funcionalidades.
- Los pagos no se procesan dentro de la aplicación; el cobro de reservaciones se realiza de forma presencial en el hotel.
- No se soportan planos 3D de eventos por la complejidad técnica y consumo de recursos.
- La IP del backend está hardcodeada en el código fuente, lo que requiere modificación manual para cambiar de servidor.
- La aplicación no utiliza un manejador de estado global (Provider, Bloc, etc.), lo que puede dificultar el mantenimiento a largo plazo.
