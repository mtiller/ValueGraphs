using Graphs 

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

export ValueGraph, ValueEdge
