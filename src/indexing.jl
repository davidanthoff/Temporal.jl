import Base: getindex, setindex!
const RNG_DLM = '/'

#===============================================================================
                            SETTING VALUES
===============================================================================#
# Translate indices TS understands into indices Arrays can understand (Int Arrays)
getrows{V,T}(x::TS{V,T}, r::Int) = r
getrows{V,T}(x::TS{V,T}, r::T) = find(x.index .== r)
getrows{V,T}(x::TS{V,T}, r::AbstractArray{Int,1}) = r
getrows{V,T}(x::TS{V,T}, r::Vector{Bool}) = (@assert size(x,1)==length(r); find(r))
getrows{V,T}(x::TS{V,T}, r::BitArray{1}) = (@assert size(x,1)==length(r); find(r))
getrows{V,T}(x::TS{V,T}, r::Vector{T}) = find(overlaps(x.index, r))

getcols{V,T}(x::TS{V,T}, c::Int) = c
getcols{V,T}(x::TS{V,T}, c::Symbol) = find(x.fields .== c)
getcols{V,T}(x::TS{V,T}, c::AbstractArray{Int,1}) = c
getcols{V,T}(x::TS{V,T}, c::Vector{Bool}) = (@assert size(x,2)==length(c); find(c))
getcols{V,T}(x::TS{V,T}, c::BitArray{1}) = (@assert size(x,2)==length(c); find(c))
getcols{V,T}(x::TS{V,T}, c::Vector{Symbol}) = find(overlaps(x.fields, c))

# Ensure no bounds are violated before calling `setindex!`
function checkdims(x::TS, v; r=1:size(x,1), c=1:size(x,2))
    @assert size(v,2) == length(c)
    @assert size(v,1) == length(r)
    @assert size(x,1) >= length(r)
    @assert size(x,2) >= length(c)
    if size(x,2)==1
        @assert length(c)==1
    else
        @assert size(x,2)>=length(c)
    end
end

# All rows + all columns
setindex!{V,T}(x::TS{V,T}, v, ::Colon) = (checkdims(x,v); x.values=v)
setindex!{V,T}(x::TS{V,T}, v, ::Colon, ::Colon) = (checkdims(x,v); x.values=v)
# Row subset + all columns
setindex!{V,T}(x::TS{V,T}, v, r::Int, ::Colon) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::T, ::Colon) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::AbstractArray{Int,1}, ::Colon) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{Bool}, ::Colon) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{T}, ::Colon) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Int) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::T) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::AbstractArray{Int,1}) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{Bool}) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{T}) = (checkdims(x,v,r=r); x.values[getrows(x,r),:]=v)
# Column subset + all rows
setindex!{V,T}(x::TS{V,T}, v, ::Colon, c::Int) = (checkdims(x,v,c=c); x.values[:,getcols(x,c)]=v)
setindex!{V,T}(x::TS{V,T}, v, ::Colon, c::Symbol) = (checkdims(x,v,c=c); x.values[:,getcols(x,c)]=v)
setindex!{V,T}(x::TS{V,T}, v, ::Colon, c::AbstractArray{Int,1}) = (checkdims(x,v,c=c); x.values[:,getcols(x,c)]=v)
setindex!{V,T}(x::TS{V,T}, v, ::Colon, c::Vector{Bool}) = (checkdims(x,v,c=c); x.values[:,getcols(x,c)]=v)
setindex!{V,T}(x::TS{V,T}, v, ::Colon, c::Vector{Symbol}) = (checkdims(x,v,c=c); x.values[:,getcols(x,c)]=v)
# Row subset + column subset
setindex!{V,T}(x::TS{V,T}, v, r::Int, c::Int) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(x,c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Int, c::Symbol) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(x,c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Int, c::AbstractArray{Int,1}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(x,c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Int, c::Vector{Bool}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(x,c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Int, c::Vector{Symbol}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(x,c)]=v)

setindex!{V,T}(x::TS{V,T}, v, r::AbstractArray{Int,1}, c::Int) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::AbstractArray{Int,1}, c::Symbol) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::AbstractArray{Int,1}, c::AbstractArray{Int,1}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::AbstractArray{Int,1}, c::Vector{Bool}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::AbstractArray{Int,1}, c::Vector{Symbol}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)

setindex!{V,T}(x::TS{V,T}, v, r::Vector{Bool}, c::Int) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{Bool}, c::Symbol) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{Bool}, c::AbstractArray{Int,1}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{Bool}, c::Vector{Bool}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{Bool}, c::Vector{Symbol}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)

