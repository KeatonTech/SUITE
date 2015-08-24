# Represents a property of a component that can be changed at runtime
class window.SUITE.Property
  constructor: (type, default_val, setter)->
    # Simpler property construction
    if typeof @type is 'array'
      @type = window.SUITE.Type.apply @type

    if type instanceof window.SUITE.Type and type.component?
      return window.SUITE.ComponentProperty(name, type, default_val, setter)

    @type = type
    @default = default_val

    # Properties with setters won't trigger re-renders
    if setter? then @setter = setter


# A special kind of property that responds to events from the bound component.
# Can also accept an array of components. The handlers will be applied to all of them.
class window.SUITE.ComponentProperty
  constructor: (type, handlers)->
    @type = type
    {
      @onMove,    # Called when the component changes position within its parent
      @onShift,   # Called when the component changes position on the screen
      @onResize,  # Called when the component changes size
      @onChange,  # Called when the internal markup of the component changes
      @onRender,  # Called when the component is finished generating new HTML
      @onHide,    # Called after the component is removed from the layout tree
      @onShow     # Called when the component is added to the layout tree
      @onAdd,     # Called when a component is added to this property
      @onRemove,  # Called when a component is removed from this property
      # NOTE: For single (non-array) component properties, setting them to a different
      # component calls onRemove and then onAdd
    } = handlers

  addHandler: (name, func)->
    switch name.toLowerCase()
      when "onmove" or "move" or "moved" then handler = "onMove"
      when "onshift" or "shift" or "shifted" then handler = "onShift"
      when "onresize" or "resize" or "resized" then handler = "onResize"
      when "onchange" or "change" or "changed" then handler = "onChange"
      when "onrender" or "render" or "rendered" then handler = "onRender"
      when "onhide" or "hide" or "hid" then handler = "onHide"
      when "onshow" or "show" or "shown" then handler = "onShow"
      when "onadd" or "add" or "added" then handler = "onAdd"
      when "onremove" or "remove" or "removed" then handler = "onRemove"
      else return

    if this[handler]?
      if !(this[handler] instanceof Array) then this[handler] = [this[handler]]
      this[handler].push func
    else this[handler] = func


# Slots are a special kind of component property that imply that the component is a child of
# the owner. A component can only be in one slot at once, but it can be linked to multiple
# component properties. Slots can be configured to accept multiple components.
class window.SUITE.Slot extends window.SUITE.ComponentProperty
  constructor: (isRepeated, component_type, handlers)->
    @isRepeated = isRepeated

    primative = SUITE.PrimitiveType
    if @isRepeated
      type = new SUITE.Type primative.Component, primative.List, component_type
    else
      type = new SUITE.Type primative.Component, primative.Single, component_type
    super "", type, handlers

  # Slots can reject components even if they match the given type
  allowComponent: (component)-> return true
