# Revisionist

Revisionist is a simple tool to help you manage versions of content in your web application.
Everytime your data changes, you can save it as a revision in a Revisionist instance.
You can then access the last x versions of your content (10 by default).

## Plugin Architecture

Revisionist uses a plugin architecture, so you can override the default behavior of it's two main functions.

The "Simple" plugin shipped by default simply stores and returns the values as they're passed in.
