# Very simple type system, to control the binding
# Technically Boolean, Number and String are all treated the same by the system
window.SUITE.PrimitiveType = {
  # Basic Types
  'Boolean': 1
  'String': 2
  'Color': 3
  'Component': 4
  'Number': 8

  # This will come in handy later, probably
  ## Unitted Types (Subclass of Number)
  #'px': 9
  #'pt': 10
  #'em': 11
  #'percent': 12
  #'vw': 17
  #'vh': 18
  #'vmin': 19
  #'vmax': 20

  # Container Types
  'Single': 0
  'List': 32
  'Object': 96
}

# Types like component links need more data than a single number can handle
# This class either constructs a primative type or a full type object depending on input
class window.SUITE.Type
  constructor: (type, container = window.SUITE.PrimitiveType.Single, component_type)->
    pt = window.SUITE.PrimitiveType
    typenum = type & container
    if type is pt.Component and component_type?
      @component = component_type
      @num = typenum
    else
      return typenum
