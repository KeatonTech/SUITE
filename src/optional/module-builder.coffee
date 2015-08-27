# Helper methods for building modules essentially in one line
class window.SUITE.ModuleBuilder
  constructor: (name)->
    @module = new window.SUITE.Module(name)
  build: ()-> return @module
  register: ()-> window.SUITE.registerModule @module

  addProperty: (name_or_property, type, default_val, setter)->
    @module.addProperty name_or_property, type, default_val, setter
    return this

  # Only necessary when used with copyFrom
  removeProperty: (name)->
    if @module.properties[name] then delete @module.properties[name]
    return this

  setPropertySetter: (name, setter) ->
    @module.properties[name].setter = setter
    return this

  addSlot: (name, isRepeated = false, allowType)->
    @module.addSlot name, new window.SUITE.Slot(isRepeated)
    if allowType? then @module.slots[name].allowType = allowType
    return this

  addSlotFromClass: (name, slot)->
    @module.addSlot name, slot
    return this

  addEventListener: (event, func) ->
    @module.addEventListener event, func
    return this

  addMethod: (name, func) ->
    @module.addMethod name, func
    return this

  addStyle: (name, attributes)->
    style = new SUITE.Style name, attributes
    @module.addStyle name, style
    return this

  # Only necessary when used with copyFrom
  removeStyle: (name)->
    if @module.styles[name] then delete @module.styles[name]
    return this

  setRenderer: (renderFunction)->
    @module.render = renderFunction
    return this

  setInitializer: (initializeFunction)->
    @module.initialize = initializeFunction
    return this

  setOnResize: (resizedFunction)->
    @module.onResize = resizedFunction
    return this

  extend: (module_name)->
    @module.extend module_name
    return this
