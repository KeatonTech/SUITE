new window.SUITE.ModuleBuilder("visible-element")

  # HTML ELEMENT PROPERTIES =================================================================

  .addProperty "id", [SUITE.PrimitiveType.String], "", (val)->
    @setAttrs "id": val
  .addProperty "class", [SUITE.PrimitiveType.String], "", (val)->
    @setAttrs "class": val

  # STYLE PROPETIES =========================================================================

  .addProperty "visible", [SUITE.PrimitiveType.Boolean], true
  .addProperty "fill", [SUITE.PrimitiveType.Color]
  .addProperty "stroke", [SUITE.PrimitiveType.Color]
  .addProperty "strokeWidth", [SUITE.PrimitiveType.Number]
  .addProperty "shadow", [SUITE.PrimitiveType.String]
  .addProperty "cornerRadius", [SUITE.PrimitiveType.Number]
  .addProperty "z", [SUITE.PrimitiveType.Number]
  .addProperty "opacity", [SUITE.PrimitiveType.Number]
  .addProperty "cursor", [SUITE.PrimitiveType.String]

  .addStyle "styled",
    backgroundColor: ()-> @$fill
    borderColor: ()-> @$stroke
    borderWidth: ()-> @$strokeWidth
    borderRadius: ()-> @$cornerRadius
    boxShadow: ()-> @$shadow
    zIndex: ()-> @$z
    opacity: ()-> @$opacity
    cursor: ()-> @$cursor
    display: ()-> if !@$visible then "none" else "inherit"


  # IMPLEMENTATION ==========================================================================

  .setRenderer (tag = "div")->
    div = @createElement tag

    # Adds the [data-component] attribute. Accessing the component's type is not usually
    # supported, but we make an exception here by using the @_ backdoor to the Component.
    if window.SUITE.config.component_attribute
      div.setAttribute "data-component", @_.type

    if @$id != "" then div.setAttribute "id", @$id
    if @$class != "" then div.setAttribute "class", @$class

    @applyStyle div, "positioned"
    @applyStyle div, "sized"
    @applyStyle div, "styled"

    @addHandlerBinding div, "click", "onClick"
    @addHandlerBinding div, "contextmenu", "onRightClick"
    @addHandlerBinding div, "mouseenter", "onMouseEnter"
    @addHandlerBinding div, "mouseleave", "onMouseExit"

    return div

  .register()


new window.SUITE.ModuleBuilder("absolute-element")
  .extend "visible-element"

  .addProperty "x", [SUITE.PrimitiveType.Number], 0
  .addProperty "y", [SUITE.PrimitiveType.Number], 0
  .addProperty "width", [SUITE.PrimitiveType.Number], 0, (val, oldval) ->
    if val != oldval then @dispatchEvent "onResize", @size
  .addProperty "height", [SUITE.PrimitiveType.Number], 0, (val, oldval) ->
    if val != oldval then @dispatchEvent "onResize", @size

  .addStyle "positioned",
    left: ()-> @$x
    top: ()-> @$y

  .addStyle "sized",
    width: ()-> @$width
    height: ()-> @$height

  .setRenderer (tag)->
    div = @super(tag)
    @applyStyle div, "positioned"
    @applyStyle div, "sized"
    return div

  .register()


new window.SUITE.ModuleBuilder("fixed-size-element")
  .extend "absolute-element"
  .addProperty "width", [SUITE.PrimitiveType.Number], 0, ()->
    @setPropertyWithoutSetter "width", @computeSize().width
  .addProperty "height", [SUITE.PrimitiveType.Number], 0, ()->
    @setPropertyWithoutSetter "height", @computeSize().height

  # Subclasses should override this method
  .addMethod "computeSize", ()->
    return {width: 100, height: 100}

  # Subclasses run this method to recalculate their size
  .addMethod "updateSize", ()->
    @$width = 0
    @$height = 0
    @dispatchEvent "onResize", @size

  .register()
