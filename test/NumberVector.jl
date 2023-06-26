using Random: seed!

include("environment.jl")

# ---- #

for (nu_, re) in (
    ([0, 1, 2], [0, 1, 2]),
    ([0, 1, 2, 0], [0, 0, 0, 0]),
    ([0, 1, 2, 2, 1, 0, 1, 2, 3], [0, 0, 0, 0, 0, 0, 1, 2, 3]),
)

    @test BioLab.NumberVector.force_increasing_with_min!(nu_) == re

end

# ---- #

for (nu_, re) in (
    ([0, 1, 2], [0, 1, 2]),
    ([0, 1, 2, 0], [0, 1, 2, 2]),
    ([0, 1, 2, 2, 1, 0, 1, 2, 3], [0, 1, 2, 2, 2, 2, 2, 2, 3]),
)

    @test BioLab.NumberVector.force_increasing_with_max!(nu_) == re

end

# ---- #

se = 20230610

n = 3

# ---- #

seed!(se)

ne_, po_ = BioLab.NumberVector._simulate(n)

ren = [-1.4897554994413376, -0.370149968439238, -0.0]

rep = -reverse((ren))

@test ne_ == ren

@test po_ == rep

# ---- #

ref = vcat(ren[1:(end - 1)], rep)

ret = vcat(ren, rep)

for (ze, re) in ((false, ref), (true, ret))

    @test BioLab.NumberVector._concatenate(ne_, ze, po_) == re

end

# ---- #

for (ze, re) in ((false, ref), (true, ret))

    seed!(se)

    @test BioLab.NumberVector.simulate(n; ze) == re

end

# ---- #

for (ze, re) in ((false, vcat(ren[1:(end - 1)] * 2, rep)), (true, vcat(ren * 2, rep)))

    seed!(se)

    @test BioLab.NumberVector.simulate_deep(n; ze) == re

end

# ---- #

wi_ = [-1.4897554994413376, -0.9299527339402878, -0.370149968439238, -0.185074984219619]

for (ze, re) in ((false, vcat(wi_, rep)), (true, vcat(wi_, -0.0, rep)))

    seed!(se)

    @test BioLab.NumberVector.simulate_wide(n; ze) == re

end