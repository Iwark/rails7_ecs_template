import InputController from "components/general/input/component_controller"
import SlimSelect from 'slim-select'

export default class extends InputController {

  static get values() {
    return {
      placeholder: String,
      search: Boolean,
      disabled: Boolean
    }
  }

  connect() {
    super.connect();
    if (!this.disabledValue) {
      this._initSlimSelect();
    }
  }

  disconnect() {
    this.slimSelect?.destroy();
    this.slimSelect = null;
  }

  reload() {
    this.slimSelect?.destroy();
    this.slimSelect = null;
    setTimeout(() => {
      this._initSlimSelect();
    }, 50);
  }

  addOption(label, value) {
    const option = document.createElement('option');
    option.value = value;
    option.textContent = label;
    this.inputTarget.lastElementChild.before(option);
    this.reload();
  }

  disable(hide = false) {
    this.disabledValue = true;
    this.inputTarget.disabled = true;
    this.slimSelect?.destroy();
    this.slimSelect = null;
    if (hide) {
      this.inputTarget.classList.add('hidden');
    }
  }

  enable(show = false) {
    if (this.slimSelect) {
      return;
    }

    this.disabledValue = false;
    this.inputTarget.disabled = false;
    if (show) {
      this.inputTarget.classList.remove('hidden');
    }
    setTimeout(() => {
      this._initSlimSelect();
    }, 50);
  }

  _initSlimSelect() {
    const settings = {
      showSearch: this.hasSearchValue && this.searchValue,
    }

    // Make sure there is an option with [data-placeholder] that slim-select uses
    // when there should be a placeholder
    if (this.hasPlaceholderValue) {
      let placeholderOption = this.inputTarget.querySelector('option[value=""]');
      if (!placeholderOption) {
        placeholderOption = document.createElement('option');
        this.inputTarget.prepend(placeholderOption);
      }
      placeholderOption.setAttribute('data-placeholder', true);
      settings['placeholderText'] = this.placeholderValue;
    }
    this.slimSelect = new SlimSelect({
      select: this.inputTarget,
      settings: settings,
      events: {
        afterClose: this.validateNow.bind(this),
      }
    })
  }
}