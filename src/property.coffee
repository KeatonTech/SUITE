# Represents a property of a component that can be changed at runtime
class window.SUITE.Property
  constructor: (type, default_val, setter)->
    # Simpler property construction
    if typeof @type is 'array'
      @type = window.SUITE.Type.apply @type

    if type instanceof window.SUITE.Type and type.component?
      return window.SUITE.ComponentProperty(type, setter)

    @type = type
    @default = default_val

    # Properties with setters won't trigger re-renders
    if setter? then @setter = setter

  copy: ()-> return new window.SUITE.Property(@type, @default, @setter)


# Property that holds a function
class window.SUITE.EventListenerProperty extends window.SUITE.Property
  constructor: (listener, element_name, setter, default_val) ->
    super SUITE.PrimitiveType.Function, default_val, setter
    @listener = listener
    @element = element_name

  copy: ()->
    copy = super()
    copy.listener = @listener
    copy.element = @element
    return copy


# A special kind of property that responds to events from the bound component.
# Can also accept an array of components. The handlers will be applied to all of them.
class window.SUITE.ComponentProperty
  constructor: (type, handlers = {})->
    @type = type
    @handlers = handlers

  addHandler: (event, func)->
    if !@handlers[event]? then @handlers[event] = []
    @handlers[event].push func

  copy: ()->
    handlers_copy = {}
    handlers_copy[e] = h for e,h of @handlers
    new SUITE.ComponentProperty @type, handlers_copy


# Slots are a special kind of component property that imply that the component is a child of
# the owner. A component can only be in one slot at once, but it can be linked to multiple
# component properties. Slots can be configured to accept multiple components.
class window.SUITE.Slot extends window.SUITE.ComponentProperty
  constructor: (isRepeated, component_type, handlers)->
    @isRepeated = isRepeated
    @componentType = component_type

    primative = SUITE.PrimitiveType
    if @isRepeated
      type = new SUITE.Type primative.Component, primative.List, component_type
    else
      type = new SUITE.Type primative.Component, primative.Single, component_type
    super type, handlers

  # Slots can reject components even if they match the given type
  allowComponent: (component)-> return true

  copy: ()->
    handlers_copy = {}
    handlers_copy[e] = h for e,h of @handlers
    new SUITE.Slot @isRepeated, @componentType, handlers_copy
