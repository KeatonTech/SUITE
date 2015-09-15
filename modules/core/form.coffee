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


# Adds a textarea that expands with its content
new window.SUITE.ModuleBuilder("text-area")
  .extend "absolute-element"

  .addProperty "value", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@rootElement? then return
    @rootElement.value = val
    @contentResize()

  .addProperty "placeholder", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@rootElement? then return
    @rootElement.setAttribute "placeholder", val

  .addMethod "contentResize", ()->
    @rootElement.style.height = 'auto'
    @$height = @rootElement.scrollHeight

  .addMethod "deferredContentResize", ()-> wait 0, @contentResize

  .setRenderer ()->
    textarea = @super("textarea")
    textarea.setAttribute "rows", "1"
    if @$value? then textarea.setAttribute "value", @$value
    if @$placeholder? then textarea.setAttribute "placeholder", @$placeholder

    textarea.addEventListener 'change',  @contentResize
    textarea.addEventListener 'cut',     @deferredContentResize
    textarea.addEventListener 'paste',   @deferredContentResize
    textarea.addEventListener 'drop',    @deferredContentResize
    textarea.addEventListener 'keydown', @deferredContentResize

    textarea.focus();
    textarea.select();
    @contentResize

    textarea.addEventListener "keypress", (e)-> if e.keyCode is 13 then return false

    textarea.addEventListener "keyup", (e)=>
      @setPropertyWithoutSetter "value", textarea.value
      if e.keyCode is 13
        @dispatchEvent "onSubmit", [@$value]
      else
        @dispatchEvent "onChange", [@$value]

    return textarea

  .register()
