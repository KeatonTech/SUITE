# Sidebars are hidden by default. When triggered they are rendered and moved in from the side
# of the screen. Sidebars are always full height.
new window.SUITE.ModuleBuilder("sidebar")
  .extend "layout-in-container"

  # Sidebars can't be positioned manually, and always have 100% height
  .addProperty "width", [SUITE.PrimitiveType.Number], 200
  .addProperty "position", [SUITE.PrimitiveType.Number]
  .setInitializer ()-> @$position = -@$width

  # Sidebars only take one child element, a container that holds the sidebar
  # It's done this way to make render deferring easier
  .addSlot "content", false

  # Set to false to make the sidebar come from the right side of the screen
  .addProperty "pinLeft", [SUITE.PrimitiveType.Boolean], false

  # Time it takes for the sidebar to appear
  .addProperty "slideTime", [SUITE.PrimitiveType.Number], 250

  .addProperty "shown", [SUITE.PrimitiveType.Boolean], false, (val, oldval)->
    if val == oldval then return
    if val then @show()
    else @hide()

  .addStyle "sidebar",
    left: ()-> if @$pinLeft then @$position
    right: ()-> if !@$pinLeft then @$position
    height: ()-> @$containerHeight
    width: ()-> @$width
    backgroundColor: "white"
    boxShadow: ()->
      if !@$shown then "none"
      else "0px 0px 4px rgba(0,0,0,.5)"

  # Internal function to update the layout of the stack
  .addMethod "show", ()->

    # Make sure $shown gets set to true, without causing an infinite loop
    @setPropertyWithoutSetter "shown", true

    # Render the content
    @appendElement @setElement "content_div", @renderSlot(@slots.content)
    @slots.content.resize({width: @$width, height: @$containerHeight})

    # Animate in
    SUITE.AnimateChanges new SUITE.Transition(@$slideTime), ()=>
      @$position = 0

  .addMethod "hide", ()->

    # Animate out
    SUITE.AnimateChanges new SUITE.Transition(@$slideTime), ()=>
      @$position = -@$width

    wait @$slideTime + 10, ()=>
      @removeElement "content_div"

  # Lay out the children
  .setRenderer ()->
    div = @super()
    if @$shown then wait 1, @show()
    @applyStyle div, "sidebar"
    return div

  .setOnResize (size)->
    @super(size)
    if !@$shown then return
    @slots.content.resize({width: @$width, height: size.height})

  .register()
