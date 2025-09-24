import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    url: String,
    loading: { type: Boolean, default: false }
  }

  connect() {
    this.observe()
  }

  disconnect() {
    this.unobserve()
  }

  observe() {
    if (this.observer) return
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.load()
        }
      })
    }, { rootMargin: '200px' })
    this.observer.observe(this.element)
  }

  unobserve() {
    if (!this.observer) return
    this.observer.disconnect()
    this.observer = null
  }

  load() {
    if (this.loadingValue || !this.hasUrlValue) return
    this.loadingValue = true
    fetch(this.urlValue, {
      headers: { 'Accept': 'text/vnd.turbo-stream.html' }
    }).then(response => {
      if (response.ok) {
        return response.text()
      }
      throw new Error('Request failed')
    }).then(html => {
      Turbo.renderStreamMessage(html)
      this.element.remove()
    }).catch(error => {
      console.warn('Load more failed', error)
      this.loadingValue = false
    })
  }
}
