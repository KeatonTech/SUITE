# Boxes, unlike containers, do not scale to fit their container. They have either a fixed
# width and height, or a minimum/maximum width and height
new window.SUITE.ModuleBuilder("box")
  .extend("container")

  # These properties can be overridden to give the box's size some flexibility
  .addProperty "minWidth", [SUITE.PrimitiveType.Number]
  .addProperty "minHeight", [SUITE.PrimitiveType.Number]
  .addProperty "maxWidth", [SUITE.PrimitiveType.Number]
  .addProperty "maxHeight", [SUITE.PrimitiveType.Number]

  # This is separated out from onResize to make overriding easier
  .addMethod "adjustSizeBounded", (size)->
    size.width -= @$x
    size.height -= @$y
    if @$maxWidth? and @$minWidth?
      @$width = parseInt Math.max(Math.min(size.width, @$maxWidth), @$minWidth)
    if @$maxHeight? and @$minHeight?
      @$height = parseInt Math.max(Math.min(size.height, @$maxHeight), @$minHeight)

  .setOnResize (size)->
    @adjustSizeBounded size
    slot.resize(@size) for slot in @slots.children

  .register()
