# A simple and fast way to create complex templates in Javascript
window.SUITE.ParseTemplate = (json)->
  if Object.keys(json).length == 0 then return

  # If there are multiple top-level objects they must be wrapped in a container
  if Object.keys(json).length > 1
    container = new SUITE.Component "container"
    for selector, properties of json
      single_template = {}
      single_template[selector] = properties
      container.addChild SUITE.ParseTemplate single_template
    return container

  # Selectors determine the fundamental properties of the component, and use the
  # following format: component-name[$jsVarName][#id][.class[.class]]
  selector_regex = ///
                   ([A-Za-z0-9\-\_]+)       # Component Name
                   (\$[A-Za-z0-9\-\_]+)?    # JS Variable Name
                   (\#([A-Za-z0-9\-\_]+))?  # HTML ID
                   (\.([A-Za-z0-9\-\_]+))?  # HTML Classes
                   ///
  parse_selector = (selector)->
    selector = selector.replace("<","").replace(">","")
    match = selector.match selector_regex
    if !match? then throw new Error "Invalid selector: '#{selector}'"

    [_,component, jsvar, _, id, _, classes] = match
    classes = if classes? then classes.replace ".", " "
    return [component, jsvar, id, classes]

  # This is where the magic happens
  build_recursive = (selector, properties)->
    [component_name, jsvar, id, classes] = parse_selector selector
    component = new SUITE.Component component_name
    if id? and component.hasPropertyValue("id") then component.$id = id
    if classes? and component.hasPropertyValue("class") then component.$class = classes

    for name, val of properties
      if name[0] == "$" then component[name] = val
      else if component._module.slots[name]?
        if !(properties instanceof Object)
          throw new Error "Expected component(s) on slot '#{name}', got #{typeof properties}"
        if comp_count = Object.keys(properties).length == 0
          throw new Error "Expected component(s) on slot '#{name}', got none"
        if !component._module.slots[name].isRepeated and comp_count > 1
          throw new Error "Slot '#{name}' can only accept 1 component, got #{comp_count}"

        for slot_selector, slot_properties of val
          component.fillSlot name, build_recursive(slot_selector, slot_properties)

      else
        throw new Error "No slot named '#{name}' exists on module '#{component_name}'"

    if jsvar? then window[jsvar] = component
    return component

  single_key = Object.keys(json)[0]
  return build_recursive single_key, json[single_key]
