[![Build Status](https://travis-ci.org/inf0rmer/revisionist.png?branch=master)](https://travis-ci.org/inf0rmer/revisionist)

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

**update(newValue)**

Creates a new revision. It returns the same value you passed in
```javascript
rev.update('bananas')
// -> 'bananas'
```

**recover(version, callback)**

Asynchronously recovers a previous version of your content.
```javascript
rev.update('tomatoes')

rev.recover(0, function(data){
  // data === 'bananas'
})

rev.recover(1, function(data){
  // data === 'tomatoes'
})
```

**diff(version1, version2, callback)**

Asynchronously presents the difference between two versions.
If no parameters are passed in, the two latest versions are assumed.
If only the first parameter is passed, it is checked against the version before it.

This function uses the Store's ```get``` methods directly instead of Revisionist's ```recover```, so the Plugin's code will not run when calling ```diff```.

Calling diff returns a hash with two keys, ```old``` and ```new```, containing the values for the oldest and newest versions passed in.

```javascript
rev.update(2)
rev.update(10)

rev.diff(0, 1, function(hash){
  // hash == { old: 2, new: 10 }
})
```

**visualDiff(version1, version2, callback)**

This function will produce an HTML annotated diff string. If any non-String values are detected, an Error will be thrown.

```javascript
rev.update('fox')
rev.update('the brown fox jumped over the lazy wizard')

rev.visualDiff(0, 1, function(html){
  // html === <ins>the </ins><ins>brown </ins> fox <ins>jumped </ins><ins>over </ins><ins>the </ins><ins>lazy </ins><ins>wizard\n</ins>
})
```

**getLatestVersionNumber**

Returns the index for the last saved version. The earliest version stored is always 0, so:

```javascript
rev.update('once')
rev.update('twice')
rev.update('thrice')

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
Revisionist uses a plugin architecture, so you can wrap around it's two main functions, ```update``` and ```recover``` to implement your own logic.

The "Simple" plugin shipped by default simply stores and returns the values as they're passed in.

## Authoring a plugin
To write a plugin, all you really have to do is provide Revisionist with a hash containing two methods:

**update(newValue)**

This method will be called by the Revisionist instance when you do ```instance.update("bananas")```. In this case, your implementation of ```update``` would receive an argument with a value of ```bananas```.

**recover(oldValue)**

This method will be called by the Revisionist instance when you do ```instance.recover(2)```. Your implementation of ```recover``` gets an argument with the value previously stored as revision #2.

Both of these methods are executed in the context of your own plugin.

### Registering and Unregistering a plugin
The ```Revisionist``` class exposes a class method to register your plugins.

**registerPlugin(name, hash)**

Registers a plugin with a name and a hash containing ```update``` and ```recover``` functions. If your plugin does not follow this naming convention, it will not work properly.

Example:
```javascript
MyPlugin = {
  update: function(newValue) {},
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

# Store Architecture
Revisionist uses a store architecture, so if you require more advanced storage functions (ie. localStorage, Redis, etc) you can write your own Store class.

The "Simple" store shipped by default stores the values using an in-memory cache in the form of an array.

## Authoring a Store
To write a store, you need to provide Revisionist with a Function with certain public API methods (plus anything else you might want).

### Defining the Store constructor

Using CoffeeScript:
```coffeescript

class MyStore
  constructor: (options) ->
    # Initialize here...

  set: (value, version) ->
    # Your implementation of "set"...

  myMethod: ->
    # Your implementation of "myMethod"...

```

Using Javascript:
```javascript

function MyStore(options) {
  // Initialize here...
}

MyStore.prototype.set = function(value, version) {
  // Your implementation of "set"...
};

MyStore.prototype.myMethod = function() {
  // Your implementation of "myMethod"...
};

```

The function constructor automatically receives the Revisionist instance options hash as an argument.

### Store API

**set (value, version)**

Stores a new version. The value is user-supplied and the version number is an Integer supplied by Revisionist stating which version number should be saved.

**get (version, callback)**

Retrieves the value for a specific version and executes the callback with it as an argument. The version number is an Integer supplied by Revisionist. It is already clamped to minimize chances that the version number is invalid.

**remove (version)**

Removes a version from the Store. This is typically called by Revisionist automatically when the Store's size reaches the maximum number of versions allowed.

**clear**

Fully empties the Store.

**size**

This should return an Integer containing the current size of the Store.

### Registering and Unregistering a Store
The ```Revisionist``` class exposes a class method to register your stores.

**registerStore(name, Store)**

Registers a store with a name and a constructor that follows the Store API. If your store does not implement these API methods, it will not work properly.

Example:
```javascript
var MyStore = function(options){
  //...
}
MyStore.prototype.get = function() {}
...

Revisionist.registerStore('myStore', MyStore);
```

**unregisterStore(name)**

Unregisters a store with a given name.

Example:
```javascript
Revisionist.unregisterStore('myStore')
// MyStore is not available anymore
```
