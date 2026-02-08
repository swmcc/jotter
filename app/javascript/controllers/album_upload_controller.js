import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "dropzone", "filename", "icon", "submit"]
  static values = {
    photoUrl: String,
    videoUrl: String
  }

  connect() {
    this.bindEvents()
    this.currentFileType = null
  }

  bindEvents() {
    const dropzone = this.dropzoneTarget

    ;["dragenter", "dragover", "dragleave", "drop"].forEach(eventName => {
      dropzone.addEventListener(eventName, (e) => {
        e.preventDefault()
        e.stopPropagation()
      }, false)
    })

    ;["dragenter", "dragover"].forEach(eventName => {
      dropzone.addEventListener(eventName, () => {
        this.highlight()
      }, false)
    })

    ;["dragleave", "drop"].forEach(eventName => {
      dropzone.addEventListener(eventName, () => {
        this.unhighlight()
      }, false)
    })

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
      const isVideo = file.type.startsWith("video/")

      // Update form action based on file type
      // this.element is the form since the controller is attached to the form
      if (isVideo) {
        this.element.action = this.videoUrlValue
        this.inputTarget.name = "video[original]"
        this.currentFileType = "video"
      } else {
        this.element.action = this.photoUrlValue
        this.inputTarget.name = "photo[image]"
        this.currentFileType = "photo"
      }

      // Update submit button text
      if (this.hasSubmitTarget) {
        this.submitTarget.value = isVideo ? "Upload Video" : "Upload Photo"
      }

      // Update filename display
      if (this.hasFilenameTarget) {
        this.filenameTarget.textContent = file.name
        this.filenameTarget.classList.remove("hidden")
      }

      // Update icon
      if (this.hasIconTarget) {
        this.iconTarget.textContent = isVideo ? "🎬" : "📸"
      }

      // Show preview for images
      if (file.type.startsWith("image/")) {
        const reader = new FileReader()
        reader.onload = (e) => {
          if (this.hasPreviewTarget) {
            this.previewTarget.src = e.target.result
            this.previewTarget.classList.remove("hidden")
          }
        }
        reader.readAsDataURL(file)
      } else if (this.hasPreviewTarget) {
        this.previewTarget.classList.add("hidden")
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
