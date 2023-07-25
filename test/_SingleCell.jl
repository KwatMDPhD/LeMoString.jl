using Test: @test

using BioLab

# ---- #

DA = joinpath(BioLab.DA, "SingleCell")

@test readdir(DA) == []

# ---- #

sa_di = Dict(
    sa => joinpath(DA, di) for
    (sa, di) in (("Sample 96", "7166_mr_96_filtered"), ("Sample 87", "7166_mr_87_filtered"))
)

# ---- #

fe_, ba_, fe_x_ba_x_co, sa_, ids___ = BioLab.SingleCell.read(sa_di)

n_fe = 58395

n_ba = 5158

@test length(fe_) == n_fe

@test length(ba_) == n_ba

@test size(fe_x_ba_x_co) == (n_fe, n_ba)

@test sa_ == collect(keys(sa_di))

@test ids___ == [1:3905, 3906:n_ba]

# ---- #

# 6.025 s (49138936 allocations: 5.27 GiB)
# 6.658 s (49140059 allocations: 5.27 GiB) with @showprogress
#@btime BioLab.SingleCell.read($sa_di);

# ---- #

n = 1000

me_ = randn(n)

for (mi, ma, re) in
    ((0, 0, fill(false, n)), (-Inf, 0, me_ .<= 0), (0, Inf, 0 .<= me_), (-Inf, Inf, fill(true, n)))

    @test BioLab.Vector.select(TE, me_, mi, ma) == re

end