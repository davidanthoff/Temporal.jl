using Temporal
using NamedTuples
using Base.Test

@testset "TableTraits" begin

dates  = collect(Date(1999,1,1):Date(1999,1,3))

source_ta1 = TS(collect(1:length(dates)), dates, [:value])

@test IteratorInterfaceExtensions.isiterable(source_ta1) == true

source_it = IteratorInterfaceExtensions.getiterator(source_ta1)

@test length(source_it) == 3

df1 = collect(source_it)
@test df1 == [@NT(Index=Date(1999,1,1),value=1),
    @NT(Index=Date(1999,1,2),value=2),
    @NT(Index=Date(1999,1,3),value=3)]

source_ta2 = TS(collect(1:length(dates)), dates, :a)
df2 = collect(IteratorInterfaceExtensions.getiterator(source_ta2))
@test df2 == [@NT(Index=Date(1999,1,1),a=1),
    @NT(Index=Date(1999,1,2),a=2),
    @NT(Index=Date(1999,1,3),a=3)]

source_ta3 = TS(hcat(collect(1:length(dates)), collect(length(dates):-1:1)), dates, [:a, :b])
df3 = collect(IteratorInterfaceExtensions.getiterator(source_ta3))
@test df3 == [@NT(Index=Date(1999,1,1),a=1,b=3),
    @NT(Index=Date(1999,1,2),a=2,b=2),
    @NT(Index=Date(1999,1,3),a=3,b=1)]

source_tt = [@NT(a=4.,time=Date(1999,1,1),b=6.,c=12.), @NT(a=5.,time=Date(1999,1,2),b=8.,c=24.)]
ta1 = TS(source_tt, index_column=:time)
@test size(ta1) == (2,3)
@test ta1.values == [4. 6. 12.;5. 8. 24]
@test ta1.index == [Date(1999,1,1),Date(1999,1,2)]

end
