# Containers are kind of weird in SVG. They consist of an invisible group and a backing
# layer that displays the fill color. If there is no fill color, the backing is not created.
new window.SUITE.ModuleBuilder("container")
  .extend("absolute-element")
  .addSlot("children", true) # Repeated slot

  .addMethod "addChild", (child)->
    @fillSlot "children", child
    if @rootElement?
      newSlot = @slots.children[@slots.children.length - 1]
      @rootElement.appendChild @renderSlot newSlot
      newSlot.resize(@size)

  .addMethod "clearChildren", ()->
    @emptySlot "children"
    @unrender()

  # Rendered as a group, does not enforce any layout
  .setRenderer (type)->
    div = @super(type)
    div.appendChild(@renderSlot slot) for slot in @slots.children
    return div

  # Containers fill their available space
  .setOnResize (size)->
    @$width = size.width - @$x
    @$height = size.height - @$y
    slot.resize(size) for slot in @slots.children

  .register()
