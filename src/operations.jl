importall Base.Operators
import Base: one,
             ones,
             zero,
             zeros,
             rand,
             randn,
             trues,
             falses,
             isnan,
             sum,
             mean,
             maximum,
             minimum,
             round,
             prod,
             cumsum,
             cumprod,
             diff,
             all,
             any,
             countnz,
             sign,
             find,
             findfirst,
             log,
             broadcast

find(x::TS) = find(x.values)
findfirst(x::TS) = findfirst(x.values)

ones{V<:Real,T<:TimeType}(x::TS{V,T}) = TS{V,T}(ones(V, size(x)), x.index, x.fields)
ones{V<:Real}(::Type{TS{V}}, n::Int) = TS{V}(ones(V, n))
ones{V<:Real}(::Type{TS{V}}, dims::Tuple{Int,Int}) = TS{V}(ones(V, dims))
ones{V<:Real}(::Type{TS{V}}, r::Int, c::Int) = TS{V}(ones(V, r, c))
one{V<:Real}(x::TS{V})::V = one(V)
one{V<:Real}(::Type{TS{V}})::V = one(V)

zeros{V<:Real,T<:TimeType}(x::TS{V,T}) = TS{V,T}(zeros(V, size(x)), x.index, x.fields)
zeros{V<:Real}(::Type{TS{V}}, n::Int) = TS{V}(zeros(V, n))
zeros{V<:Real}(::Type{TS{V}}, r::Int, c::Int) = TS{V}(zeros(V, r, c))
zeros{V<:Real}(::Type{TS{V}}, dims::Tuple{Int,Int}) = TS{V}(zeros(V, dims))
zero{V<:Real}(x::TS{V})::V = zero(V)
zero{V<:Real}(::Type{TS{V}})::V = zero(V)

rand(::Type{TS}, n::Int=1) = TS(rand(Float64, n))
rand(::Type{TS}, r::Int, c::Int) = TS(rand(Float64, r, c))
rand(::Type{TS}, dims::Tuple{Int,Int}) = TS(rand(Float64, dims))

randn(::Type{TS}, n::Int=1) = TS(randn(Float64, n))
randn(::Type{TS}, r::Int, c::Int) = TS(randn(Float64, r, c))
randn(::Type{TS}, dims::Tuple{Int,Int}) = TS(randn(Float64, dims))

trues(x::TS) = TS(trues(x.values), x.index, x.fields)
falses(x::TS) = TS(falses(x.values), x.index, x.fields)
isnan(x::TS) = TS(isnan.(x.values), x.index, x.fields)
countnz(x::TS) = countnz(x.values)
sign(x::TS) = TS(sign.(x.values), x.index, x.fields)
log(x::TS) = TS(log.(x.values), x.index, x.fields)
log(b::Number, x::TS) = TS(log.(b, x.values), x.index, x.fields)

# Number functions
round(x::TS, n::Int=0)::TS = TS(round.(x.values,n), x.index, x.fields)
round{R}(::Type{R}, x::TS) = TS(round.(R, x.values), x.index, x.fields)
sum{V}(x::TS{V})::V = sum(x.values)
sum{V}(x::TS{V}, dim::Int)::Array{V} = sum(x.values, dim)
sum{V}(f::Function, x::TS{V})::V = sum(f, x.values)
mean{V}(x::TS{V}) = mean(x.values)
mean{V}(x::TS{V}, dim::Int)::Array{V} = mean(x, dim)
mean{V}(f::Function, x::TS{V})::V = mean(f, x.values)
prod{V}(x::TS{V})::V = prod(x.values)
prod{V}(x::TS{V}, dim::Int)::Array{V} = prod(x.values, dim)
maximum{V}(x::TS{V})::V = maximum(x.values)
maximum{V}(x::TS{V}, dim::Int)::Array{V} = maximum(x.values, dim)
minimum{V}(x::TS{V})::V = minimum(x.values)
minimum{V}(x::TS{V}, dim::Int)::Array{V} = minimum(x.values, dim)
cumsum(x::TS, dim::Int=1) = TS(cumsum(x.values, dim), x.index, x.fields)
cummin(x::TS, dim::Int=1) = TS(cummin(x.values, dim), x.index, x.fields)
cummax(x::TS, dim::Int=1) = TS(cummax(x.values, dim), x.index, x.fields)
cumprod(x::TS, dim::Int=1) = TS(cumprod(x.values, dim), x.index, x.fields)

