# Very simple Transition system
# Most of the functional code is part of attributes.coffee
class window.SUITE.Transition
  constructor: (duration = 300, easing = "ease-out")->
    @duration = duration
    @easing = easing

    @elements = []
    @attributes = []

  addAttribute: (element, attr, value)->
    index = @elements.indexOf element
    if index is -1
      index = @elements.length
      @elements.push element
      @attributes.push {}
    @attributes[index][attr] = value

  addAttrs: (element, attrs)->
    new SUITE.AttrFunctionFactory(element, this)(attrs)

  run: ()->
    for i, attrs of @attributes
      element = @elements[i]
      @_animateAttrs element, attrs

  _animateAttrs: (element, attrs)->

    # Set up CSS3 transitions
    transition_strings = for name, value of attrs
      "#{_sh.camelToDash(name)} #{@duration}ms #{@easing}"
    transition_style = transition_strings.join ","
    prefixes = ["","-webkit-","-moz-","-ms-"]
    full_style = ("#{p}transition:#{transition_style}" for p in prefixes).join(";")
    element.setAttribute("style", element.getAttribute("style") + full_style)

    # Make the style changes
    wait 5, ()=>
      element.style[name] = value for name, value of attrs

      # Clean up the CSS3 transitions
      wait @duration+5, ()->
        element.style.transition = ""
        element.style.webkitTransition = ""
        element.style.mozTransition = ""
        element.style.msTransition = ""


# Animations are collections of transitions that execute in order
class window.SUITE.Animation
  constructor: ()->
    @times = []
    @transitions = []

  addTransition: (time, transition)->
    for existing_time in @times
      if Math.abs(existing_time - time) <= 10
        console.log "Transitions must be at least 11ms apart to prevent CSS conflicts"
        return false

    @times.push time
    @transitions.push transition
    return @transitions.length - 1

  run: ()->
    for i, time of @times
      wait time, ((transition)-> ()->
        transition.run()
      )(@transitions[i])


window.SUITE._currentTransition = undefined

# Totally not thread safe but it's JS so ¯\_(ツ)_/¯
window.SUITE.AnimateChanges = (transition, func)->
  if window.SUITE._animationState.blocked
    return window.SUITE._animationState.queue.push [transition, func]

  window.SUITE._animationState.blocked = true
  if typeof transition is 'number' then transition = new SUITE.Transition transition
  window.SUITE._currentTransition = transition
  func()
  window.SUITE._currentTransition.run()
  window.SUITE._currentTransition = undefined

  wait window.SUITE._animationState.freq, ()->
    window.SUITE._animationState.blocked = false
    if window.SUITE._animationState.queue.length > 0
      [transition, func] = window.SUITE._animationState.queue.shift()
      window.SUITE.AnimateChanges transition, func

# Makes sure CSS changes can propogate between animations
window.SUITE._animationState =
  freq: 20
  blocked: false
  queue: []
