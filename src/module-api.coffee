# Modules can use these functions to modify aspects of the component. The API is passed into
# module functions as 'this'.
class window.SUITE.ModuleAPI
  constructor: (component) ->
    @_ = component

    @slots = {}
    for name, slot of @_.slots
      if slot instanceof Array
        @slots[name] = (s._api for s in slot)
      else
        @slots[name] = slot._api

    # Copy in the property objects
    for name, property of @_._module.properties
      prefixed = "$" + name
      Object.defineProperty @, prefixed, Object.getOwnPropertyDescriptor @_, prefixed

    # Add custom methods from the module
    for name, func of @_._module.methods
      @[name] = @_[name]

    Object.defineProperty @, "size", get: ()-> return {width: @$width, height: @$height}
    Object.defineProperty @, "rootElement", get: ()-> return @_._rootElement

    # Passthrough
    @resize = @_.resize.bind @_
    @render = @_.render.bind @_
    @rerender = @_.rerender.bind @_
    @unrender = @_.unrender.bind @_
    @dispatchEvent = @_._dispatchEvent.bind @_
    @hasPropertyValue = @_.hasPropertyValue.bind @_
    @fillSlot = @_.fillSlot.bind @_
    @removeSlotComponent = @_.removeSlotComponent.bind @_
    @emptySlot = @_.emptySlot.bind @_
    @allSlotComponents = @_.allSlotComponents.bind @_
    @allSubComponents = @_.allSubComponents.bind @_


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

  setPropertyWithoutSetter: (name, val) ->
    @_._values[name] = val

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
    name_or_element.parentNode.removeChild name_or_element

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

  # COMPONENTS ==============================================================================

  createComponent: (type_name)-> return new SUITE.Component type_name
