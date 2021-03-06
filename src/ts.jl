import Base: size, length, show, start, next, done, endof, isempty, convert, ndims, float, eltype, copy
using Base.Dates

################################################################################
# TYPE DEFINITION ##############################################################
################################################################################

abstract type AbstractTS end

@doc doc"""
Time series type aimed at efficiency and simplicity.

Motivated by the `xts` package in R and the `pandas` package in Python.
""" ->
mutable struct TS{V<:Real,T<:TimeType}
    values::Matrix{V}
    index::Vector{T}
    fields::Vector{Symbol}
    function TS{V,T}(values::AbstractArray{V}, index::AbstractVector{T}, fields::Vector{Symbol}) where {V<:Real,T<:TimeType}
        @assert size(values,1)==length(index) "Length of index not equal to number of value rows."
        @assert size(values,2)==length(fields) "Length of fields not equal to number of columns in values."
        order = sortperm(index)
        return new(values[order,:], index[order], SANITIZE_NAMES ? namefix.(fields) : fields)
    end
end

TS{V,T}(v::AbstractArray{V}, t::AbstractVector{T}, f::Union{Symbol,String,Char}) = TS{V,T}(v, t, [Symbol(f)])
TS{V,T}(v::AbstractArray{V}, t::AbstractVector{T}, f::Union{AbstractVector{Symbol},AbstractVector{String},AbstractVector{Char}}) = TS{V,T}(v, t, Symbol.(f))
TS{V,T}(v::AbstractArray{V}, t::AbstractVector{T}) = TS{V,T}(v, t, autocol(1:size(v,2)))
TS{V,T}(v::AbstractArray{V}, t::T, f) = TS{V,T}(v, [t], f)
TS{V,T}(v::V, t::AbstractVector{T}, f) = TS{V,T}([v], t, f)
TS{V,T}(v::V, t::T, f) = TS{V,T}([v][:,:], [t], f)
TS{V,T}(v::V, t::T) = TS{V,T}([v], [t], [:A])
TS{V}(v::AbstractArray{V}) = TS{V,Date}(v, autoidx(size(v,1)), autocol(1:size(v,2)))
TS() = TS{Float64,Date}(Matrix{Float64}(0,0), Date[], Symbol[])

# Conversions ------------------------------------------------------------------
convert(::Type{TS{Float64}}, x::TS{Bool}) = TS{Float64}(map(Float64, x.values), x.index, x.fields)
convert(::Type{TS{Int}}, x::TS{Bool}) = TS{Int}(map(Int, x.values), x.index, x.fields)
convert{V<:Real}(::Type{TS{Bool}}, x::TS{V}) = TS{Bool}(map(V, x.values), x.index, x.fields)
convert(x::TS{Bool}) = convert(TS{Int}, x::TS{Bool})
# convert{V}(::Type{TS}, x::Array{V}) = TS{V,Date}(x, [Dates.Date() for i in 1:size(x,1)])
# convert(x::TS{Bool}) = convert(TS{Float64}, x::TS{Bool})
const ts = TS

################################################################################
# BASIC UTILITIES ##############################################################
################################################################################
size(x::TS) = size(x.values)
size(x::TS, dim::Int) = size(x.values, dim)
length(x::TS) = prod(size(x))::Int
start(x::TS) = 1
next(x::TS, i::Int) = ((x.index[i], x.values[i,:]), i+1)
done(x::TS, i::Int) = (i > size(x,1))
isempty(x::TS) = (isempty(x.index) && isempty(x.values))
first(x::TS) = x[1]
last(x::TS) = x[end]
#FIXME: should interface with indexing (changing this messed with show method)
endof(x::TS) = endof(x.values)
ndims(::TS) = 2
float(x::TS) = ts(float(x.values), x.index, x.fields)
eltype(x::TS) = eltype(x.values)
copy(x::TS) = TS(x.values, x.index, x.fields)
# round(V::Type, x::TS) = TS(round(V, x.values), x.index, x.fields)

