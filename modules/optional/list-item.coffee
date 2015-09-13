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
