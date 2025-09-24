import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "smart-shelf-theme"
const DARK_CLASS = "dark"
const DARK_COLOR = "#0f172a"
const LIGHT_COLOR = "#f8fafc"
const SESSION_KEY = "theme"

export default class extends Controller {
  static targets = ["iconSun", "iconMoon"]
  static values = {
    authenticated: Boolean,
    initial: String
  }

  hydrate() {
    const stored = this.readStoredPreference()
    const initial = (this.initialValue || "").trim()
    const prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
    let theme

    if (stored) {
      theme = stored
    } else if (initial) {
      theme = initial
    } else {
      theme = prefersDark ? DARK_CLASS : "light"
    }

    this.persistLocal(theme)
    theme === DARK_CLASS ? this.enableDark(false) : this.enableLight(false)
  }

  toggle() {
    if (document.documentElement.classList.contains(DARK_CLASS)) {
      this.enableLight()
    } else {
      this.enableDark()
    }
  }

  enableDark(persist = true) {
    document.documentElement.classList.add(DARK_CLASS)
    this.updateThemeColor(DARK_COLOR)
    this.swapIcons(true)
    if (persist) this.savePreference(DARK_CLASS)
  }

  enableLight(persist = true) {
    document.documentElement.classList.remove(DARK_CLASS)
    this.updateThemeColor(LIGHT_COLOR)
    this.swapIcons(false)
    if (persist) this.savePreference("light")
  }

  swapIcons(isDark) {
    if (this.hasIconSunTarget) this.iconSunTarget.classList.toggle("hidden", !isDark)
    if (this.hasIconMoonTarget) this.iconMoonTarget.classList.toggle("hidden", isDark)
  }

  updateThemeColor(color) {
    const themeMeta = document.querySelector("#theme-color")
    if (themeMeta) themeMeta.setAttribute("content", color)
  }

  savePreference(theme) {
    this.persistLocal(theme)

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (!token) return

    fetch("/theme", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ theme })
    }).catch((error) => console.warn("Theme sync failed", error))
  }

  persistLocal(theme) {
    try {
      window.localStorage.setItem(STORAGE_KEY, theme)
      sessionStorage.setItem(SESSION_KEY, theme)
    } catch (error) {
      console.warn("Unable to persist theme in localStorage", error)
    }
  }

  readStoredPreference() {
    try {
      return window.localStorage.getItem(STORAGE_KEY) || sessionStorage.getItem(SESSION_KEY)
    } catch (error) {
      console.warn("Unable to read stored theme", error)
      return null
    }
  }
}