setindex!{V,T}(x::TS{V,T}, v, r::Vector{T}, c::Int) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{T}, c::Symbol) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{T}, c::AbstractArray{Int,1}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{T}, c::Vector{Bool}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::Vector{T}, c::Vector{Symbol}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)

setindex!{V,T}(x::TS{V,T}, v, r::T, c::Int) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::T, c::Symbol) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::T, c::AbstractArray{Int,1}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::T, c::Vector{Bool}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)
setindex!{V,T}(x::TS{V,T}, v, r::T, c::Vector{Symbol}) = (checkdims(x,v,r=r,c=c); x.values[getrows(x,r),getcols(c)]=v)

#===============================================================================
							NUMERICAL INDEXING
===============================================================================#
getindex{V,T}(x::TS{V,T})::TS{V,T} = x

getindex{V,T}(x::TS{V,T}, ::Colon)::TS{V,T} = x
getindex{V,T}(x::TS{V,T}, ::Colon, ::Colon)::TS{V,T} = x
getindex{V,T}(x::TS{V,T}, ::Colon, c::Int)::TS{V,T} = ts(x.values[:,c], x.index, [x.fields[c]])
getindex{V,T}(x::TS{V,T}, ::Colon, c::AbstractArray{Int,1})::TS{V,T} = ts(x.values[:,c], x.index, x.fields[c])

getindex{V,T}(x::TS{V,T}, r::Int)::TS{V,T} = ts(x.values[r,:]', [x.index[r]], x.fields)
getindex{V,T}(x::TS{V,T}, r::Int, ::Colon)::TS{V,T} = ts(x.values[r,:]', [x.index[r]], x.fields)
getindex{V,T}(x::TS{V,T}, r::Int, c::Int)::TS{V,T} = ts([x.values[r,c]], [x.index[r]], [x.fields[c]])
getindex{V,T}(x::TS{V,T}, r::Int, c::AbstractArray{Int,1})::TS{V,T} = ts(x.values[r,c]', [x.index[r]], x.fields[c])

getindex{V,T}(x::TS{V,T}, r::AbstractArray{Int,1})::TS{V,T} = ts(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Int,1}, ::Colon)::TS{V,T} = ts(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Int,1}, c::Int)::TS{V,T} = ts(x.values[r,c], x.index[r], [x.fields[c]])
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Int,1}, c::AbstractArray{Int,1})::TS{V,T} = ts(x.values[r, c], x.index[r], x.fields[c])

#===============================================================================
							BOOLEAN INDEXING
===============================================================================#
getindex{V,T}(x::TS{V,T}, r::BitArray{1})::TS{V,T} = TS(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, ::Colon)::TS{V,T} = TS(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::Int)::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::AbstractArray{Int,1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::BitArray{1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::Vector{Bool})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])

getindex{V,T}(x::TS{V,T}, r::Vector{Bool})::TS{V,T} = TS(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, ::Colon)::TS{V,T} = TS(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::Int)::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::AbstractArray{Int,1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::Vector{Bool})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::BitArray{1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])

getindex{V,T}(x::TS{V,T}, r::AbstractArray{Int,1}, c::BitArray{1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Int,1}, c::Vector{Bool})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Int, c::BitArray{1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Int, c::Vector{Bool})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, ::Colon, c::BitArray{1})::TS{V,T} = TS(x.values[:,c], x.index[:], x.fields[c])
getindex{V,T}(x::TS{V,T}, ::Colon, c::Vector{Bool})::TS{V,T} = TS(x.values[:,c], x.index[:], x.fields[c])

getindex{V,T}(x::TS{V,T}, r::TS{Bool})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values]]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, ::Colon)::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values]]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::Int)::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::AbstractArray{Int,1})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::Vector{Bool})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::BitArray{1})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::Symbol)::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::Vector{Symbol})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]

#===============================================================================
							TEMPORAL INDEXING
===============================================================================#
getindex{V,T}(x::TS{V,T}, r::TimeType)::TS{V,T} = x[x.index.==r]
getindex{V,T}(x::TS{V,T}, r::TimeType, ::Colon)::TS{V,T} = x[x.index.==r,:]
getindex{V,T}(x::TS{V,T}, r::TimeType, c::Int)::TS{V,T} = x[x.index.==r,c]
getindex{V,T}(x::TS{V,T}, r::TimeType, c::AbstractArray{Int,1})::TS{V,T} = x[x.index.==r,c]
getindex{V,T}(x::TS{V,T}, r::TimeType, c::BitArray{1})::TS{V,T} = x[x.index.==r,c]

getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1})::TS{V,T} = x[overlaps(x.index, r)]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, ::Colon)::TS{V,T} = x[overlaps(x.index, r), :]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::Int)::TS{V,T} = x[overlaps(x.index, r), c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::AbstractArray{Int,1})::TS{V,T} = x[overlaps(x.index, r), c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::BitArray{1})::TS{V,T} = x[overlaps(x.index, r), c]

getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1})::TS{V,T} = x[overlaps(x.index, r)]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, ::Colon)::TS{V,T} = x[overlaps(x.index, r), :]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::Int)::TS{V,T} = x[overlaps(x.index, r), c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::AbstractArray{Int,1})::TS{V,T} = x[overlaps(x.index, r), c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::BitArray{1})::TS{V,T} = x[overlaps(x.index, r), c]

#===============================================================================
							TEXTUAL INDEXING
===============================================================================#
getindex{V,T}(x::TS{V,T}, c::Symbol)::TS{V,T} = x[:, x.fields.==c]
getindex{V,T}(x::TS{V,T}, c::Vector{Symbol})::TS{V,T} = x[:, overlaps(x.fields, c)]

getindex{V,T}(x::TS{V,T}, ::Colon, c::Symbol)::TS{V,T} = x[:, x.fields.==c]
getindex{V,T}(x::TS{V,T}, ::Colon, c::Vector{Symbol})::TS{V,T} = x[:, overlaps(x.fields, c)]

getindex{V,T}(x::TS{V,T}, r::Int, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
getindex{V,T}(x::TS{V,T}, r::Int, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]

getindex{V,T}(x::TS{V,T}, r::TimeType, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
getindex{V,T}(x::TS{V,T}, r::TimeType, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]

getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]

getindex{V,T}(x::TS{V,T}, r::AbstractArray{Int,1}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Int,1}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]

getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]

getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]


function thrudt(s::AbstractString, t::Vector{Date})
    n = length(s)
    if n == 4  # yyyy given
        y = parse(Int, s)
        ymd = Date(y, 12, 31)
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        ymd = lastdayofmonth(Date(y, m, 1))
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        ymd = Date(y, m, d)
    else
        error("Unable to parse date string $s.")
    end
    return t .<= ymd
end
function fromdt(s::AbstractString, t::Vector{Date})
    n = length(s)
    if n == 4  # yyyy given
        y = parse(Int, s)
        ymd = Date(y, 1, 1)
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        ymd = Date(y, m, 1)
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        ymd = Date(y, m, d)
    else
        error("Unable to parse date string $s.")
    end
    return t .>= ymd
end
function thisdt(s::AbstractString, t::Vector{Date})
    n = length(s)
    if n == 4  # yyyy given
        y = parse(Int, s)
        return year.(t) .== y
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        return (year.(t) .== y) .* (month.(t) .== m)
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        return (year.(t) .== y) .* (month.(t) .== m) .* day.(t) .== d
    else
        error("Unable to parse date string $s.")
    end
end
function fromthru(from::AbstractString, thru::AbstractString, t::Vector{Date})
    fromidx = fromdt(from, t)
    thruidx = thrudt(thru, t)
    return fromidx .* thruidx
end
function thrudt(s::AbstractString, t::Vector{DateTime})
    n = length(s)
    if n == 4  # yyyy given
        y = parse(Int, s)
        ymdhms = DateTime(y, 12, 31)
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        ymdhms = lastdayofmonth(DateTime(y, m, 1))
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        ymdhms = DateTime(y, m, d)
    elseif n == 13  # yyyy-mm-ddTHH given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = 59
        sec = 59
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n == 16  # yyyy-mm-ddTHH:MM given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = 59
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n == 19  # yyyy-mm-ddTHH:MM:SS given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, c[3])
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n >= 20  # milliseconds given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        f = split(c[3], '.')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, f[1])
        milli = parse(Int, f[2])
        ymdhms = DateTime(y, m, d, hr, min, sec, milli)
    else
        error("Unable to parse date string $s.")
    end
    return t .<= ymdhms
end
function fromdt(s::AbstractString, t::Vector{DateTime})
    n = length(s)
    if n == 4  # yyyy given
        y = parse(Int, s)
        ymdhms = DateTime(y)
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        ymdhms = DateTime(y, m)
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        ymdhms = DateTime(y, m, d)
    elseif n == 13  # yyyy-mm-ddTHH given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n == 16  # yyyy-mm-ddTHH:MM given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n == 19  # yyyy-mm-ddTHH:MM:SS given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, c[3])
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n >= 20  # milliseconds given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        f = split(c[3], '.')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, f[1])
        milli = parse(Int, f[2])
        ymdhms = DateTime(y, m, d, hr, min, sec, milli)
    else
        error("Unable to parse date string $s.")
    end
    return t .>= ymdhms
