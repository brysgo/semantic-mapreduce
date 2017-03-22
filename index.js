const Rule = require('./rule');

//
// The Funnel Class
// ----------------
// This is where the API and some of the setup for the rules live.

class Funnel {
  constructor( rules ) {
    this.listen = this.listen.bind(this);
    if (rules == null) { rules = {}; }
    this._rules = {};
    rules.input = function(arg) {
      return this.emit(arg);
    };
    for (let name in rules) {
      let fn = rules[name];
      var rule = this.rule(name, fn );
      this[name] = ( ...args ) => rule.run( args );
    }
    this.compile();
  }
  
  listen( fn ) {
    let key = `_${Object.keys(this._rules).length}`;
    this.rule(key, fn);
    return this.compile();
  }

  // Allow other rules to register dependencies
  on( dependencies, rule ) {
    let [min,d] = Array.from([Infinity, undefined]);
    for (let dependency of Array.from(dependencies)) {
      let n = dependency.passes(dependencies);
      if ((n > -1) && (n < min)) {
        min = n;
        d = dependency;
      }
    }
    if ((min > -1) && (min < Infinity)) { return d.bind( rule ); }
  }

  // Compile current set of rules
  compile() {
    let rule;
    for (var name in this._rules) {
      rule = this._rules[name];
      rule.clear();
    }
    return (() => {
      let result = [];
      for (name in this._rules) {
        rule = this._rules[name];
        result.push(this.on( rule.dependencies(), rule ));
      }
      return result;
    })();
  }

  // Construct a new rule and pass it a reference to us
  rule( name, fn ) {
    let rule = new Rule( name, fn );
    this._rules[name] = rule;
    rule.constructor.f = this;
    return rule;
  }
}



//### Helpers

Array.prototype.remove = function(object) { return this.splice(this.indexOf(object), 1); };
Array.prototype.clone = function() { return this.slice(); };

//### Export Funnel

module.exports = Funnel;