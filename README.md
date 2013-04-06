Funnel.js
======

Funnel.js is a funky hybrid between an event loop and a map-reduce implementation.
The main use-case is to untangle complex buisness logic into something far more simple and expressive than our massive OO code bases usually end up being.
Right now only a rudimentary serial implementation exists, but the ambition is to someday have it scale across machines and handle things like server-client communication and persistance.

## Design Goals

The design goals below all yeild to the main goal of making large scale data driven apps dead simple to write and maintain. That being said, to make it easier to get there a few principles must be followed as closely as possible.

### Simplicity

I will probably use the term scalable simplicity a lot, the reason for this is that there are a ton of
programming paradigms out there that are simple. Object oriented programming is simple, but once you grow your OO software to a large suite the simplicity fades fast.

Now nothing is going to change the fact that enormous software suites are complex and take a long time to learn. This is the reason splitting up large code bases is good, however, there may be a better way to limit the complexity of the software to the complexity of the domain. Instead of increasing the technological  complexity at a rate equal to the domain complexity, funnel intends to limit the learning curve to the  complexity of the domain.

### Scalability

I touch on this in the section above but it is important enough for its own section. Writing code in funnel should be the same whether you are running it on one server or a million. This is an extremely ambitious goal that I'm sure will have to be compromised slightly, but I want to be clear about the guiding star.

### Testability

Knowing when, what, why your code does not work is of the utmost importance.

### Flexibility

I am a strong believer in the agile process, and to me, it is extremely valuable for a code base to be able to pivot. One of the things I want to be sure of when designing funnel is that it is easy to make changes.

## Getting Started

### Try it out

Check out the documentation [here](http://brysgo.github.io/funnel/).

```coffeescript
obj.input( 'pass a string to the existing object to test the example' )
```

You can also try writing your own funnel code, its easy.

```coffeescript
my_funnel = new Funnel(
  brick: (input) -> # make the input into a brick
  morter: (input) -> # make the input into morter
  wall: (brick,morter) -> # make a new wall from brick and morter
)

my_funnel.listen( (wall) ->
  # update your view when a new wall is created
)
```

### Contribute

Right now the best way to contribute is with an example or a suggestion. I would love to hear from you if you have either, just head over to the issues page.
