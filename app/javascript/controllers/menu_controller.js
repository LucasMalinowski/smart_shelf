import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "iconOpen", "iconClose", "notificationsPanel"]

  connect() {
    this.handleOutsideNotificationClick = this.handleOutsideNotificationClick.bind(this)
    this.closeDrawer()
    this.hideNotifications()
  }

  toggle() {
    this.drawerVisible ? this.closeDrawer() : this.openDrawer()
  }

  toggleNotifications(event) {
    event.preventDefault()
    if (!this.hasNotificationsPanelTarget) return
    this.notificationsVisible ? this.hideNotifications() : this.showNotifications()
  }

  openDrawer() {
    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.remove("hidden")
      this.drawerVisible = true
    }
    this.swapMenuIcons(true)
  }

  closeDrawer() {
    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.add("hidden")
      this.drawerVisible = false
    }
    this.swapMenuIcons(false)
  }

  showNotifications() {
    this.notificationsPanelTarget.classList.remove("hidden")
    this.notificationsVisible = true
    document.addEventListener("click", this.handleOutsideNotificationClick)
  }

  hideNotifications() {
    if (!this.hasNotificationsPanelTarget) return
    this.notificationsPanelTarget.classList.add("hidden")
    this.notificationsVisible = false
    document.removeEventListener("click", this.handleOutsideNotificationClick)
  }

  handleOutsideNotificationClick(event) {
    if (!this.element.contains(event.target)) {
      this.hideNotifications()
    }
  }

  swapMenuIcons(isOpen) {
    if (this.hasIconOpenTarget) this.iconOpenTarget.classList.toggle("hidden", isOpen)
    if (this.hasIconCloseTarget) this.iconCloseTarget.classList.toggle("hidden", !isOpen)
  }
}
