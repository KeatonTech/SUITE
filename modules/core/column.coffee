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
    stack_height = 0
    total_spacing = 0
    for child in @slots.children
      if !child.$visible then continue
      if child.$width is "auto" then child._colAutoWidth = true
      if child._colAutoWidth then continue
      if child.$expanded? and !child.$expanded then continue
      total_spacing += child.$columnSpacing or @$spacing
      stack_width = Math.max(child.$width, stack_width)
      if @_hasAutoHeight and !child._colAutoHeight
        stack_height += child.$height
    @$width = stack_width

    # For auto height, figure out the target
    pull_height = if @_baseSize.height? then @$height else @_.parent?.$height
    pull_height -= total_spacing - @$spacing

    # Position each child in the stack
    total_height = 0
    for child in @slots.children
      if !child.$visible then continue
      if child._colAutoWidth
        child.$width = stack_width

      spacing = if child.$columnSpacing? then child.$columnSpacing else @$spacing
      if child._colAutoHeight
        autospacing = if child.$columnSpacing?
          @$spacing - child.$columnSpacing
        else -spacing
        child.$height = pull_height - stack_height + autospacing

      child.$x = (@$width - child.$width) * @$justify
      child.$y = total_height - (@$spacing - spacing)
      total_height += (child.$height or 0) + spacing

    # Make this stack the correct height
    @$height = total_height - spacing

    @_layoutInProgress = false

  # Check which children don't have a fixed size
  .setInitializer ()->
    @_baseSize = @size
    if @$height is "auto"
      @_baseSize.height = undefined
      @$height = 0
      @_.parent.addHandler "onResize", (size)=> @_relayout()
    @_hasAutoHeight = false
    for child in @slots.children
      if child.$width is "auto"
        child._colAutoWidth = true
        child.$width = 0
      if child.$height is "auto"
        @_hasAutoHeight = true
        child._colAutoHeight = true
        child.$height = 0

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
