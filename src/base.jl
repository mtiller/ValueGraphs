import GraphViz
import Graphs
using Printf

# Base related functions
Base.contains(g::ValueGraph{T}, v::T) where {T} = !isnothing(vertex(g, v))
Base.contains(g::ValueGraph{T}, v::T, w::T) where {T} = !isnothing(findfirst(item -> g.values[item.src] == v && g.values[item.dst] == w, g.edges))

function Base.zero(::ValueGraph{T}) where {T}
    ValueGraph(T)
end

function attrs(metadata::Dict{Symbol, String})::String
    if length(metadata)==0
        return ""
    end
    s = ["$(k)=\"$(v)\"" for (k,v) in metadata]
    "[$(join(s, ", "))]"
end

export attrs

# TODO: Consider using Metadata.jl as a way of adding metadata like labels, fill style,
# etc. without having to keep them in the ValueGraph datatype itself.
function Base.convert(::Type{GraphViz.Graph}, x::ValueGraph)::GraphViz.Graph
    header = Vector{String}(["strict graph {"])
    vlines = [@sprintf("  \"V%d\" [label=\"%s\"]", i, x.values[i]) for i in 1:Graphs.nv(x)]
    elines = [@sprintf("  \"V%d\" -- \"V%d\" %s", e.src, e.dst, attrs(e.metadata)) for e in Graphs.edges(x)]
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
