# Similar to UINavigationController on iOS, this module manages, renders and animates
# multi-level navigation stacks for use on mobile and in sidebars.
new window.SUITE.ModuleBuilder("hierarchical-navigation")
  .extend "absolute-element"

  # PAGE MANAGEMENT =========================================================================

  # One component per page
  .addSlot "pages", true

  # Initialize page management variables
  .setInitializer ()->
    if @slots.pages.length is 0
      throw new Error "<hierarchical-navigation> must have default page."
    @_pageIndex = 0
    @_animating = false
    @_loading = false

  # $generatePage is a function that takes two arguments, an object of data about the
  # requested page, and a callback function. It can either return a template/component or
  # return nothing and send the template/component to the callback function.
  .addProperty "generatePage", [SUITE.PrimitiveType.Function], ()->
    throw new Error "Must override $generatePage on <hierarchical-navigation>"

  # Run $generatePage and add the returned component to the stack
  .addMethod "push", (pageData, replaceParent = false)->
    pushFunction = @_pushComponent.bind(this, replaceParent)
    component = @$generatePage pageData, pushFunction, replaceParent
    if !component? then @_startLoading(replaceParent)

  # Move up the stack
  .addMethod "pop", ()->
    @dispatchEvent "onPop"
    @_animateTo @_pageIndex-1, false, ()=> @slots.pages.pop()

  # Move to a specific page
  .addMethod "switchTo", (i)-> @_animateTo i, i < @_pageIndex

  # Internal method, runs on result of $generatePage
  .addMethod "_pushComponent", (replaceParent, component)->
    if !component? then return
    if !(component instanceof SUITE.Component) and !(component instanceof SUITE.Template)
      return

    @_finishLoading()

    if component instanceof SUITE.Template then component = component._component
    @slots.pages.push component

    @_animateTo @slots.pages.length-1, true, ()=>
      if replaceParent
        @slots.pages.splice -2, 1
        @_pageIndex -= 1


  # RENDERING & ANIMATION ===================================================================

  .addProperty "duration", [SUITE.PrimitiveType.Number], 200

  .addMethod "_animateTo", (index, goRight, callback, oncomplete)->
    if index >= @slots.pages.length or index < 0
      throw new Error "<hierarchical-navigation> Page index #{index} out of bounds."

    if @_animating then return
    @_animating = true

    newPage = @slots.pages[index]
    newPage.$x = 0
    newPage.resize(@size)
    newPage.$x = if goRight then @$width else -newPage.$width
    @appendElement newPageElement = newPage.render()

    currentPage = @slots.pages[@_pageIndex]
    SUITE.AnimateChanges @$duration, ()=>
      currentPage.$x = if goRight then -currentPage.$width else @$width
      newPage.$x = 0

    wait @$duration, ()=>
      @_pageIndex = index
      if callback then callback(true)
      @_animating = false

      # Give the animation some extra time to complete
      wait @$duration, ()=>
        currentPage.unrender()
        if oncomplete then oncomplete()


  .setRenderer ()->
    div = @super()
    div.style.overflow = "hidden"

    pageElement = @slots.pages[@_pageIndex].render()
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
    @$width = size.width - @$x
    @$height = size.height - @$y
    for slot in @slots.pages
      oldX = slot.$x
      slot.$x = 0
      slot.resize(@size)
      slot.$x = oldX

  .register()
