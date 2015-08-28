(function() {


}).call(this);
(function() {
  new window.SUITE.ModuleBuilder("stack").extend("box").removeProperty("maxWidth").removeProperty("maxHeight").addProperty("justify", [SUITE.PrimitiveType.Number], 0.5, function() {
    return this._relayout();
  }).addProperty("spacing", [SUITE.PrimitiveType.Number], 0, function() {
    return this._relayout();
  }).addMethod("_relayout", function() {
    var child, stack_width, total_height, _i, _j, _len, _len1, _ref, _ref1;
    stack_width = 0;
    _ref = this.slots.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      stack_width = Math.max(child.$width, stack_width);
    }
    this.$width = stack_width;
    total_height = 0;
    _ref1 = this.slots.children;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      child = _ref1[_j];
      child.$x = (this.$width - child.$width) * this.$justify;
      child.$y = total_height;
      total_height += child.$height + this.$spacing;
    }
    return this.$height = total_height - this.$spacing;
  }).setRenderer(function() {
    var div;
    div = this["super"]();
    this._relayout();
    return div;
  }).addEventHandler("onResize", function(size) {
    return this._relayout();
  }).addSlotEventHandler("children", "onResize", function(size) {
    return this._relayout();
  }).register();

}).call(this);
(function() {
  new window.SUITE.ModuleBuilder("dialog-container").extend("container").addSlot("dialog", false, function(type) {
    return type === "floating-box";
  }).addProperty("overlayColor", [SUITE.PrimitiveType.Color], "black").addProperty("overlayOpacity", [SUITE.PrimitiveType.Number], 0.6).addStyle("overlay", {
    backgroundColor: function() {
      return this.$overlayColor;
    },
    opacity: function() {
      return this.$overlayOpacity;
    },
    zIndex: 899
  }).addStyle("dialog", {
    zIndex: 900,
    opacity: 0
  }).addProperty("displayed", [SUITE.PrimitiveType.Boolean], false, function(val, oldval) {
    var dc, dialog, fm, oc;
    if (oldval === val) {
      return;
    }
    if (val) {
      if (this.slots.dialog == null) {
        this._values.displayed = false;
        return;
      }
      dialog = this.slots.dialog;
      oc = this.createElement("overlay", "div");
      this.applyStyle(oc, "positioned");
      this.applyStyle(oc, "sized");
      this.applyStyle(oc, "overlay");
      fm = this._floating = this.createComponent("float-layout");
      fm.fillSlot("child", dialog);
      fm.resize(this.size);
      dialog.resize(this.size);
      dialog.dispatchEvent("onResize");
      dc = this.setElement("dialog", fm.render());
      this.applyStyle(dc, "dialog");
      this.setAttrs(dc, {
        opacity: 1
      });
      this.appendElement("overlay");
      return this.appendElement("dialog");
    } else {
      this.removeElement("overlay");
      this.removeElement("dialog");
      return this._floating = void 0;
    }
  }).addMethod("hideDialog", function() {
    return this.$displayed = false;
  }).addMethod("showDialog", function(dialog) {
    if ((dialog != null) && this.fillSlot("dialog", dialog) === -1) {
      return;
    }
    return this.$displayed = true;
  }).setRenderer(function() {
    var div;
    div = this["super"]();
    if (this.$displayed) {
      this.$displayed = false;
      wait(1, function() {
        return this.$displayed = true;
      });
    }
    return div;
  }).setOnResize(function(size) {
    var slot, _i, _len, _ref;
    this.$width = size.width;
    this.$height = size.height;
    _ref = this.slots.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      slot = _ref[_i];
      slot.resize(size);
    }
    if (this.$displayed) {
      return this._floating.resize(size);
    }
  }).register();

}).call(this);
(function() {
  new window.SUITE.ModuleBuilder("sidebar-layout").extend("layout-in-container").addProperty("position", [SUITE.PrimitiveType.Number]).addProperty("childWidth", [SUITE.PrimitiveType.Number], 0, function(val) {
    return this.$position = this.$shown ? 0 : -val;
  }).addProperty("pinLeft", [SUITE.PrimitiveType.Boolean], true).addProperty("slideTime", [SUITE.PrimitiveType.Number], 250).addProperty("shown", [SUITE.PrimitiveType.Boolean], false, function(val, oldval) {
    if (val === oldval) {
      return;
    }
    if (val) {
      return this.show();
    } else {
      return this.hide();
    }
  }).addMethod("show", function() {
    if (!this.$shown) {
      return this.$shown = true;
    }
    this.appendElement(this.setElement("content_div", this.renderSlot(this.slots.child)));
    this.slots.child.resize({
      width: this.$childWidth,
      height: this.$containerHeight
    });
    this.slots.child.dispatchEvent("onResize");
    this.$position = -this.slots.child.$width;
    return wait(5, (function(_this) {
      return function() {
        return SUITE.AnimateChanges(new SUITE.Transition(_this.$slideTime), function() {
          _this.$position = 0;
          return _this.dispatchEvent("onShow");
        });
      };
    })(this));
  }).addMethod("hide", function() {
    if (this.$shown) {
      return this.$shown = false;
    }
    SUITE.AnimateChanges(new SUITE.Transition(this.$slideTime), (function(_this) {
      return function() {
        _this.$position = -_this.$childWidth;
        return _this.dispatchEvent("onHide");
      };
    })(this));
    return wait(this.$slideTime + 10, (function(_this) {
      return function() {
        return _this.removeElement("content_div");
      };
    })(this));
  }).addStyle("sidebar", {
    left: function() {
      if (this.$pinLeft) {
        return this.$position;
      }
    },
    right: function() {
      if (!this.$pinLeft) {
        return this.$position;
      }
    },
    height: function() {
      return this.$containerHeight;
    },
    width: function() {
      return this.$childWidth;
    },
    backgroundColor: "white"
  }).setRenderer(function() {
    var div;
    div = this["super"](false);
    if (this.$shown) {
      wait(1, this.show());
    }
    this.applyStyle(div, "sidebar");
    return div;
  }).setOnResize(function(size) {
    this["super"](size);
    if (!this.$shown) {
      return;
    }
    return this.slots.child.resize({
      width: this.$childWidth,
      height: size.height
    });
  }).register();

}).call(this);
