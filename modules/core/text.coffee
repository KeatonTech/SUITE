# Holds a single line of text. Multiple lines of text will need an HTML box
new window.SUITE.ModuleBuilder("text")
  .extend("fixed-size-element")

  .addProperty "string", [SUITE.PrimitiveType.String], "", (val)->
    if !@rootElement? then return
    @rootElement.innerHTML = val
    @updateSize()

  .addProperty "color", [SUITE.PrimitiveType.Color]
  .addProperty "font", [SUITE.PrimitiveType.String,SUITE.PrimitiveType.List], ["sans-serif"],
    ()-> @updateSize()
  .addProperty "fontSize", [SUITE.PrimitiveType.Number], 12, ()-> @updateSize()
  .addProperty "letterSpacing", [SUITE.PrimitiveType.Number], 0, ()-> @updateSize()

  .addStyle "text",
    color: ()-> @$color
    fontSize: ()-> @$fontSize
    fontFamily: ()->
      if @$font instanceof Array then "'#{@$font.join(', ')}'" else "'#{@$font}'"
    letterSpacing: ()-> @$letterSpacing

  .setRenderer ()->
    p = @super("p")
    p.innerHTML = @$string
    @applyStyle p, "text"
    @updateSize()
    return p

  .addMethod "computeSize", ()-> return new SUITE.TextMetrics(this).measure(@$string)

  .register()
