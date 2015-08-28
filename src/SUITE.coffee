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
#@prepros-append ./text.coffee
#@prepros-append ./module-api.coffee
#@prepros-append ./component.coffee
#@prepros-append ./stage.coffee
#@prepros-append ./template.coffee

# OPTIONAL IMPORTS ==========================================================================
# These are necessary to use SUITE normally, but could be compiled out in the future

#@prepros-append ./optional/module-builder.coffee
#@prepros-append ./optional/json-templating.coffee

# CORE MODULES ==============================================================================
#@prepros-append ../modules/core/core.coffee
#@prepros-append ../modules/core/container.coffee
#@prepros-append ../modules/core/layouts.coffee
#@prepros-append ../modules/core/box.coffee
#@prepros-append ../modules/core/text.coffee
#@prepros-append ../modules/core/interactive.coffee
