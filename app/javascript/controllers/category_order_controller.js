import { Controller } from "@hotwired/stimulus"

const ORDER_SEPARATOR = ","

export default class extends Controller {
  static targets = ["list", "input", "form"]

  connect() {
    this.draggedElement = null
    this.lastOrderValue = null
    this.syncInput()
  }

  dragStart(event) {
    const item = event.currentTarget
    this.draggedElement = item
    item.classList.add("opacity-60")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", "")
  }

  dragOver(event) {
    if (!this.draggedElement) return
    event.preventDefault()
    const target = event.currentTarget
    if (target === this.draggedElement) return

    const bounds = target.getBoundingClientRect()
    const offset = event.clientY - bounds.top
    const midpoint = bounds.height / 2

    if (offset > midpoint) {
      target.after(this.draggedElement)
    } else {
      target.before(this.draggedElement)
    }
  }

  dragEnd(event) {
    if (!this.draggedElement) return

    this.draggedElement.classList.remove("opacity-60")
    this.draggedElement = null

    const previousValue = this.inputTarget.value
    this.syncInput()

    if (this.inputTarget.value !== previousValue) {
      this.submitOrder()
    }
  }

  syncInput() {
    const ids = Array.from(this.listTarget.querySelectorAll("[data-category-id]"))
      .map((element) => element.dataset.categoryId)
    const value = ids.join(ORDER_SEPARATOR)
    this.inputTarget.value = value
    this.lastOrderValue = value
  }

  submitOrder() {
    if (!this.hasFormTarget) return
    this.formTarget.requestSubmit()
  }
}
