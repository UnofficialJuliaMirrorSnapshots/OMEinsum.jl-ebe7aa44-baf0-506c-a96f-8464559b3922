using Test
using OMEinsum
using OMEinsum: subindex

@testset "EinCode" begin
    code = EinCode(((1,2), (2,3)), (1,3))
    @test code isa EinCode
    @test OMEinsum.getixs(code) == ((1,2), (2,3))
    @test OMEinsum.getiy(code) == (1,3)
end

@testset "indexer" begin
    si = EinIndexer{()}(())
    @test subindex(si, (1,2,3)) == 1
    si = EinIndexer{(3,2)}((7,6))
    @test OMEinsum.getlocs(si) == (3,2)
    a = randn(7,6)
    @test a[subindex(si, (4,5,2))] == a[2,5]
end

@testset "EinArray" begin
    locs_xs = (EinIndexer{(1,2)}((8,8)), EinIndexer{(2,3)}((8,8)))
    ixs = ((1,2), (2,3))
    iy = (1,3)
    x1 = randn(8, 8)
    x2 = randn(8, 8)
    arr = einarray(EinCode(ixs, iy), (x1, x2), OMEinsum.get_size_dict(ixs, (x1, x2)))
    @test size(arr) == (8,8,8)
    # inner first, then outer
    @test arr[CartesianIndex((3,4,2))] == x1[4,3]*x2[3,2]
    @test arr[3,4,2] == x1[4,3]*x2[3,2]
end