nans(r::Int, c::Int) = fill(NaN, 1, 2)
nans(dims::Tuple{Int,Int}) = fill(NaN, dims)

function rowdx!{T,N}(dx::AbstractArray{T,N}, x::AbstractArray{T,N}, n::Int, r::Int=size(x,1))
    idx = n > 0 ? (n+1:r) : (1:r+n)
    @inbounds for i=idx
        dx[i,:] = x[i,:] - x[i-n,:]
    end
    nothing
end

function coldx!{T,N}(dx::AbstractArray{T,N}, x::AbstractArray{T,N}, n::Int, c::Int=size(x,2))
    idx = n > 0 ? (n+1:c) : (1:c+n)
    @inbounds for j=idx
        dx[:,j] = x[:,j] - x[:,j-n]
    end
    nothing
end

function diffn(x::AbstractArray, dim::Int=1, n::Int=1)
    @assert dim == 1 || dim == 2 "Argument `dim` must be 1 (rows) or 2 (columns)."
    @assert abs(n) < size(x,dim) "Argument `n` out of bounds."
    if n == 0
        return x
    end
    dx = zeros(x)
    if dim == 1
        rowdx!(dx, x, n)
    else
        coldx!(dx, x, n)
    end
    return dx
end

function diff{V,T}(x::TS{V,T}, n::Int=1; dim::Int=1, pad::Bool=false, padval::V=zero(V))
    @assert dim == 1 || dim == 2 "Argument dim must be either 1 (rows) or 2 (columns)."
    r = size(x, 1)
    c = size(x, 2)
    dx = diffn(x.values, dim, n)
    if dim == 1
        if pad
            idx = n>0 ? (1:n) : (r+n+1:r)
            dx[idx,:] = padval
            return TS(dx, x.index, x.fields)
        else
            idx = n > 0 ? (n+1:r) : (1:r+n)
            return TS(dx[idx,:], x.index[idx], x.fields)
        end
    else
        if pad
            idx = n > 0 ? (1:c) : (c+1+1:c)
            dx[:,idx] = padval
            return TS(dx, x.index, x.fields[idx])
        else
            idx = n > 0 ? (n+1:c) : (1:c+n)
            return TS(dx[:,idx], x.index, x.fields[idx])
        end
    end
end

function lag{V,T}(x::TS{V,T}, n::Int=1; pad::Bool=false, padval::V=zero(V))
	@assert abs(n) < size(x,1) "Argument `n` out of bounds."
	if n == 0
		return x
	elseif n > 0
		out = zeros(x.values)
		out[n+1:end,:] = x.values[1:end-n,:]
	elseif n < 0
		out = zeros(x.values)
		out[1:end+n,:] = x.values[1-n:end,:]
	end
    r = size(x, 1)
    c = size(x, 2)
    if pad
        idx = n>0 ? (1:n) : (r+n+1:r)
        out[idx,:] = padval
        return TS(out, x.index, x.fields)
    else
        idx = n > 0 ? (n+1:r) : (1:r+n)
        return TS(out[idx,:], x.index[idx], x.fields)
    end
end

const shift = lag

function pct_change{V}(x::TS{V}, n::Int=1; continuous::Bool=true, pad::Bool=false, padval::V=zero(V))
    if continuous
        return diff(log(x), n; pad=pad, padval=padval)
    else
        if pad
            return diff(x, n, pad=pad, padval=padval) ./ x
        else
            return diff(x, n) ./ x[n+1:end,:]
        end
    end
end

