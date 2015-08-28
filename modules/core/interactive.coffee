new window.SUITE.ModuleBuilder("button")
  .extend "absolute-element"
  .addProperty "onClick", [SUITE.PrimitiveType.Function], undefined, (val, _, oldVal)->
    if !@rootElement? then return
    if oldVal? then @rootElement.removeEventListener "click", oldVal
    @rootElement.addEventListener "click", val

  .addStyle "button",
    cursor: "pointer"

  .setRenderer ()->
    div = @super()
    @applyStyle div, "button"
    div.addEventListener "click", @$onClick
    return div

  .register()
