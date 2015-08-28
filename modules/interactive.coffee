new window.SUITE.ModuleBuilder("button")
  .extend "visible-element"
  .addProperty "onClick", [SUITE.PrimitiveType.Function], undefined, (val, _, oldVal)->
    if oldVal? then @_rootElement.removeEventListener "click", oldVal
    @_rootElement.addEventListener "click", val

  .setRenderer ()->
    div = @super()
    div.addEventListener "click", @$onClick
    return div
