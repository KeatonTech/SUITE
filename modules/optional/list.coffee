# Lists are similar to columns, but with more features like infinite scroll and deferred
# rendering.
new window.SUITE.ModuleBuilder("list")
  .extend "box"

  # How much space to leave rendered on either side of the visible scroll area.
  .addProperty "scrollMargin", [SUITE.PrimitiveType.Number], 500

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
    container = @createElement "container", "div"
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


# Lists can take any type of element. List items are mostly just a convenient style thing.
new window.SUITE.ModuleBuilder("list-item")
  .extend "absolute-element"
  .setPropertyDefault "height", 55

  .addProperty "title", [SUITE.PrimitiveType.String], "", ()-> @rerender
  .addProperty "subtitle", [SUITE.PrimitiveType.String], "", ()-> @rerender

  # Modern styling
  .addStyle "list_item",
    padding: "8px 12px"
    borderBottom: "1px solid #eee"
    boxSizing: "border-box"

  .addStyle "list_component",
    margin: 0
    padding: 0
    position: "static"

  .addStyle "list_title",
    fontSize: 18

  .addStyle "list_subtitle",
    fontSize: 12
    color: "#666"

  .setRenderer ()->
    div = @super()
    @applyStyle div, "list_item"

    title = @createElement "title", "h1"
    title.innerHTML = @$title
    @applyStyle title, "list_component"
    @applyStyle title, "list_title"
    @appendElement title

    if @$subtitle?
      subtitle = @createElement "subtitle", "h1"
      subtitle.innerHTML = @$subtitle
      @applyStyle subtitle, "list_component"
      @applyStyle subtitle, "list_subtitle"
      @appendElement subtitle

    return div

  # Containers fill their available space
  .setOnResize (size)->
    @$width = size.width
    if container = @getElement "container"
      container.$width = @$width

  .register()


# HTML lists save a lot of overhead by rendering items directly instead of having children.
new window.SUITE.ModuleBuilder("html-list")
  .extend "list"

  .addProperty "minItemHeight", [SUITE.PrimitiveType.Number], 20
  .addProperty "itemCount", [SUITE.PrimitiveType.Number], 0, ()-> @_scrolled()
  .addProperty "renderSlot", [SUITE.PrimitiveType.Function]

  .setInitializer ()->
    @renderedElements = []

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
        item = @renderedElements[i] = @$renderSlot.call this, i
        item.style.width = @$width + "px"
        new_items = true
        container.appendChild item
        pos += @$minItemHeight

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
