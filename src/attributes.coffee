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
            transition.addAttribute element, name, value
