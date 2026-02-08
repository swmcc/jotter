import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropzone", "filename"]

  connect() {
    this.bindEvents()
  }

  bindEvents() {
    const dropzone = this.dropzoneTarget

    // Prevent default drag behaviors
    ;["dragenter", "dragover", "dragleave", "drop"].forEach(eventName => {
      dropzone.addEventListener(eventName, (e) => {
        e.preventDefault()
        e.stopPropagation()
      }, false)
    })

    // Highlight drop zone when item is dragged over it
    ;["dragenter", "dragover"].forEach(eventName => {
      dropzone.addEventListener(eventName, () => {
        this.highlight()
      }, false)
    })

    // Unhighlight when dragging out
    ;["dragleave", "drop"].forEach(eventName => {
      dropzone.addEventListener(eventName, () => {
        this.unhighlight()
      }, false)
    })

    // Handle dropped files
    dropzone.addEventListener("drop", (e) => {
      this.handleDrop(e)
    }, false)
  }

  highlight() {
    this.dropzoneTarget.classList.add("border-blue-500", "bg-blue-50")
  }

  unhighlight() {
    this.dropzoneTarget.classList.remove("border-blue-500", "bg-blue-50")
  }

  handleDrop(e) {
    const dt = e.dataTransfer
    const files = dt.files
    this.handleFiles(files)
  }

  handleFileSelect(event) {
    const files = event.target.files
    this.handleFiles(files)
  }

  handleFiles(files) {
    if (files.length > 0) {
      const file = files[0]

      // Update filename display
      if (this.hasFilenameTarget) {
        this.filenameTarget.textContent = file.name
        this.filenameTarget.classList.remove("hidden")
      }

      // Update the file input
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(file)
      this.inputTarget.files = dataTransfer.files
    }
  }

  triggerFileInput() {
    this.inputTarget.click()
  }
}
