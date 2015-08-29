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
* **Style:** Essentially the same as a CSS style, but attributes can be javascript functions
  that depend on object properties.
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

SUITE has a built in CSS3 animation system that works with almost everything automatically.
So, animating the height of the dialog is as easy as:

```coffeescript
SUITE.AnimateChanges(new SUITE.Transition(300, "linear"), function(){
  dialog_setup.dialog.$height = 300
});
```

**Pro Tip:** Most components have only one named slot. In these cases, it is not necessary
to label the slot in the template. You can simply add child elements on the top level.

```coffeescript
SUITE.ParseTemplate
  "<container>":
    "<text>":
      $string: "SO EASY!"
```

### Building a new module
The easiest way to create your own modules is to use the ModuleBuilder, based off of Java's
famous builder pattern. It allows you to configure your module, override functions, add
properties, and then register it with SUITE – all in one technically amounts to one line.

Here is annotated code for the floating layout module, which positions a child element
within its parent.

```coffeescript
# Floating layouts are positioned relative to their parent using a fractional location, where
# (0,0) puts them in the top left and (0.5,0.5) centers them.
new window.SUITE.ModuleBuilder("float-layout")

  # The visible-element component provides things like basic styling
  .extend "visible-element"

  # Slots can hold child elements. This module only has one slot, but you can imagine
  # something like a multi-column layout needing more.
  # The addSlot function takes 2 arguments: The name and whether the slot is repeated.
  # Repeated slots can accept multiple components.
  .addSlot "child", false

  # Define two properties that let the user define where the box floats
  .addProperty "floatX", [SUITE.PrimitiveType.Number], 0.5
  .addProperty "floatY", [SUITE.PrimitiveType.Number], 0.5

  # These properties are mostly for internal use, but there may be some situations where
  # the user wants to edit them
  .addProperty "childWidth", [SUITE.PrimitiveType.Number]
  .addProperty "childHeight", [SUITE.PrimitiveType.Number]
  .addProperty "containerWidth", [SUITE.PrimitiveType.Number]
  .addProperty "containerHeight", [SUITE.PrimitiveType.Number]

  # This function is called by this component's parent whenever its size changes.
  # The 'size' argument is the space available to this component. The component can resize
  # itself by setting @$width/@$height here, but this one doesn't need that.
  .setOnResize (size)->
    @$containerWidth = size.width
    @$containerHeight = size.height

  # This function is called whenever the size of the child element changes
  .addSlotEventHandler "child", "onResize", (size)->
    @$childWidth = @slots.child.$width
    @$childHeight = @slots.child.$height

  # Styles can have both static and function properties. Static properties are turned into
  # normal CSS. Function properties are analyzed to see which of the component's properties
  # they rely on, and are re-evaluated whenever any of those properties change!
  .addStyle "floating",
    left: ()-> (@$containerWidth - @$childWidth) * @$floatX
    top: ()-> (@$containerHeight - @$childHeight) * @$floatY

  # The renderer creates an HTML representation of the component
  .setRenderer ()->

    # Call the render function of the visible-element module, which returns a div
    div = super()

    # Apply our floating style to this div. The left and top properties will now be
    # automatically updated when this component's properties change
    @applyStyle div, "floating"

    # Render the child slot
    div.appendChild @renderSlot @slots.child

    return div

  # Add this module to SUITE under the name "float-layout"
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
* **dispatchEvent(event_name):** Runs all registered handlers for event_name on the component
* **createComponent(module_name):** Creates and returns a new SUITE component (not its API)
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
