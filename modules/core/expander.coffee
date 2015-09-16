# Expanders are containers that start off with no area and grow to reveal their contents
new window.SUITE.ModuleBuilder("expander")
  .extend("box")


  # RUNTIME PROPERTIES ======================================================================

  # This can be modified to open and close the box. Open() and Close() also work
  .addProperty "expanded", [SUITE.PrimitiveType.Boolean], false, (val, old)->
    if val == old then return
    if val then @open()
    else @close()

  # The expander must have no area by default, so either closedWidth or closedHeight must
  # be equal to zero.
  .addProperty "closedWidth", [SUITE.PrimitiveType.Number], 0, (val)->
    if val > 0 and @$closedHeight > 0 then @$closedWidth = 0
    if !@$expanded then @$width = val
  .addProperty "closedHeight", [SUITE.PrimitiveType.Number], 0, (val)->
    if val > 0 and @$closedWidth > 0 then @$closedHeight = 0
    if !@$expanded then @$height = val

  .addProperty "openWidth", [SUITE.PrimitiveType.Number], 0, (val)->
    if @$expanded then @$width = val
  .addProperty "openHeight", [SUITE.PrimitiveType.Number], 0, (val)->
    if @$expanded then @$height = val

  # How long it takes to expand
  .addProperty "duration", [SUITE.PrimitiveType.Number], 200


  # ANIMATION ===============================================================================

  # This is where the magic happens
  .addMethod "open", ()->
    @setPropertyWithoutSetter "expanded", true

    if @rootElement.children.length < 1
      @appendElement(@renderSlot slot) for slot in @slots.children

    slot.resize(@size) for slot in @slots.children
    @$opacity = 0

    SUITE.AnimateChanges @$duration, ()=>
      @$width = @$openWidth
      @$height = @$openHeight
      @$opacity = 1
      slot.resize(@size) for slot in @slots.children


  .addMethod "close", ()->
    @setPropertyWithoutSetter "expanded", false
    @$opacity = 1

    SUITE.AnimateChanges @$duration, ()=>
      @$width = @$closedWidth
      @$height = @$closedHeight
      @$opacity = 0
      slot.resize({width: @$closedWidth, height: @$closedHeight}) for slot in @slots.children

    # There seems to be little to no benefit of doing this
    #wait @$duration, ()=>
    #  slot.unrender() for slot in @slots.children


  # SUITE FUNCTIONS =========================================================================

  # Normal module stuff
  .setInitializer ()->
    @$width = @$closedWidth
    @$height = @$closedHeight
    @_renderedSlots = false

  .setRenderer ()->
    div = @supermodule("absolute-element")
    div.style.overflow = "hidden"

    if @$expanded
      wait 0, ()=>
        @$width = @$openWidth
        @$height = @$openHeight
        @$opacity = 1
        slot.resize(@size) for slot in @slots.children
        div.appendChild(@renderSlot slot) for slot in @slots.children

    return div

  .setOnResize (size)->
    if @$expanded
      @super(size)
    else
      @super({width: @$closedWidth, height: @$closedHeight})
    if @expanded
      @$openWidth = @$width
      @$openHeight = @$height
    else
      @$width = @$closedWidth
      @$height = @$closedHeight

  .register()
