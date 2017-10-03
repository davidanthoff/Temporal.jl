import Base:getindex

# all element indexing
getindex(x::TS) = x
getindex(x::TS, ::Colon) = x
getindex(x::TS, ::Colon, ::Colon) = x

# int/bool row indexing
getindex{R<:Integer}(x::TS, r::R) = TS(x.values[r,:], x.index[r], x.fields)
getindex{R<:AbstractVector{<:Integer}}(x::TS, r::R) = TS(x.values[r,:], x.index[r], x.fields)
getindex{R<:Integer}(x::TS, r::R, ::Colon) = TS(x.values[r,:], x.index[r], x.fields)
getindex{R<:AbstractVector{<:Integer}}(x::TS, r::R, ::Colon) = TS(x.values[r,:], x.index[r], x.fields)

# int/bool column indexing
getindex{C<:Integer}(x::TS, ::Colon, c::C) = TS(x.values[:,c], x.index, x.fields[c])
getindex{C<:Vector{<:Integer}}(x::TS, ::Colon, c::C) = TS(x.values[:,c], x.index, x.fields[c])
getindex{C<:AbstractVector{<:Integer}}(x::TS, ::Colon, c::C) = TS(x.values[:,c], x.index, x.fields[c])

# symbol column indexing
getindex{C<:Symbol}(x::TS, c::C) = (cols=findcolumns(c,x); TS(x.values[:,cols], x.index, x.fields[cols]))
getindex{C<:AbstractVector{Symbol}}(x::TS, c::C) = (cols=findcolumns(c,x); TS(x.values[:,cols], x.index, x.fields[cols]))
getindex{C<:Symbol}(x::TS, ::Colon, c::C) = (cols=findcolumns(c,x); TS(x.values[:,cols], x.index, x.fields[cols]))
getindex{C<:AbstractVector{Symbol}}(x::TS, ::Colon, c::C) = (cols=findcolumns(c,x); TS(x.values[:,cols], x.index, x.fields[cols]))
getindex{C<:Symbol}(x::TS, c::C) = x[:, x.fields.==c]
getindex{C<:Symbol}(x::TS, ::Colon, c::C) = x[c]
getindex{C<:AbstractVector{<:Symbol}}(x::TS, c::C) = x[:, overlaps(x.fields, c)]
getindex{C<:AbstractVector{<:Symbol}}(x::TS, ::Colon, c::C) = x[c]
getindex{R<:Integer,C<:Symbol}(x::TS, r::R, c::C) = x[r, x.fields.==c]
getindex{R<:Integer,C<:AbstractVector{<:Symbol}}(x::TS, r::R, c::C) = x[r, overlaps(x.fields, c)]
getindex{R<:AbstractVector{<:Integer},C<:Symbol}(x::TS, r::R, c::C) = x[r, x.fields.==c]
getindex{R<:AbstractVector{<:Integer},C<:AbstractVector{<:Symbol}}(x::TS, r::R, c::C) = x[r, overlaps(x.fields, c)]

# boolean time series indexing
getindex(x::TS, r::TS{Bool}) = x[r.index[overlaps(r.index,x.index).*r.values]]
getindex(x::TS, r::TS{Bool}, ::Colon) = x[r.index[overlaps(r.index,x.index).*r.values]]
getindex{C<:Symbol}(x::TS, r::TS{Bool}, c::C) = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{C<:AbstractVector{<:Symbol}}(x::TS, r::TS{Bool}, c::C) = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{C<:Integer}(x::TS, r::TS{Bool}, c::C) = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{C<:AbstractVector{<:Integer}}(x::TS, r::TS{Bool}, c::C) = x[r.index[overlaps(r.index,x.index).*r.values],c]

# timetype row indexing
getindex{V,T<:TimeType}(x::TS{V,T}, t::T) = x[x.index.==t]
getindex{V,T<:TimeType}(x::TS{V,T}, t::T, ::Colon) = x[x.index.==t,:]
getindex{V,T<:TimeType,C<:Integer}(x::TS{V,T}, t::T, c::C) = x[x.index.==t,c]
getindex{V,T<:TimeType,C<:Symbol}(x::TS{V,T}, t::T, c::C) = x[x.index.==t,c]
getindex{V,T<:TimeType,C<:AbstractVector{<:Integer}}(x::TS{V,T}, t::T, c::C) = x[x.index.==t,c]
getindex{V,T<:TimeType,C<:AbstractVector{<:Symbol}}(x::TS{V,T}, t::T, c::C) = x[x.index.==t,c]

# string-based date(time) row indexing
getindex{R<:AbstractString}(x::TS, r::R) = x[dtidx(r, x.index)]
getindex{R<:AbstractString}(x::TS, r::R, ::Colon) = x[r]
getindex{R<:AbstractString,C<:Integer}(x::TS, r::R, c::C) = x[dtidx(r, x.index), c]
getindex{R<:AbstractString,C<:AbstractVector{<:Integer}}(x::TS, r::R, c::C) = x[dtidx(r, x.index), c]
getindex{R<:AbstractString,C<:Symbol}(x::TS, r::R, c::C) = x[dtidx(r, x.index), c]
getindex{R<:AbstractString,C<:AbstractVector{<:Symbol}}(x::TS, r::R, c::C) = x[dtidx(r, x.index), c]