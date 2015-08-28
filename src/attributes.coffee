# Quick function to set attributes on DOM elements. Allows for automatic transition, without
# the modules having to do anything. Also prevents modules from needing to interact with
# actual DOM elements in most cases.
# This function returns an attribute function for an element w/ transition settings in place.
window.SUITE.AttrFunctionFactory = (default_element, transition)->
  (attributes_or_element, or_attributes)->

    # Two ways to call this function
    if attributes_or_element instanceof HTMLElement
      element = attributes_or_element
      attributes = or_attributes
    else
      element = default_element
      attributes = attributes_or_element

    # Apply non-style changes, keep the style changes
    style_changes = {}
    for name, value of attributes
      switch name.split(".")[0].toLowerCase()

        # Cover the basic HTML attributes
        when "id" or "src" or "href" or "rel" or "target" or "alt" or "title"
          if !element? then return
          element.setAttribute name, value

        # Custom HTML attributes, eg attr.data-name
        when "attr"
          if !element? then return
          attr_name = name.split(".")[1]
          element.setAttribute attr_name, value

        # Users can add or remove classes
        when "class"
          if !element? then return
          if value[0] is "+"
            classname = element.getAttribute "class"
            element.setAttribute "class", classname + " " + value.substr(1)
          else if value[0] is "-"
            classname = element.getAttribute "class"
            element.setAttribute "class", classname.replace value.substr(1), ""
          else
            element.setAttribute "class", value

        # Everything else is assumed to be a style, and can be animated if necessary
        else
          if typeof value is "number" and !(name in SUITE.UnitlessAttributes)
            value = "#{value}px"
          if !transition? then element.style[name] = value
          else
            style_changes[name] = value

    # If there's no transition, we've already applied all the changes so we're done
    if !transition? then return

    # Set up CSS3 transitions
    transition_strings = for name, value of style_changes
      "#{_sh.camelToDash(name)} #{transition.duration}ms #{transition.easing}"
    transition_style = transition_strings.join ","
    prefixes = ["","-webkit-","-moz-","-ms-"]
    full_style = ("#{p}transition:#{transition_style}" for p in prefixes).join(";")
    element.setAttribute("style", element.getAttribute("style") + full_style)

    # Make the style changes
    wait 5, ()->
      element.style[name] = value for name, value of style_changes

      # Clean up the CSS3 transitions
      wait 5, ()->
        element.setAttribute("style", element.getAttribute("style").replace(full_style,""))
