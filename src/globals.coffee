# Globals provide a way to change values in multiple components with one setter
class window.SUITE.Global
  constructor: (value)->
    @value = value
    @deps = []

  addDependency: (component, property)->
    @deps.push [component, property]

  set: (value)->
    @value = value
    for [component, property] in @deps
      component[property] = value
