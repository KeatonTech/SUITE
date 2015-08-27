# Represents the top level component, which puts all the rendered stuff into the actual
# DOM of the actual page
class window.SUITE.Stage extends window.SUITE.Component
  constructor: (elementSelector)->
    if document.querySelectorAll(elementSelector).length > 1
      throw new Error "Please choose a unique selector (only applies to 1 element)"

    @html_container = document.querySelector elementSelector
    super "container"

    window.addEventListener "resize", ()=>
      @resize
        width: @html_container.offsetWidth
        height: @html_container.offsetHeight

  render: ()->
    _sh.time "Full stage render", ()=>

      # Get ready to track styles
      new window.SUITE.StyleManager()

      # Make sure the sizes are up to date
      @resize
        width: @html_container.offsetWidth
        height: @html_container.offsetHeight

      # Full view tree render
      container = super()

      # Add comment
      header_comment = document.createComment(SUITE.config.header)

      # Bundle it all up
      container.insertBefore header_comment, container.firstChild
      @html_container.appendChild container
