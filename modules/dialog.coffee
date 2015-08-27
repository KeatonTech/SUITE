# Dialogs can only be displayed inside of a special dialog container
new window.SUITE.ModuleBuilder("dialog-container")
  .extend("container")
  .addSlot "dialog", false, (type)-> type == "dialog"

  # Dialog styling properties
  .addProperty "overlayColor", [SUITE.PrimitiveType.Color], "black"
  .addProperty "overlayOpacity", [SUITE.PrimitiveType.Number], 0.6

  .addStyle "overlay",
    backgroundColor: ()-> @$overlayColor
    opacity: ()-> @$overlayOpacity
    zIndex: 899

  .addStyle "dialog",
    top: ()-> @$height / 2 - @slots.dialog.$height / 2
    left: ()-> @$width / 2 - @slots.dialog.$width / 2
    width: ()-> @slots.dialog.$width
    height: ()-> @slots.dialog.$height
    zIndex: 900
    opacity: 0

  # This is where the HTML magic happens
  .addProperty "displayed", [SUITE.PrimitiveType.Boolean], false, (val, oldval)->
    if oldval == val then return # No change in displayed status
    if val
      if !@slots.dialog?
        @_values.displayed = false # Circumvent setter
        return
      dialog = @slots.dialog

      oc = @createElement "overlay", "div"
      @applyStyle oc, "positioned"
      @applyStyle oc, "sized"
      @applyStyle oc, "overlay"

      dc = @renderSlot "dialog", dialog
      @applyStyle dc, "dialog"

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
  .setRenderer ()->
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

      @forceAttrs @getElement("dialog"),
        width: dialog.$width
        height: dialog.$height
        left: size.width / 2 - dialog.$width / 2
        top: size.height / 2 - dialog.$height / 2

  .register()

# The actual dialog is just a container with some special sizing stuff
new window.SUITE.ModuleBuilder("dialog")
  .extend("container")
  .removeProperty "x"
  .removeProperty "y"

  # Dialogs scale down when necessary
  .addProperty "minWidth", [SUITE.PrimitiveType.Number], 0
  .addProperty "minHeight", [SUITE.PrimitiveType.Number], 0
  .addProperty "maxWidth", [SUITE.PrimitiveType.Number], 640
  .addProperty "maxHeight", [SUITE.PrimitiveType.Number], 480

  .setInitializer ()->
    @$width = @$maxWidth
    @$height = @$maxHeight

  .setOnResize (size)->
    @$width = parseInt Math.max(Math.min(size.width, @$maxWidth), @$minWidth)
    @$height = parseInt Math.max(Math.min(size.height, @$maxHeight), @$minHeight)

  .setRenderer ()->
    div = @super()
    @applyStyle div, "sized"
    return div

  .register()
