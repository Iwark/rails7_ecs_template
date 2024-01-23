import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static get values() {
    return {
      timeout: { type: Number, default: 5000 }
    }
  }

  connect() {
    setTimeout(() => {
      this.removeNotification();
    }, this.timeoutValue);
  }

  disconnect() {
    this.removeNotification();
  }

  removeNotification() {
    this.element.classList.remove('animate-fade-in-left');
    this.element.classList.add('animate-fade-out-left');
    setTimeout(() => {
      this.element.remove();
    }, 500);
  }
}
