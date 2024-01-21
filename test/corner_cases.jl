using Test
using GraphViz
using Graphs

@testset "Corner Case Tests" begin
    g = ValueGraph(String)
    add_vertex!(g, "A")
    dpath = dijkstra_shortest_paths(g, [vertex(g, "A")])
    @test farthest(dpath, g) == Pair(Vector(["A"]), 0)
    @test dist(dpath, g, "A") == 0
end

@testset "Cycles" begin
    g = ValueGraph(String)
    add_vertex!(g, "A")
    add_vertex!(g, "B")
    add_vertex!(g, "C")
    add_vertex!(g, "D")
    add_edge!(g, "A", "B")
    add_edge!(g, "B", "C")
    add_edge!(g, "C", "D")
    add_edge!(g, "D", "A")
    ret = cycle_basis(g)
    print(ret)
end
