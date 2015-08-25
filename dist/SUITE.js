
/*
  SUITE: Scriptable UI Templating Engine
  Keaton Brandt, 3am LLC
  -----------------------------------------
  A structured layout system for the modern
  web, providing a light-weight framework
  on which to build complex web app UIs.
  In many ways it is set up as a cross
  between FB React and Apple's UIKit.
  -----------------------------------------
 */

(function() {
  window.SUITE = {
    modules: {},
    config: {
      header: "This HTML was auto-generated by SUITE (suitejs.com). Do not edit directly.",
      id_prefix: "sc__",
      component_attribute: true
    }
  };

}).call(this);
(function() {
  window.wait = function(t, f) {
    return setTimeout(f, t);
  };

  window._sh = window.SUITE.Helpers = {
    camelToDash: function(str) {
      return str.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
    },
    dashToCamel: function(str) {
      return str.toLowerCase().replace(/([a-z])-([a-z])/g, function(_, a, b) {
        return "" + a + (b.toUpperCase());
      });
    },
    time: function(label, func) {
      var diff, start_time;
      start_time = new Date().getTime();
      func();
      diff = (new Date().getTime()) - start_time;
      return console.log("" + label + " took " + diff + "ms");
    }
  };

}).call(this);
(function() {
  window.SUITE.PrimitiveType = {
    'Boolean': 1,
    'String': 2,
    'Color': 3,
    'Component': 4,
    'Number': 8,
    'Single': 0,
    'List': 32,
    'Object': 96
  };

  window.SUITE.Type = (function() {
    function Type(type, container, component_type) {
      var pt, typenum;
      if (container == null) {
        container = window.SUITE.PrimitiveType.Single;
      }
      pt = window.SUITE.PrimitiveType;
      typenum = type & container;
      if (type === pt.Component && (component_type != null)) {
        this.component = component_type;
        this.num = typenum;
      } else {
        return typenum;
      }
    }

    return Type;

  })();

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.SUITE.Property = (function() {
    function Property(type, default_val, setter) {
      if (typeof this.type === 'array') {
        this.type = window.SUITE.Type.apply(this.type);
      }
      if (type instanceof window.SUITE.Type && (type.component != null)) {
        return window.SUITE.ComponentProperty(name, type, default_val, setter);
      }
      this.type = type;
      this["default"] = default_val;
      if (setter != null) {
        this.setter = setter;
      }
    }

    return Property;

  })();

  window.SUITE.ComponentProperty = (function() {
    function ComponentProperty(type, handlers) {
      this.type = type;
      this.onMove = handlers.onMove, this.onShift = handlers.onShift, this.onResize = handlers.onResize, this.onChange = handlers.onChange, this.onRender = handlers.onRender, this.onHide = handlers.onHide, this.onShow = handlers.onShow, this.onAdd = handlers.onAdd, this.onRemove = handlers.onRemove;
    }

    ComponentProperty.prototype.addHandler = function(name, func) {
      var handler;
      switch (name.toLowerCase()) {
        case "onmove" || "move" || "moved":
          handler = "onMove";
          break;
        case "onshift" || "shift" || "shifted":
          handler = "onShift";
          break;
        case "onresize" || "resize" || "resized":
          handler = "onResize";
          break;
        case "onchange" || "change" || "changed":
          handler = "onChange";
          break;
        case "onrender" || "render" || "rendered":
          handler = "onRender";
          break;
        case "onhide" || "hide" || "hid":
          handler = "onHide";
          break;
        case "onshow" || "show" || "shown":
          handler = "onShow";
          break;
        case "onadd" || "add" || "added":
          handler = "onAdd";
          break;
        case "onremove" || "remove" || "removed":
          handler = "onRemove";
          break;
        default:
          return;
      }
      if (this[handler] != null) {
        if (!(this[handler] instanceof Array)) {
          this[handler] = [this[handler]];
        }
        return this[handler].push(func);
      } else {
        return this[handler] = func;
      }
    };

    return ComponentProperty;

  })();

  window.SUITE.Slot = (function(_super) {
    __extends(Slot, _super);

    function Slot(isRepeated, component_type, handlers) {
      var primative, type;
      this.isRepeated = isRepeated;
      primative = SUITE.PrimitiveType;
      if (this.isRepeated) {
        type = new SUITE.Type(primative.Component, primative.List, component_type);
      } else {
        type = new SUITE.Type(primative.Component, primative.Single, component_type);
      }
      Slot.__super__.constructor.call(this, "", type, handlers);
    }

    Slot.prototype.allowComponent = function(component) {
      return true;
    };

    return Slot;

  })(window.SUITE.ComponentProperty);

}).call(this);
(function() {
  window.SUITE.Module = (function() {
    function Module(name, extend_name, properties, slots) {
      if (properties == null) {
        properties = {};
      }
      if (slots == null) {
        slots = {};
      }
      this.name = name.toLowerCase();
      this.properties = properties;
      this.slots = slots;
      this.handlers = {};
      this.methods = {};
      if (extend_name != null) {
        this.extend(extend_name);
      }
    }

    Module.prototype.addProperty = function(name, type_or_property, default_val, setter) {
      if (type_or_property instanceof window.SUITE.Property) {
        return this.properties[name] = type_or_property;
      }
      return this.properties[name] = new window.SUITE.Property(type_or_property, default_val, setter);
    };

    Module.prototype.addSlot = function(name, slot) {
      if (slot == null) {
        slot = new window.SUITE.Slot(false);
      }
      return this.slots[name] = slot;
    };

    Module.prototype.addHandler = function(event, func) {
      return this.handlers[event] = func;
    };

    Module.prototype.addMethod = function(name, func) {
      if (window.SUITE.Component.prototype.hasOwnProperty(name)) {
        console.log("Method name '" + name + "' is already taken by an internal component function");
        return;
      }
      return this.methods[name] = func;
    };

    Module.prototype.extend = function(existingModuleName) {
      var e, existingModule, m, name, p, s, _ref, _ref1, _ref2, _ref3;
      this["super"] = existingModule = SUITE.modules[existingModuleName];
      _ref = existingModule.properties;
      for (name in _ref) {
        p = _ref[name];
        this.properties[name] = p;
      }
      _ref1 = existingModule.slots;
      for (name in _ref1) {
        s = _ref1[name];
        this.slots[name] = s;
      }
      _ref2 = existingModule.events;
      for (name in _ref2) {
        e = _ref2[name];
        this.events[name] = e;
      }
      _ref3 = existingModule.handlers;
      for (name in _ref3) {
        m = _ref3[name];
        this.module.handlers[name] = m;
      }
      if (this.render == null) {
        this.render = existingModule.render;
      }
      if (this.onResize == null) {
        this.onResize = existingModule.onResize;
      }
      if (this.getWidth == null) {
        this.getWidth = existingModule.getWidth;
      }
      if (this.getHeight == null) {
        return this.getHeight = existingModule.getHeight;
      }
    };

    Module.prototype.render = function(slots, super_mod) {
      return super_mod != null ? super_mod.render.call(this, slots, super_mod["super"]) : void 0;
    };

    Module.prototype.onResize = function(size) {
      return false;
    };

    return Module;

  })();

  window.SUITE.newModule = function(name) {
    name = name.toLowerCase();
    return window.SUITE.modules[name] = new window.SUITE.Module(name);
  };

  window.SUITE.registerModule = function(module) {
    return window.SUITE.modules[module.name] = module;
  };

}).call(this);
(function() {
  window.SUITE.Transition = (function() {
    function Transition(duration, easing) {
      if (duration == null) {
        duration = 300;
      }
      if (easing == null) {
        easing = "ease-out";
      }
      this.duration = duration;
      this.easing = easing;
    }

    return Transition;

  })();

  window.SUITE._currentTransition = void 0;

  window.SUITE.AnimateChanges = function(transition, func) {
    window.SUITE._currentTransition = transition;
    func();
    return window.SUITE._currentTransition = void 0;
  };

}).call(this);
(function() {
  window.SUITE.AttrFunctionFactory = function(default_element, transition) {
    return function(attributes_or_element, or_attributes) {
      var attr_name, attributes, classname, element, full_style, name, p, prefixes, style_changes, transition_strings, transition_style, value;
      if (attributes_or_element instanceof HTMLElement) {
        element = attributes_or_element;
        attributes = or_attributes;
      } else {
        element = default_element;
        attributes = attributes_or_element;
      }
      style_changes = {};
      for (name in attributes) {
        value = attributes[name];
        switch (name.split(".")[0].toLowerCase()) {
          case "id" || "src" || "href" || "rel" || "target" || "alt" || "title":
            element.setAttribute(name, value);
            break;
          case "attr":
            attr_name = name.split(".")[1];
            element.setAttribute(attr_name, value);
            break;
          case "class":
            if (value[0] === "+") {
              classname = element.getAttribute("class");
              element.setAttribute("class", classname + " " + value.substr(1));
            } else if (value[0] === "-") {
              classname = element.getAttribute("class");
              element.setAttribute("class", classname.replace(value.substr(1), ""));
            } else {
              element.setAttribute("class", value);
            }
            break;
          default:
            if (transition == null) {
              element.style[name] = value;
            } else {
              style_changes[name] = value;
            }
        }
      }
      if (transition == null) {
        return;
      }
      transition_strings = (function() {
        var _results;
        _results = [];
        for (name in style_changes) {
          value = style_changes[name];
          _results.push("" + (_sh.camelToDash(name)) + " " + transition.duration + "ms " + transition.easing);
        }
        return _results;
      })();
      transition_style = transition_strings.join(",");
      prefixes = ["", "-webkit-", "-moz-", "-ms-"];
      full_style = ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = prefixes.length; _i < _len; _i++) {
          p = prefixes[_i];
          _results.push("" + p + "transition:" + transition_style);
        }
        return _results;
      })()).join(";");
      element.setAttribute("style", element.getAttribute("style") + full_style);
      return wait(5, function() {
        for (name in style_changes) {
          value = style_changes[name];
          element.style[name] = value;
        }
        return wait(5, function() {
          return element.setAttribute("style", element.getAttribute("style").replace(full_style, ""));
        });
      });
    };
  };

}).call(this);
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.SUITE.Component = (function() {
    function Component(module_or_name) {
      var func, name, slot, _ref, _ref1;
      this.element = void 0;
      this.parent = void 0;
      this._varname = void 0;
      if (module_or_name instanceof window.SUITE.Module) {
        this._module = module_or_name;
        this.type = module_or_name.name;
      } else {
        name = module_or_name.toLowerCase();
        this._module = window.SUITE.modules[name];
        this.type = name;
      }
      this._setupPropertyBindings();
      Object.defineProperty(this, "width", {
        get: function() {
          var _ref;
          return ((_ref = this._module.getWidth) != null ? _ref.call(this) : void 0) || parseInt(this.element.offsetWidth);
        }
      });
      Object.defineProperty(this, "height", {
        get: function() {
          var _ref;
          return ((_ref = this._module.getHeight) != null ? _ref.call(this) : void 0) || parseInt(this.element.offsetHeight);
        }
      });
      _ref = this._module.methods;
      for (name in _ref) {
        func = _ref[name];
        this[name] = func.bind(this);
      }
      this.slots = {};
      _ref1 = this._module.slots;
      for (name in _ref1) {
        slot = _ref1[name];
        if (slot.isRepeated) {
          this.slots[name] = [];
        }
      }
    }

    Component.prototype.copy = function() {
      var copy, k, s, slot_contents, v, _ref, _ref1;
      copy = new SUITE.Component(this.type);
      copy.parent = this.parent;
      copy._module = this._module;
      copy._varname = this._varname;
      _ref = this._values;
      for (k in _ref) {
        v = _ref[k];
        copy._values[k] = v;
      }
      _ref1 = this.slots;
      for (k in _ref1) {
        slot_contents = _ref1[k];
        if (slot_contents instanceof Array) {
          copy.slots[k] = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = slot_contents.length; _i < _len; _i++) {
              s = slot_contents[_i];
              _results.push(s.copy());
            }
            return _results;
          })();
        } else {
          copy.slots[k] = slot_contents.copy();
        }
      }
      return copy;
    };

    Component.prototype._setupPropertyBindings = function() {
      var name, p, _ref, _results;
      this._values = {};
      _ref = this._module.properties;
      _results = [];
      for (name in _ref) {
        p = _ref[name];
        if (name == null) {
          continue;
        }
        this._values[name] = p["default"];
        _results.push(Object.defineProperty(this, "$" + name, {
          get: (function(_this, name) {
            return function() {
              return _this._values[name];
            };
          })(this, name),
          set: ((function(_this) {
            return function(name, p) {
              if (p.setter != null) {
                return function(val) {
                  var oldval, setAttr;
                  oldval = _this._values[name];
                  _this._values[name] = val;
                  if (_this.element == null) {
                    return;
                  }
                  setAttr = SUITE.AttrFunctionFactory(_this.element, SUITE._currentTransition);
                  return p.setter.call(_this, val, setAttr, oldval);
                };
              } else {
                return function(val) {
                  _this._values[name] = val;
                  return _this.rerender();
                };
              }
            };
          })(this))(name, p)
        }));
      }
      return _results;
    };

    Component.prototype.hasPropertyValue = function(name) {
      return this._module.properties[name] != null;
    };

    Component.prototype.fillSlot = function(slotName, component) {
      var index, slot_class;
      if ((slot_class = this._module.slots[slotName]) == null) {
        return -1;
      }
      if (component instanceof SUITE.Template) {
        component = component._component;
      }
      if (!slot_class.allowComponent(component)) {
        return -1;
      }
      component.parent = this;
      index = 0;
      if (slot_class.isRepeated) {
        if (!(__indexOf.call(this.slots, slotName) >= 0)) {
          this.slots[slotName] = [];
        }
        index = this.slots.length;
        this.slots[slotName].push(component);
      } else {
        this.slots[slotName] = component;
      }
      this.rerender();
      return index;
    };

    Component.prototype.removeSlotComponent = function(slotName, index) {
      if (!(__indexOf.call(this.slots, slotName) >= 0)) {
        return false;
      }
      if (!(this.slots[slotName] instanceof Array)) {
        return false;
      }
      this.slots[slotName][index].parent = void 0;
      this.slots[slotName].splice(index, 1);
      return true;
    };

    Component.prototype.emptySlot = function(slotName) {
      var slot, _i, _len, _ref;
      if (!(__indexOf.call(this.slots, slotName) >= 0)) {
        return;
      }
      if (this.slots[slotName] instanceof Array) {
        _ref = this.slots[slotName];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          slot = _ref[_i];
          slot.parent = void 0;
        }
      } else {
        this.slots[slotName].parent = void 0;
      }
      delete this.slots[slotName];
      return this.rerender();
    };

    Component.prototype.allSlotComponents = function() {
      var all, k, slot_contents, _ref;
      all = [];
      _ref = this.slots;
      for (k in _ref) {
        slot_contents = _ref[k];
        if (slot_contents instanceof Array) {
          if (slot_contents.length === 0) {
            continue;
          }
          Array.prototype.push.apply(all, slot_contents);
        } else {
          all.push(slot_contents);
        }
      }
      return all;
    };

    Component.prototype.allSubComponents = function() {
      var all, c, _i, _len, _ref;
      all = [];
      _ref = this.allSlotComponents();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        all.push(c);
        Array.prototype.push.apply(all, c.allSubComponents());
      }
      return all;
    };

    Component.prototype.render = function() {
      var c, name, rendered_slots, slot, _ref;
      if (this._module.render == null) {
        return;
      }
      rendered_slots = {};
      _ref = this.slots;
      for (name in _ref) {
        slot = _ref[name];
        if (slot instanceof Array) {
          rendered_slots[name] = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = slot.length; _i < _len; _i++) {
              c = slot[_i];
              _results.push(c.render());
            }
            return _results;
          })();
        } else if (slot != null) {
          rendered_slots[name] = slot.render();
        }
      }
      this.element = this._module.render.call(this, rendered_slots, this._module["super"]);
      this.bindEventListeners();
      return this.element;
    };

    Component.prototype.rerender = function() {
      var olddom;
      if (this.element == null) {
        return;
      }
      olddom = this.element;
      this.render();
      olddom.parentNode.insertBefore(this.element, olddom);
      olddom.parentNode.removeChild(olddom);
      return this.element;
    };

    Component.prototype.resize = function(size) {
      if (this._module.onResize == null) {
        return;
      }
      return this._module.onResize.call(this, size);
    };

    Component.prototype.bindEventListeners = function() {
      var func, name, _ref, _results;
      _ref = this._module.events;
      _results = [];
      for (name in _ref) {
        func = _ref[name];
        _results.push(this.element.addEventListener(name, func.bind(this)));
      }
      return _results;
    };

    return Component;

  })();

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.SUITE.Stage = (function(_super) {
    __extends(Stage, _super);

    function Stage(elementSelector) {
      if (document.querySelectorAll(elementSelector).length > 1) {
        throw new Error("Please choose a unique selector (only applies to 1 element)");
      }
      this.html_container = document.querySelector(elementSelector);
      Stage.__super__.constructor.call(this, "container");
      window.addEventListener("resize", (function(_this) {
        return function() {
          return _this.resize({
            width: _this.html_container.offsetWidth,
            height: _this.html_container.offsetHeight
          });
        };
      })(this));
    }

    Stage.prototype.render = function() {
      return _sh.time("Full stage render", (function(_this) {
        return function() {
          var container, header_comment;
          _this.resize({
            width: _this.html_container.offsetWidth,
            height: _this.html_container.offsetHeight
          });
          container = Stage.__super__.render.call(_this);
          header_comment = document.createComment(SUITE.config.header);
          container.insertBefore(header_comment, container.firstChild);
          return _this.html_container.appendChild(container);
        };
      })(this));
    };

    return Stage;

  })(window.SUITE.Component);

}).call(this);
(function() {
  window.SUITE.Template = (function() {
    function Template(topLevelComponent) {
      this._component = topLevelComponent;
    }

    Template.prototype.addComponentVariable = function(name, component) {
      component._varname = name;
      return this[name] = component;
    };

    Template.prototype.copy = function() {
      var component, copy, _i, _len, _ref;
      copy = new SUITE.Template(this._component.copy());
      if (this._component._varname) {
        copy[this._component._varname] = this._component;
      }
      _ref = copy._component.allSubComponents();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        component = _ref[_i];
        if (component._varname != null) {
          copy[component._varname] = component;
        }
      }
      return copy;
    };

    return Template;

  })();

}).call(this);
(function() {
  window.SUITE.ModuleBuilder = (function() {
    function ModuleBuilder(name) {
      this.module = new window.SUITE.Module(name);
    }

    ModuleBuilder.prototype.build = function() {
      return this.module;
    };

    ModuleBuilder.prototype.register = function() {
      return window.SUITE.registerModule(this.module);
    };

    ModuleBuilder.prototype.addProperty = function(name_or_property, type, default_val, setter) {
      this.module.addProperty(name_or_property, type, default_val, setter);
      return this;
    };

    ModuleBuilder.prototype.removeProperty = function(name) {
      if (this.module.properties[name]) {
        delete this.module.properties[name];
      }
      return this;
    };

    ModuleBuilder.prototype.setPropertySetter = function(name, setter) {
      this.module.properties[name].setter = setter;
      return this;
    };

    ModuleBuilder.prototype.addSlot = function(name, isRepeated, allowType) {
      if (isRepeated == null) {
        isRepeated = false;
      }
      this.module.addSlot(name, new window.SUITE.Slot(isRepeated));
      if (allowType != null) {
        this.module.slots[name].allowType = allowType;
      }
      return this;
    };

    ModuleBuilder.prototype.addSlotFromClass = function(name, slot) {
      this.module.addSlot(name, slot);
      return this;
    };

    ModuleBuilder.prototype.addEventListener = function(event, func) {
      this.module.addEventListener(event, func);
      return this;
    };

    ModuleBuilder.prototype.addMethod = function(name, func) {
      this.module.addMethod(name, func);
      return this;
    };

    ModuleBuilder.prototype.setRenderer = function(renderFunction) {
      this.module.render = renderFunction;
      return this;
    };

    ModuleBuilder.prototype.setOnResize = function(resizedFunction) {
      this.module.onResize = resizedFunction;
      return this;
    };

    ModuleBuilder.prototype.setGetWidth = function(getWidthFunction) {
      this.module.getWidth = getWidthFunction;
      return this;
    };

    ModuleBuilder.prototype.setGetHeight = function(getHeightFunction) {
      this.module.getHeight = getHeightFunction;
      return this;
    };

    ModuleBuilder.prototype.extend = function(module_name) {
      this.module.extend(module_name);
      return this;
    };

    return ModuleBuilder;

  })();

}).call(this);
(function() {
  window.SUITE.ParseTemplate = function(json) {
    var build_recursive, container, parse_selector, properties, selector, selector_regex, single_key, single_template;
    if (Object.keys(json).length === 0) {
      return;
    }
    if (Object.keys(json).length > 1) {
      container = new SUITE.Component("container");
      for (selector in json) {
        properties = json[selector];
        single_template = {};
        single_template[selector] = properties;
        container.addChild(SUITE.ParseTemplate(single_template));
      }
      return container;
    }
    selector_regex = /([A-Za-z0-9\-\_]+)(\@([A-Za-z0-9\-\_]+))?(\#([A-Za-z0-9\-\_]+))?(\.([A-Za-z0-9\-\_]+))?/;
    parse_selector = function(selector) {
      var classes, component, id, jsvar, match, _;
      selector = selector.replace("<", "").replace(">", "");
      match = selector.match(selector_regex);
      if (match == null) {
        throw new Error("Invalid selector: '" + selector + "'");
      }
      _ = match[0], component = match[1], _ = match[2], jsvar = match[3], _ = match[4], id = match[5], _ = match[6], classes = match[7];
      classes = classes != null ? classes.replace(".", " ") : void 0;
      return [component, jsvar, id, classes];
    };
    build_recursive = function(selector, properties, template) {
      var classes, comp_count, component, component_name, id, jsvar, name, slot_properties, slot_selector, top_level, val, _ref;
      _ref = parse_selector(selector), component_name = _ref[0], jsvar = _ref[1], id = _ref[2], classes = _ref[3];
      component = new SUITE.Component(component_name);
      if ((id != null) && component.hasPropertyValue("id")) {
        component.$id = id;
      }
      if ((classes != null) && component.hasPropertyValue("class")) {
        component.$class = classes;
      }
      top_level = template == null;
      if (top_level) {
        template = new SUITE.Template(component);
      }
      for (name in properties) {
        val = properties[name];
        if (name[0] === "$") {
          component[name] = val;
        } else if (component._module.slots[name] != null) {
          if (!(properties instanceof Object)) {
            throw new Error("Expected component(s) on slot '" + name + "', got " + (typeof properties));
          }
          if (comp_count = Object.keys(properties).length === 0) {
            throw new Error("Expected component(s) on slot '" + name + "', got none");
          }
          if (!component._module.slots[name].isRepeated && comp_count > 1) {
            throw new Error("Slot '" + name + "' can only accept 1 component, got " + comp_count);
          }
          for (slot_selector in val) {
            slot_properties = val[slot_selector];
            component.fillSlot(name, build_recursive(slot_selector, slot_properties, template));
          }
        } else {
          throw new Error("No slot named '" + name + "' exists on module '" + component_name + "'");
        }
      }
      if (jsvar != null) {
        template.addComponentVariable(jsvar, component);
      }
      if (top_level) {
        return template;
      } else {
        return component;
      }
    };
    single_key = Object.keys(json)[0];
    return build_recursive(single_key, json[single_key]);
  };

}).call(this);
(function() {
  new window.SUITE.ModuleBuilder("visible-element").addProperty("id", [SUITE.PrimitiveType.String], "", function(val, setAttrs) {
    return setAttrs({
      "id": val
    });
  }).addProperty("class", [SUITE.PrimitiveType.String], "", function(val, setAttrs) {
    return setAttrs({
      "class": val
    });
  }).addProperty("x", [SUITE.PrimitiveType.Number], 0, function(val, setAttrs) {
    return setAttrs({
      "left": val + "px"
    });
  }).addProperty("y", [SUITE.PrimitiveType.Number], 0, function(val, setAttrs) {
    return setAttrs({
      "top": val + "px"
    });
  }).addProperty("width", [SUITE.PrimitiveType.Number], 0, function(val, setAttrs) {
    return setAttrs({
      "width": val + "px"
    });
  }).addProperty("height", [SUITE.PrimitiveType.Number], 0, function(val, setAttrs) {
    return setAttrs({
      "height": val + "px"
    });
  }).setRenderer(function() {
    var div;
    div = document.createElement("div");
    if (window.SUITE.config.component_attribute) {
      div.setAttribute("data-component", this.type);
    }
    if (this.$id !== "") {
      div.setAttribute("id", this.$id);
    }
    if (this.$class !== "") {
      div.setAttribute("class", this.$class);
    }
    div.style.left = this.$x + "px";
    div.style.top = this.$y + "px";
    div.style.width = this.$width + "px";
    div.style.height = this.$height + "px";
    return div;
  }).register();

}).call(this);
(function() {
  new window.SUITE.ModuleBuilder("container").extend("visible-element").addSlot("children", true).addMethod("addChild", function(child) {
    return this.fillSlot("children", child);
  }).addProperty("fill", [SUITE.PrimitiveType.Color], "none", function(val, setAttrs) {
    return setAttrs({
      backgroundColor: val
    });
  }).setRenderer(function(slots, super_mod) {
    var div, slot, _i, _len, _ref;
    div = super_mod.render.call(this, slots, super_mod["super"]);
    div.style.backgroundColor = this.$fill;
    _ref = slots.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      slot = _ref[_i];
      div.appendChild(slot);
    }
    return div;
  }).setOnResize(function(size) {
    var slot, _i, _len, _ref, _results;
    this.$width = size.width;
    this.$height = size.height;
    _ref = this.slots.children;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      slot = _ref[_i];
      _results.push(slot.resize(size));
    }
    return _results;
  }).register();

}).call(this);
(function() {
  new window.SUITE.ModuleBuilder("dialog-container").extend("container").addSlot("dialog", false, function(type) {
    return type === "dialog";
  }).addProperty("overlayColor", [SUITE.PrimitiveType.Color], "black", function(val, setAttrs) {
    if (displayed) {
      return setAttrs(this.overlay_container, {
        backgroundColor: val
      });
    }
  }).addProperty("overlayOpacity", [SUITE.PrimitiveType.Number], 0.6, function(val, setAttrs) {
    if (displayed) {
      return setAttrs(this.overlay_container, {
        opacity: val
      });
    }
  }).addProperty("displayed", [SUITE.PrimitiveType.Boolean], false, function(val, setAttrs, oldval) {
    var dc, dialog, oc;
    if (oldval === val) {
      return;
    }
    if (val) {
      if (this.slots.dialog == null) {
        this._values.displayed = false;
        return;
      }
      dialog = this.slots.dialog;
      oc = this.overlay_container = document.createElement("div");
      oc.style.top = 0;
      oc.style.left = 0;
      oc.style.width = this.width + "px";
      oc.style.height = this.height + "px";
      oc.style.zIndex = 899;
      setAttrs(oc, {
        backgroundColor: this.$overlayColor,
        opacity: this.$overlayOpacity
      });
      dc = this.dialog_container = dialog.render();
      dc.style.width = dialog.width + "px";
      dc.style.height = dialog.height + "px";
      dc.style.left = this.width / 2 - dialog.width / 2 + "px";
      dc.style.top = this.height / 2 - dialog.height / 2 + "px";
      dc.style.zIndex = 900;
      dc.style.opacity = 0;
      setAttrs(dc, {
        opacity: 1
      });
      this.element.appendChild(oc);
      return this.element.appendChild(dc);
    } else {
      this.overlay_container.parentNode.removeChild(this.overlay_container);
      return this.dialog_container.parentNode.removeChild(this.dialog_container);
    }
  }).addMethod("hideDialog", function() {
    return this.$displayed = false;
  }).addMethod("showDialog", function(dialog) {
    if ((dialog != null) && this.fillSlot("dialog", dialog) === -1) {
      return;
    }
    return this.$displayed = true;
  }).setRenderer(function(slots, superclass) {
    var div;
    div = superclass.render.call(this, slots, superclass["super"]);
    if (this.$displayed) {
      this._values.displayed = false;
      wait(1, function() {
        return this.$displayed = true;
      });
    }
    return div;
  }).setOnResize(function(size) {
    var dialog, slot, _i, _len, _ref;
    this.$width = size.width;
    this.$height = size.height;
    _ref = this.slots.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      slot = _ref[_i];
      slot.resize(size);
    }
    if (this.$displayed) {
      dialog = this.slots.dialog;
      dialog.resize(size);
      this.overlay_container.style.width = size.width + "px";
      this.overlay_container.style.height = size.height + "px";
      this.dialog_container.style.width = dialog.width + "px";
      this.dialog_container.style.height = dialog.height + "px";
      this.dialog_container.style.left = size.width / 2 - dialog.width / 2 + "px";
      return this.dialog_container.style.top = size.height / 2 - dialog.height / 2 + "px";
    }
  }).register();

  new window.SUITE.ModuleBuilder("dialog").extend("container").removeProperty("x").removeProperty("y").addProperty("minWidth", [SUITE.PrimitiveType.Number], 0).addProperty("minHeight", [SUITE.PrimitiveType.Number], 0).setGetWidth(function() {
    return parseInt(Math.max(Math.min(this._containerX || 999999, this.$width), this.$minWidth));
  }).setGetHeight(function() {
    return parseInt(Math.max(Math.min(this._containerY || 999999, this.$height), this.$minHeight));
  }).setOnResize(function(size) {
    this._containerX = size.width;
    return this._containerY = size.height;
  }).register();

}).call(this);