end
function thisdt(s::AbstractString, t::Vector{DateTime})
    n = length(s)
    if n == 4  # yyyy given
        y = parse(Int, s)
        return year.(t) .== y
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        return (year.(t) .== y) .* (month.(t) .== m)
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        return (year.(t) .== y) .* (month.(t) .== m) .* (day.(t) .== d)
    elseif n == 13  # yyyy-mm-ddTHH given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        return (year.(t) .== y) .* (month.(t) .== m) .* (day.(t) .== d) .* (hour.(t) .== hr)
    elseif n == 16  # yyyy-mm-ddTHH:MM given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        return (year.(t) .== y) .* (month.(t) .== m) .* (day.(t) .== d) .* (hour.(t) .== hr) .* (minute.(t) .== min)
    elseif n == 19  # yyyy-mm-ddTHH:MM:SS given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, c[3])
        return (year.(t) .== y) .* (month.(t) .== m) .* (day.(t) .== d) .* (hour.(t) .== hr) .* (minute.(t) .== min) .* (second.(t) .== sec)
    elseif n >= 20  # milliseconds given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        f = split(c[3], '.')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, f[1])
        milli = parse(Int, f[2])
        return (year.(t) .== y) .* (month.(t) .== m) .* (day.(t) .== d) .* (hour.(t) .== hr) .* (minute.(t) .== min) .* (second.(t) .== sec) .* (millisecond.(t) .== milli)
    else
        error("Unable to parse date string $s.")
    end
end
function fromthru(from::AbstractString, thru::AbstractString, t::Vector{DateTime})
    fromidx = fromdt(from, t)
    thruidx = thrudt(thru, t)
    return fromidx .* thruidx
end

function dtidx(s::AbstractString, t::Vector{Date})
    @assert !in('T', s) "Cannot index Date type with sub-daily frequency."
    bds = split(s, RNG_DLM)
    if length(bds) == 1  # single date
        return thisdt(s, t)
    elseif length(bds) == 2  # date range
        n1 = length(bds[1])
        n2 = length(bds[2])
        if n1 == 0 && n2 != 0  # thru date given
            return thrudt(bds[2], t)
        elseif n1 != 0 && n2 == 0  # from date given
            return fromdt(bds[1], t)
        elseif n1 != 0 && n2 != 0  # from and thru date given
            return fromthru(bds[1], bds[2], t)
        else
            error("Invalid indexing string: Unable to parse $s")
        end
    else
        error("Invalid indexing string: Unable to parse $s")
    end
end
function dtidx(s::AbstractString, t::Vector{DateTime})
    bds = split(s, RNG_DLM)
    if length(bds) == 1  # single date
        return thisdt(s, t)
    elseif length(bds) == 2  # date range
        n1 = length(bds[1])
        n2 = length(bds[2])
        if n1 == 0 && n2 != 0  # thru date given
            return thrudt(bds[2], t)
        elseif n1 != 0 && n2 == 0  # from date given
            return fromdt(bds[1], t)
        elseif n1 != 0 && n2 != 0  # from and thru date given
            return fromthru(bds[1], bds[2], t)
        else
            error("Invalid indexing string: Unable to parse $s")
        end
    else
        error("Invalid indexing string: Unable to parse $s")
    end
end

getindex{V,T}(x::TS{V,T}, r::AbstractString)::TS{V,T} = x[dtidx(r, x.index)]
getindex{V,T}(x::TS{V,T}, r::AbstractString, ::Colon)::TS{V,T} = x[dtidx(r, x.index)]
getindex{V,T}(x::TS{V,T}, r::AbstractString, c::Int)::TS{V,T} = x[dtidx(r, x.index), c]
getindex{V,T}(x::TS{V,T}, r::AbstractString, c::AbstractArray{Int,1})::TS{V,T} = x[dtidx(r, x.index), c]
getindex{V,T}(x::TS{V,T}, r::AbstractString, c::BitArray{1})::TS{V,T} = x[dtidx(r, x.index), c]
getindex{V,T}(x::TS{V,T}, r::AbstractString, c::Symbol)::TS{V,T} = x[dtidx(r, x.index), c]
getindex{V,T}(x::TS{V,T}, r::AbstractString, c::Vector{Symbol})::TS{V,T} = x[dtidx(r, x.index), c]
