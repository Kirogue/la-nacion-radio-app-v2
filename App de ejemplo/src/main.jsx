import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

// Registro explícito del Service Worker con lógica de actualización automática
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js').then(registration => {
      console.log('SW registered: ', registration);
      
      // Detectar nueva versión y forzar actualización
      registration.onupdatefound = () => {
        const installingWorker = registration.installing;
        if (installingWorker == null) {
          return;
        }
        installingWorker.onstatechange = () => {
          if (installingWorker.state === 'installed') {
            if (navigator.serviceWorker.controller) {
              // Nuevo contenido disponible; forzamos recarga para que el usuario lo vea
              console.log('Nueva versión disponible. Actualizando...');
              // Opcional: Podrías mostrar un toast "Actualizando..." antes de recargar
              window.location.reload(); 
            } else {
              console.log('Contenido en caché para uso offline.');
            }
          }
        };
      };
    }).catch(registrationError => {
      console.log('SW registration failed: ', registrationError);
    });
  });

  // Recargar si el controller cambia (ej. después de skipWaiting en el SW)
  let refreshing;
  navigator.serviceWorker.addEventListener('controllerchange', () => {
    if (refreshing) return;
    window.location.reload();
    refreshing = true;
  });
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
