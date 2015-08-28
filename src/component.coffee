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

    # Add empty arrays for repeated slots
    @slots = {}
    for name, slot of @_module.slots when slot.isRepeated
      @slots[name] = []

    # Add custom methods from the module
    for name, func of @_module.methods
      @[name] = ((func)=> ()=>
        @_api._prepareAttrSetter()
        func.apply @_api, arguments
      )(func)

    # Add handlers from the module
    @_handlers = {}
    for event, func of @_module.handlers
      @addHandler event, func

    # Prepare for property change listeners
    @_changeListeners = {}

    # Create an instance of the Module API, which allows the owner module to interact with
    # this component in an easy but safe way.
    @_api = new SUITE.ModuleAPI this

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
              @_runPropertyChangeListeners name, val, oldval
            else (val)=>
              oldval = @_values[name]
              @_values[name] = val
              @_api._prepareAttrSetter()
              @_runPropertyChangeListeners name, val, oldval
          )(name, p)

  # Runs property change listeners
  _runPropertyChangeListeners: (property_name, val, oldval)->
    if @_changeListeners[property_name]?
      listener.call(@_api, val, oldval) for listener in @_changeListeners[property_name]
      return true
    return false

  # Adds a change listener that runs whenever a property value is changed
  addPropertyChangeListener: (property_name, func)->
    if !@_changeListeners[property_name]? then @_changeListeners[property_name] = []
    @_changeListeners[property_name].push func

  # Checks to see if a component has a property
  hasPropertyValue: (name)-> return @_module.properties[name]?


  # SLOTS ===================================================================================

  # Fills a slot with another component
  fillSlot: (slotName, component)->
    if !(slot_class = @_module.slots[slotName])? then return -1
    if component instanceof SUITE.Template then component = component._component
    if !slot_class.allowComponent(component) then return -1
    component.parent = this
    component.bindToComponentProperty this, slot_class

    index = 0
    if slot_class.isRepeated
      if !(slotName in @slots) then @slots[slotName] = []
      index = @slots.length
      @slots[slotName].push component
      @_api.slots[slotName].push component._api
    else
      if @slots[slotName]?
        @slots[slotName].unbindFromComponentProperty slot_class
      @slots[slotName] = component
      @_api.slots[slotName] = component._api

    @rerender()
    return index # 0 for non-repeated slots

  # Remove a specific component in a repeated slot
  removeSlotComponent: (slotName, index)->
    if !(slot_class = @_module.slots[slotName])? then return -1
    if !(@slots[slotName] instanceof Array) then return false
    @slots[slotName][index].parent = undefined
    @slots[slotName][index].unbindFromComponentProperty slot_class
    @slots[slotName].splice index, 1
    @_api.slots[slotName].splice index, 1
    return true

  # Remove all components in a slot
  emptySlot: (slotName)->
    if !(slot_class = @_module.slots[slotName])? then return -1
    if @slots[slotName] instanceof Array
      for slot in @slots[slotName]
        slot.parent = undefined
        slot.unbindFromComponentProperty(slot_class)
    else
      @slots[slotName].parent = undefined
      @slots[slotName].unbindFromComponentProperty(slot_class)
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


  # EVENT HANDLERS ==========================================================================

  # Add a handler for a SUITE event (different from HTML events, see events.coffee)
  addHandler: (event, func) ->
    if !@_handlers[event]? then @_handlers[event] = []
    if func instanceof Array
      @_handlers[event].push(f) for f in func
    else
      @_handlers[event].push func

  removeHandler: (event, func) ->
    if !@_handlers[event]? then @_handlers[event] = []
    @_handlers[event].filter (h)-> h != func

  # Add all handlers in a ComponentProperty
  bindToComponentProperty: (component, property)->
    console.log property

    # Handlers are bound to the api of the
    boundHandler = (func)-> ()->
      component._api._prepareAttrSetter()
      args = (a for a in arguments) # ArgumentsList -> Array
      if args? then args.unshift this else args = [this]
      func.apply component._api, args

    for type, handler_s of property.handlers
      if handler_s instanceof Array
        @addHandler type, boundHandler(s) for s in handler_s
      else
        @addHandler type, boundHandler(handler_s)

  # Add all handlers in a ComponentProperty
  unbindFromComponentProperty: (property)->
    for type, handler_s of property.handlers
      if handler_s instanceof Array
        @removeHandler type, s for s in handler_s
      else
        @removeHandler type, handler_s

  # Dispatch an event by calling all registered handlers
  _dispatchEvent: (event, args)->
    if !@_handlers[event]? then return
    if !(args instanceof Array) then args = [args]
    handler.apply(@_api,args) for handler in @_handlers[event]


  # HTML GENERATION =========================================================================

  render: (first_render = true)->
    if !@_module.render? then return

    # If this is the first render, initialize the component
    if first_render
      cleanup = @_api._prepare @_module.super, "initialize"
      @_module.initialize.call @_api
      cleanup()

    # Run the module's render function with the appropriate super function
    cleanup = @_api._prepare @_module.super, "render"
    @_rootElement = @_module.render.call @_api, @slots
    cleanup()

    return @_rootElement

  rerender: ()->
    if !@_rootElement? then return
    olddom = @_rootElement
    @render(false)
    olddom.parentNode.insertBefore @_rootElement, olddom
    olddom.parentNode.removeChild olddom
    return @_rootElement

  # Call the module's onResize function to update the HTML
  resize: (size)->
    if !@_module.onResize? then return
    cleanup = @_api._prepare @_module.super, "onResize"
    @_module.onResize.call @_api, size
    cleanup()
