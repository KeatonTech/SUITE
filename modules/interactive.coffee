new window.SUITE.ModuleBuilder("button")
  .extend "absolute-element"
  .addProperty "onClick", [SUITE.PrimitiveType.Function], undefined, (val, _, oldVal)->
    if !@rootElement? then return
    if oldVal? then @rootElement.removeEventListener "click", oldVal
    @rootElement.addEventListener "click", val

  .setRenderer ()->
    div = @super()
    div.addEventListener "click", @$onClick
    return div

  .register()
