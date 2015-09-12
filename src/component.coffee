# Represents an instance of a VUE component
class window.SUITE.Component
  constructor: (module_or_name)->
    @parent = undefined           # Parent component

    @_rootElement = undefined     # Rendered HTML element
    @_elements = {}               # Stores named HTML elements rendered by this module
    @_varname = undefined         # Stores this component's template variable name

    @_initialized = false         # Whether initialize() has run

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
    @_handlerBindings = {}
    for event, func of @_module.handlers
      @addHandler event, func

    # Prepare for property change listeners
    @_changeListeners = {}

    # Create an instance of the Module API, which allows the owner module to interact with
    # this component in an easy but safe way.
    @_builtAPI = false
    Object.defineProperty this, "_api",
      configurable: true
      get: ()->
        @_builtAPI = true
        Object.defineProperty this, "_api",
          get: undefined
        Object.defineProperty this, "_api",
          value: new SUITE.ModuleAPI this
        return @_api

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
        get: @_getProperty.bind this, name
        set: @_setProperty.bind this, name, p

  # Internal function that retrieves a property value in a ridiculously simple way
  _getProperty: (name)-> return @_values[name]

  # Internal function that's called whenever a property changes
  _setProperty: (name, property, val)->
    oldval = @_values[name]
    @_values[name] = val
    if !@_rootElement? then return
    @_api._prepareAttrSetter()
    if property.setter? then property.setter.call @_api, val, oldval
    @_runPropertyChangeListeners name, val, oldval

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

  _prepareComponentForSlot: (slotName, component)->
    if !(slot_class = @_module.slots[slotName])? then return false

    # Allow for some flexibility
    if component instanceof SUITE.Template then component = component._component
    if component instanceof SUITE.ModuleAPI then component = component._

    if !slot_class.allowComponent(component) then return false
    component.parent = this
    component.bindToComponentProperty this, slot_class
    return component

  # Adds a getter function as a slot to defer templating of that slot.
  deferSlot: (slotName, func)->
    if !(slot_class = @_module.slots[slotName])? then return false
    @emptySlot slotName
    delete @slots[slotName]
    Object.defineProperty @slots, slotName,
      configurable: true
      get: ()=>
        Object.defineProperty @slots, slotName,
          get: undefined
          configurable: true
        Object.defineProperty @slots, slotName,
          value: if slot_class.isRepeated then [] else undefined
          writable: true

        components = func()
        if components instanceof Array
          @fillSlot(slotName, c) for c in components
        else @fillSlot slotName, components

        return @slots[slotName]

  # Fills a slot with another component
  fillSlot: (slotName, component)->
    if !(slot_class = @_module.slots[slotName])? then return false
    component = @_prepareComponentForSlot slotName, component
    if !component? then return -1

    index = 0
    if slot_class.isRepeated
      if !@slots[slotName]? then @slots[slotName] = []
      index = @slots.length
      @slots[slotName].push component
      if @_builtAPI and !Object.getOwnPropertyDescriptor(@_api.slots,slotName).get?
        @_api.slots[slotName].push component._api
      @_dispatchEvent "onAdd", [slotName, component, index]
    else
      if @slots[slotName]?
        @slots[slotName].unbindFromComponentProperty slot_class
      @slots[slotName] = component
      if @_builtAPI then @_api.slots[slotName] = component._api

    @_dispatchEvent "onSlotChange", [slotName]
    return index # 0 for non-repeated slots

  # Add to a repeated slot at a specific index
  insertSlotComponent: (slotName, index)->
    if !(slot_class = @_module.slots[slotName])? or !slot_class.isRepeated then return false

    component = @_prepareComponentForSlot slotName, component
    if !component? then return -1

    if !@slots[slotName]? then @slots[slotName] = []
    @slots[slotName].splice index, 0, component
    if @_builtAPI then @_api.slots[slotName].splice index, 0, component._api
    @_dispatchEvent "onAdd", [slotName, component, index]

  # Remove a specific component in a repeated slot
  removeSlotComponent: (slotName, index)->
    if !(slot_class = @_module.slots[slotName])? then return -1
    if !(@slots[slotName] instanceof Array) then return false
    @slots[slotName][index].parent = undefined
    @slots[slotName][index].unbindFromComponentProperty slot_class
    @slots[slotName].splice index, 1
    if @_builtAPI then @_api.slots[slotName].splice index, 1
    @_dispatchEvent "onRemove", [slotName, index]
    @_dispatchEvent "onSlotChange", [slotName]
    return true

  # Remove all components in a slot
  emptySlot: (slotName)->
    if !(slot_class = @_module.slots[slotName])? then return -1

    if @slots[slotName] instanceof Array
      for slot in @slots[slotName]
        slot.parent = undefined
        slot.unbindFromComponentProperty(slot_class)
        slot.unrender()
      @_dispatchEvent "onRemove", [slotName, -1]
      @slots[slotName] = []
      if @_builtAPI then @_api.slots[slotName] = []
    else
      if !@slots[slotName]? then return
      @slots[slotName].parent = undefined
      @slots[slotName].unbindFromComponentProperty(slot_class)
      delete @slots[slotName]
      if @_builtAPI then delete @_api.slots[slotName]

    @_dispatchEvent "onSlotChange", [slotName]

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

  # Add a handler for a SUITE event (different from HTML events)
  addHandler: (event, func) ->
    if !@_handlers[event]? then @_handlers[event] = []
    if func instanceof Array
      @_handlers[event].push(f) for f in func
    else
      @_handlers[event].push func

    # Allows modules to attach handlers to specific HTML elements
    if @_handlerBindings[event]?
      for [element, htmlEvent] in @_handlerBindings[event]
        element.addEventListener htmlEvent, func

  # Called by ModuleAPI, adds an HTMLElement that should be tied to specific handlers
  _addHandlerBinding: (element, htmlEvent, suiteEvent) ->
    if @_handlers[suiteEvent]?
      element.addEventListener(htmlEvent, h) for h in @_handlers[suiteEvent]
    if !@_handlerBindings[suiteEvent]? then @_handlerBindings[suiteEvent] = []
    @_handlerBindings[suiteEvent].push [element, htmlEvent]

  removeHandler: (event, func) ->
    if !@_handlers[event]? then @_handlers[event] = []
    @_handlers[event].filter (h)-> h != func

  # Add all handlers in a ComponentProperty
  bindToComponentProperty: (component, property)->

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
  _dispatchEvent: (event, args, propogateDown)->
    if @_handlers[event]?
      if !(args instanceof Array) then args = [args]
      handler.apply(@_api,args) for handler in @_handlers[event]

    if propogateDown
      for child in @allSlotComponents()
        child._dispatchEvent event, args, true


  # HTML GENERATION =========================================================================

  initialize: ()->
    @_initialized = true
    cleanup = @_api._prepare @_module.super, "initialize"
    @_module.initialize.call @_api
    cleanup()

  render: (first_render = true)->
    if !@_module.render? then return

    # If this is the first render, initialize the component
    if !@_initialized then @initialize()

    # Run the module's render function with the appropriate super function
    cleanup = @_api._prepare @_module.super, "render"
    @_rootElement = @_module.render.call @_api
    cleanup()

    if first_render then @_dispatchEvent "onShow"

    return @_rootElement

  rerender: ()->
    if !@_rootElement? then return
    olddom = @_rootElement
    @render(false)
    olddom.parentNode.insertBefore @_rootElement, olddom
    olddom.parentNode.removeChild olddom
    return @_rootElement

  unrender: ()->
    if !@_rootElement? then return
    if @_rootElement.parentNode?
      @_rootElement.parentNode.removeChild @_rootElement
    @_rootElement = undefined
    @_handlerBindings = {}
    @_dispatchEvent "onHide"
    for child in @allSlotComponents()
      child.unrender()

  # Call the module's onResize function to update the HTML
  resize: (size)->
    if !@_module.onResize? then return
    if !@_initialized then @initialize()
    cleanup = @_api._prepare @_module.super, "onResize"
    @_module.onResize.call @_api, size
    cleanup()
