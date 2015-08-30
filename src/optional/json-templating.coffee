# A simple and fast way to create complex templates in Javascript
window.SUITE.ParseTemplate = (json)->
  _sh.time "JSON Template Construction", ()-> SUITE._parseTemplateInternal json

window.SUITE._parseTemplateInternal = (json)->
  if Object.keys(json).length == 0 then return

  # If there are multiple top-level objects they must be wrapped in a container
  if Object.keys(json).length > 1
    container = new SUITE.Component "container"
    template = new SUITE.Template container
    for selector, properties of json
      single_template = {}
      single_template[selector] = properties
      new_template = SUITE._parseTemplateInternal single_template
      template.extend new_template
      container.addChild new_template._component
    return template

  # Selectors determine the fundamental properties of the component, and use the
  # following format: component-name[$jsVarName][#id][.class[.class]]
  selector_regex = ///
                   ([A-Za-z0-9\-\_]+)       # Component Name
                   (\@([A-Za-z0-9\-\_]+))?    # JS Variable Name
                   (\#([A-Za-z0-9\-\_]+))?  # HTML ID
                   (\.([A-Za-z0-9\-\_]+))?  # HTML Classes
                   ///
  parse_selector = (selector)->
    selector = selector.replace("<","").replace(">","")
    match = selector.match selector_regex
    if !match? then throw new Error "Invalid selector: '#{selector}'"

    [_,component, _, jsvar, _, id, _, classes] = match
    classes = if classes? then classes.replace ".", " "
    return [component, jsvar, id, classes]

  # Allows build_recursive to work with either objects or arrays
  iterate_properties = (properties)->
    tuples = []
    if properties instanceof Array
      if properties.length % 2 is 1
        throw new Error "Invalid properties array: Must have an even length."
      for i in [0...properties.length/2]
        tuples.push [properties[i*2], properties[i*2+1]]
    else if properties instanceof Object
      tuples.push([name, val]) for name, val of properties
    else throw new Error "Expected Object or Array for template properties"
    return tuples

  # This is where the magic happens
  build_recursive = (selector, properties, template)->
    [component_name, jsvar, id, classes] = parse_selector selector
    component = new SUITE.Component component_name
    if id? and component.hasPropertyValue("id") then component.$id = id
    if classes? and component.hasPropertyValue("class") then component.$class = classes

    top_level = !template?
    if top_level then template = new SUITE.Template component

    for [name, val] in iterate_properties properties
      if name[0] == "$" then component[name] = val

      # Handlers can be bound from here
      else if name.length > 1 and name[0] == "o" and name[1] == "n"
        components.addHandler name, val

      # When there is only one slot, components can be added on the top level
      else if name[0] == "<"
        if Object.keys(component._module.slots).length != 1
          throw new Error "Cannot add children on the top level: Module has multiple slots"
        slot_name = Object.keys(component._module.slots)[0]
        component.fillSlot slot_name, build_recursive(name, val, template)

      # If there are multiple slots, they must be named
      else if component._module.slots[name]?
        if !(val instanceof Object) and !(val instanceof Array)
          throw new Error "Expected component(s) on slot '#{name}', got #{typeof val}"
        if comp_count = Object.keys(val).length == 0
          throw new Error "Expected component(s) on slot '#{name}', got none"
        if !component._module.slots[name].isRepeated and comp_count > 1
          throw new Error "Slot '#{name}' can only accept 1 component, got #{comp_count}"

        for [slot_selector, slot_properties] in iterate_properties val
          component.fillSlot name, build_recursive(slot_selector, slot_properties, template)

      else
        throw new Error "No slot named '#{name}' exists on module '#{component_name}'"

    if jsvar? then template.addComponentVariable jsvar, component
    return if top_level then template else component

  single_key = Object.keys(json)[0]
  return build_recursive single_key, json[single_key]
