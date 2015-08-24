# Very simple Transition system
# Most of the functional code is part of attributes.coffee
class window.SUITE.Transition
  constructor: (duration = 300, easing = "ease-out")->
    @duration = duration
    @easing = easing

window.SUITE._currentTransition = undefined

# Totally not thread safe but it's JS so ¯\_(ツ)_/¯
window.SUITE.AnimateChanges = (transition, func)->
  window.SUITE._currentTransition = transition
  func()
  window.SUITE._currentTransition = undefined
