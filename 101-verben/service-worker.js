// ============================================================
// Verb-Café — Service Worker für Offline-Verfügbarkeit
// ============================================================
const CACHE_NAME = "verbcafe-v5";

const URLS_TO_CACHE = [
  "./",
  "./index.html",
  "./manifest.json",
  "./icon-192.png",
  "./icon-512.png",
  "./fonts/BarlowCondensed-Medium.woff2",
  "./fonts/BarlowCondensed-SemiBold.woff2",
  "./fonts/BarlowCondensed-Bold.woff2",
  "./fonts/BarlowCondensed-ExtraBold.woff2",
  "./fonts/NunitoSans-Regular.woff2",
  "./fonts/NunitoSans-Italic.woff2",
  "./fonts/NunitoSans-Medium.woff2",
  "./fonts/NunitoSans-SemiBold.woff2",
  "./fonts/NunitoSans-Bold.woff2",
  "./fonts/Caveat-SemiBold.woff2",
  "./fonts/Caveat-Bold.woff2",
  "./fonts/JetBrainsMono-Regular.woff2",
  "./fonts/JetBrainsMono-SemiBold.woff2",
  "./fonts/JetBrainsMono-Bold.woff2",
  "./fonts/Kalam-Regular.woff2",
  "./fonts/Kalam-Bold.woff2"
];

// Erstinstallation: alle Kern-Dateien in den Cache legen
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(CACHE_NAME)
      .then((cache) => cache.addAll(URLS_TO_CACHE))
      .catch(() => {
        // z.B. wenn Google Fonts beim Install-Zeitpunkt nicht erreichbar ist —
        // Rest wird trotzdem versucht; fetch-Handler cacht später nach.
      })
  );
  self.skipWaiting(); // neue Version sofort aktiv, sobald alle Tabs geschlossen/neu geladen sind
});

// Aktivierung: alte Cache-Versionen aufräumen
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

// Anfragen: erst Cache, dann Netz — Netzwerktreffer werden nachgecacht,
// damit die Seite auch offline weiter aktuell bleibt, sobald online besucht.
self.addEventListener("fetch", (event) => {
  // Nur GET-Anfragen behandeln (POST/Formulare etc. unangetastet lassen)
  if (event.request.method !== "GET") return;

  event.respondWith(
    caches.match(event.request).then((cached) => {
      const networkFetch = fetch(event.request)
        .then((response) => {
          if (response && response.ok) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          }
          return response;
        })
        .catch(() => cached); // offline & kein Netz -> auf Cache zurückfallen

      // Cache-first für sofortige Ladezeit, im Hintergrund trotzdem aktualisieren
      return cached || networkFetch;
    })
  );
});
