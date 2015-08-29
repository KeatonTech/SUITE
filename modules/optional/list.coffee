# Lists are similar to columns, but with more features like infinite scroll and deferred
# rendering.
new window.SUITE.ModuleBuilder("list")
  .extend "box"

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

  # This is where the magic happens
  .addMethod "_scrolled", ()->
    container = @getElement "container"

    # The margin gives the browser some leeway
    margin = 500
    vstart = @rootElement.scrollTop - margin
    vstop = vstart + @$height + 2 * margin

    # Render and unrender list items as appropriate
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
    @_scrolled()

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
