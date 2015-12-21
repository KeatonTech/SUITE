# Modules can use these functions to modify aspects of the component. The API is passed into
# module functions as 'this'.
class window.SUITE.ModuleAPI
  constructor: (component) ->
    @_ = component
    @_bindSlots()

    # Copy in the property objects
    for name in Object.getOwnPropertyNames(@_) when name[0] is "$"
      Object.defineProperty @, name,
        get: @_getComponentProperty.bind this, name
        set: @_setComponentProperty.bind this, name

    # Add custom methods from the module
    for name, func of @_._module.methods
      @[name] = @_[name]

    Object.defineProperty @, "size", get: ()-> return {width: @$width, height: @$height}
    Object.defineProperty @, "rootElement", get: ()-> return @_._rootElement

  # Passthrough
  resize: ()-> @_.resize.apply @_, arguments
  render: ()-> @_.render.apply @_, arguments
  rerender: ()-> @_.rerender.apply @_, arguments
  unrender: ()-> @_.unrender.apply @_, arguments
  dispatchEvent: ()-> @_._dispatchEvent.apply @_, arguments
  hasPropertyValue: ()-> @_.hasPropertyValue.apply @_, arguments
  fillSlot: ()-> @_.fillSlot.apply @_, arguments
  insertSlotComponent: ()-> @_.insertSlotComponent.apply @_, arguments
  removeSlotComponent: ()-> @_.removeSlotComponent.apply @_, arguments
  emptySlot: ()-> @_.emptySlot.apply @_, arguments
  allSlotComponents: ()-> @_.allSlotComponents.apply @_, arguments
  allSubComponents: ()-> @_.allSubComponents.apply @_, arguments
  addHandler: ()-> @_.addHandler.apply @_, arguments
  addHandlerBinding: ()-> @_._addHandlerBinding.apply @_, arguments


  # Prepares the API for use with the latest values
  _prepare: (super_module, super_function_name) ->
    @_prepareAttrSetter()
    @_setSuper super_module, super_function_name

    # Return a cleanup function after the API has been used
    return @_clearSuper

  _prepareAttrSetter: ()->
    @setAttrs = SUITE.AttrFunctionFactory(@_._rootElement, SUITE._currentTransition)
    @forceAttrs = SUITE.AttrFunctionFactory(@_._rootElement) # Supresses animation

  # SIMPLE INHERITANCE ======================================================================

  _setSuper: (super_module, function_name)->
    if !super_module? then @super = ()->

    @_super_module = super_module
    @_super_func = @_super_module[function_name]
    @_super_func_name = function_name

    @super = ()->
      run = @_super_func
      oldmod = @_super_module

      # Move up a level so if this new function calls super it'll still work
      @_super_module = @_super_module?.super
      @_super_func = @_super_module?[function_name]

      # Run the superfunction
      if run? then result = run.apply this, arguments

      # Move back up to the correct level
      @_super_module = oldmod
      @_super_func = run

      # Makes things work nice
      if function_name is "render" then @_._rootElement = result

      return result

  _clearSuper: ()-> @super = undefined

  supermodule: (class_name, args...)->
    if !@_super_module? or !@_super_func? or !@_super_func_name? then return undefined

    backup_module = @_super_module
    backup_function = @_super_func

    while @_super_module? and @_super_module.name isnt class_name
      @_super_module = @_super_module.super
      @_super_func = @_super_module?[@_super_func_name]

    # Run the super function if possible
    if @_super_module? and @_super_func?
      result = @_super_func.apply this, args
      if @_super_func_name is "render" then @_._rootElement = result

    @_super_module = backup_module
    @_super_func = backup_function
    return result

  # HELPER FUNCTIONS ========================================================================

  isRendered: ()-> return @_._rootElement?

  # Useful for preventing infinite loops
  setPropertyWithoutSetter: (name, val) ->
    @_._values[name] = val

  # Getter and setter functions
  _getComponentProperty: (name, val)-> @_[name]
  _setComponentProperty: (name, val)-> @_[name] = val

  # STORED HTML ELEMENTS ====================================================================

  appendElement: (root_or_element, element)->
    if element?
      if typeof element is "string" then element = @getElement element
      root_or_element.appendChild element
    else
      if typeof root_or_element is "string"
        root_or_element = @getElement root_or_element
      @_._rootElement.appendChild root_or_element

  removeElement: (name_or_element)->
    if typeof name_or_element is "string" then name_or_element = @getElement name_or_element
    if !name_or_element? then return
    name_or_element.parentNode?.removeChild name_or_element

  createElement: (elementName_or_tagName, tagName)->
    if !tagName? then return document.createElement elementName_or_tagName
    return @_._elements[elementName_or_tagName] = document.createElement tagName

  setElement: (name, element) -> @_._elements[name] = element
  getElement: (name) -> return @_._elements[name]

  applyStyle: (element, style_name) ->
    style = @_._module.styles[style_name]
    if !style? then return false
    style.applyToElement @_, element
    return true

  # SLOTS ===================================================================================

  renderSlot: (slot_or_name, slot)->
    if slot? then @_._elements[slot_or_name] = slot.render()
    else slot_or_name.render()

  _lazySlotAPI: (slot_container, name, slot)->
    Object.defineProperty slot_container, name,
      configurable: true
      get: ()->
        Object.defineProperty this, name,
          get: undefined
        Object.defineProperty this, name,
          value: slot._api
        return slot._api

  # Sometimes the slots themselves haven't been resolved on the parent yet
  _lazySlot: (name)->
    Object.defineProperty @slots, name,
      configurable: true
      get: ()=>

        # This will create the slot if it hasn't been created already
        slot = @_.slots[name]

        Object.defineProperty @slots, name,
          get: undefined
        Object.defineProperty @slots, name,
          value: undefined
          writable: true

        if slot instanceof Array
          sc = @slots[name] = []
          @_lazySlotAPI(sc, i, s) for i,s of slot
        else
          @_lazySlotAPI(@slots, name, slot)

        return @slots[name]

  _bindSlots: ()->
    # Lazy loading prevents slot APIs from being created until they're required
    @slots = {}

    for name in Object.getOwnPropertyNames(@_.slots)
      if Object.getOwnPropertyDescriptor(@_.slots, name).get?
        @_lazySlot(name)
      else
        slot = @_.slots[name]
        if slot instanceof Array
          sc = @slots[name] = []
          @_lazySlotAPI(sc, i, s) for i,s of slot
        else
          @_lazySlotAPI(@slots, name, slot)


  # COMPONENTS ==============================================================================

  createComponent: (type_name)-> return new SUITE.Component type_name
