# Methods for measuring text
class window.SUITE.TextMetrics
  constructor: (cfg)->
    if !SUITE._hiddenCanvas? then SUITE._hiddenCanvas = @createCanvas()
    @ctx = SUITE._hiddenCanvas.getContext "2d"

    if cfg instanceof SUITE.Component or cfg instanceof SUITE.ModuleAPI
      @font = if cfg.$fontFamily instanceof Array
          "'" + cfg.$fontFamily.join("', '") + "'"
        else
          "'" + cfg.$fontFamily + "'"

      @fontSize = cfg.$fontSize
      @fontWeight = cfg.$fontWeight
      @letterSpacing = cfg.$letterSpacing

    else
      @font = "sans-serif"
      @fontSize = 18
      @fontWeight = "normal"
      @letterSpacing = 0

  createCanvas: ()->
    c = document.createElement "canvas"
    c.style.display = "none"
    document.body.appendChild c
    return c

  measure: (string)->
    @ctx.font = (if @fontWeight? then "#{@fontWeight} ") + @fontSize + "px " + @font
    width = @ctx.measureText(string).width
    width += (string.length - 1) * @letterSpacing
    return {width: width, height: @fontSize}
