import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "trigger"]

  connect() {
    this.hide()
    this.boundClick = this.handleOutsideClick.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    this.menuVisible ? this.hide() : this.show()
  }

  show() {
    if (this.menuVisible) return
    this.menuTarget.classList.remove("hidden")
    document.addEventListener("click", this.boundClick)
    this.menuVisible = true
  }

  hide() {
    if (!this.hasMenuTarget) return
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.boundClick)
    this.menuVisible = false
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }
}
