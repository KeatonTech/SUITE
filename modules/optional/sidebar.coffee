# Sidebars are hidden by default. When triggered they are rendered and moved in from the side
# of the screen. Sidebars are always full height.
new window.SUITE.ModuleBuilder("sidebar-layout")
  .extend "layout-in-container"

  # Sidebars can't be positioned manually, and always have 100% height
  .addProperty "position", [SUITE.PrimitiveType.Number]
  .addProperty "childWidth", [SUITE.PrimitiveType.Number], 0, (val)->
    @$position = if @$shown then 0 else -val

  # Set to false to make the sidebar come from the right side of the screen
  .addProperty "pinLeft", [SUITE.PrimitiveType.Boolean], true

  # Time it takes for the sidebar to appear
  .addProperty "slideTime", [SUITE.PrimitiveType.Number], 250

  .addProperty "shown", [SUITE.PrimitiveType.Boolean], false, (val, oldval)->
    if val == oldval then return
    if val then @show()
    else @hide()

  # Internal function to update the layout of the stack
  .addMethod "show", ()->

    # Make sure $shown gets set to true, without causing an infinite loop
    if !@$shown then return @$shown = true

    # Render the content
    @appendElement @setElement "content_div", @renderSlot(@slots.child)
    @slots.child.resize({width: @$childWidth, height: @$containerHeight})
    @slots.child.dispatchEvent "onResize"
    @$position = -@slots.child.$width

    # Animate in
    SUITE.AnimateChanges new SUITE.Transition(@$slideTime), ()=>
      @$position = 0

      # Let everybody know the sidebar is coming in
      @dispatchEvent "onShow"

  .addMethod "hide", ()->

    # Make sure $shown gets set to false, without causing an infinite loop
    if @$shown then return @$shown = false

    # Animate out
    SUITE.AnimateChanges new SUITE.Transition(@$slideTime), ()=>
      @$position = -@$childWidth

      # Let everybody know the sidebar is going away
      @dispatchEvent "onHide"

    wait @$slideTime + 10, ()=>
      @removeElement "content_div"

  .addStyle "sidebar",
    left: ()-> if @$pinLeft then @$position
    right: ()-> if !@$pinLeft then @$position
    height: ()-> @$containerHeight
    width: ()-> @$childWidth
    backgroundColor: "white"

  # Lay out the children
  .setRenderer ()->
    div = @super(false)
    if @$shown then wait 1, @show()
    @applyStyle div, "sidebar"
    return div

  .setOnResize (size)->
    @super(size)
    if !@$shown then return
    @slots.child.resize({width: @$childWidth, height: size.height})

  .register()
