import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["radio", "categorySection", "toggleButton"]

  connect() {
    // Show all categories initially
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
    const selectedRadio = this.radioTargets.find(radio => radio.checked)
    const selectedCategory = selectedRadio ? selectedRadio.value : 'all'

    this.categorySectionTargets.forEach(section => {
      const categoryId = section.dataset.categoryId
      if (selectedCategory === 'all' || selectedCategory === categoryId) {
        section.style.display = ''
      } else {
        section.style.display = 'none'
      }
    })
  }
}
