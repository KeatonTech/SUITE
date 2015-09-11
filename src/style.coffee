# These attributes are unitless and therefore should not have 'px' appended to their values
window.SUITE.UnitlessAttributes = [
  "opacity",
  "zIndex",
  "fontWeight", "lineHeight",
  "counterIncrement", "counterReset",
  "flexGrow", "flexShrink",
  "volume", "stress", "pitchRange", "richness"
]

# Represents an inline stylesheet element (<style>) on the page.
class window.SUITE.StyleManager
  constructor: ()->

    # It's a singleton!
    if window.SUITE.styleManager? then return window.SUITE.styleManager
    window.SUITE.styleManager = this

    # Create a stylesheet element
    @element = document.createElement "style"
    @element.setAttribute "type", "text/css"
    document.head.appendChild @element

    # Track what styles have been added
    @styles = {}

  addStyle: (style_instance)->

    # Prevent duplicate styles from getting added
    if @styles[style_instance.id]? then return
    @styles[style_instance.id] = true

    # Add the style
    @element.innerHTML += style_instance.generateCSS()


# Represents a style, equivalent to one CSS rule (.selector{styles})
# SUITE Styles can have dynamic properties that involve object properties. These are
# automatically updated per-object when the property values they depend on change.
# Styles are applied to objects when they're created.
class window.SUITE.Style
  constructor: (name, attributes)->
    @id = SUITE.config.id_prefix + name
    @static = {}
    @dynamic = {}

    @has_static = false
    @has_dynamic = false

    for attr, val of attributes
      needs_unit = !(attr in SUITE.UnitlessAttributes)
      if typeof val is 'function'
        attr = _sh.dashToCamel attr
        @has_dynamic = true
        @dynamic[attr] = new SUITE.DynamicStyleAttribute val, needs_unit
      else
        attr = _sh.camelToDash attr
        if typeof val is 'number' and needs_unit then val = val + "px"
        @has_static = true
        @static[attr] = val

  CSSSelector: ()-> return "." + @id

  # Static properties are stored in a stylesheet
  generateCSS: ()->
    body = ("#{attr}: #{val};" for attr, val of @static).join("")
    return "#{@CSSSelector()}{#{body}}\n"

  # Apply this style to a child element of a component
  applyToElement: (component, element)->

    # Apply static attributes
    if @has_static
      window.SUITE.styleManager.addStyle this
      element.className += " " + @id

    # Apply dynamic attributes directly to the element
    for attr, dsa of @dynamic
      computed = dsa.eval component._api
      if computed? then  element.style[attr] = computed

      # Add listeners so the style is updated when a property it depends on changes
      for property, _ of dsa.dependencies
        component.addPropertyChangeListener property, ((attr, dsa, element)-> ()->
          change = {}
          change[attr] = dsa.eval @
          if !change[attr]? then return
          @setAttrs element, change
        )(attr, dsa, element)

    return true

# A style with a different kind of selector
class window.SUITE.CSSRule extends window.SUITE.Style
  constructor: (selector, attributes)->
    super selector, attributes
    @selector = selector
  CSSSelector: ()-> return @selector

# Dynamic attributes are functions that can rely on object property values
class window.SUITE.DynamicStyleAttribute
  constructor: (func, needs_unit)->
    @needs_unit = needs_unit
    @_eval = func
    @dependencies = {}

    # Figure out all of the object properties retrieved by the function
    func_body = func.toString()
    extract_properties = /\$([A-Za-z0-9\_]+)/g
    while match = extract_properties.exec(func_body)
      @dependencies[match[1]] = true

  eval: (moduleAPI)->
    if !@needs_unit then @_eval.call moduleAPI
    else
      result = @_eval.call moduleAPI
      if !result? then return undefined
      if typeof result is "number" then result = result + "px"
      return result
