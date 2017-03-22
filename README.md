Funnel.js
======

Funnel.js lets you write a mapreduce (the functional programming kind, not the distributed computing one) in a way that is a bit easier to read.

It is sort of like the early angular dependancy injector.

```js
obj.input( 'pass a string to the existing object to test the example' )
```

You can also try writing your own funnel code, its easy.

```js
const my_funnel = new Funnel(
  brick: (input) => // make the input into a brick
  morter: (input) => // make the input into morter
  wall: (brick,morter) => // make a new wall from brick and morter
);

my_funnel.listen( (wall) =>
  // update your view when a new wall is created
)
```