# Boxes, unlike containers, do not scale to fit their container. They have either a fixed
# width and height, or a minimum/maximum width and height
new window.SUITE.ModuleBuilder("box")
  .extend("container")

  # These properties can be overridden to give the box's size some flexibility
  .addProperty "minWidth", [SUITE.PrimitiveType.Number]
  .addProperty "minHeight", [SUITE.PrimitiveType.Number]
  .addProperty "maxWidth", [SUITE.PrimitiveType.Number]
  .addProperty "maxHeight", [SUITE.PrimitiveType.Number]

  # Initialize the min and max to the set width if they are not set by the user
  .setInitializer ()->
    if !@$maxWidth? then @$maxWidth = @$width
    if !@$minWidth? then @$minWidth = @$width
    if !@$maxHeight? then @$maxHeight = @$height
    if !@$minHeight? then @$minHeight = @$height

  .setOnResize (size)->
    if @$maxWidth? and @$minWidth?
      @$width = parseInt Math.max(Math.min(size.width, @$maxWidth), @$minWidth)
    if @$maxHeight? and @$minHeight?
      @$height = parseInt Math.max(Math.min(size.height, @$maxHeight), @$minHeight)

  .register()


# Floating boxes are positioned relative to their parent using a fractional location, where
# (0,0) puts them in the top left and (0.5,0.5) centers them
new window.SUITE.ModuleBuilder("floating-box")
  .extend("box")
  .removeProperty "x"
  .removeProperty "y"
  .removeStyle "positioned"

  # Centered in the parent by default
  .addProperty "floatX", [SUITE.PrimitiveType.Number], 0.5
  .addProperty "floatY", [SUITE.PrimitiveType.Number], 0.5

  # Keep track of how much space this thing has to play with
  .addProperty "containerWidth", [SUITE.PrimitiveType.Number]
  .addProperty "containerHeight", [SUITE.PrimitiveType.Number]
  .setOnResize (size)->
    @super(size)
    @$containerWidth = size.width
    @$containerHeight = size.height

  # Floating style
  .addStyle "floating",
    left: ()-> @$containerWidth / 2 - @$width / 2
    top: ()-> @$containerHeight / 2 - @$height / 2
  .setRenderer ()->
    div = @super()
    @applyStyle div, "floating"
    return div

  .register()
