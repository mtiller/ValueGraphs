module ValueGraphs

import Graphs
import GraphViz
using Printf

struct ValueEdge
    src::Int64
    dst::Int64
    label::String
end

function ValueEdge(src::Int64, dst::Int64; label::String="")
    ValueEdge(src, dst, label)
end

mutable struct ValueGraph{T<:Any} <: Graphs.AbstractGraph{UInt64}
    values::Vector{T}
    edges::Vector{ValueEdge}
    engine::String
end

ValueGraph(T::Type; engine::String="neato") = ValueGraph(Vector{T}(), Vector{ValueEdge}(), engine)

# Graph related functions
Graphs.is_directed(::ValueGraph) = false

# Vertex related functions
Graphs.nv(g::ValueGraph) = length(g.values)
Graphs.vertices(g::ValueGraph) = 1:Graphs.nv(g)
vertex(g::ValueGraph{T}, v::T) where {T} = findfirst(item -> item == v, g.values)
Base.contains(g::ValueGraph{T}, v::T) where {T} = !isnothing(vertex(g, v))
Graphs.has_vertex(g::ValueGraph, v::Int64) = v <= Graphs.nv(g) && v > 0

# Edge related functions
Graphs.ne(g::ValueGraph) = length(g.edges)
Base.contains(g::ValueGraph{T}, v::T, w::T) where {T} = !isnothing(findfirst(item -> g.values[item.src] == v && g.values[item.dst] == w, g.edges))
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


function Base.zero(::ValueGraph{T}) where {T}
    ValueGraph(T)
end

function dist(p::Graphs.DijkstraState{Int64}, g::ValueGraph{T}, v::T) where {T}
    v = vertex(g, v)
    p.dists[v]
end

function next(p::Graphs.DijkstraState{Int64}, g::ValueGraph{T}, v::T) where {T}
    idx = vertex(g, v)
    if p.parents[idx] == 0 || p.parents[idx] > Graphs.nv(g)
        return nothing
    end
    g.values[p.parents[idx]]
end

function path(p::Graphs.DijkstraState{Int64}, g::ValueGraph{T}, v::T) where {T}
    ret = Vector{T}()

    n = next(p, g, v)
    while !isnothing(n)
        push!(ret, n)
        n = next(p, g, n)
    end
    ret
end

function farthest(p::Graphs.DijkstraState{Int64}, g::ValueGraph{T})::Union{Pair{Vector{T},Int64},Nothing} where{T}
    max::Int64 = -1
    ret::Union{Vector{T}, Nothing} = nothing
    for i in 1:Graphs.nv(g)
        if p.dists[i]==max
            push!(ret, g.values[i])
        end
        if p.dists[i] > max
            max = p.dists[i]
            ret = Vector{T}([g.values[i]])
        end
    end
    if ret!==nothing
        return Pair{Vector{T},Int64}(ret, max)
    else
        return nothing
    end
end

function beyond(p::Graphs.DijkstraState{Int64}, g::ValueGraph{T}, d::Int64)::Set{T} where{T}
    ret = Set{T}()
    for i in 1:Graphs.nv(g)
        if p.dists[i]>d
            push!(ret, g.values[i])
        end
    end
    ret
end

function Base.convert(::Type{GraphViz.Graph}, x::ValueGraph)::GraphViz.Graph
    header = Vector{String}(["strict graph {"])
    vlines = [@sprintf("  \"V%d\" [label=\"%s\"]", i, x.values[i]) for i in 1:Graphs.nv(x)]
    elines = [@sprintf("  \"V%d\" -- \"V%d\" [label=\"%s\"]", e.src, e.dst, e.label) for e in Graphs.edges(x)]
    footer = Vector{String}(["}"])

    str = join(vcat(header, vlines, elines, footer), "\n")
    ret = GraphViz.Graph(str)
    GraphViz.layout!(ret, engine=x.engine)
    ret
end

function Base.show(io::IO, t::MIME"image/svg+xml", x::ValueGraph)
    ret = convert(GraphViz.Graph, x)
    return Base.show(io, t, ret)
end

export ValueGraph, dist, next, path, ValueEdge, vertex, farthest, beyond

end # module ValueGraph
