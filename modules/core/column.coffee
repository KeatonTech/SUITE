# Stacks contain all of their child elements in a single column.
# By default the child elements are horizontally centered, this can be changed using the
# $justify property, where 0 is left-justify and 1 is right-justify
# $spacing determines how much vertical space to leave between items
new window.SUITE.ModuleBuilder("column")
  .extend "box"

  .addProperty "justify", [SUITE.PrimitiveType.Number], 0.5, ()-> @_relayout()
  .addProperty "spacing", [SUITE.PrimitiveType.Number], 0, ()-> @_relayout()

  # Internal function to update the layout of the stack
  .addMethod "_relayout", ()->
    if @_layoutInProgress then return
    @_layoutInProgress = true

    # Figure out how wide this stack should be
    stack_width = @_baseSize.width
    for child in @slots.children
      if child._colFloatingWidth then continue
      if child.$expanded? and !child.$expanded then continue
      stack_width = Math.max(child.$width, stack_width)
    @$width = stack_width

    # Position each child in the stack
    total_height = 0
    for child in @slots.children
      if child._colFloatingWidth
        child.$width = stack_width

      spacing = if child.$columnSpacing? then child.$columnSpacing else @$spacing
      child.$x = (@$width - child.$width) * @$justify
      child.$y = total_height - (@$spacing - spacing)
      total_height += child.$height + spacing

    # Make this stack the correct height
    @$height = total_height - spacing

    @_layoutInProgress = false

  # Check which children don't have a fixed size
  .setInitializer ()->
    @_baseSize = @size
    for child in @slots.children
      if child.$width is "auto"
        child._colFloatingWidth = true
        child.$width = 0

  # Lay out the children
  .setRenderer ()->
    div = @super()
    @_relayout()
    return div

  # Watch for this component or any of its children to resize
  .addEventHandler "onResize", (size)-> @_relayout()
  .addSlotEventHandler "children", "onResize", (size)-> @_relayout()

  .register()
