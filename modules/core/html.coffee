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
    return div

  .register()
