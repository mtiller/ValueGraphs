import Graphs 

struct ValueEdge
    src::Int64
    dst::Int64
    metadata::Dict{Symbol,String}
end

function ValueEdge(src::Int64, dst::Int64; metadata...)
    ValueEdge(src, dst, Dict(metadata))
end

mutable struct ValueGraph{T<:Any} <: Graphs.AbstractGraph{UInt64}
    values::Vector{T}
    edges::Vector{ValueEdge}
    engine::String
    vertex_metadata::Dict{Int64,Dict{Symbol,String}}
end

Base.:(==)(x::ValueEdge, y::ValueEdge) = x.src==y.src && x.dst==y.dst && x.metadata==y.metadata

ValueGraph(T::Type; engine::String="neato") = ValueGraph(Vector{T}(), Vector{ValueEdge}(), engine, Dict{Int64,Dict{Symbol,String}}())

export ValueGraph, ValueEdge
