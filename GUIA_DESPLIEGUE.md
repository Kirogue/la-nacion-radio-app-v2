# 🚀 Instrucciones de Instalación Backend & Despliegue

## 1. Plugin Maestro de WordPress (Backend)
Hemos creado un plugin personalizado para centralizar la gestión de contenido de tu App.

### Instalación:
1. Ve a la carpeta `backend-plugin/` en este proyecto.
2. Comprime la carpeta `la-nacion-radio-core` en un archivo **ZIP** (`la-nacion-radio-core.zip`).
3. Ve a tu WordPress -> Plugins -> Añadir nuevo -> Subir plugin.
4. Sube el ZIP y actívalo.

### ¿Qué hace este plugin?
*   Crea las secciones **"Programas de Radio"**, **"Directorio Empresas"** y **"Publicidad App"** en tu panel de admin.
*   Habilita los endpoints API que la app consume:
    *   `tusitio.com/wp-json/api/programas`
    *   `tusitio.com/wp-json/api/companies`
    *   `tusitio.com/wp-json/api/ads`
*   **Nota:** Para que funcione al 100% como la app espera, asegúrate de tener instalado también el plugin **Advanced Custom Fields (ACF)** en tu WordPress, ya que la app busca campos específicos dentro de `acf`.

---

## 2. Despliegue Automático (Frontend PWA)
Hemos configurado un flujo de trabajo en GitHub Actions para automatizar la publicación de tu versión Web.

### Configuración en GitHub:
1. Sube este proyecto a un repositorio en GitHub.
2. Ve a la pestaña **Settings** -> **Secrets and variables** -> **Actions**.
3. Agrega los siguientes "Repository secrets" (dependiendo de dónde alojes la web):

**Si usas Hostinger (FTP):**
*   `FTP_SERVER`: La dirección de tu servidor FTP (ej. ftp.tusitio.com).
*   `FTP_USERNAME`: Tu usuario FTP.
*   `FTP_PASSWORD`: Tu contraseña FTP.

*Luego, edita el archivo `.github/workflows/deploy_web.yml` y descomenta la sección de "Opción 2: FTP".*

### Cómo funciona:
Cada vez que hagas un cambio en el código y lo subas a GitHub (`git push`), el sistema automáticamente:
1. Compilará la App versión Web.
2. Se conectará a tu servidor.
3. Subirá los archivos nuevos.
¡Tu app web estará actualizada en minutos sin tocar nada!


