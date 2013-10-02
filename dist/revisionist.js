(function(e){if("function"==typeof bootstrap)bootstrap("revisionist",e);else if("object"==typeof exports)module.exports=e();else if("function"==typeof define&&define.amd)define(e);else if("undefined"!=typeof ses){if(!ses.ok())return;ses.makeRevisionist=e}else"undefined"!=typeof window?window.Revisionist=e():global.Revisionist=e()})(function(){var define,ses,bootstrap,module,exports;
return (function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require=="function"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error("Cannot find module '"+n+"'")}var u=t[n]={exports:{}};e[n][0].call(u.exports,function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require=="function"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){
/*
 * Javascript Diff Algorithm
 *  By John Resig (http://ejohn.org/)
 *  Modified by Chu Alan "sprite"
 *
 * Released under the MIT license.
 *
 * More Info:
 *  http://ejohn.org/projects/javascript-diff-algorithm/
 */

function escape(s) {
  var n = s;
  n = n.replace(/&/g, "&amp;");
  n = n.replace(/</g, "&lt;");
  n = n.replace(/>/g, "&gt;");
  n = n.replace(/"/g, "&quot;");

  return n;
}

function diffString( o, n ) {
  o = o.replace(/\s+$/, '');
  n = n.replace(/\s+$/, '');

  var out = diff(o == "" ? [] : o.split(/\s+/), n == "" ? [] : n.split(/\s+/) );
  var str = "";

  var oSpace = o.match(/\s+/g);
  if (oSpace == null) {
    oSpace = ["\n"];
  } else {
    oSpace.push("\n");
  }
  var nSpace = n.match(/\s+/g);
  if (nSpace == null) {
    nSpace = ["\n"];
  } else {
    nSpace.push("\n");
  }

  if (out.n.length == 0) {
    for (var i = 0; i < out.o.length; i++) {
      str += '<del>' + escape(out.o[i]) + oSpace[i] + "</del>";
    }
  } else {
    if (out.n[0].text == null) {
      for (n = 0; n < out.o.length && out.o[n].text == null; n++) {
        str += '<del>' + escape(out.o[n]) + oSpace[n] + "</del>";
      }
    }

    for ( var i = 0; i < out.n.length; i++ ) {
      if (out.n[i].text == null) {
        str += '<ins>' + escape(out.n[i]) + nSpace[i] + "</ins>";
      } else {
        var pre = "";

        for (n = out.n[i].row + 1; n < out.o.length && out.o[n].text == null; n++ ) {
          pre += '<del>' + escape(out.o[n]) + oSpace[n] + "</del>";
        }
        str += " " + out.n[i].text + nSpace[i] + pre;
      }
    }
  }

  return str;
}

function diff( o, n ) {
  var ns = new Object();
  var os = new Object();

  for ( var i = 0; i < n.length; i++ ) {
    if ( ns[ n[i] ] == null )
      ns[ n[i] ] = { rows: new Array(), o: null };
    ns[ n[i] ].rows.push( i );
  }

  for ( var i = 0; i < o.length; i++ ) {
    if ( os[ o[i] ] == null )
      os[ o[i] ] = { rows: new Array(), n: null };
    os[ o[i] ].rows.push( i );
  }

  for ( var i in ns ) {
    if ( ns[i].rows.length == 1 && typeof(os[i]) != "undefined" && os[i].rows.length == 1 ) {
      n[ ns[i].rows[0] ] = { text: n[ ns[i].rows[0] ], row: os[i].rows[0] };
      o[ os[i].rows[0] ] = { text: o[ os[i].rows[0] ], row: ns[i].rows[0] };
    }
  }

  for ( var i = 0; i < n.length - 1; i++ ) {
    if ( n[i].text != null && n[i+1].text == null && n[i].row + 1 < o.length && o[ n[i].row + 1 ].text == null &&
         n[i+1] == o[ n[i].row + 1 ] ) {
      n[i+1] = { text: n[i+1], row: n[i].row + 1 };
      o[n[i].row+1] = { text: o[n[i].row+1], row: i + 1 };
    }
  }

  for ( var i = n.length - 1; i > 0; i-- ) {
    if ( n[i].text != null && n[i-1].text == null && n[i].row > 0 && o[ n[i].row - 1 ].text == null &&
         n[i-1] == o[ n[i].row - 1 ] ) {
      n[i-1] = { text: n[i-1], row: n[i].row - 1 };
      o[n[i].row-1] = { text: o[n[i].row-1], row: i - 1 };
    }
  }

  return { o: o, n: n };
}


module.exports = diffString;

},{}],2:[function(require,module,exports){
var extend;

extend = function(target, source) {
  var prop;
  if (target == null) {
    target = {};
  }
  for (prop in source) {
    if (typeof source[prop] === 'object') {
      target[prop] = extend(target[prop], source[prop]);
    } else {
      target[prop] = source[prop];
    }
  }
  return target;
};

module.exports = extend;


},{}],3:[function(require,module,exports){
var SimplePlugin;

SimplePlugin = {
  change: function(newValue) {
    return newValue;
  },
  recover: function(prevValue) {
    return prevValue;
  }
};

module.exports = SimplePlugin;


},{}],4:[function(require,module,exports){
var Revisionist, SimplePlugin, SimpleStore, extend, htmlDiff;

htmlDiff = require('./lib/diff');

extend = require('./lib/extend.coffee');

Revisionist = (function() {
  var _currentVersion, _getPreviousVersion, _plugins, _store, _stores;

  _plugins = {};

  _stores = {};

  _currentVersion = 0;

  _store = null;

  _getPreviousVersion = function() {
    var version;
    version = _currentVersion - 1;
    if (version < 0) {
      version = 0;
    }
    return version;
  };

  Revisionist.registerPlugin = function(namespace, Plugin) {
    if (_plugins[namespace] != null) {
      throw new Error("There's already a plugin in this namespace");
    }
    return _plugins[namespace] = Plugin;
  };

  Revisionist.unregisterPlugin = function(namespace) {
    return _plugins[namespace] = null;
  };

  Revisionist.registerStore = function(namespace, Store) {
    if (_stores[namespace] != null) {
      throw new Error("There's already a store in this namespace");
    }
    return _stores[namespace] = Store;
  };

  Revisionist.unregisterStore = function(namespace) {
    return _stores[namespace] = null;
  };

  Revisionist.prototype.defaults = {
    versions: 10,
    plugin: 'simple',
    store: 'simple'
  };

  function Revisionist(options) {
    this.options = {};
    extend(this.options, this.defaults);
    extend(this.options, options);
    this.setStore(this.options.store);
  }

  Revisionist.prototype.getLatestVersionNumber = function() {
    return _currentVersion - 1;
  };

  Revisionist.prototype.setStore = function(store) {
    var Store;
    Store = _stores[store];
    if (Store == null) {
      throw new Error("The Store '" + store + "' is not available!");
    }
    return _store = new Store(this.options);
  };

  Revisionist.prototype.change = function(newValue) {
    var plugin;
    plugin = _plugins[this.options.plugin];
    if ((plugin != null ? plugin.change : void 0) == null) {
      throw new Error("Plugin " + this.options.plugin + " is not available!");
    }
    newValue = plugin.change.call(plugin, newValue);
    _currentVersion += 1;
    _store.set(newValue, _currentVersion);
    if (_currentVersion > this.options.versions) {
      _store.remove(0);
      _currentVersion = _store.size();
    }
    return newValue;
  };

  Revisionist.prototype.recover = function(version, callback) {
    var plugin;
    plugin = _plugins[this.options.plugin];
    if ((plugin != null ? plugin.recover : void 0) == null) {
      throw new Error("Plugin " + this.options.plugin + " is not available!");
    }
    if (version == null) {
      version = _getPreviousVersion();
    }
    if (version < 0) {
      throw new Error("Version needs to be a positive number");
    }
    if (version > _store.size()) {
      throw new Error("This version doesn't exist");
    }
    if (typeof callback === 'function') {
      return _store.get(version, function(data) {
        return callback(plugin.recover.call(plugin, data));
      });
    }
  };

  Revisionist.prototype.diff = function(v1, v2, callback) {
    var max, min;
    if (v1 == null) {
      v1 = _currentVersion - 1;
      if (v1 < 0) {
        v1 = 0;
      }
    }
    if (v2 == null) {
      v2 = v1 - 1;
      if (v2 < 0) {
        v2 = 0;
      }
    }
    min = Math.min(v1, v2);
    max = Math.max(v1, v2);
    if (typeof callback === 'function') {
      return _store.get(min, function(old) {
        return _store.get(max, function(n) {
          return callback({
            old: old,
            "new": n
          });
        });
      });
    }
  };

  Revisionist.prototype.visualDiff = function(v1, v2, callback) {
    return this.diff(v1, v2, function(diff) {
      if (!(typeof diff.old === 'string' && typeof diff["new"] === 'string')) {
        throw new Error('The content types of both versions must match');
      }
      return callback(htmlDiff(diff.old, diff["new"]));
    });
  };

  Revisionist.prototype.clear = function() {
    _store.clear();
    _currentVersion = 0;
    return this;
  };

  return Revisionist;

})();

SimplePlugin = require('./plugins/simple.coffee');

Revisionist.registerPlugin('simple', SimplePlugin);

SimpleStore = require('./stores/simple.coffee');

Revisionist.registerStore('simple', SimpleStore);

module.exports = Revisionist;


},{"./lib/diff":1,"./lib/extend.coffee":2,"./plugins/simple.coffee":3,"./stores/simple.coffee":5}],5:[function(require,module,exports){
var SimpleStore;

SimpleStore = (function() {
  var _cache;

  _cache = [];

  function SimpleStore(options) {
    this.options = options;
  }

  SimpleStore.prototype.set = function(value, version) {
    return _cache.push(value);
  };

  SimpleStore.prototype.get = function(version, callback) {
    return callback(_cache[version]);
  };

  SimpleStore.prototype.remove = function(version) {
    return _cache.splice(version, 1);
  };

  SimpleStore.prototype.clear = function() {
    return _cache = [];
  };

  SimpleStore.prototype.size = function() {
    return _cache.length;
  };

  return SimpleStore;

})();

module.exports = SimpleStore;


},{}]},{},[4])(4)
});
;