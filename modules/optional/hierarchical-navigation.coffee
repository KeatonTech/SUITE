# Similar to UINavigationController on iOS, this module manages, renders and animates
# multi-level navigation stacks for use on mobile and in sidebars.
new window.SUITE.ModuleBuilder("hierarchical-navigation")
  .extend "absolute-element"

  # PAGE MANAGEMENT =========================================================================

  # One component per page
  .addSlot "pages", true

  # Initialize page management variables like @_pageStack
  .setInitializer ()->
    if @slots.pages.length is 0
      throw new Error "<hierarchical-navigation> must have default page."
    @_pageStack = [@slots.pages[0]]
    @_pageIndex = 0
    @_animating = false
    @_loading = false

  # $generatePage is a function that takes two arguments, an object of data about the
  # requested page, and a callback function. It can either return a template/component or
  # return nothing and send the template/component to the callback function.
  .addProperty "generatePage", [SUITE.PrimitiveType.Function], ()->
    throw new Error "Must override $generatePage on <hierarchical-navigation>"

  # Run $generatePage and add the returned component to the stack
  .addMethod "push", (pageData)->
    component = $generatePage pageData, @_pushComponent
    if !component? then @_startLoading()
    else @_pushComponent component

  # Move up the stack
  .addMethod "pop", ()-> @_animateTo @_pageIndex-1, ()-> @_pageStack.pop()

  # Move to a specific page
  .addMethod "switchTo", (i)-> @_animateTo i

  # Internal method, runs on result of $generatePage
  .addMethod "_pushComponent", (component)->
    if !component? then return
    if !(component instanceof SUITE.Component) or !(component instanceof SUITE.Template)
      return

    @_finishLoading()
    @_pageStack.push component
    @_animateTo @_pageStack.length-1


  # RENDERING & ANIMATION ===================================================================

  .addProperty "duration", [SUITE.PrimitiveType.Number], 200

  .addMethod "_animateTo", (index, callback)->
    if index >= @_pageStack.length or index < 0
      throw new Error "<hierarchical-navigation> Page index #{index} out of bounds."

    if @_animating then return
    @_animating = true

    goRight = index > @_pageIndex
    newPage = @slots.pages[index]
    newPage.$x = if goRight then @$width else -newPage.$width
    @appendElement newPageElement = newPage.render()

    currentPage = @slots.pages[@_pageIndex]
    SUITE.AnimateChanges @$duration, ()=>
      currentPage.$x = if goRight then -currentPage.$width else @$width
      newPage.$x = 0

    wait @$duration, ()=>
      currentPage.unrender()
      @setElement "currentPage", newPageElement
      @_pageIndex = index
      @resize()
      if callback then callback(true)
      @_animating = false


  .setRenderer ()->
    div = @super()

    pageElement = @slots.pages[@_pageIndex].render()
    @setElement "currentPage", pageElement
    @appendElement pageElement

    return div


  # EVENTS ==================================================================================

  .addMethod "_startLoading", ()->
    if !@_loading
      @_loading = true
      @dispatchEvent "startLoading"

  .addMethod "_finishLoading", ()->
    if @_loading
      @_loading = false
      @dispatchEvent "finishLoading"


  # SIZING ==================================================================================

  .setOnResize (size)->
    page = @slots.pages[@_pageIndex]
    page.resize(size)
    @$width = page.$width
    @$height = page.$height

  .register()
