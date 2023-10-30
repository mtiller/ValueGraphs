# Base related functions
Base.contains(g::ValueGraph{T}, v::T) where {T} = !isnothing(vertex(g, v))
Base.contains(g::ValueGraph{T}, v::T, w::T) where {T} = !isnothing(findfirst(item -> g.values[item.src] == v && g.values[item.dst] == w, g.edges))

function Base.zero(::ValueGraph{T}) where {T}
    ValueGraph(T)
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
