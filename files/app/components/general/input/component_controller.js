import { Controller } from "@hotwired/stimulus"
import validate from 'validator';

export default class extends Controller {
  static get targets() {
    return ['errorContainer', 'input']
  }
  static get values() {
    return {
      hasError: Boolean,
      validations: Array
    }
  }

  connect() {
    // if (this.hasErrorValue) {
    //   this._validate();
    // }
  }

  validateNow() {
    this._validate();
  }

  validateLater() {
    this._removeErrors();

    clearTimeout(this.timeoutId);
    this.timeoutId = setTimeout(() => this._validate(), 200);
  }

  _validate() {
    if (!this.hasInputTarget) return;

    const results = validate(this.inputTarget.value, this.validationsValue, this);
    const errors = results.filter(e => e.level === 'error');
    const warnings = results.filter(e => e.level === 'warning');
    this._removeErrors();
    if (errors.length > 0) {
      this.element.classList.add('error');
      errors.forEach((e) => this._addErrorMessage(e.message));
    }
    if (warnings.length > 0) {
      this.element.classList.add('warning');
      warnings.forEach((e) => this._addWarningMessage(e.message));
    }
  }

  _removeErrors() {
    this.errorContainerTarget.innerHTML = '';
    this.element.classList.remove('error', 'warning');
  }

  _addErrorMessage(message) {
    const error = document.createElement('small');
    error.classList.add('mt-1', 'text-left', 'text-semantic-danger');
    error.textContent = message;
    this.errorContainerTarget.appendChild(error);
  }

  _addWarningMessage(message) {
    const error = document.createElement('small');
    error.classList.add('mt-1', 'text-left', 'text-warning-400');
    error.textContent = message;
    this.errorContainerTarget.appendChild(error);
  }
}
