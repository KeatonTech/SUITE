# Exactly what you'd expect
new window.SUITE.ModuleBuilder("image")
  .extend("absolute-element")

  .addProperty "url", [SUITE.PrimitiveType.String], "", (val)->
    if image = @getElement "image"
      image.setAttribute "src", @getSrc()

  .addProperty "has2x", [SUITE.PrimitiveType.Boolean], true
  .addProperty "hasSVG", [SUITE.PrimitiveType.Boolean], false

  # Return the correct link to the image
  .addMethod "getSrc", ()->
    svg_support = @$hasSVG and document.implementation.hasFeature(
      "http://www.w3.org/TR/SVG11/feature#Image", "1.1")
    if window.devicePixelRatio > 2 and svg_support
      return @$url.replace /\.([^\.]*)$/,'.svg'
    else if @$has2x and window.devicePixelRatio > 1
      return @$url.replace /\.([^\.]*)$/,'@2x.$1'
    else
      return @$url

  .addStyle "imageStyle",
    height: "100%"
    margin: "0 auto"

  .setRenderer ()->
    div = @super()

    image = @createElement "image", "img"
    image.setAttribute "src", @getSrc()
    @applyStyle image, "imageStyle"
    @appendElement div, image

    return div

  .register()