# Artithmetic operators
-(x::TS) = TS(-x.values, x.index, x.fields)

broadcast(::typeof(+), x::TS, y::TS) = TS(x.values .+ y.values, x.index, x.fields)
+(x::TS, y::TS) = TS(x.values + y.values, x.index, x.fields)
broadcast(::typeof(-), x::TS, y::TS) = TS(x.values .- y.values, x.index, x.fields)
-(x::TS, y::TS) = TS(x.values - y.values, x.index, x.fields)
broadcast(::typeof(*), x::TS, y::TS) = TS(x.values .* y.values, x.index, x.fields)
*(x::TS, y::TS) = x .* y
broadcast(::typeof(/), x::TS, y::TS) = TS(x.values ./ y.values, x.index, x.fields)
/(x::TS, y::TS) = x ./ y
broadcast(::typeof(^), x::TS, y::TS) = TS(x.values .^ y.values, x.index, x.fields)
^(x::TS, y::TS) = x .^ y
broadcast(::typeof(%), x::TS, y::TS) = TS(x.values .% y.values, x.index, x.fields)
%(x::TS, y::TS) = x .% y

broadcast(::typeof(+), x::TS, y::AbstractArray) = TS(x.values .+ y, x.index, x.fields)
+(x::TS, y::AbstractArray) = x .+ y
broadcast(::typeof(-), x::TS, y::AbstractArray) = TS(x.values .- y, x.index, x.fields)
-(x::TS, y::AbstractArray) = x .- y
broadcast(::typeof(*), x::TS, y::AbstractArray) = TS(x.values .* y, x.index, x.fields)
*(x::TS, y::AbstractArray) = x .* y
broadcast(::typeof(/), x::TS, y::AbstractArray) = TS(x.values ./ y, x.index, x.fields)
/(x::TS, y::AbstractArray) = x ./ y
broadcast(::typeof(%), x::TS, y::AbstractArray) = TS(x.values .% y, x.index, x.fields)
%(x::TS, y::AbstractArray) = x .% y
broadcast(::typeof(^), x::TS, y::AbstractArray) = TS(x.values .^ y, x.index, x.fields)
^(x::TS, y::AbstractArray) = x .^ y

broadcast(::typeof(+), y::AbstractArray, x::TS) = x .+ y
+(y::AbstractArray, x::TS) = x + y
broadcast(::typeof(-), y::AbstractArray, x::TS) = x .- y
-(y::AbstractArray, x::TS) = x - y
broadcast(::typeof(*), y::AbstractArray, x::TS) = TS(y .* x.values, x.index, x.fields)
*(y::AbstractArray, x::TS) = y .* x
broadcast(::typeof(/), y::AbstractArray, x::TS) = TS(y ./ x.values, x.index, x.fields)
/(y::AbstractArray, x::TS) = y ./ x
broadcast(::typeof(%), y::AbstractArray, x::TS) = TS(y .% x.values, x.index, x.fields)
%(y::AbstractArray, x::TS) = y .% x
broadcast(::typeof(^), y::AbstractArray, x::TS) = TS(y .^ x.values, x.index, x.fields)
^(y::AbstractArray, x::TS) = y .^ x

broadcast(::typeof(+), x::TS, y::Number) = TS(x.values .+ y, x.index, x.fields)
+(x::TS, y::Number) = TS(x.values .+ y, x.index, x.fields)
broadcast(::typeof(-), x::TS, y::Number) = TS(x.values .- y, x.index, x.fields)
-(x::TS, y::Number) = TS(x.values .- y, x.index, x.fields)
broadcast(::typeof(*), x::TS, y::Number) = TS(x.values .* y, x.index, x.fields)
*(x::TS, y::Number) = TS(x.values .* y, x.index, x.fields)
broadcast(::typeof(/), x::TS, y::Number) = TS(x.values ./ y, x.index, x.fields)
/(x::TS, y::Number) = TS(x.values ./ y, x.index, x.fields)
broadcast(::typeof(%), x::TS, y::Number) = TS(x.values .% y, x.index, x.fields)
%(x::TS, y::Number) = TS(x.values .% y, x.index, x.fields)
broadcast(::typeof(^), x::TS, y::Number) = TS(x.values .^ y, x.index, x.fields)
^{B<:Real,E<:Real}(x::TS{B}, y::E) = TS(x.values .^ y, x.index, x.fields)

