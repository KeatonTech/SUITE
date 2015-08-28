# Represents a piece of the view tree, with variables set for its various sub-components
# Templates must have one top level component
class window.SUITE.Template
  constructor: (topLevelComponent)->
    @_component = topLevelComponent
    @_namedComponents = []

  addComponentVariable: (name, component)->
    component._varname = name
    @_namedComponents.push name
    @[name] = component

  copy: ()->
    copy = new SUITE.Template @_component.copy()
    if @_component._varname then copy[@_component._varname] = @_component
    for component in copy._component.allSubComponents()
      if component._varname?
        copy[component._varname] = component
    return copy

  extend: (template)->
    for nc in template._namedComponents
      @[nc] = template[nc]
