# Dialogs can only be displayed inside of a special dialog container
new window.SUITE.ModuleBuilder("dialog-container")
  .extend("container")
  .addSlot "dialog", false, (type)-> type == "dialog"

  # Dialog styling properties
  .addProperty "overlayColor", [SUITE.PrimitiveType.Color], "black", (val)->
    if displayed then @setAttrs @getElement("overlay"), backgroundColor: val
  .addProperty "overlayOpacity", [SUITE.PrimitiveType.Number], 0.6, (val)->
    if displayed then @setAttrs @getElement("dialog"), opacity: val

  # This is where the HTML magic happens
  .addProperty "displayed", [SUITE.PrimitiveType.Boolean], false, (val, oldval)->
    if oldval == val then return # No change in displayed status
    if val
      if !@slots.dialog?
        @_values.displayed = false # Circumvent setter
        return
      dialog = @slots.dialog

      oc = @createElement "overlay", "div"
      @forceAttrs oc,
        top: 0, left: 0,
        width: @width
        height: @height
        zIndex: 899

      # Fade in if animated
      @setAttrs oc,
        backgroundColor: @$overlayColor
        opacity: @$overlayOpacity

      dc = @renderSlot "dialog", dialog
      @forceAttrs dc,
        top: @height / 2 - dialog.height / 2
        left: @width / 2 - dialog.width / 2
        width: dialog.width
        height: dialog.height
        zIndex: 900
        opacity: 0

      # Fade in if animated
      @setAttrs dc, opacity: 1

      @appendElement "overlay"
      @appendElement "dialog"

    # Clean up the dialog
    else
      @removeElement "overlay"
      @removeElement "dialog"

  # Add methods to show or hide the dialog
  .addMethod "hideDialog", ()-> @$displayed = false
  .addMethod "showDialog", (dialog)->
    if dialog? and @fillSlot("dialog", dialog) == -1 then return
    @$displayed = true

  # Doesn't need any special rendering unless the dialog is displayed
  .setRenderer (slots, superclass)->
    div = @super()
    if @$displayed
      @$displayed = false
      wait 1, ()-> @$displayed = true
    return div

  # Containers fill their available space
  .setOnResize (size)->
    @$width = size.width
    @$height = size.height
    slot.resize(size) for slot in @slots.children

    if @$displayed
      dialog = @slots.dialog
      dialog.resize size

      dialog_element = @getElement "dialog"

      @forceAttrs @getElement("overlay"),
        width: size.width
        height: size.height

      @forceAttrs @getElement("dialog"),
        width: dialog.width
        height: dialog.height
        left: size.width / 2 - dialog.width / 2
        top: size.height / 2 - dialog.height / 2

  .register()

# The actual dialog is just a container with some special sizing stuff
new window.SUITE.ModuleBuilder("dialog")
  .extend("container")
  .removeProperty "x"
  .removeProperty "y"

  # Dialogs scale down when necessary
  .addProperty "minWidth", [SUITE.PrimitiveType.Number], 0
  .addProperty "minHeight", [SUITE.PrimitiveType.Number], 0
  .setGetWidth ()->
    return parseInt Math.max(Math.min(@_containerX||999999, @$width), @$minWidth)
  .setGetHeight ()->
    return parseInt Math.max(Math.min(@_containerY||999999, @$height), @$minHeight)
  .setOnResize (size)->
    @_containerX = size.width
    @_containerY = size.height

  .register()
