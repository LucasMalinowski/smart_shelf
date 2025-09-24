import { Controller } from "@hotwired/stimulus"

const DEFAULT_PRECISION = 0

export default class extends Controller {
  static targets = [
    "amountInput",
    "decrementInput",
    "incrementInput",
    "panel"
  ]

  static values = {
    step: Number,
    precision: { type: Number, default: DEFAULT_PRECISION }
  }

  connect() {
    this.ensureMinimumAmount()
  }

  submitDecrement() {
    const value = this.currentAmount()
    this.decrementInputTarget.value = (-value).toString()
  }

  submitIncrement() {
    const value = this.currentAmount()
    this.incrementInputTarget.value = value.toString()
  }

  sanitize() {
    this.ensureMinimumAmount()
  }

  togglePanel(event) {
    event.preventDefault()
    this.panelTarget.classList.toggle("hidden")
  }

  ensureMinimumAmount() {
    const input = this.amountInputTarget
    const step = this.stepValue || 1
    let value = parseFloat(input.value)

    if (Number.isNaN(value) || value <= 0) {
      value = step
    }

    value = this.roundToPrecision(value)

    if (value < step) {
      value = step
    }

    input.value = value
  }

  currentAmount() {
    const step = this.stepValue || 1
    const value = parseFloat(this.amountInputTarget.value)
    if (Number.isNaN(value) || value <= 0) {
      return step
    }
    return this.roundToPrecision(value)
  }

  roundToPrecision(value) {
    const precision = this.precisionValue || DEFAULT_PRECISION
    if (precision <= 0) {
      return Math.round(value)
    }
    const factor = Math.pow(10, precision)
    return Math.round(value * factor) / factor
  }
}
