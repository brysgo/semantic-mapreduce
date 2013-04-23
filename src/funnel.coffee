#
# The Funnel Class
# ----------------
# This is where the API and some of the setup for the rules live.

class Funnel
  constructor: ( rules={} ) ->
    @_rules = {}
    rules.input = (arg) ->
      @return arg
    for name, fn of rules
      rule = @rule(name, fn )
      @[name] = ( args... ) -> rule.run( args )
    @compile()
    return
  
  listen: ( fn ) =>
    key = "_#{Object.keys(@_rules).length}"
    @rule(key, fn)
    @compile()

  # Allow other rules to register dependencies
  on: ( dependencies, rule ) ->
    [min,d] = [Infinity, undefined]
    if rule in dependencies
      i = dependencies.indexOf(rule)
      dependencies = dependencies[...i].concat(dependencies[i+1..])
      console.log dependencies
    for dependency in dependencies
      n = dependency.passes(dependencies)
      if n > -1 and n < min
        min = n
        d = dependency
    if min > -1 and min < Infinity
      d.bind( rule )

  # Compile current set of rules
  compile: ->
    for name, rule of @_rules
      rule.clear()
    for name, rule of @_rules
      @on( rule.dependencies(), rule )

  # Construct a new rule and pass it a reference to us
  rule: ( name, fn ) ->
    rule = new Rule( name, fn )
    @_rules[name] = rule
    rule.constructor.f = @
    return rule

#### Export Funnel

@Funnel = Funnel
module?.exports = Funnel
