# Overview
Revisionist is a simple tool to help you manage versions of content in your web application.
Everytime your data changes, you can save it as a revision in a Revisionist instance.
You can then access the last x versions of your content (10 by default).

Revisionist is open source. View the [annotated source code](http://inf0rmer.github.io/revisionist/docs/annotated.html).

# Get it

## Through [Bower](http://bower.io/)
```bower install revisionist```

## Through [NPM](https://npmjs.org/)
```npm install revisionist```

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

**diff(version1, version2)**

Presents the difference between two versions.
If no parameters are passed in, the two latest versions are assumed.
If only the first parameter is passed, it is checked against the version before it.

Calling diff returns a hash with two keys, ```old``` and ```new```, containing the values for the oldest and newest versions passed in.

```javascript
rev.change(2)
rev.change(10)

rev.diff()
// -> { old: 2, new: 10 }
```

**visualDiff(version1, version2)**

This function will produce an HTML annotated diff string. If any non-String values are detected, an Error will be thrown.

```javascript
rev.change('fox')
rev.change('the brown fox jumped over the lazy wizard')

rev.visualDiff()
// -> <ins>the </ins><ins>brown </ins> fox <ins>jumped </ins><ins>over </ins><ins>the </ins><ins>lazy </ins><ins>wizard\n</ins>
```

**getLatestVersionNumber**

Returns the index for the last saved version. The earliest version stored is always 0, so:

```javascript
rev.change('once')
rev.change('twice')
rev.change('thrice')

rev.getLatestVersionNumber()
// -> 2
```

**clear**

Clears the internal cache for this instance.

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
