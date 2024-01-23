import InputController from "components/general/input/component_controller"

import flatpickr from "flatpickr";
import { Japanese } from "flatpickr/dist/l10n/ja.js"

export default class extends InputController {

  connect() {
    const customStyle = document.createElement("style")
    customStyle.innerText = this._customStyles();
    this.element.prepend(customStyle);
    this.calendar = flatpickr(this.inputTarget, {
      altInput: true,
      dateFormat: "Y-m-d",
      altFormat: "Y年m月d日",
      locale: Japanese,
      // allowInput: true,
    });
  }

  disconnect() {
    // Destroys the flatpickr instance, cleans up - removes event listeners, restores inputs, etc.
    this.calendar.destroy();
  }

  setDate(date) {
    this.calendar.setDate(date);
  }

  _customStyles() {
    return `
    .flatpickr-calendar .flatpickr-monthDropdown-months {
      margin: 0;
      padding: 0;
    }
    .flatpickr-calendar .numInputWrapper {
      position: absolute;
      left: 2px;
      font-size: 14px;
      display: flex;
      top: 8px;
      align-items: center;
      width: 3.75rem;
      color: #666;
    }
    .flatpickr-calendar .numInputWrapper .arrowUp,
    .flatpickr-calendar .numInputWrapper .arrowDown {
      display: none;
    }
    .flatpickr-calendar .numInputWrapper:after {
      position: absolute;
      right: 0;
      content: '年';
    }
    `
  }
}
