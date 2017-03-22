class Funnel {


  constructor( rules ) {
    this.listen = this.listen.bind(this);
    this.input = this.input.bind(this);
    this.compile = this.compile.bind(this);
    this.lca = this.lca.bind(this);
    this.run_rule = this.run_rule.bind(this);
    this.reduce = this.reduce.bind(this);
    this.map = this.map.bind(this);
    this.rules = rules;
    this.compile();
  }

    
  listen( fn ) {
    let key = `_${Object.keys(this.rules).length}`;
    this.rules.key = fn;
    return this.compile();
  }

 
  input( ...args ) {
    return this.map( 'input', args );
  }

  compile() {
    this.lca_of_rule = {};
    return (() => {
      let result = [];
      for (var name in this.rules) {
        let fn = this.rules[name];
        this[name] = ( ...args ) => this.run_rule( name, args );
        result.push(this.lca_of_rule[name] = this.lca( ...Array.from(this.arg_names( fn ) || []) ));
      }
      return result;
    })();
  }
      

  arg_names( func ) {
    let reg = /\(([\s\S]*?)\)/;
    let params = reg.exec(func);
    if (params) { return params[1].split(/\s*,\s*/); }
  }

  
  lca( ...rules ) {
    if (rules.length > 2) {
      return this.lca( this.lca(...Array.from(rules.slice(0, 2) || [])), this.lca(...Array.from(rules.slice(2) || [])) );
    } else if (rules.length === 1) {
      return rules[0];
    } else {
      let [ one, two ] = Array.from(rules);
      let one_ancestors = [ ];
      let two_ancestors = [ ];
      let one_tmp = [ one ];
      let two_tmp = [ two ];
      while (true) {
        var i;
        one_ancestors = one_ancestors.concat( one_tmp );
        two_ancestors = two_ancestors.concat( two_tmp );
        for (let o of Array.from(one_ancestors)) {
          if (Array.from(two_ancestors).includes(o)) { return o; }
        }
        one_tmp =  [].concat( ...Array.from(((() => {
          let result = [];
          for (i of Array.from(one_tmp)) {                 result.push(this.arg_names(this.rules[i]));
          }
          return result;
        })()) || []) );
        two_tmp =  [].concat( ...Array.from(((() => {
          let result1 = [];
          for (i of Array.from(two_tmp)) {                 result1.push(this.arg_names(this.rules[i]));
          }
          return result1;
        })()) || []) );
        if (Array.from(one_tmp).includes(undefined) && Array.from(two_tmp).includes(undefined)) { break; }
      }
    }
  }


 
  run_rule( rule, args ) {
    if (Object.prototype.toString.call( args ) !== '[object Array]') { args = [ args ]; }
    let result = this.rules[ rule ]( ...Array.from(args || []) );
    return this.map( rule, result );
  }
    

    
  extend( ...objects ) {
    let result = {};
    for (let o of Array.from(objects)) {
      for (let k in o) {
        let v = o[k];
        if (result[k] == null) { result[k] = []; }
        if (Object.prototype.toString.call( v ) !== '[object Array]') { v = [ v ]; }
        result[k] = result[k].concat(...Array.from(v || []));
      }
    }
    return result;
  }

  
  reduce( rule, outputs ) {
    for (let n in this.rules) {
      let fn = this.rules[n];
      let a = this.arg_names( fn );
      let args = [];
      args.push( ...Array.from(( Array.from(a).map((i) => outputs[i]) ) || []) );
      if ((a.length > 1) && (this.lca_of_rule[ n ] === rule)) {
        let o = this.run_rule( n, args );
        outputs = this.extend( outputs, o );
      }
    }
    return outputs;
  }


  map( rule, result ) {
    if (Object.prototype.toString.call( result ) === '[object Array]') {
      return this.extend( ...Array.from(( Array.from(result).map((r) => this.map(rule, r)) ) || []) );
    } else {
      let output = {};
      for (let n in this.rules) {
        let fn = this.rules[n];
        let a = this.arg_names( fn );
        if ((a.length === 1) && (this.lca_of_rule[ n ] === rule)) {
          let o = this.run_rule( n, result );
          o[ rule ] = result;
          o = this.reduce( rule, o );
          output = this.extend( output, o );
        }
      }
      if (output[ rule ] == null) { output[rule] = result; }
      return output;
    }
  }
}

module.exports = Funnel