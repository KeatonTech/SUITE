# Adds <input type='text'>
new window.SUITE.ModuleBuilder("text-input")
  .extend "absolute-element"

  .addProperty "value", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@rootElement? then return
    @rootElement.value = val

  .addProperty "placeholder", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@rootElement? then return
    @rootElement.setAttribute "placeholder", val

  .setRenderer ()->
    input = @super("input")
    if @$value? then input.setAttribute "value", @$value
    if @$placeholder? then input.setAttribute "placeholder", @$placeholder

    input.addEventListener "keyup", (e)=>
      @setPropertyWithoutSetter "value", input.value
      if e.keyCode is 13
        @dispatchEvent "onSubmit", [@$value]
      else
        @dispatchEvent "onChange", [@$value]

    return input

  .register()
