# The simplest and probably most useful module
# Embeds HTML in a SUITE view
new window.SUITE.ModuleBuilder("html")
  .extend "container"
  .addProperty "html", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@rootElement? then return
    @rootElement.innerHTML = val

  .setInitializer ()->
    new SUITE.StyleManager().addStyle(
      new SUITE.CSSRule "." + SUITE.config.id_prefix + "htmlblock *",
        position: "static"
    )

  .setRenderer ()->
    div = @super()
    div.className += SUITE.config.id_prefix + "htmlblock"
    div.innerHTML = @$html
    div.style.overflow = "scroll"
    return div

  .register()


# A different way of adding HTML to the page: through an iFrame
new window.SUITE.ModuleBuilder("iframe")
  .extend "box"
  .addProperty "src", [SUITE.PrimitiveType.String], undefined, (val)->
    if !@rootElement? then return
    @rootElement.setAttribute "src", val

  .setRenderer ()->
    frame = @super("iframe")
    frame.setAttribute "src", @$src
    return frame

  .register()
