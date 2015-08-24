new window.SUITE.ModuleBuilder("visible-element")

  .addProperty "id", [SUITE.PrimitiveType.String], "", (val, setAttrs)->
    setAttrs "id": val
  .addProperty "class", [SUITE.PrimitiveType.String], "", (val, setAttrs)->
    setAttrs "class": val

  .addProperty "x", [SUITE.PrimitiveType.Number], 0, (val, setAttrs)->
    setAttrs "left": val+"px"
  .addProperty "y", [SUITE.PrimitiveType.Number], 0, (val, setAttrs)->
    setAttrs "top": val+"px"
  .addProperty "width", [SUITE.PrimitiveType.Number], 0, (val, setAttrs)->
    setAttrs "width": val+"px"
  .addProperty "height", [SUITE.PrimitiveType.Number], 0, (val, setAttrs)->
    setAttrs "height": val+"px"

  .setRenderer ()->
    div = document.createElement "div"
    if window.SUITE.config.component_attribute
      div.setAttribute "data-component", @type
    if @$id != "" then div.setAttribute "id", @$id
    if @$class != "" then div.setAttribute "class", @$class
    div.style.left = @$x + "px"
    div.style.top = @$y + "px"
    div.style.width = @$width + "px"
    div.style.height = @$height + "px"
    return div

  .register()
