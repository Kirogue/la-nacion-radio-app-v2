const CACHE_NAME = "enigma-app-v4-force-network"; // Actualizado a v4 para invalidar caché previo

// Detectar la ruta base donde está alojado el archivo sw.js
const path = location.pathname.substring(0, location.pathname.lastIndexOf('/')) + '/';

const urlsToCache = [
  path + "",
  path + "index.html",
  path + "manifest.json"
];

// Instalación: Forzamos skipWaiting para que tome el control de inmediato
self.addEventListener("install", (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(urlsToCache);
    })
  );
});

// Fetch: ESTRATEGIA AGRESIVA "NETWORK FIRST" (Red Primero)
// Intenta SIEMPRE obtener la versión más nueva de la red.
// Solo usa la caché si NO hay internet (offline).
self.addEventListener("fetch", (event) => {
  const url = new URL(event.request.url);

  // 1. Ignorar peticiones que no sean http(s) (ej. chrome-extension://)
  if (!url.protocol.startsWith('http')) return;

  // 2. Para navegación (HTML) y assets principales (JS/CSS):
  // Intentamos ir a la red con un timeout corto para no bloquear si es lento
  event.respondWith(
    fetch(event.request, { cache: 'no-store' }) // 'no-store' fuerza al navegador a ir al servidor
      .then((networkResponse) => {
        // Si la red responde bien, actualizamos la caché en segundo plano y devolvemos la respuesta fresca
        if (networkResponse && networkResponse.status === 200) {
            const responseToCache = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => {
                cache.put(event.request, responseToCache);
            });
        }
        return networkResponse;
      })
      .catch(() => {
        // Si falla la red (Offline), entonces y SOLO entonces, usamos caché
        console.log('Offline mode: Serving from cache');
        return caches.match(event.request);
      })
  );
});

// Activación: BORRADO AGRESIVO de cachés viejas
self.addEventListener("activate", (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            console.log("Deleting old cache:", cacheName);
            return caches.delete(cacheName); // Borra todo lo que no sea la versión actual
          }
        })
      );
    }).then(() => self.clients.claim()) // Toma el control de todas las pestañas abiertas inmediatamente
  );
});

// Escuchar mensajes para forzar actualización desde el cliente
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
