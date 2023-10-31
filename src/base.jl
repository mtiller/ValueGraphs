import GraphViz
import Graphs
using Printf

# Base related functions
Base.contains(g::ValueGraph{T}, v::T) where {T} = !isnothing(vertex(g, v))
Base.contains(g::ValueGraph{T}, v::T, w::T) where {T} = !isnothing(findfirst(item -> g.values[item.src] == v && g.values[item.dst] == w, g.edges))

function Base.zero(::ValueGraph{T}) where {T}
    ValueGraph(T)
end

"""
Any metadata that starts with `:gv_` is treated as a GraphViz attribute and 
collected here to be included after nodes and edges.
"""
function gv_attrs(metadata::Dict{Symbol, String})::String
    matching = filter(metadata) do (k,v)
        startswith(repr(k), ":gv_")
    end
    if length(matching)==0
        return ""
    end
    s = ["$(chop(repr(k),head=4,tail=0))=\"$(v)\"" for (k,v) in matching]
    "[$(join(s, ", "))]"
end

function Base.convert(::Type{GraphViz.Graph}, x::ValueGraph)::GraphViz.Graph
    header = Vector{String}(["strict graph {"])
    vlines = [@sprintf("  \"V%d\" %s", i, gv_attrs(getmetadata(x, x.values[i]))) for i in 1:Graphs.nv(x)]
    elines = [@sprintf("  \"V%d\" -- \"V%d\" %s", e.src, e.dst, gv_attrs(e.metadata)) for e in Graphs.edges(x)]
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
