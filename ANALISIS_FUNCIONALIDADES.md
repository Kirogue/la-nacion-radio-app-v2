# Análisis de Funcionalidades - La Nación Radio App

Este documento detalla las funcionalidades identificadas en el código fuente de la aplicación móvil "La Nación Radio".

## 1. Estructura General y Navegación
*   **Barra de Navegación Inferior (Bottom Navigation)**: La aplicación utiliza una navegación principal basada en pestañas con cuatro secciones clave:
    1.  **Inicio (Home)**: Vista principal del dashboard.
    2.  **Radio**: Reproductor de radio en vivo y podcasts.
    3.  **Noticias (News)**: Feed de noticias.
    4.  **Empresas (Companies)**: Directorio de empresas.
*   **Mini Reproductor Global**: Un reproductor de audio persistente (`GlobalMiniPlayer`) que se muestra sobre la barra de navegación, permitiendo controlar la reproducción (radio o podcast) mientras se navega por otras secciones de la app.
*   **Gestión de Estado**: Utiliza el patrón `Provider` para la gestión de estado global (`MultiProvider` en `AppState`), asegurando que controladores como `RadioController` y `NewsController` estén disponibles en toda la app.

## 2. Funcionalidades por Módulo

### A. Módulo de Radio y Audio
*   **Transmisión en Vivo**: Capacidad para reproducir la señal de radio en vivo.
*   **Reproducción de Podcasts**:
    *   Obtención de listado de podcasts (`fetchPodcasts`).
    *   Selección y reproducción de episodios específicos.
*   **Reproducción en Segundo Plano**: Integración con `audio_service` (`MyAudioHandler`) para permitir que el audio continúe reproduciéndose cuando la app está minimizada o el teléfono bloqueado, incluyendo controles en la notificación del sistema (Android).
*   **Persistencia**: El reproductor maneja estados de carga, reproducción y pausa, y se inicializa antes de arrancar la UI para evitar errores.

### B. Módulo de Noticias (News)
*   **Feed de Noticias**: Visualización de artículos y noticias, probablemente obtenidos desde un backend WordPress (`WpApiController`).
*   **Lectura de Artículos**: Integración de un visor web (WebView) interno para leer las noticias completas sin salir de la aplicación (`isArticleWebViewOpen`).
*   **Búsqueda**: Funcionalidad de búsqueda universal (`UniversalSearch`) para encontrar contenido.

### C. Módulo de Directorio de Empresas (Companies)
*   **Listado de Empresas**: Visualización de empresas afiliadas o anunciantes.
*   **Categorización**: Selección de empresas por categorías (`CompaniesCategorySelect`).
*   **Detalle de Empresa**: Vista detallada con información de la empresa (`CompanyDetail`).
*   **Publicidad Específica**: Banners de publicidad asociados a empresas (`CompanyAdBanner`).

### D. Módulo de Contenido Multimedia (Reels y YouTube)
*   **Reels**: Soporte para videos cortos tipo "Reels" (`ReelsController`, `ReelCard`), permitiendo una experiencia de consumo de video vertical.
*   **Integración con YouTube**: Widget dedicado para la reproducción de videos de YouTube dentro de la app.

### E. Publicidad (Ads)
*   **Gestión de Anuncios**: Controlador centralizado (`AdsController`, `AdManager`) para gestionar la publicidad en la app.
*   **Formatos**: Soporte para banners publicitarios (`AdBanner`) integrados en las vistas.

## 3. Aspectos Técnicos y UI/UX
*   **Tema Personalizado**: Configuración de tema global (`AppTheme`) y constantes de estilo (`AppConstants`, `TextStyles`).
*   **Animaciones**: Uso de animaciones personalizadas (`FadeInUp`, `BounceButton`) para mejorar la experiencia de usuario.
*   **Manejo de Errores de Conexión**: Diálogos para informar al usuario sobre problemas de red (`ConnectionErrorDialog`).
*   **Configuración por Entorno**: Uso de variables de entorno (`.env`) para manejar configuraciones sensibles o dependientes del entorno (desarrollo/producción).
*   **Skeleton Loading**: Pantallas de carga tipo "esqueleto" (`SkeletonNetworkImage`, `SkeletonPulse`) para mejorar la percepción de velocidad durante la carga de datos.


