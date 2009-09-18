
// TODO Change to dropping the name property off the input element when in example mode
TextFieldWithExample = Class.create();
TextFieldWithExample.prototype = {
	initialize: function(inputElementId, defaultText, options) {
	  this.setOptions(options);

		this.input = $(inputElementId);
		this.name = this.input.name;
		this.defaultText = defaultText;
		this.createHiddenInput();

		this.checkAndShowExample();

		Event.observe(this.input, "blur", this.onBlur.bindAsEventListener(this));
		Event.observe(this.input, "focus", this.onFocus.bindAsEventListener(this));
		Event.observe(this.input, "select", this.onFocus.bindAsEventListener(this));
		Event.observe(this.input, "keydown", this.onKeyPress.bindAsEventListener(this));
		Event.observe(this.input, "click", this.onClick.bindAsEventListener(this));
	},
	createHiddenInput: function() {
		this.hiddenInput = document.createElement("input");
		this.hiddenInput.type = "hidden";
		this.hiddenInput.value = "";
		this.input.parentNode.appendChild(this.hiddenInput);
	},
	setOptions: function(options) {
    	this.options = { exampleClassName: 'example' };
    	Object.extend(this.options, options || {});
  	},
	onKeyPress: function(event) {
		if (!event) var event = window.event;
	 	var code = (event.which) ? event.which : event.keyCode
	 	if (this.isAlphanumeric(code)) {
	 		this.removeExample();
	 	}
	},
	onBlur: function(event) {
		this.checkAndShowExample();
	},
	onFocus: function(event) {
		if (this.exampleShown()) {
		    this.removeExample();
	  	}
	},
	onClick: function(event) {
		this.removeExample();
	},
	isAlphanumeric: function(keyCode) {
		return keyCode >= 40 && keyCode <= 90;
	},
	checkAndShowExample: function() {
		if (this.input.value == '') {
			this.input.value = this.defaultText;
			this.input.name = null;
			this.hiddenInput.name = this.name;
			Element.addClassName(this.input, this.options.exampleClassName);
		}
	},
  removeExample: function() {
		if (this.exampleShown()) {
			this.input.value = '';
			this.input.name = this.name;
			this.hiddenInput.name = null;
			Element.removeClassName(this.input, this.options.exampleClassName);
		}
	},
	exampleShown: function() {
		return Element.hasClassName(this.input, this.options.exampleClassName);
	}
}

Form.disable = function(form) {
    var elements = this.getElements(form);
    for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      try { element.blur(); } catch (e) {}
      element.disabled = 'disabled';
      Element.addClassName(element, 'disabled');
    }
  }
Form.enable = function(form) {
    var elements = this.getElements(form);
    for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      element.disabled = '';
      Element.removeClassName(element, 'disabled');
    }
  }