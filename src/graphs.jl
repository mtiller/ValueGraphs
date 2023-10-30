import Graphs

# Graph related functions
Graphs.is_directed(::ValueGraph) = false

# Vertex related functions
Graphs.nv(g::ValueGraph) = length(g.values)
Graphs.vertices(g::ValueGraph) = 1:Graphs.nv(g)
Graphs.has_vertex(g::ValueGraph, v::Int64) = v <= Graphs.nv(g) && v > 0

# Edge related functions
Graphs.ne(g::ValueGraph) = length(g.edges)
Graphs.has_edge(g::ValueGraph, v::Int64, w::Int64) = !isnothing(findfirst(item -> item.src == v && item.dst == w, g.edges))
Graphs.edgetype(::ValueGraph) = ValueEdge
Graphs.edges(g::ValueGraph) = g.edges

# Vertex and Edge related functions
Graphs.neighbors(g::ValueGraph, other::Int64) = [(g.edges[i].src == other ? g.edges[i].dst : g.edges[i].src) for i in 1:Graphs.ne(g) if g.edges[i].src == other || g.edges[i].dst == other]
Graphs.outneighbors(g::ValueGraph, other::Int64) = [(g.edges[i].src == other ? g.edges[i].dst : g.edges[i].src) for i in 1:Graphs.ne(g) if g.edges[i].src == other || g.edges[i].dst == other]
Graphs.inneighbors(g::ValueGraph, other::Int64) = [(g.edges[i].src == other ? g.edges[i].dst : g.edges[i].src) for i in 1:Graphs.ne(g) if g.edges[i].src == other || g.edges[i].dst == other]

# Mutability functions
function Graphs.add_vertex!(g::ValueGraph{T}, v::T) where {T}
    cur = vertex(g, v)
    if !isnothing(cur)
        return false
    end
    push!(g.values, v)
end

function Graphs.add_edge!(g::ValueGraph{T}, src::T, dst::T; strict::Bool=false, label::String="") where {T}
    if !strict
        # Add these vertices if they don't exist
        Graphs.add_vertex!(g, src)
        Graphs.add_vertex!(g, dst)
    end
    s = vertex(g, src)
    d = vertex(g, dst)
    if isnothing(s) || isnothing(d)
        return false
    end
    push!(g.edges, ValueEdge(s, d, label))
end

function Graphs.rem_edge!(g::ValueGraph, e::ValueEdge)
    idx = findfirst(item -> item == e, g.edges)
    if isnothing(idx)
        return false
    else
        deleteat!(g.edges, idx)
        return true
    end
end

