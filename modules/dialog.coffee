# Dialogs can only be displayed inside of a special dialog container
new window.SUITE.ModuleBuilder("dialog-container")
  .extend("container")
  .addSlot "dialog", false, (type)-> type == "dialog"

  # Dialog styling properties
  .addProperty "overlayColor", [SUITE.PrimitiveType.Color], "black", (val, setAttrs)->
    if displayed then setAttrs @overlay_container, backgroundColor: val
  .addProperty "overlayOpacity", [SUITE.PrimitiveType.Number], 0.6, (val, setAttrs)->
    if displayed then setAttrs @overlay_container, opacity: val

  # This is where the HTML magic happens
  .addProperty "displayed", [SUITE.PrimitiveType.Boolean], false, (val, setAttrs, oldval)->
    if oldval == val then return # No change in displayed status
    if val
      if !@slots.dialog?
        @_values.displayed = false # Circumvent setter
        return
      dialog = @slots.dialog

      oc = @overlay_container = document.createElement "div"
      oc.style.top = 0
      oc.style.left = 0
      oc.style.width = @width + "px"
      oc.style.height = @height + "px"
      oc.style.zIndex = 899

      # Fade in if animated
      setAttrs oc,
        backgroundColor: @$overlayColor
        opacity: @$overlayOpacity

      dc = @dialog_container = dialog.render()
      dc.style.width = dialog.width + "px"
      dc.style.height = dialog.height + "px"
      dc.style.left = @width / 2 - dialog.width / 2 + "px"
      dc.style.top = @height / 2 - dialog.height / 2 + "px"
      dc.style.zIndex = 900

      # Fade in if animated
      dc.style.opacity = 0
      setAttrs dc, opacity: 1

      @element.appendChild oc
      @element.appendChild dc

    # Clean up the dialog
    else
      @overlay_container.parentNode.removeChild @overlay_container
      @dialog_container.parentNode.removeChild @dialog_container

  # Add methods to show or hide the dialog
  .addMethod "hideDialog", ()-> @$displayed = false
  .addMethod "showDialog", (dialog)->
    if dialog? and @fillSlot("dialog", dialog) == -1 then return
    @$displayed = true

  # Doesn't need any special rendering unless the dialog is displayed
  .setRenderer (slots, superclass)->
    div = superclass.render.call this, slots, superclass.super
    if @$displayed
      @_values.displayed = false
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
      @overlay_container.style.width = size.width + "px"
      @overlay_container.style.height = size.height + "px"
      @dialog_container.style.width = dialog.width + "px"
      @dialog_container.style.height = dialog.height + "px"
      @dialog_container.style.left = size.width / 2 - dialog.width / 2 + "px"
      @dialog_container.style.top = size.height / 2 - dialog.height / 2 + "px"

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
