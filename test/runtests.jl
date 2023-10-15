using Test

@testset "Value Graph Tests" begin
    using Graphs
    using ValueGraphs
    g = ValueGraph(String)

    @test is_directed(g) == false

    @test nv(g) == 0
    @test vertices(g) == Vector{Int}()
    @test vertex(g, "Foo") == nothing
    @test contains(g, "Foo") == false
    @test has_vertex(g, 1) == false

    @test ne(g) == 0
    @test has_edge(g, 1, 2) == false
    @test contains(g, "Foo", "Bar") == false
    @test edgetype(g) == Graphs.SimpleGraphs.SimpleEdge{Int}
    @test edges(g) == Vector{Graphs.SimpleGraphs.SimpleEdge{Int}}()

    @test neighbors(g, 1) == Vector{Int}()

    add_vertex!(g, "Foo")

    @test nv(g) == 1
    @test ne(g) == 0
    @test vertices(g) == 1:1
    @test vertex(g, "Foo") == 1
    @test contains(g, "Foo")
    @test !contains(g, "Bar")

    add_vertex!(g, "Bar")

    @test nv(g) == 2
    @test ne(g) == 0
    @test contains(g, "Bar")
    @test vertex(g, "Bar") == 2

    add_edge!(g, "Foo", "Bar")

    @test ne(g) == 1

    # Note, vertex "Fuz" hasn't been added explicitly, but
    # it will be added by add_edge since the default value for
    # the strict argument is false
    add_edge!(g, "Bar", "Fuz")

    @test vertex(g, "Fuz") == 3

    @test nv(g) == 3
    @test ne(g) == 2

    @test nv(zero(g)) == 0
    @test ne(zero(g)) == 0

    dpath = dijkstra_shortest_paths(g, [vertex(g, "Foo")])

    @test dpath.dists == [0, 1, 2]
    @test dpath.parents == [0, 1, 2]
    @test dist(dpath, g, "Foo") == 0
    @test dist(dpath, g, "Bar") == 1
    @test dist(dpath, g, "Fuz") == 2

    @test next(dpath, g, "Foo") == nothing
    @test next(dpath, g, "Bar") == "Foo"
    @test next(dpath, g, "Fuz") == "Bar"

    @test path(dpath, g, "Foo") == []
    @test path(dpath, g, "Bar") == ["Foo"]
    @test path(dpath, g, "Fuz") == ["Bar", "Foo"]

    @test farthest(dpath, g) == Pair(Vector(["Fuz"]), 2)

    # Note, vertex "Fuz2" hasn't been added explicitly, but
    # it will be added by add_edge since the default value for
    # the strict argument is false
    add_edge!(g, "Bar", "Fuz2")

    dpath = dijkstra_shortest_paths(g, [vertex(g, "Foo")])

    @test dpath.dists == [0, 1, 2, 2]
    @test dpath.parents == [0, 1, 2, 2]
    @test dist(dpath, g, "Foo") == 0
    @test dist(dpath, g, "Bar") == 1
    @test dist(dpath, g, "Fuz") == 2
    @test dist(dpath, g, "Fuz2") == 2

    @test next(dpath, g, "Foo") == nothing
    @test next(dpath, g, "Bar") == "Foo"
    @test next(dpath, g, "Fuz") == "Bar"
    @test next(dpath, g, "Fuz2") == "Bar"

    @test path(dpath, g, "Foo") == []
    @test path(dpath, g, "Bar") == ["Foo"]
    @test path(dpath, g, "Fuz") == ["Bar", "Foo"]
    @test path(dpath, g, "Fuz2") == ["Bar", "Foo"]

    @test farthest(dpath, g) == Pair(Vector(["Fuz", "Fuz2"]), 2)
    @test beyond(dpath, g, 1) == Set{String}(["Fuz", "Fuz2"])
end
