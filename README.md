# `ValueGraphs.jl`

According to the `Graphs.jl` package, verticies are keyed by an integer.  But in
practice, the algorithms of the `Graphs` package (_e.g.,_, Dijkstra's algorithm)
also include an _implicit_ assumption that these integers are contiguous.  Sadly,
these means that while hash values are integers, they cannot be used as the
keys for vertices without some kind of mapping between the hash values and the
key values.

This package addresses all of this "under the hood".  So it is possible to create
a `ValueGraph` instance from any hashable Julia type and then enumerate the edges
between those values as well, _e.g._,

```julia
using Graphs
using ValueGraphs

g = ValueGraph(String)

@test is_directed(g) == false

# Test that the graph is initially empty
@test nv(g) == 0
@test vertices(g) == Vector{Int}()
@test vertex(g, "Foo") == nothing
@test contains(g, "Foo") == false

# Add a vertex
add_vertex!(g, "Foo")

# Check that the vertex shows up using Graphs.* functions
@test nv(g) == 1
@test vertices(g) == 1:1
@test vertex(g, "Foo") == 1
@test contains(g, "Foo")

# Add another vertex and an edge
add_vertex!(g, "Bar")
add_edge!(g, "Foo", "Bar")

# Confirm the edge shows up using Graphs.* functions
@test ne(g) == 1

# Note, vertex "Fuz" hasn't been added explicitly, but
# it will be added implicitly by add_edge since the default value for
# the strict argument is false
add_edge!(g, "Bar", "Fuz")

# Test vertex is known
@test vertex(g, "Fuz") == 3

# Test the total vertex and edge counts
@test nv(g) == 3
@test ne(g) == 2

# Compute shortest path information for this graph
dpath = dijkstra_shortest_paths(g, [vertex(g, "Foo")])

# Confirm distances from all nodes to "Foo"
@test dist(dpath, g, "Foo") == 0
@test dist(dpath, g, "Bar") == 1
@test dist(dpath, g, "Fuz") == 2

# Elaborate the path from all nodes to "Foo"
@test path(dpath, g, "Foo") == []
@test path(dpath, g, "Bar") == ["Foo"]
@test path(dpath, g, "Fuz") == ["Bar", "Foo"]
```
