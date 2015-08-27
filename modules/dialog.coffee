# Dialogs can only be displayed inside of a special dialog container
new window.SUITE.ModuleBuilder("dialog-container")
  .extend("container")
  .addSlot "dialog", false, (type)-> type == "floating-box"

  # Dialog styling properties
  .addProperty "overlayColor", [SUITE.PrimitiveType.Color], "black"
  .addProperty "overlayOpacity", [SUITE.PrimitiveType.Number], 0.6

  .addStyle "overlay",
    backgroundColor: ()-> @$overlayColor
    opacity: ()-> @$overlayOpacity
    zIndex: 899

  .addStyle "dialog",
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

      dialog.resize @size
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

    if @$displayed then @slots.dialog.resize size

  .register()
