import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["radio", "option", "sidebar", "backdrop", "counter"]
  static values = {
    selected: { type: String, default: "all" }
  }

  connect() {
    this.highlight(this.currentSelection())
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }

  filterItems(event) {
    event.preventDefault()
    const value = event.target.value
    this.navigate(value)
  }

  toggleSidebar(event) {
    event.preventDefault()
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.toggle("hidden")
      document.body.classList.toggle("overflow-hidden")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.toggle("hidden")
    }
  }

  closeSidebar(event) {
    event?.preventDefault()
    if (this.hasSidebarTarget) this.sidebarTarget.classList.add("hidden")
    if (this.hasBackdropTarget) this.backdropTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  navigate(value) {
    const category = value || "all"
    this.highlight(category)

    const url = new URL(window.location.href)
    if (category === "all") {
      url.searchParams.delete("category_id")
    } else {
      url.searchParams.set("category_id", category)
    }
    url.searchParams.delete("page")

    Turbo.visit(url.toString(), { action: "replace" })
    if (window.innerWidth < 1024) this.closeSidebar()
  }

  highlight(value) {
    this.selectedValue = value || "all"

    this.radioTargets.forEach(radio => {
      radio.checked = radio.value === this.selectedValue
    })

    this.optionTargets.forEach(option => {
      const isActive = option.dataset.categoryValue === this.selectedValue
      option.classList.toggle("bg-primary-500/15", isActive)
      option.classList.toggle("text-primary-600", isActive)
      option.classList.toggle("border-primary-300/80", isActive)
      option.classList.toggle("shadow-soft", isActive)
      option.classList.toggle("text-ink-500", !isActive)
      option.classList.toggle("border-transparent", !isActive)
    })
  }

  currentSelection() {
    const urlValue = new URL(window.location.href).searchParams.get("category_id")
    return urlValue || this.selectedValue
  }
}
