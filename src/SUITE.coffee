###
  SUITE: Scriptable UI Templating Engine
  Keaton Brandt, 3am LLC
  -----------------------------------------
  A structured layout system for the modern
  web, providing a light-weight framework
  on which to build complex web app UIs.
  In many ways it is set up as a cross
  between FB React and Apple's UIKit.
  -----------------------------------------
###

window.SUITE =
  modules: {}
  config:

    # Shows up in a comment on top of the stage
    header: "This HTML was auto-generated by SUITE (suitejs.com). Do not edit directly."

    # Some components create HTML elements with specific IDs or classes
    # These must be prefixed to avoid conflicts
    id_prefix: "sc__" # Suite Component

    # Whether to add a [data-component] attribute to each component's top-level HTML tags
    component_attribute: true


# CORE FUNCTIONALITY IMPORTS ================================================================
#@prepros-append ./helpers.coffee
#@prepros-append ./types.coffee
#@prepros-append ./property.coffee
#@prepros-append ./events.coffee
#@prepros-append ./module.coffee
#@prepros-append ./animation.coffee
#@prepros-append ./style.coffee
#@prepros-append ./attributes.coffee
#@prepros-append ./module-api.coffee
#@prepros-append ./component.coffee
#@prepros-append ./stage.coffee
#@prepros-append ./template.coffee

# OPTIONAL IMPORTS ==========================================================================
#@prepros-append ./optional/module-builder.coffee
#@prepros-append ./optional/json-templating.coffee

# BUILT-IN COMPONENT IMPORTS ================================================================
#@prepros-append ../modules/core.coffee
#@prepros-append ../modules/container.coffee
#@prepros-append ../modules/box.coffee
#@prepros-append ../modules/stack.coffee
#@prepros-append ../modules/dialog.coffee
