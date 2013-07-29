(function() {
  define(['revisionist'], function(Revisionist) {
    return describe('Constructor', function() {
      return it('defines the Revisionist class', function() {
        return expect(Revisionist).toBeDefined();
      });
    });
  });

}).call(this);
