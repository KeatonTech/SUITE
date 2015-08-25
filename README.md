# SUITE
### Scriptable UI Templating Engine
***

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
component-name[$jsVarName][#id][.class[.class]]
```

Where component-name is the name of the module, #id is the HTML id and .class is the HTML
class. $jsVarName automatically attaches the element to the template object as a variable.
This means no more query selectors, everything you need is already there in a variable. So
changing the dialog's size and then showing it is as simple as:

```coffeescript
dialog_setup.dialog.$width = 640
dialog_setup.dc.showDialog()
```

### Building a new module

*This syntax is still in progress, I'll document it as soon as it stabilizes*
