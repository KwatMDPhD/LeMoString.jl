# ----------------------------------------------------------------------------------------------- #
TE = joinpath(tempdir(), "speed.test")

if isdir(TE)

    rm(TE, recursive = true)

    println("Removed $TE.")

end

mkdir(TE)

println("Made $TE.")

# ----------------------------------------------------------------------------------------------- #
using OnePiece

# ----------------------------------------------------------------------------------------------- #
using BenchmarkTools

# ----------------------------------------------------------------------------------------------- #
println("sum_1_absolute_and_0_count")

ve = [-2.0, -1, 0, 1, 2]

in_ = convert(Vector{Bool}, [1, 1, 0, 0, 1])

@btime OnePiece.feature_set_enrichment.sum_1_absolute_and_0_count(ve, in_)

# ----------------------------------------------------------------------------------------------- #
using DataFrames

# ----------------------------------------------------------------------------------------------- #
fe_, sc_, fe1_ = OnePiece.feature_set_enrichment.make_benchmark("myc")

in_ = OnePiece.vector.is_in(fe_, fe1_)

sc_fe_sa = DataFrame(
    "Feature" => fe_,
    "Score" => sc_,
    "Score x 10" => sc_ * 10,
    "Constant" => fill(0.8, length(fe_)),
)

se_fe_ =
    OnePiece.gmt.read(joinpath(@__DIR__, "feature_set_enrichment.data", "h.all.v7.1.symbols.gmt"))

# ----------------------------------------------------------------------------------------------- #
println("is_in")

@btime OnePiece.vector.is_in(fe_, fe1_)

# ----------------------------------------------------------------------------------------------- #
println("score_set in_")

@btime OnePiece.feature_set_enrichment.score_set(fe_, sc_, fe1_, in_, pl = false)

# ----------------------------------------------------------------------------------------------- #
println("score_set")

@btime OnePiece.feature_set_enrichment.score_set(fe_, sc_, fe1_, pl = false)

# ----------------------------------------------------------------------------------------------- #
println("score_set se_fe_")

@btime OnePiece.feature_set_enrichment.score_set(fe_, sc_, se_fe_)

# ----------------------------------------------------------------------------------------------- #
println("score_set se_fe_sa")

@btime OnePiece.feature_set_enrichment.score_set(sc_fe_sa, se_fe_)

# ----------------------------------------------------------------------------------------------- #
println("score_set_new")

@btime OnePiece.feature_set_enrichment.score_set_new(fe_, sc_, fe1_, pl = false)

# ----------------------------------------------------------------------------------------------- #
println("score_set_new se_fe_")

@btime OnePiece.feature_set_enrichment.score_set_new(fe_, sc_, se_fe_)

# ----------------------------------------------------------------------------------------------- #
println("Done.")
