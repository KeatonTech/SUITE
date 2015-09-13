# Lists are similar to columns, but with more features like infinite scroll and deferred
# rendering.
new window.SUITE.ModuleBuilder("list")
  .extend "box"

  # How much space to leave rendered on either side of the visible scroll area.
  .addProperty "scrollMargin", [SUITE.PrimitiveType.Number], 500

  # Functions that run when to request that more items be added
  .addProperty "expandBack", [SUITE.PrimitiveType.Function]
  .addProperty "expandFront", [SUITE.PrimitiveType.Function]

  # When true, inner HTML is wrapped in a table
  .addProperty "isTable", [SUITE.PrimitiveType.Boolean], false

  # Similar to the function in <column> but much more limited in that it does not support
  # $justify and does not resize the container based on the children
  .addProperty "totalHeight", [SUITE.PrimitiveType.Number]
  .addMethod "_relayout", ()->
    total_height = 0
    for child in @slots.children
      child.$x = 0
      child.$y = total_height
      total_height += child.$height
    @$totalHeight = total_height

  .addEventHandler "onResize", (size)-> @_relayout()

  # Render and unrender children as necessary
  .addMethod "_scrolled", ()->
    container = @getElement "container"

    # The margin gives the browser some leeway
    vstart = @rootElement.scrollTop - @$scrollMargin
    vstop = vstart + @$height + 2 * @$scrollMargin

    for item in @slots.children
      if item.$y + item.$height > vstart
        if item.$y > vstop
          if item.isRendered() then item.unrender()
        else
          if !item.isRendered()
            @appendElement container, nli = item.render()
            item.resize {width: @$width, height: nli.$height}
      else if item.isRendered() then item.unrender()
    return


  # Basic rendering stuff
  .addStyle "listStyle",
    overflowY: "scroll"

  .addStyle "listContainerStyle",
    height: ()-> @$totalHeight

  .setInitializer ()->
    @_relayout()

  .setRenderer ()->
    div = @supermodule("absolute-element")
    container = @createElement "container", if @$isTable then "table" else "div"
    @applyStyle container, "listContainerStyle"
    @appendElement container

    div.addEventListener "scroll", @_scrolled
    @applyStyle div, "listStyle"
    @_relayout()
    @_scrolled()
    return div

  .setOnResize (size)->
    @adjustSizeBounded size
    slot.resize({width: @$width, height: slot.$height}) for slot in @slots.children
    if @rootElement? then @_scrolled()

  .register()
