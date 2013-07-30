(function(global) {
  var Revisionist, SimplePlugin, extend;
  extend = function(target, other) {
    var prop;
    if (target == null) {
      target = {};
    }
    for (prop in other) {
      if (typeof source[prop] === 'object') {
        target[prop] = extend(target[prop], source[prop]);
      } else {
        target[prop] = source[prop];
      }
    }
    return target;
  };
  Revisionist = (function() {
    var _cache, _currentVersion, _plugins;

    _cache = [];

    _plugins = {};

    _currentVersion = 0;

    Revisionist.register = function(namespace, Plugin) {
      if (_plugins[namespace] != null) {
        throw new Error("There's already a plugin in this namespace!");
      }
      return _plugins[namespace] = Plugin;
    };

    Revisionist.prototype.options = {
      versions: 10,
      plugin: 'simple'
    };

    function Revisionist(options) {
      this.options = extend(this.options, options);
    }

    Revisionist.prototype.change = function(newValue) {
      var plugin;
      plugin = _plugins[this.options.plugin];
      if ((plugin != null ? plugin.change : void 0) == null) {
        throw new Error("Plugin " + this.options.plugin + " is not available!");
      }
      newValue = plugin.change.call(this, newValue);
      _currentVersion += 1;
      _cache.push(newValue);
      if (_currentVersion > this.options.versions) {
        _cache.shift();
      }
      return newValue;
    };

    Revisionist.prototype.recover = function(version) {
      var plugin;
      plugin = _plugins[this.options.plugin];
      if ((plugin != null ? plugin.recover : void 0) == null) {
        throw new Error("Plugin " + this.options.plugin + " is not available!");
      }
      if (version == null) {
        version = _currentVersion - 1;
      }
      if (version < 0) {
        throw new Error("Version needs to be a positive number");
      }
      if (version > _cache.length) {
        throw new Error("Not enough versions yet");
      }
      return plugin.recover.call(this, _cache[version]);
    };

    Revisionist.prototype.clear = function() {
      return _cache = [];
    };

    return Revisionist;

  })();
  SimplePlugin = {
    change: function(newValue) {
      return newValue;
    },
    recover: function(prevValue) {
      return prevValue;
    }
  };
  Revisionist.register('simple', SimplePlugin);
  if (typeof define === 'function' && (define.amd != null)) {
    return define(function() {
      return Revisionist;
    });
  } else if (typeof module !== void 0 && (module.exports != null)) {
    return module.exports = Revisionist;
  } else {
    return global['Revisionist'] = Revisionist;
  }
})(this);

/*
//@ sourceMappingURL=revisionist.js.map
*/