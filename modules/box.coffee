# Boxes, unlike containers, do not scale to fit their container. They have either a fixed
# width and height, or a minimum/maximum width and height
new window.SUITE.ModuleBuilder("box")
  .extend("container")

  # These properties can be overridden to give the box's size some flexibility
  .addProperty "minWidth", [SUITE.PrimitiveType.Number]
  .addProperty "minHeight", [SUITE.PrimitiveType.Number]
  .addProperty "maxWidth", [SUITE.PrimitiveType.Number]
  .addProperty "maxHeight", [SUITE.PrimitiveType.Number]

  .setOnResize (size)->
    if @$maxWidth? and @$minWidth?
      @$width = parseInt Math.max(Math.min(size.width, @$maxWidth), @$minWidth)
    if @$maxHeight? and @$minHeight?
      @$height = parseInt Math.max(Math.min(size.height, @$maxHeight), @$minHeight)

  .register()
