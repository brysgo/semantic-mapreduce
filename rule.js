//
// The Rule Class
// --------------
// The rule class is a singleton that is created for every new
// rule definition. It computes and maintains information that
// is essential for the Funnel runtime.

class Rule {

  // Get a rule that is already defined
  static get( name ) { return this.f._rules[name]; }

  // Clear cached dependency info
  clear() {
    this._dependencies = undefined;
    this._passes = undefined;
    return this._bound = undefined;
  }

  // Construct a new rule
  // and save it as a singleton
  constructor( name, _fn ) {
    this.dependencies = this.dependencies.bind(this);
    this.passes = this.passes.bind(this);
    this.bind = this.bind.bind(this);
    this.run = this.run.bind(this);
    this.name = name;
    this._fn = _fn;
  }

  // Get the rules dependancies from the function's code
  // and store it for later
  dependencies() {
    if (this._dependencies == null) {
      let fnStr = this._fn.toString();
      let params = fnStr.slice(fnStr.indexOf('(')+1, fnStr.indexOf(')'));
      params = params.match(/([^\s,]+)/g);
      if (params) {
        this._dependencies = (Array.from(params).map((p) => this.constructor.get(p)));
      }
      if ((this._dependencies == null) || Array.from(this._dependencies).includes(undefined)) { this._dependencies = []; }
    }
    return this._dependencies;
  }

  // Get a list of all the dependencies that will be satisfied
  // after this function is called, optionally pass a list of
  // dependencies to check against this list
  passes( dependencies ) {
    if (dependencies == null) { dependencies = undefined; }
    if (!this._passes) {
      this._passes = [];
      for (let d of Array.from(this.dependencies())) {
        this._passes.push(d);
        this._passes.concat(d.passes());
      }
      this._passes.push(this);
    }
    if (dependencies == null) { return this._passes; }

    // Check if dependancies are passed
    if (this._passes.length === 0) { return -1; }
    for (let dependency of Array.from(dependencies)) {
      if (!Array.from(this._passes).includes(dependency)) { return -1; }
    }
    return this._passes.length;
  }

  // Allow rules to bind to this rule's completion
  bind( rule ) {
    if (this._bound == null) { this._bound = []; }
    return this._bound.push(rule);
  }

  // Run this rule and trigger the next ones
  run( args ) {
    // Accept either a result hash or an argument list
    let name;
    let results = undefined;
    let d = this.dependencies();
    if (args) {
      if (Object.prototype.toString.call(args) === '[object Array]') {
        results = {};
        for (let i = 0; i < d.length; i++) { name = d[i]; results[name] = args[i]; }
      } else {
        results = args;
        args = (Array.from(d).map((x) => args[x.name]));
      }
    }
    let context = {
      emit: val => {
        let results_ = JSON.parse(JSON.stringify(results));
        results_[ this.name ] = val;
        if (this._bound == null) { this._bound = []; }
        return Array.from(this._bound).map((rule) => rule.run( results_ ));
      }
    };
    // Run the rule
    const iter = this._fn.apply(context, args);
    if (iter && typeof iter[Symbol.iterator] === 'function') {
      for (let val of iter) {
        context.emit(val);
      }
    }
  }
}

module.exports = Rule;