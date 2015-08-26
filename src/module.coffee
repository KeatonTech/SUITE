# Represents a module that provides a component
class window.SUITE.Module
  constructor: (name, extend_name, properties = {}, slots = {})->
    @name = name.toLowerCase()
    @properties = properties
    @slots = slots
    @handlers = {}
    @methods = {}
    if extend_name? then @extend extend_name

  addProperty: (name, type_or_property, default_val, setter)->
    if type_or_property instanceof window.SUITE.Property
      return @properties[name] = type_or_property
    @properties[name] = new window.SUITE.Property(type_or_property, default_val, setter)

  addSlot: (name, slot = new window.SUITE.Slot(false))->
    @slots[name] = slot

  addHandler: (event, func) ->
    @handlers[event] = func

  addMethod: (name, func) ->
    if window.SUITE.Component.prototype.hasOwnProperty(name)
      console.log "Method name '#{name}' is already taken by an internal component function"
      return
    @methods[name] = func

  # Module inheritance
  extend: (existingModuleName)->
    @super = existingModule = SUITE.modules[existingModuleName]

    for name, p of existingModule.properties
      @properties[name] = p
    for name, s of existingModule.slots
      @slots[name] = s
    for name, e of existingModule.events
      @events[name] = e
    for name, m of existingModule.handlers
      @module.handlers[name] = m

    if !@render? then @render = existingModule.render
    if !@onResize? then @onResize = existingModule.onResize
    if !@getWidth? then @getWidth = existingModule.getWidth
    if !@getHeight? then @getHeight = existingModule.getHeight


  # OVERRIDE THESE FUNCTIONS ================================================================

  # Returns the text of the SVG markup
  # By default calls the render function of the module's superclass
  render: ()-> return @super()

  # Allows property values to be changed when the component is resized.
  # Return true to indicate that a re-render is necessary
  onResize: (size)-> return false

  # YOU MAY ALSO OVERRIDE THESE =============================================================

  # Returns the width of the module
  # getWidth: () -> @element.offsetWidth

  # Returns the height of the module
  # getHeight: () -> @element.offsetHeight

# Module adding helper functions
window.SUITE.newModule = (name)->
  name = name.toLowerCase()
  return window.SUITE.modules[name] = new window.SUITE.Module(name)

window.SUITE.registerModule = (module)->
  window.SUITE.modules[module.name] = module
