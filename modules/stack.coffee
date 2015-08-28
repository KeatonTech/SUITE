# Stacks contain all of their child elements in a single column.
# By default the child elements are horizontally centered, this can be changed using the
# $justify property, where 0 is left-justify and 1 is right-justify
# $spacing determines how much vertical space to leave between items
new window.SUITE.ModuleBuilder("stack")
  .extend("floating-box")
  .removeProperty "maxWidth"
  .removeProperty "maxHeight"

  .addProperty "justify", [SUITE.PrimitiveType.Number], 0.5
  .addProperty "spacing", [SUITE.PrimitiveType.Number], 0

  # Internal function to update the layout of the stack
  .addMethod "_relayout", ()->

    # Figure out how wide this stack should be
    stack_width = 0
    for child in @slots.children
      stack_width = Math.max(child.$width, stack_width)
    @$width = stack_width

    # Position each child in the stack
    total_height = 0
    for child in @slots.children
      child.$x = @$width / 2 - child.$width / 2
      child.$y = total_height
      total_height += child.$height + @$spacing

    # Make this stack the correct height
    @$height = total_height - @$spacing

  # Lay out the children
  .setRenderer ()->
    div = @super()
    wait 1, ()=> @_relayout()
    return div

  # Watch for this component or any of its children to resize
  .addEventHandler "onResize", (size)-> @_relayout()
  .addSlotEventHandler "children", "onResize", (size)-> @_relayout()

  .register()
