# Globals provide a way to change values in multiple components with one setter
class window.SUITE.Global
  constructor: (value)->
    @value = value
    @deps = []
    @fdeps = []

  addDependency: (component, property)->
    @deps.push [component, property]

  addFunctionDependency: (f)->
    @fdeps.push f

  set: (value)->
    @value = value
    for [component, property] in @deps
      component[property] = value
    for f in @fdeps
      f.call this, value

# Expressions allow users to modify the values of globals
class window.SUITE.Expression extends window.SUITE.Global
  constructor: (globals..., func)->
    super()
    @globals = globals
    @func = func

    for g in @globals
      g.addFunctionDependency @update.bind this

    @update()

  update: ()->
    values = (g.value for g in @globals)
    output = @func.apply this, values
    @set output
