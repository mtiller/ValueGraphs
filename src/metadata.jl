function setmetadata!(g::ValueGraph{T}, v::T, kv::Pair{Symbol,Any})::Bool where {T} 
    cur = vertex(g, v)
    if isnothing(cur)
        return false
    end
    md = get(g.vertex_metadata, cur, nothing)
    if isnothing(md) 
        md = Dict{Symbol,Any}()
        g.vertex_metadata[cur] = md
    end
    push!(md, kv)
    true
end

function setmetadata!(g::ValueGraph{T}, v::Int64, w::Int64; kv::Pair{Symbol,Any})::Bool where {T}
    idx = findfirst(item -> item.src == v && item.dst == w, g.edges)
    if isnothing(idx)
        return false
    end
    edge = g.edges[idx]
    push!(edge.metadata, kv)
    true
end

export setmetadata!

"""
The result of this call is **read only**.  Any changes to the dictionary will not 
be reflected back on the vertex.  For that, use the setmetadata! method.
"""
function getmetadata(g::ValueGraph{T}, v::T)::Dict{Symbol,Any} where {T}
    cur = vertex(g, v)
    ret = isnothing(cur) ? Dict{Symbol,Any}() : get(g.vertex_metadata, cur, Dict{Symbol,Any}())
    if !(:gv_label in keys(ret))
        push!(ret, :gv_label=>repr(v))
    end
    ret
end

"""
The result of this call is **read only**.  Any changes to the dictionary will not 
be reflected back on the edge.  For that, use the setmetadata! method.
"""
function getmetadata(g::ValueGraph{T}, v::Int64, w::Int64)::Dict{Symbol,Any} where {T}
    idx = findfirst(item -> item.src == v && item.dst == w, g.edges)
    if isnothing(idx)
        return Dict{Symbol,Any}()
    end
    edge = g.edges[idx]
    edge.metadata
end

export getmetadata
