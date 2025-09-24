if ('serviceWorker' in navigator) {
  const registerServiceWorker = () => {
    navigator.serviceWorker
      .register('/service-worker.js')
      .catch((error) => console.error('Service worker registration failed:', error))
  }

  document.addEventListener('turbo:load', registerServiceWorker)
}
