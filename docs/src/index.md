# Documentation

```@autodocs
Modules = [ValueGraphs]
Order   = [:function, :type]
```

## Graph Related Functions

## Utility Functions

```@index
Modules = [ValueGraphs]
```

```@docs
vertex
```

## GraphViz Output

The `ValueGraphs` edges and vertices support associating arbitrary metadata data
which each instance.  Anything prefixed with `gv_` is interpreted as being an
[attribute](https://graphviz.org/doc/info/attrs.html) for the `GraphViz`
rendering of that data, _e.g.,_


```@example
using Graphs
using ValueGraphs
g = ValueGraph(String, engine="dot")

add_vertex!(g, "Foo", gv_label="Label", gv_color="black", gv_fillcolor="green", gv_style="filled")
add_edge!(g, "Foo", "Bar", gv_label="Child 1")
add_edge!(g, "Foo", "Fuz", gv_label="Child 2", gv_penwidth=5)

g
```