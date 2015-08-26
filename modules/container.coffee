# Containers are kind of weird in SVG. They consist of an invisible group and a backing
# layer that displays the fill color. If there is no fill color, the backing is not created.
new window.SUITE.ModuleBuilder("container")
  .extend("visible-element")
  .addSlot("children", true) # Repeated slot
  .addMethod "addChild", (child)-> @fillSlot "children", child

  # SVG Fill property w/ setter
  .addProperty "fill", [SUITE.PrimitiveType.Color], "none", (val)->
    @setAttrs backgroundColor: val

  # Rendered as a group, does not enforce any layout
  .setRenderer ()->
    div = @super()
    div.style.backgroundColor = @$fill
    div.appendChild(@renderSlot slot) for slot in @slots.children
    return div

  # Containers fill their available space
  .setOnResize (size)->
    @$width = size.width
    @$height = size.height
    slot.resize(size) for slot in @slots.children

  .register()
