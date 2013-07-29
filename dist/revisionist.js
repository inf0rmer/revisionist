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
    var _cache, _plugins;

    _cache = [];

    _plugins = {};

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
      this._currentVersion = 0;
    }

    Revisionist.prototype.change = function(newValue) {
      newValue = _plugin.change.call(this, this._currentVersion);
      this._currentVersion += 1;
      _cache.push(newValue);
      if (this._currentVersion > this.options.versions) {
        _cache.shift();
      }
      return newValue;
    };

    Revisionist.prototype.recover = function(version) {
      if (version == null) {
        version -= 1;
      }
      if (version < 0) {
        throw new Error("Version needs to be a positive number");
      }
      if (version > _cache.length) {
        throw new Error("Not enough versions yet");
      }
      return _plugin.recover.call(this, _cache[version]);
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