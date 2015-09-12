# Expanders are containers that start off with no area and grow to reveal their contents
new window.SUITE.ModuleBuilder("expander")
  .extend("box")

  # The expander must have no area by default, so either closedWidth or closedHeight must
  # be equal to zero.
  .addProperty "closedWidth", [SUITE.PrimitiveType.Number], 0, (val)->
    if val > 0 and @$closedHeight > 0 then @$closedWidth = 0
  .addProperty "closedHeight", [SUITE.PrimitiveType.Number], 0, (val)->
    if val > 0 and @$closedWidth > 0 then @$closedHeight = 0

  # How long it takes to expand
  .addProperty "duration", [SUITE.PrimitiveType.Number], 200

  # This can be modified to open and close the box. Open() and Close() also work
  .addProperty "expanded", [SUITE.PrimitiveType.Boolean], false, (val, old)->
    if val == old then return
    if val then @open()
    else @close()

  # This is where the magic happens
  .addMethod "open", ()->
    @setPropertyWithoutSetter "expanded", true
    @appendElement(@renderSlot slot) for slot in @slots.children
    slot.resize(@size) for slot in @slots.children
    SUITE.AnimateChanges @$duration, ()=>
      @$width = @openWidth
      @$height = @openHeight
      slot.resize(@size) for slot in @slots.children


  .addMethod "close", ()->
    @setPropertyWithoutSetter "expanded", false
    SUITE.AnimateChanges @$duration, ()=>
      @$width = @$closedWidth
      @$height = @$closedHeight
      slot.resize({width: @$closedWidth, height: @$closedHeight}) for slot in @slots.children

    wait @$duration, ()=>
      slot.unrender() for slot in @slots.children

  # Normal module stuff
  .setInitializer ()->
    @openWidth = @$width
    @openHeight = @$height

  .setRenderer ()->
    div = @supermodule("absolute-element")
    div.style.overflow = "hidden"
    if @$expanded then div.appendChild(@renderSlot slot) for slot in @slots.children
    return div

  .setOnResize (size)->
    if @$expanded
      @super(size)
    else
      @super({width: @$closedWidth, height: @$closedHeight})
    @openWidth = @$width
    @openHeight = @$height
    if !@$expanded
      @$width = @$closedWidth
      @$height = @$closedHeight

  .register()
