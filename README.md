# Overview
Revisionist is a simple tool to help you manage versions of content in your web application.
Everytime your data changes, you can save it as a revision in a Revisionist instance.
You can then access the last x versions of your content (10 by default).

Revisionist is open source. View the [annotated source code](http//inf0rmer.github.io/revisionist/docs/revisionist.html).

# How to use it

## In a ```<script>``` tag
Include the script in your page. A global "Revisionist" variable will be made available.

```javascript
rev = new window.Revisionist()
```

## With an AMD loader
Using an AMD loader such as [RequireJS](http://requirejs.org):

```javascript
require(['path/to/revisionist'], function(Revisionist) {
  rev = new Revisionist()
});
```

## In Node

``` javascript
Revisionist = require('path/to/revisionist')
rev = new Revisionist()
```

# API

Any instance has these two methods available:

**change(newValue)**

Creates a new revision. It returns the same value you passed in
```javascript
rev.change('bananas')
// -> 'bananas'
```

**recover(version)**

Recovers a previous version of your content and returns it.
```javascript
rev.change('tomatoes')

rev.recover(0)
// -> 'bananas'

rev.recover(1)
// -> 'tomatoes'
```

# Options
When creating a Revisionist instance, you can pass it an options hash to change the default behaviour. The available options are:

**versions | Number**
The maximum number of revisions you wish to store. Defaults to 10.

**plugin | String**
The plugin you wish to use with this instance. The plugin must have been registered before using the class method ```registerPlugin```

# Plugin Architecture
Revisionist uses a plugin architecture, so you can wrap around it's two main functions, ```change``` and ```recover``` to implement your own logic.

The "Simple" plugin shipped by default simply stores and returns the values as they're passed in.

## Authoring a plugin
To write a plugin, all you really have to do is provide Revisionist with a hash containing two methods:

**change(newValue)**

This method will be called by the Revisionist instance when you do ```instance.change("bananas")```. In this case, your implementation of ```change``` would receive an argument with a value of ```bananas```.

**recover(oldValue)**

This method will be called by the Revisionist instance when you do ```instance.recover(2)```. Your implementation of ```recover``` gets an argument with the value previously stored as revision #2.

Both of these methods are executed in the context of your own plugin.

### Registering and Unregistering a plugin
The ```Revisionist``` class exposes a class method to register your plugins.

**registerPlugin(name, hash)**

Registers a plugin with a name and a hash containing ```change``` and ```recover``` functions. If your plugin does not follow this naming convention, it will not work properly.

Example:
```javascript
MyPlugin = {
  change: function(newValue) {},
  recover: function(oldValue) {}
}

Revisionist.registerPlugin('myPlugin', MyPlugin);
```

**unregisterPlugin(name)**

Unregisters a plugin with a given name.

Example:
```javascript
Revisionist.unregisterPlugin('myPlugin')
// MyPlugin is not available anymore
```
