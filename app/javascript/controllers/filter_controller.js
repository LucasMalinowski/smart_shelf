import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "categorySection", "toggleButton"]

  connect() {
    this.filterItems()
    this.updateToggleButton()
  }

  updateToggleButton() {
    const sidebarFilter = document.getElementById('sidebarFilter')
    if (sidebarFilter) {
      const observer = new MutationObserver(() => {
        this.toggleButtonTarget.style.display = sidebarFilter.classList.contains('show') ? 'none' : 'block'
      })
      observer.observe(sidebarFilter, { attributes: true })
    }
  }

  filterItems() {
    const selectedCategories = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)

    this.categorySectionTargets.forEach(section => {
      const categoryId = section.dataset.categoryId
      if (selectedCategories.length === 0 || selectedCategories.includes(categoryId)) {
        section.style.display = ''
      } else {
        section.style.display = 'none'
      }
    })
  }
}
