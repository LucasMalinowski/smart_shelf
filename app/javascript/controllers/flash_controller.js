import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 4000 }
  }

  connect() {
    this.startTimer()
  }

  startTimer() {
    this.clearTimer()
    this.timer = window.setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  dismiss() {
    this.element.classList.add("opacity-0", "translate-y-2")
    window.setTimeout(() => this.element.remove(), 200)
  }

  clearTimer() {
    if (this.timer) window.clearTimeout(this.timer)
  }

  disconnect() {
    this.clearTimer()
  }
}
