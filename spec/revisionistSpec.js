(function() {
  define(['revisionist'], function(Revisionist) {
    describe('Constructor', function() {
      it('defines the Revisionist class', function() {
        return expect(Revisionist).toBeDefined();
      });
      it('defaults to keeping 10 versions', function() {
        var rev;
        rev = new Revisionist;
        return expect(rev.options.versions).toBe(10);
      });
      it('defaults to using SimplePlugin', function() {
        var rev;
        rev = new Revisionist;
        return expect(rev.options.plugin).toBe('simple');
      });
      return it('extends its options object with user-defined options', function() {
        var rev;
        rev = new Revisionist({
          plugin: 'complex',
          versions: 20
        });
        expect(rev.options.versions).toBe(20);
        return expect(rev.options.plugin).toBe('complex');
      });
    });
    describe('#change', function() {
      it('throws an Error if the plugin can\'t be found', function() {
        var e, rev;
        rev = new Revisionist({
          plugin: 'unexistant'
        });
        e = new Error("Plugin unexistant is not available!");
        return expect(function() {
          return rev.change('bananas');
        }).toThrow(e);
      });
      it('throws an Error if the plugin doesn\'t have a "change" method', function() {
        var e, rev;
        Revisionist.registerPlugin('incomplete', {
          recover: function() {},
          notChange: function() {}
        });
        rev = new Revisionist({
          plugin: 'incomplete'
        });
        e = new Error("Plugin incomplete is not available!");
        expect(function() {
          return rev.change('bananas');
        }).toThrow(e);
        return Revisionist.unregisterPlugin('incomplete');
      });
      it('calls the plugin\'s "change" method with the new value as an argument', function() {
        var CustomPlugin, rev, spy;
        CustomPlugin = {
          recover: function() {},
          change: function() {}
        };
        spy = spyOn(CustomPlugin, 'change');
        Revisionist.registerPlugin('custom', CustomPlugin);
        rev = new Revisionist({
          plugin: 'custom'
        });
        rev.change('bacon');
        expect(spy).toHaveBeenCalledWith('bacon');
        return Revisionist.unregisterPlugin('custom');
      });
      it('calls the plugin\'s "change" method within it\'s own context', function() {
        var CustomPlugin, rev, spy;
        CustomPlugin = {
          recover: function() {},
          change: function() {
            return this.ownFunction();
          },
          ownFunction: function() {}
        };
        spy = spyOn(CustomPlugin, 'ownFunction');
        Revisionist.registerPlugin('custom', CustomPlugin);
        rev = new Revisionist({
          plugin: 'custom'
        });
        rev.change('pancakes');
        expect(spy).toHaveBeenCalled();
        return Revisionist.unregisterPlugin('custom');
      });
      return it('only keeps a limited amount of versions', function() {
        var recovered, rev;
        rev = new Revisionist({
          versions: 2
        });
        rev.change('bananas');
        rev.change('bacon');
        rev.change('pineapples');
        recovered = rev.recover(0);
        return expect(recovered).toEqual('bacon');
      });
    });
    describe('#recover', function() {
      it('throws an Error if the plugin can\'t be found', function() {
        var e, rev;
        rev = new Revisionist({
          plugin: 'unexistant'
        });
        e = new Error("Plugin unexistant is not available!");
        return expect(function() {
          return rev.recover(0);
        }).toThrow(e);
      });
      it('throws an Error if the plugin doesn\'t have a "change" method', function() {
        var e, rev;
        Revisionist.registerPlugin('incomplete2', {
          notRecover: function() {},
          change: function() {}
        });
        rev = new Revisionist({
          plugin: 'incomplete'
        });
        e = new Error("Plugin incomplete is not available!");
        return expect(function() {
          return rev.recover(0);
        }).toThrow(e);
      });
      it('throws an Error if the version is lower than 0', function() {
        var e, rev;
        rev = new Revisionist;
        e = new Error("Version needs to be a positive number");
        return expect(function() {
          return rev.recover(-10);
        }).toThrow(e);
      });
      it('throws an Error if the version doesn\'t exist yet', function() {
        var e, rev;
        rev = new Revisionist;
        e = new Error("This version doesn't exist");
        return expect(function() {
          return rev.recover(99);
        }).toThrow(e);
      });
      it('calls the plugin\'s "recover" method with the revision value as an argument', function() {
        var CustomPlugin, rev, spy;
        CustomPlugin = {
          recover: function() {},
          change: function() {}
        };
        spy = spyOn(CustomPlugin, 'recover');
        Revisionist.registerPlugin('custom', CustomPlugin);
        rev = new Revisionist({
          plugin: 'custom'
        });
        rev.change('bacon');
        rev.recover(0);
        expect(spy).toHaveBeenCalledWith('bacon');
        return Revisionist.unregisterPlugin('custom');
      });
      it('calls the plugin\'s "recover" method within it\'s own context', function() {
        var CustomPlugin, rev, spy;
        CustomPlugin = {
          recover: function() {
            return this.ownFunction();
          },
          change: function() {},
          ownFunction: function() {}
        };
        spy = spyOn(CustomPlugin, 'ownFunction');
        Revisionist.registerPlugin('custom', CustomPlugin);
        rev = new Revisionist({
          plugin: 'custom'
        });
        rev.change('pancakes');
        rev.recover();
        expect(spy).toHaveBeenCalled();
        return Revisionist.unregisterPlugin('custom');
      });
      return it('defaults to the version prior to the current one', function() {
        var recovered, rev;
        rev = new Revisionist;
        rev.change('bacon');
        rev.change('bananas');
        rev.change('oranges');
        recovered = rev.recover();
        return expect(recovered).toEqual('oranges');
      });
    });
    describe('#diff', function() {
      var rev;
      rev = null;
      beforeEach(function() {
        return rev = new Revisionist;
      });
      afterEach(function() {
        rev.clear();
        return rev = null;
      });
      it('throws an Error if the content types mismatch', function() {
        var e;
        rev.change('string');
        rev.change(2);
        e = new Error('The content types of both versions must match');
        return expect(function() {
          return rev.diff();
        }).toThrow(e);
      });
      it('throws an Error if the content type is not supported', function() {
        var e;
        rev.change([1, 2]);
        rev.change([2, 3]);
        e = new Error('Diff algorithm unavailable for values of type object');
        return expect(function() {
          return rev.diff();
        }).toThrow(e);
      });
      it('compares the two most recent versions if no parameters are passed in', function() {
        var diff;
        rev.change(1);
        rev.change(3);
        rev.change(10);
        diff = rev.diff();
        return expect(diff).toEqual(-7);
      });
      it('compares the passed in version against the version before it if only one parameter is passed in', function() {
        var diff;
        rev.change(1);
        rev.change(3);
        rev.change(10);
        diff = rev.diff(1);
        return expect(diff).toEqual(-2);
      });
      it('returns a number difference for Number values', function() {
        var diff;
        rev.change(1);
        rev.change(3);
        diff = rev.diff();
        return expect(diff).toEqual(-2);
      });
      return it('returns an HTML diff for String values', function() {
        var diff, expectedDiff;
        rev.change('fox');
        rev.change('the brown fox jumped over the lazy wizard');
        expectedDiff = '<ins>the </ins><ins>brown </ins> fox <ins>jumped </ins><ins>over </ins><ins>the </ins><ins>lazy </ins><ins>wizard\n</ins>';
        diff = rev.diff();
        return expect(diff).toEqual(expectedDiff);
      });
    });
    return describe('.registerPlugin', function() {
      return it("exposes the registerPlugin method as a Class method", function() {
        return expect(Revisionist.registerPlugin).toEqual(jasmine.any(Function));
      });
    });
  });

}).call(this);
