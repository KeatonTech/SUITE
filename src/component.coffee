# Represents an instance of a VUE component
class window.SUITE.Component
  constructor: (module_or_name)->
    @parent = undefined           # Parent component

    @_rootElement = undefined     # Rendered HTML element
    @_elements = {}               # Stores named HTML elements rendered by this module
    @_varname = undefined         # Stores this component's template variable name

    if module_or_name instanceof window.SUITE.Module
      @_module = module_or_name
      @type = module_or_name.name
    else
      name = module_or_name.toLowerCase()
      @_module = window.SUITE.modules[name]
      @type = name

    # Sets up bindings for each declared property
    @_setupPropertyBindings()

    # Other special properties
    Object.defineProperty this, "width",
      get: ()-> @_module.getWidth?.call(@_api) || parseInt @_rootElement.offsetWidth

    Object.defineProperty this, "height",
      get: ()-> @_module.getHeight?.call(@_api) || parseInt @_rootElement.offsetHeight

    # Add empty arrays for repeated slots
    @slots = {}
    for name, slot of @_module.slots when slot.isRepeated
      @slots[name] = []

    # Create an instance of the Module API, which allows the owner module to interact with
    # this component in an easy but safe way.
    @_api = new SUITE.ModuleAPI this

    # Add custom methods from the module
    for name, func of @_module.methods
      @[name] = func.bind @_api

  copy: ()->
    copy = new SUITE.Component @type
    copy.parent = @parent
    copy._module = @_module
    copy._varname = @_varname
    copy._values[k] = v for k,v of @_values

    for k, slot_contents of @slots
      if slot_contents instanceof Array
        copy.slots[k] = (s.copy() for s in slot_contents)
      else
        copy.slots[k] = slot_contents.copy()

    return copy

  # PROPERTIES ==============================================================================

  # Internal function sets up bindings for each declared property
  _setupPropertyBindings: ()->
    @_values = {}
    for name,p of @_module.properties
      if !name? then continue
      @_values[name] = p.default
      Object.defineProperty this, "$#{name}",
        get: ((_this, name)->()-> return _this._values[name])(this, name)
        set:
          ((name, p)=>
            if p.setter? then (val)=>
              oldval = @_values[name]
              @_values[name] = val
              if !@_rootElement? then return
              @_api._prepareAttrSetter()
              p.setter.call @_api, val, oldval
            else (val)=>
              @_values[name] = val
              @rerender()
          )(name, p)

  # Checks to see if a component has a property
  hasPropertyValue: (name)-> return @_module.properties[name]?

  # SLOTS ===================================================================================

  # Fills a slot with another component
  fillSlot: (slotName, component)->
    if !(slot_class = @_module.slots[slotName])? then return -1
    if component instanceof SUITE.Template then component = component._component
    if !slot_class.allowComponent(component) then return -1
    component.parent = this

    index = 0
    if slot_class.isRepeated
      if !(slotName in @slots) then @slots[slotName] = []
      index = @slots.length
      @slots[slotName].push component
      @_api.slots[slotName].push component._api
    else
      @slots[slotName] = component
      @_api.slots[slotName] = component._api

    @rerender()
    return index # 0 for non-repeated slots

  # Remove a specific component in a repeated slot
  removeSlotComponent: (slotName, index)->
    if !(slotName in @slots) then return false
    if !(@slots[slotName] instanceof Array) then return false
    @slots[slotName][index].parent = undefined
    @slots[slotName].splice index, 1
    @_api.slots[slotName].splice index, 1
    return true

  # Remove all components in a slot
  emptySlot: (slotName)->
    if !(slotName in @slots) then return
    if @slots[slotName] instanceof Array
      slot.parent = undefined for slot in @slots[slotName]
    else
      @slots[slotName].parent = undefined
    delete @slots[slotName]
    delete @_api.slots[slotName]
    @rerender()

  # List all 'child' elements in any slot
  allSlotComponents: ()->
    all = []
    for k, slot_contents of @slots
      if slot_contents instanceof Array
        if slot_contents.length is 0 then continue
        Array.prototype.push.apply(all, slot_contents)
      else
        all.push slot_contents
    return all

  # List all child components including children of children
  allSubComponents: ()->
    all = []
    for c in @allSlotComponents()
      all.push c
      Array.prototype.push.apply(all, c.allSubComponents())
    return all

  # HTML GENERATION =========================================================================

  render: ()->
    if !@_module.render? then return

    # Run the module's render function with the appropriate super function
    cleanup = @_api._prepare @_module.super, "render"
    @_rootElement = @_module.render.call @_api, @slots
    cleanup()

    @bindEventListeners()
    return @_rootElement

  rerender: ()->
    if !@_rootElement? then return
    olddom = @_rootElement
    @render()
    olddom.parentNode.insertBefore @_rootElement, olddom
    olddom.parentNode.removeChild olddom
    return @_rootElement

  # EVENT HANDLERS ==========================================================================

  # Resize events
  resize: (size)->
    if !@_module.onResize? then return
    @_api._prepareAttrSetter()
    @_module.onResize.call @_api, size

  # Other events
  bindEventListeners: ()->
    for name, func of @_module.events
      @_rootElement.addEventListener name, func.bind this
