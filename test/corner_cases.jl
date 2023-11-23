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
