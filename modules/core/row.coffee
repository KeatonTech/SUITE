# Stacks contain all of their child elements in a single column.
# By default the child elements are horizontally centered, this can be changed using the
# $justify property, where 0 is left-justify and 1 is right-justify
# $spacing determines how much vertical space to leave between items
new window.SUITE.ModuleBuilder("row")
  .extend "box"
  .removeProperty "maxWidth"
  .removeProperty "maxHeight"

  .addProperty "verticalAlign", [SUITE.PrimitiveType.Number], 0.5, ()-> @_relayout()
  .addProperty "spacing", [SUITE.PrimitiveType.Number], 0, ()-> @_relayout()

  # Internal function to update the layout of the stack
  .addMethod "_relayout", ()->

    # Prevent changes in here from triggering recursive relayouts
    if @inRelayout then return
    @inRelayout = true

    # Figure out how wide this stack should be
    stack_height = 0
    for child in @slots.children
      if !child.$visible then continue
      height = child.$height
      if child.$rowPadding? then height += child.$rowPadding * 2
      stack_height = Math.max(height, stack_height)
    @$height = stack_height

    # Position each child in the stack
    total_width = 0
    for child in @slots.children
      if !child.$visible then continue
      child.$x = total_width
      height = child.$height
      if child.$rowPadding? then height += child.$rowPadding * 2
      child.$y = (@$height - height) * @$verticalAlign
      if child.$rowPadding? then child.$y += child.$rowPadding
      total_width += child.$width + @$spacing

    # Make this stack the correct height
    @$width = total_width - @$spacing

    @inRelayout = false

  # Lay out the children
  .setRenderer ()->
    div = @super()
    @_relayout()
    return div

  # Watch for this component or any of its children to resize
  .addEventHandler "onResize", (size)-> @_relayout()
  .addSlotEventHandler "children", "onResize", (size)-> @_relayout()
  .addSlotEventHandler "children", "onHide", (size)-> @_relayout()
  .addSlotEventHandler "children", "onShow", (size)-> @_relayout()

  .register()
