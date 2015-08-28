# Floating layouts are positioned relative to their parent using a fractional location, where
# (0,0) puts them in the top left and (0.5,0.5) centers them.
new window.SUITE.ModuleBuilder("layout-in-container")
  .extend "visible-element"

  # Keep track of how much space this thing has to play with
  .addProperty "containerWidth", [SUITE.PrimitiveType.Number]
  .addProperty "containerHeight", [SUITE.PrimitiveType.Number]

  .setOnResize (size)->
    @$containerWidth = size.width
    @$containerHeight = size.height

  .register()


# Floating layouts are positioned relative to their parent using a fractional location, where
# (0,0) puts them in the top left and (0.5,0.5) centers them.
new window.SUITE.ModuleBuilder("float-layout")
  .extend "layout-in-container"
  .addSlot "child", false

  # Centered in the parent by default
  .addProperty "floatX", [SUITE.PrimitiveType.Number], 0.5
  .addProperty "floatY", [SUITE.PrimitiveType.Number], 0.5

  # Keep track of how much space this thing has to play with
  .addProperty "childWidth", [SUITE.PrimitiveType.Number]
  .addProperty "childHeight", [SUITE.PrimitiveType.Number]

  .addSlotEventHandler "child", "onResize", (size)->
    @$childWidth = @slots.child.$width
    @$childHeight = @slots.child.$height

  # Floating style
  .addStyle "floating",
    left: ()-> (@$containerWidth - @$childWidth) * @$floatX
    top: ()-> (@$containerHeight - @$childHeight) * @$floatY

  .setRenderer ()->
    div = @super()
    @applyStyle div, "floating"
    div.appendChild @renderSlot @slots.child
    return div

  .register()
