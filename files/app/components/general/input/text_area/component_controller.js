import InputController from "components/general/input/component_controller"

export default class extends InputController {
  static get targets() {
    return [...super.targets, 'counter']
  }
  static get values() {
    return {
      ...super.values,
      maxLength: Number
    }
  }

  connect() {
    super.connect();
    this._initCounter();
  }

  updateCounter(init = false) {
    const text = `${this.inputTarget.value.length}/${this.maxLengthValue}`;
    this.counterTarget.textContent = text;
    if (!init || this.inputTarget.value) {
      this.validateLater();
    }
  }

  _initCounter() {
    this.counterTarget.classList.add('active');
    this.updateCounter(true);
  }
}