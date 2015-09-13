# HTML lists save a lot of overhead by rendering items directly instead of having children.
new window.SUITE.ModuleBuilder("html-list")
  .extend "list"
  .setPropertyDefault "isTable", true

  .addProperty "minItemHeight", [SUITE.PrimitiveType.Number], 20
  .addProperty "itemCount", [SUITE.PrimitiveType.Number], 0, ()-> @_scrolled()
  .addProperty "renderSlot", [SUITE.PrimitiveType.Function]

  .setInitializer ()->
    @renderedElements = []


  # Calls @$renderSlot and returns the element's height
  .addMethod "_renderElement", (container, i)->
    item = @renderedElements[i] = @$renderSlot.call this, i
    item.style.width = @$width + "px"
    container.appendChild item
    return @$minItemHeight

  # Override parent method
  .addMethod "_scrolled", ()->
    container = @getElement "container"

    # The margin gives the browser some leeway
    vstart = @rootElement.scrollTop - @$scrollMargin
    vstop = vstart + @$height + 2 * @$scrollMargin
    new_items = false
    pos = 0

    for i in [0...@$itemCount]
      if i >= @renderedElements.length then @renderedElements.push undefined
      if !(item = @renderedElements[i])
        if pos > vstop then continue
        new_items = true
        pos += @_renderElement container, i
      else
        pos += item.offsetHeight

    # Wait for the DOM to update
    if new_items
      wait 5, ()=>
        for item in @renderedElements when item?
          if !accY? then accY = (item.offsetTop + item.offsetHeight) || 0
          else
            item.style.top = accY + "px"
            accY += item.offsetHeight

    return

  .setRenderer ()->
    @renderedElements = []
    @super()

  .setOnResize (size)->
    @adjustSizeBounded size
    (item.style.width = size.width) for item in @renderedElements when item?
    if @rootElement? then @_scrolled()

  .register()
