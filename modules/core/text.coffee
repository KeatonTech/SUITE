# Holds a single line of text. Multiple lines of text will need an HTML box
new window.SUITE.ModuleBuilder("text")
  .extend("fixed-size-element")

  .addProperty "string", [SUITE.PrimitiveType.String], "", (val)->
    if !@rootElement? then return
    @rootElement.innerHTML = val
    @updateSize()

  .addProperty "color", [SUITE.PrimitiveType.Color]
  .addProperty "fontFamily", [SUITE.PrimitiveType.String,SUITE.PrimitiveType.List], null,
    ()-> @updateSize()
  .addProperty "fontWeight", [SUITE.PrimitiveType.String], null, ()-> @updateSize()
  .addProperty "fontSize", [SUITE.PrimitiveType.Number], 12, ()-> @updateSize()
  .addProperty "letterSpacing", [SUITE.PrimitiveType.Number], 0, ()-> @updateSize()

  .addStyle "text",
    color: ()-> @$color
    fontSize: ()-> @$fontSize
    fontFamily: ()-> if @$fontFamily? then "'#{@$fontFamily.join("', '")}'"
    fontWeight: ()-> @$fontWeight
    letterSpacing: ()-> @$letterSpacing
    lineHeight: ()-> @$height + "px"

  .setRenderer ()->
    p = @super("p")
    p.innerHTML = @$string
    @applyStyle p, "text"
    @updateSize()
    return p

  .addMethod "computeSize", ()-> return new SUITE.TextMetrics(this).measure(@$string) + 2

  .register()
