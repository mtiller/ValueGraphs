# Utility methods

"""
This function extracts the vertex index for the provided value (or `nothing` if
the value is not associated with a vertex).
"""
vertex(g::ValueGraph{T}, v::T) where {T} = findfirst(item -> item == v, g.values)

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

export dist, next, path, vertex, farthest, beyond
