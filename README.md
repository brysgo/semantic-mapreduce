Funnel.js
======

Funnel.js is a funky hybrid between an event loop and a map-reduce implementation.
The main use-case is to untangle complex buisness logic into something far more simple and expressive than our massive OO code bases usually end up being.
Right now only a rudimentary serial implementation exists, but the ambition is to someday have it scale across machines and handle things like server-client communication and persistance.

## Design Goals

The design goals below all yeild to the main goal of making large scale data driven apps dead simple to write and maintain. That being said, to make it easier to get there a few principles must be followed as closely as possible.

### 1) Simplicity

Funnel is declarative and prefers convention over configuration. This way you describe your system and it figures out what to do.

### 2) Scalability

Funnel breaks your program into small discrete chunks that are perfect for sharding and distributing.

### 3) Testability

It just so happens that those small chunks are very easy to test.

## Getting Started

### Try it out

Check out the annotated source [here](http://brysgo.github.io/funnel/docs/funnel.html).

#### Rules

What makes a rule different from a function?

When I am defining a rule, the name of the arguments matter.

In fact, Funnel uses the names of the arguments to figure out what values to pass it.

When a funnel rule is done running, it knows what rules to call next because the arguments say which rules depend on it.

#### Funnel

The funnel object holds all the rules and is the gateway between your front end and your funnel.

##### Give input

Input can be given either by calling the reserved `input` rule with your input 

*or*

By calling the rule of your choosing directly with the right arguments.

Be carefull when calling a rule that is in the middle of the dependency tree (see section below for details).

##### Listen to output

By calling `listen` on a funnel object, you can pass a rule that will be anonymous. These anonymous rules can be easily hooked up to your views.

### The Bleeding Edge

#### The `@return` (IMPLEMENTED)

In the previous implementation rules returned their output like a normal function does.
We knew output needed to be mapped if we weren't in a reduce and we returned an array.

The days of weird array vs. non-array return values are over. The new `@return` statement lets
you return as many things from the same function as you please. Furthermore, regular return statements
will still break out of the functions, but their value will be ignored.

#### The `self` keyword (PLANNED)

A rule can't depend on itself, however, it is also called once for every set of dependencies returned. How is one supposed
to reduce data if a rule can't see what it returned previously.

In the previous implementation we just passed around arrays. So when a rule was doing reducing, it just got an array of its
dependencies' results. That can be pretty inefficient if you are just trying to calculate something from the results and not
planning on returning the whole array.

Now that we are calling once with every output, we have introduced the `self` keyword. When a rule depends on `self` it is passed the result of its last execution
in scope, or if it is keyed it gets the result of the last execution with a matching key.

#### Persistence with the `$` prefix (PLANNED)

A `$` prefix when naming dependencies (aka. arguments) will denote that the rule should be keyed on that dependency.

For example:

```coffeescript
  rulename: (dep0, $keyeddep1, $keyeddep2, self) ->
```
After this rule runs, its result will be stored in a key-value store with the key `rulename_#{keyeddep1}_#{keyeddep2}` (Where the #{} is to show string interpolation)

Before the rule runs, a key-value query will check to see if the above key exists and use it as `self`.

#### Call a rule in the middle of the dependency tree (NOT RECOMMENDED)

If for some reason you have a rule that is in the middle of the dependency and you really need to call it, all of the rules that
depend on it may need the results of executing all the rules higher up in the tree.

Fortunatly for you, or unfortunately because why are you doing this, you can call a rule with more arguments then it takes by passing an
object where the keys are the names of the dependencies and the values are what they have supposedly returned from being called.

This may be helpful for testing or playing around or whatever, so I figured I would document it.

### Contribute

Right now the best way to contribute is with an example or a suggestion. I would love to hear from you if you have either, just head over to the issues page.
