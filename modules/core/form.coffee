# Adds <input type='text'>
new window.SUITE.ModuleBuilder("text-input")
  .extend "absolute-element"

  .addProperty "value", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@rootElement? then return
    @rootElement.value = val

  .addProperty "placeholder", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@rootElement? then return
    @rootElement.setAttribute "placeholder", val

  .addProperty "type", [SUITE.PrimitiveType.String], "text", (val)->
    if !@rootElement? then return
    @rootElement.setAttribute "type", val

  .setRenderer ()->
    input = @super("input")
    input.setAttribute "type", @$type or "text"
    if @$value? then input.setAttribute "value", @$value
    if @$placeholder? then input.setAttribute "placeholder", @$placeholder

    input.addEventListener "keyup", (e)=>
      @setPropertyWithoutSetter "value", input.value
      if e.keyCode is 13
        @dispatchEvent "onSubmit", [@$value]
      else
        @dispatchEvent "onChange", [@$value]

    input.addEventListener "change", (e)=>
      @dispatchEvent "onChanged", [@$value]

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


# Adds <input type='checkbox'>
new window.SUITE.ModuleBuilder("checkbox-input")
  .extend "absolute-element"

  .addProperty "value", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@input? then return
    @input.checked = val?

  .addProperty "label", [SUITE.PrimitiveType.String], "Check this box", ()->
    if !@label? then return
    @label.innerHTML = val

  .setRenderer ()->
    container = @super("p")

    name = "scb_" + Math.floor(Math.random() * 10000000)

    @input = @createElement "input"
    @input.setAttribute "type", "checkbox"
    @input.setAttribute "name", name
    container.appendChild @input

    @input.addEventListener "click", (e)=>
      @setPropertyWithoutSetter "value", @input.checked
      @dispatchEvent "onChange", [@$value]
      @dispatchEvent "onChanged", [@$value]

    @label = @createElement "label"
    @label.innerHTML = @$label
    @label.setAttribute "for", name
    container.appendChild @label

    return container

  .register()
