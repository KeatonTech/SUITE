# SUITE
### Scriptable UI Templating Engine

Suite is a lightweight UI framework for web applications inspired by both Facebook's React
and Apple's UIKit. It aims to abstract out the intricacies of HTML by creating its own view
structure comprised of functional components rather than DOM elements. This componentized
approach makes it easy to share code between projects, and encourages a clean & maintainable
code structure for your app. Suite components also use their own layout system, which leaves
CSS to just do what it's good at: styling things. Internally, Suite stays fast and nimble by
keeping things out of the DOM unless they are actually on-screen.

**tl;dr** Suite is a framework for interactive web components with their own layout system.

*Suite is still in the early stages of development. Everything is subject to change*

## Usage
### Terminology
* **Component:** The Suite equivalent of UIView/HTMLElement, represents a piece of the page.
* **Module:** A type of component. Modules provide a number of functions that determine how
  the component is rendered and how it behaves.
* **Property:** Each module defines properties that can be set on any component of their type
  at runtime. Properties determine the content, style, and layout of components.
* **Slot:** Some components contain other components, in the same way that a <div> can hold
  child divs. The difference in Suite is that a component can have multiple different places
  to put its children. For example, the two-column layout component has two slots, so child
  components can be added to either column.
* **Stage:** The top level component, bound to part of the HTML page.

### Building a template
Suite templates can be built a number of different ways. The easiest and smallest involves
Suite's unique JSON templating syntax, expressed here in Coffeescript:

```coffeescript
stage = new SUITE.Stage "body"

dialog_setup = SUITE.ParseTemplate
  "<dialog-container@dc>":
    dialog:
      "<dialog@dialog.dialog>":
        $width: 600
        $height: 400

stage.addChild dialog_setup
stage.render()
```

Field that begin with a dollar sign ("$") are properties of the component. Other fields are
slots that can contain one or more other components. The syntax of the component header is:

```
component-name[@jsVarName][#id][.class[.class]]
```

Where component-name is the name of the module, #id is the HTML id and .class is the HTML
class. @jsVarName automatically attaches the element to the template object as a variable.
This means no more query selectors, everything you need is already there in a variable. So
changing the dialog's size and then showing it is as simple as:

```coffeescript
dialog_setup.dialog.$width = 640
dialog_setup.dc.showDialog()
```

### Building a new module
The easiest way to create your own modules is to use the ModuleBuilder, based off of Java's
famous builder pattern. It allows you to configure your module, override functions, add
properties, and then register it with SUITE – all in one technically amounts to one line.

Here is annotated code for a simple two-column module

```coffeescript
new window.SUITE.ModuleBuilder("two-column")

  # visible-element provides basic properties like position and size
  .extend("visible-element")

  # The addSlot function takes two arguments: the name and optionally whether it's repeated.
  # Repeated slots can hold multiple components. For this example we'll assume each column
  # can only directly hold one thing. This isn't that limiting since that one thing can
  # itself be a container holding as many elements as you'd like.
  .addSlot("left-column", false)
  .addSlot("right-column", false)

  # Overrides the render() function, which turns the component into HTML
  .setRenderer ()->
    div = @super() # visible-element's render function returns a properly sized div

    # The renderSlot function takes either (slot) or (name, slot) and returns an HTMLElement
    # Naming a slot makes it easier to access the generated element later
    left = @renderSlot "left", @slots["left-column"]
    right = @renderSlot "right", @slots["right-column"]

    # The forceAttrs function sets attributes without causing an animation
    # It takes either (attr_object) or (html_element, attr_object)
    # If no element is passed it modifies the top level element, in this case div
    # @$width is the width variable of this component
    @forceAttrs left, width: @$width * @$split
    @forceAttrs right, width: @$width * (1 - @$split)

    # Add both of these rendered elements to the top-level div
    @appendElement left
    @appendElement right

  # This property controls the relative widths of the two columns
  # The function expects (name, type, default?, setter?)
  # The type should be an instance of SUITE.Type, it will construct one if you pass an array
  .addProperty "split", [SUITE.PrimitiveType.Number], 0.5, (val)->

    # Validation
    if val > 1 then return @$split = 1 # Setter will run again
    if val < 0 then return @$split = 0

    # The setter runs whenever this variable is modified (even with component.$split = x)
    @setAttrs @getElement("left"), width: @$width * val
    @setAttrs @getElement("right"), width: @$width * (1 - val)

  # Overrides the resize function, to make sure the columns stay the same size
  .setOnResize (size)->
    @forceAttrs @getElement("left"), width: @$width * @$split
    @forceAttrs @getElement("right"), width: @$width * (1 - @$split)

    # Also make sure elements inside the columns resize
    @slots["left-column"].resize(size)
    @slots["right-column"].resize(size)

  # Add this module to SUITE, so it can be added with "<two-column>" in templates
  .register()
```

Notice that all of the useful methods are prefixed with an @ sign here. This is coffeescript
syntax, it simply means "this". All module functions are called with this set to an instance
of SUITE.ModuleAPI, which is tied to a specific component. You don't get a reference to the
component directly, because frankly I don't trust you that much.

(Actually, I designed this for myself. I don't trust *me* that much. You're probably smarter)

Here's a bunch of functions you can use in the Module API:
* **super(args..):** Runs the superclass version of the current function
* **resize(size):** Has the component resize itself
* **render():** Returns an HTML representation of the component
* **fillSlot(name, component):** Adds a component to a named slot
* **removeSlotComponent(name, index):** Removes a specific component from a repeated slot
* **emptySlot(name):** Removes all components from a named slot
* **renderSlot(name, slot):** Runs slot.render() and sets it to a named element
* **getElement(name):** Get a named element
* **appendElement(element):** Adds an HTML element to the root element of the component
* **appendElement(name):** Adds a named element to the root element of the component
* **appendElement(element,element||name):** Adds an element to another element
* **removeElement(element||name):** Removes an element or named element from its parent
* **createElement(name, tag):** Runs document.createElement to create/return a named element

Named elements are mostly just a convenience, so you don't have to run querySelector a bunch.

## Status
SUITE is still in the early phases of development. API's are basically guaranteed to change.
I am working on building a full-scale website with this tech, which I find is a very good way
to guide development of a library. That means I will first focus on building out a module set
and getting all of the features I need. After that site launches I'll come back to this and
build out a testing framework and useful things like that.

If you'd like to help, I'll give you a million internet high-fives. Get in touch @keatontech,
or keaton.brandt@gmail.com.
