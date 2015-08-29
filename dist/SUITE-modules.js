(function() {


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
    this.slots.child.$minHeight = 0;
    this.slots.child.$maxHeight = 99999;
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
        _this.removeElement("content_div");
        return _this.slots.child.unrender();
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
(function() {
  new window.SUITE.ModuleBuilder("list").extend("box").addProperty("totalHeight", [SUITE.PrimitiveType.Number]).addMethod("_relayout", function() {
    var child, total_height, _i, _len, _ref;
    total_height = 0;
    _ref = this.slots.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      child.$x = 0;
      child.$y = total_height;
      total_height += child.$height;
    }
    return this.$totalHeight = total_height;
  }).addEventHandler("onResize", function(size) {
    return this._relayout();
  }).addMethod("_scrolled", function() {
    var container, item, margin, nli, vstart, vstop, _i, _len, _ref;
    container = this.getElement("container");
    margin = 500;
    vstart = this.rootElement.scrollTop - margin;
    vstop = vstart + this.$height + 2 * margin;
    _ref = this.slots.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item.$y + item.$height > vstart) {
        if (item.$y > vstop) {
          if (item.isRendered()) {
            item.unrender();
          }
        } else {
          if (!item.isRendered()) {
            this.appendElement(container, nli = item.render());
            item.resize({
              width: this.$width,
              height: nli.$height
            });
          }
        }
      } else if (item.isRendered()) {
        item.unrender();
      }
    }
  }).addStyle("listStyle", {
    overflowY: "scroll"
  }).addStyle("listContainerStyle", {
    height: function() {
      return this.$totalHeight;
    }
  }).setInitializer(function() {
    return this._relayout();
  }).setRenderer(function() {
    var container, div;
    div = this.supermodule("absolute-element");
    container = this.createElement("container", "div");
    this.applyStyle(container, "listContainerStyle");
    this.appendElement(container);
    div.addEventListener("scroll", this._scrolled);
    this.applyStyle(div, "listStyle");
    this._relayout();
    this._scrolled();
    return div;
  }).setOnResize(function(size) {
    var slot, _i, _len, _ref;
    this.adjustSizeBounded(size);
    _ref = this.slots.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      slot = _ref[_i];
      slot.resize({
        width: this.$width,
        height: slot.$height
      });
    }
    return this._scrolled();
  }).register();

  new window.SUITE.ModuleBuilder("list-item").extend("absolute-element").setPropertyDefault("height", 55).addProperty("title", [SUITE.PrimitiveType.String], "", function() {
    return this.rerender;
  }).addProperty("subtitle", [SUITE.PrimitiveType.String], "", function() {
    return this.rerender;
  }).addStyle("list_item", {
    padding: "8px 12px",
    borderBottom: "1px solid #eee",
    boxSizing: "border-box"
  }).addStyle("list_component", {
    margin: 0,
    padding: 0,
    position: "static"
  }).addStyle("list_title", {
    fontSize: 18
  }).addStyle("list_subtitle", {
    fontSize: 12,
    color: "#666"
  }).setRenderer(function() {
    var div, subtitle, title;
    div = this["super"]();
    this.applyStyle(div, "list_item");
    title = this.createElement("title", "h1");
    title.innerHTML = this.$title;
    this.applyStyle(title, "list_component");
    this.applyStyle(title, "list_title");
    this.appendElement(title);
    if (this.$subtitle != null) {
      subtitle = this.createElement("subtitle", "h1");
      subtitle.innerHTML = this.$subtitle;
      this.applyStyle(subtitle, "list_component");
      this.applyStyle(subtitle, "list_subtitle");
      this.appendElement(subtitle);
    }
    return div;
  }).setOnResize(function(size) {
    var container;
    this.$width = size.width;
    if (container = this.getElement("container")) {
      return container.$width = this.$width;
    }
  }).register();

}).call(this);
