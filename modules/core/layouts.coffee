# Floating layouts are positioned relative to their parent using a fractional location, where
# (0,0) puts them in the top left and (0.5,0.5) centers them.
new window.SUITE.ModuleBuilder("layout-in-container")
  .extend "visible-element"
  .addSlot "child", false

  # Keep track of how much space this thing has to play with
  .addProperty "containerWidth", [SUITE.PrimitiveType.Number]
  .addProperty "containerHeight", [SUITE.PrimitiveType.Number]

  .setOnResize (size)->
    @$containerWidth = size.width
    @$containerHeight = size.height

  # Keep track of how much space this thing has to play with
  .addProperty "childWidth", [SUITE.PrimitiveType.Number]
  .addProperty "childHeight", [SUITE.PrimitiveType.Number]

  .addSlotEventHandler "child", "onResize", (size)->
    @$childWidth = @slots.child.$width
    @$childHeight = @slots.child.$height

  .setRenderer (renderChild = true)->
    div = @super()
    if renderChild
      div.appendChild @renderSlot @slots.child
      @slots.child.resize({
          width: @$containerWidth
          height: @$containerHeight
      })
      @slots.child.dispatchEvent "onResize"
    return div

  .register()


# Floating layouts are positioned relative to their parent using a fractional location, where
# (0,0) puts them in the top left and (0.5,0.5) centers them.
new window.SUITE.ModuleBuilder("float-layout")
  .extend "layout-in-container"

  # Centered in the parent by default
  .addProperty "floatX", [SUITE.PrimitiveType.Number], 0.5
  .addProperty "floatY", [SUITE.PrimitiveType.Number], 0.5

  # Floating style
  .addStyle "floating",
    left: ()-> (@$containerWidth - @$childWidth) * @$floatX
    top: ()-> (@$containerHeight - @$childHeight) * @$floatY

  .setRenderer ()->
    div = @super()
    @applyStyle div, "floating"
    return div

  .register()

# Pinned layouts are basically equivalent to absolute positioning in HTML.
new window.SUITE.ModuleBuilder("pinned-layout")
  .extend "layout-in-container"

  # Centered in the parent by default
  .addProperty "top", [SUITE.PrimitiveType.Number], undefined, (v)-> @resize(@_parentSize)
  .addProperty "left", [SUITE.PrimitiveType.Number], undefined, (v)-> @resize(@_parentSize)
  .addProperty "bottom", [SUITE.PrimitiveType.Number], undefined, (v)-> @resize(@_parentSize)
  .addProperty "right", [SUITE.PrimitiveType.Number], undefined, (v)-> @resize(@_parentSize)

  # Pinned style (this is so easy!)
  .addStyle "absolute",
    top: ()-> @$top
    left: ()-> @$left
    bottom: ()-> @$bottom
    right: ()-> @$right
    width: ()-> @$childWidth
    height: ()-> @$childHeight

  .setRenderer ()->
    div = @super()
    @applyStyle div, "absolute"
    return div

  .setOnResize (size)->
    @super(size)
    @_parentSize = size;
    if @$right? and @$left?
      @$containerWidth = size.width - @$right - @$left
    if @$top? and @$bottom?
      @$containerHeight = size.height - @$top - @$bottom

    # Assume the child wants to be resized too
    if @$right? and @$left? or @$top? and @$bottom?
      @slots.child.resize {width: @$containerWidth, height: @$containerHeight}

  .register()

# Pinned layouts are basically equivalent to absolute positioning in HTML.
new window.SUITE.ModuleBuilder("fixed-layout")
  .extend "pinned-layout"

  .setRenderer ()->
    div = @super()
    div.style.position = "fixed"
    return div

  .register()
