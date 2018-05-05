using IteratorInterfaceExtensions
using TableTraits
using TableTraitsUtils
using NamedTuples

struct TSIterator{T,S}
    source::S
end

IteratorInterfaceExtensions.isiterable(x::TS) = true
TableTraits.isiterabletable(x::TS) = true

function IteratorInterfaceExtensions.getiterator(ta::S) where {S <: TS}
    col_names = [:Index; ta.fields]
    col_types = [S.parameters[2]; fill(eltype(ta.values), length(ta.fields))]

    T = eval(:(@NT($(col_names...)))){col_types...}

    return TSIterator{T,S}(ta)
end

Base.length(iter::TSIterator) = length(iter.source.index)

Base.eltype(iter::TSIterator{T,TS}) where {T,TS} = T

Base.start(iter::TSIterator) = 1

@generated function Base.next(iter::TSIterator{T,S}, row) where {T,S}
    return :(return T($([:(iter.source.index[row]); [:(iter.source.values[row,$col]) for col=1:length(T.parameters)-1]]...)), row+1)
end

Base.done(iter::TSIterator, state) = state>length(iter.source.index)

# Sink

function TS(source; index_column::Symbol=:Index)
    isiterabletable(source) || error("Source is not an iterable table.")

    iter = getiterator(source)

    if TableTraits.column_count(iter)<2
        error("Need at least two columns")
    end

    names = TableTraits.column_names(iter)
    
    timestep_col_index = findfirst(names, index_column)

    if timestep_col_index==0
        error("No index column found.")
    end
    
    col_types = TableTraits.column_types(iter)

    data_columns = collect(Iterators.filter(i->i[2][1]!=index_column, enumerate(zip(names, col_types))))

    orig_data_type = data_columns[1][2][2]

    # TODO Decide how to handle this case
    # data_type = orig_data_type <: DataValue ? orig_data_type.parameters[1] : orig_data_type

    orig_timestep_type = col_types[timestep_col_index]

    # TODO Decide how to handle this case
    # timestep_type = orig_timestep_type <: DataValue ? orig_timestep_type.parameters[1] : orig_timestep_type

    if any(i->i[2][2]!=orig_data_type, data_columns)
        error("All data columns need to be of the same type.")
    end

    cols_from_source, _ = create_columns_from_iterabletable(iter)
    t_column = cols_from_source[timestep_col_index]
    deleteat!(cols_from_source, timestep_col_index)

    d_array = hcat([cols_from_source[i] for i=1:length(cols_from_source)]...)

    ta = TS(d_array, t_column,[i[2][1] for i in data_columns])
    return ta
end