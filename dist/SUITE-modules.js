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
  }).addProperty("immidiateRender", [SUITE.PrimitiveType.Boolean], false).setInitializer(function() {
    return this._rendered = false;
  }).addMethod("toggle", function() {
    if (this.$shown) {
      return this.hide();
    } else {
      return this.show();
    }
  }).addMethod("_offscreenRender", function() {
    this.appendElement(this.setElement("content_div", this.renderSlot(this.slots.child)));
    this.slots.child.$minHeight = 0;
    this.slots.child.$maxHeight = 99999;
    this.slots.child.resize({
      width: this.$childWidth,
      height: this.$containerHeight
    });
    this.slots.child.dispatchEvent("onResize");
    this.$position = -this.slots.child.$width;
    return this._rendered = true;
  }).addMethod("show", function() {
    if (!this.$shown) {
      return this.$shown = true;
    }
    if (!this._rendered) {
      this._offscreenRender();
    } else {
      this.getElement("content_div").style.visibility = "visible";
    }
    return wait(5, (function(_this) {
      return function() {
        return SUITE.AnimateChanges(new SUITE.Transition(_this.$slideTime), function() {
          _this.$position = 0;
          return _this.dispatchEvent("onOpen");
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
        return _this.dispatchEvent("onClose");
      };
    })(this));
    return wait(this.$slideTime + 10, (function(_this) {
      return function() {

        /* It's unclear this helps at all
        @removeElement "content_div"
        @slots.child.unrender()
         */
        return _this.getElement("content_div").style.visibility = "hidden";
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
    if (this.$immidiateRender) {
      this._offscreenRender();
    }
    if (this.$shown) {
      wait(1, this.show());
    }
    this.applyStyle(div, "sidebar");
    return div;
  }).addEventHandler("onHide", function() {
    return this._rendered = false;
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
  new window.SUITE.ModuleBuilder("list").extend("box").addProperty("scrollMargin", [SUITE.PrimitiveType.Number], 500).addProperty("expandBack", [SUITE.PrimitiveType.Function]).addProperty("expandFront", [SUITE.PrimitiveType.Function]).addProperty("isTable", [SUITE.PrimitiveType.Boolean], false).addProperty("totalHeight", [SUITE.PrimitiveType.Number]).addMethod("_relayout", function() {
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
    var container, item, nli, vstart, vstop, _i, _len, _ref;
    container = this.getElement("container");
    vstart = this.rootElement.scrollTop - this.$scrollMargin;
    vstop = vstart + this.$height + 2 * this.$scrollMargin;
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
    container = this.createElement("container", this.$isTable ? "table" : "div");
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
    if (this.rootElement != null) {
      return this._scrolled();
    }
  }).register();

}).call(this);
(function() {
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
(function() {
  new window.SUITE.ModuleBuilder("html-list").extend("list").setPropertyDefault("isTable", true).addProperty("minItemHeight", [SUITE.PrimitiveType.Number], 20).addProperty("itemCount", [SUITE.PrimitiveType.Number], 0, function() {
    return this._scrolled();
  }).addProperty("renderSlot", [SUITE.PrimitiveType.Function]).setInitializer(function() {
    return this.renderedElements = [];
  }).addMethod("_renderElement", function(container, i) {
    var item;
    item = this.renderedElements[i] = this.$renderSlot.call(this, i);
    item.style.width = this.$width + "px";
    container.appendChild(item);
    return this.$minItemHeight;
  }).addMethod("_scrolled", function() {
    var container, i, item, new_items, pos, vstart, vstop, _i, _ref;
    container = this.getElement("container");
    vstart = this.rootElement.scrollTop - this.$scrollMargin;
    vstop = vstart + this.$height + 2 * this.$scrollMargin;
    new_items = false;
    pos = 0;
    for (i = _i = 0, _ref = this.$itemCount; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (i >= this.renderedElements.length) {
        this.renderedElements.push(void 0);
      }
      if (!(item = this.renderedElements[i])) {
        if (pos > vstop) {
          continue;
        }
        new_items = true;
        pos += this._renderElement(container, i);
      } else {
        pos += item.offsetHeight;
      }
    }
    if (new_items) {
      wait(5, (function(_this) {
        return function() {
          var accY, _j, _len, _ref1, _results;
          _ref1 = _this.renderedElements;
          _results = [];
          for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
            item = _ref1[_j];
            if (item != null) {
              if (typeof accY === "undefined" || accY === null) {
                _results.push(accY = (item.offsetTop + item.offsetHeight) || 0);
              } else {
                item.style.top = accY + "px";
                _results.push(accY += item.offsetHeight);
              }
            }
          }
          return _results;
        };
      })(this));
    }
  }).setRenderer(function() {
    this.renderedElements = [];
    return this["super"]();
  }).setOnResize(function(size) {
    var item, _i, _len, _ref;
    this.adjustSizeBounded(size);
    _ref = this.renderedElements;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item != null) {
        item.style.width = size.width;
      }
    }
    if (this.rootElement != null) {
      return this._scrolled();
    }
  }).register();

}).call(this);
(function() {
  new window.SUITE.ModuleBuilder("hierarchical-navigation").extend("absolute-element").addSlot("pages", true).setInitializer(function() {
    if (this.slots.pages.length === 0) {
      throw new Error("<hierarchical-navigation> must have default page.");
    }
    this._pageIndex = 0;
    this._animating = false;
    return this._loading = false;
  }).addProperty("generatePage", [SUITE.PrimitiveType.Function], function() {
    throw new Error("Must override $generatePage on <hierarchical-navigation>");
  }).addMethod("push", function(pageData) {
    var component;
    component = this.$generatePage(pageData, this._pushComponent);
    if (component == null) {
      return this._startLoading();
    } else {
      return this._pushComponent(component);
    }
  }).addMethod("pop", function() {
    this.dispatchEvent("onPop");
    return this._animateTo(this._pageIndex - 1, false, (function(_this) {
      return function() {
        return _this.slots.pages.pop();
      };
    })(this));
  }).addMethod("switchTo", function(i) {
    return this._animateTo(i, i < this._pageIndex);
  }).addMethod("_pushComponent", function(component) {
    if (component == null) {
      return;
    }
    if (!(component instanceof SUITE.Component) && !(component instanceof SUITE.Template)) {
      return;
    }
    this._finishLoading();
    if (component instanceof SUITE.Template) {
      component = component._component;
    }
    this.slots.pages.push(component);
    return this._animateTo(this.slots.pages.length - 1, true);
  }).addProperty("duration", [SUITE.PrimitiveType.Number], 200).addMethod("_animateTo", function(index, goRight, callback) {
    var currentPage, newPage, newPageElement;
    if (index >= this.slots.pages.length || index < 0) {
      throw new Error("<hierarchical-navigation> Page index " + index + " out of bounds.");
    }
    if (this._animating) {
      return;
    }
    this._animating = true;
    newPage = this.slots.pages[index];
    newPage.$x = 0;
    newPage.resize(this.size);
    newPage.$x = goRight ? this.$width : -newPage.$width;
    this.appendElement(newPageElement = newPage.render());
    currentPage = this.slots.pages[this._pageIndex];
    SUITE.AnimateChanges(this.$duration, (function(_this) {
      return function() {
        currentPage.$x = goRight ? -currentPage.$width : _this.$width;
        return newPage.$x = 0;
      };
    })(this));
    return wait(this.$duration, (function(_this) {
      return function() {
        _this._pageIndex = index;
        if (callback) {
          callback(true);
        }
        _this._animating = false;
        return wait(_this.$duration, function() {
          return currentPage.unrender();
        });
      };
    })(this));
  }).setRenderer(function() {
    var div, pageElement;
    div = this["super"]();
    div.style.overflow = "hidden";
    pageElement = this.slots.pages[this._pageIndex].render();
    this.appendElement(pageElement);
    return div;
  }).addMethod("_startLoading", function() {
    if (!this._loading) {
      this._loading = true;
      return this.dispatchEvent("startLoading");
    }
  }).addMethod("_finishLoading", function() {
    if (this._loading) {
      this._loading = false;
      return this.dispatchEvent("finishLoading");
    }
  }).setOnResize(function(size) {
    var oldX, slot, _i, _len, _ref, _results;
    this.$width = size.width - this.$x;
    this.$height = size.height - this.$y;
    _ref = this.slots.pages;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      slot = _ref[_i];
      oldX = slot.$x;
      slot.$x = 0;
      slot.resize(this.size);
      _results.push(slot.$x = oldX);
    }
    return _results;
  }).register();

}).call(this);