broadcast(::typeof(+), y::Number, x::TS) = TS(y .+ x.values, x.index, x.fields)
+(y::Number, x::TS) = x + y
broadcast(::typeof(-), y::Number, x::TS) = TS(y .- x.values, x.index, x.fields)
-(y::Number, x::TS) = x - y
broadcast(::typeof(*), y::Number, x::TS) = TS(y .* x.values, x.index, x.fields)
*(y::Number, x::TS) = x * y
broadcast(::typeof(/), y::Number, x::TS) = TS(y ./ x.values, x.index, x.fields)
/(y::Number, x::TS) = x / y
broadcast(::typeof(%), y::Number, x::TS) = TS(y .% x.values, x.index, x.fields)
%(y::Number, x::TS) = x % y
broadcast(::typeof(^), y::Number, x::TS) = TS(y .^ x.values, x.index, x.fields)
^(y::Number, x::TS) = x ^ y

# Logical operators
all(x::TS) = all(x.values)
any(x::TS) = any(x.values)

broadcast(::typeof(!), x::TS) = TS(.!x.values, x.index, x.fields)
!(x::TS) = .!(x)

function compare_elementwise(x::TS, y::TS, f::Function)
    x_cols = 1:size(x,2)
    y_cols = (1:size(y,2)) + size(x,2)
    merged = [x y]
    result = f.(merged.values[:,x_cols], merged.values[:,y_cols])
    return TS(result, merged.index)
end

# compared to another TS object
==(x::TS, y::TS) = x.values == y.values && x.index == y.index && x.fields == y.fields
!=(x::TS, y::TS) = !(x == y)
>(x::TS, y::TS) = x .> y
<(x::TS, y::TS) = x .< y
>=(x::TS, y::TS) = x .>= y
<=(x::TS, y::TS) = x .<= y

broadcast(::typeof(!=), x::TS, y::TS) = compare_elementwise(x, y, !=)
broadcast(::typeof(==), x::TS, y::TS) = compare_elementwise(x, y, ==)
broadcast(::typeof(>), x::TS, y::TS) = compare_elementwise(x, y, >)
broadcast(::typeof(<), x::TS, y::TS) = compare_elementwise(x, y, <)
broadcast(::typeof(>=), x::TS, y::TS) = compare_elementwise(x, y, >=)
broadcast(::typeof(<=), x::TS, y::TS) = compare_elementwise(x, y, <=)

# compared to singleton numebrs
#TODO/FIXME: elementwise comparison against a Real number
# ==(x::TS, y::Real) = x.values == y
# !=(x::TS, y::Real) = x.values != y
# >(x::TS, y::Real) = all(x.values .> y)
# <(x::TS, y::Real) = all(x.values .< y)
# >=(x::TS, y::Real) = all(x.values .>= y)
# <=(x::TS, y::Real) = all(x.values .<= y)
# 
# broadcast(::typeof(==), x::TS, y::Real) = TS{Bool}(x.values .== y, x.index, x.fields)
# broadcast(::typeof(!=), x::TS, y::Real) = TS{Bool}(x.values .!= y, x.index, x.fields)
# broadcast(::typeof(>), x::TS, y::Real) = TS{Bool}(x.values .> y, x.index, x.fields)
# broadcast(::typeof(<), x::TS, y::Real) = TS{Bool}(x.values .< y, x.index, x.fields)
# broadcast(::typeof(>=), x::TS, y::Real) = TS{Bool}(x.values .>= y, x.index, x.fields)
# broadcast(::typeof(<=), x::TS, y::Real) = TS{Bool}(x.values .<= y, x.index, x.fields)

