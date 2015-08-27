# Represents a module that provides a component
class window.SUITE.Module
  constructor: (name, extend_name, properties = {}, slots = {})->

    # Essentially the tag name of the generated components, like "dialog-container"
    @name = name.toLowerCase()

    # A map of settable properties that determine the style and content of the component
    @properties = properties

    # A map of slot objects that describe where children elements can go
    @slots = slots

    # Event handlers for SUITE events (different from HTML events)
    @handlers = {}

    # Additional functions that components of this type can perform
    @methods = {}

    # Styles that can be applied to generated HTML elements inside the component
    @styles = {}

    # Extend this module from another module
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

  addStyle: (name, style) ->
    @styles[name] = style
    # Namespaced version, so access to parent styles is never lost
    @styles["#{@name}.#{name}"] = style

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
      @handlers[name] = m
    for name, s of existingModule.styles
      @styles[name] = s

    if !@render? then @render = existingModule.render
    if !@onResize? then @onResize = existingModule.onResize
    if !@getWidth? then @getWidth = existingModule.getWidth
    if !@getHeight? then @getHeight = existingModule.getHeight


  # OVERRIDE THESE FUNCTIONS ================================================================

  # Sets up any properties or variables needed to make the component work
  initialize: ()-> return @super()

  # Returns the text of the SVG markup
  # By default calls the render function of the module's superclass
  render: ()-> return @super()

  # Allows property values to be changed when the component is resized.
  # Return true to indicate that a re-render is necessary
  onResize: (size)-> slot.resize(size) for slot in @allSlotComponents()

# Module adding helper functions
window.SUITE.newModule = (name)->
  name = name.toLowerCase()
  return window.SUITE.modules[name] = new window.SUITE.Module(name)

window.SUITE.registerModule = (module)->
  window.SUITE.modules[module.name] = module
