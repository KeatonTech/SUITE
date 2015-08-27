new window.SUITE.ModuleBuilder("visible-element")

  .addProperty "id", [SUITE.PrimitiveType.String], "", (val)->
    @setAttrs "id": val
  .addProperty "class", [SUITE.PrimitiveType.String], "", (val)->
    @setAttrs "class": val

  .addProperty "x", [SUITE.PrimitiveType.Number], 0
  .addProperty "y", [SUITE.PrimitiveType.Number], 0
  .addProperty "width", [SUITE.PrimitiveType.Number], 0
  .addProperty "height", [SUITE.PrimitiveType.Number], 0

  .addStyle "positioned",
    left: ()-> @$x
    top: ()-> @$y

  .addStyle "sized",
    width: ()-> @$width
    height: ()-> @$height

  .setRenderer ()->
    div = @createElement "div"

    # Adds the [data-component] attribute. Accessing the component's type is not usually
    # supported, but we make an exception here by using the @_ backdoor to the Component.
    if window.SUITE.config.component_attribute
      div.setAttribute "data-component", @_.type

    if @$id != "" then div.setAttribute "id", @$id
    if @$class != "" then div.setAttribute "class", @$class

    @applyStyle div, "positioned"
    @applyStyle div, "sized"

    return div

  .register()


new window.SUITE.ModuleBuilder("button")
  .extend "visible-element"
  .addProperty "onClick", [SUITE.PrimitiveType.Function], undefined, (val, _, oldVal)->
    if oldVal? then @_rootElement.removeEventListener "click", oldVal
    @_rootElement.addEventListener "click", val

  .setRenderer ()->
    div = @super()
    div.addEventListener "click", @$onClick
    return div
