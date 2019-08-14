using Test
using OMEinsum
using CuArrays

CuArrays.allowscalar(false)

@testset "cuda einsum" begin
    a = [randn(fill(3, i)...) for i=1:4]
    ca = a .|> CuArray
    ixs = ((1,2), (2,3))
    xs = (ca[2], ca[2])
    @test loop_einsum!(EinCode(ixs, (1,3)), xs, zeros(3,3) |> CuArray, OMEinsum.get_size_dict(ixs, xs)) ≈ ca[2]*ca[2]
    for f in [ein"ij,jk->ik", ein"ii->", ein"ijj ->i", ein"ij,ik,il->jkl", ein"ii->i", ein"ijl->i", ein"i->ii", ein"ij,jk,kl->il", ein"ij,ij,ij -> ij"]
        @show f
        cins = map(ix->ca[length(ix)], OMEinsum.getixs(f))
        ins = map(ix->a[length(ix)], OMEinsum.getixs(f))
        @test f(cins...) isa CuArray
        @test f(ins...) ≈ f(cins...)
    end
end

@testset "fallback - getindex IR error" begin
    a = rand(ComplexF64,2,2,2)
    ca = CuArray(a);
    @test Array(ein"npu,por,dom,lmn -> urdl"(ca,ca,ca,ca)) ≈ ein"npu,por,dom,lmn -> urdl"(a,a,a,a)
end
