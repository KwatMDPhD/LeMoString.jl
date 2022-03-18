# ----------------------------------------------------------------------------------------------- #
TE = joinpath(tempdir(), "constant.test")

if isdir(TE)

    rm(TE, recursive = true)

    println("Removed $TE.")

end

mkdir(TE)

println("Made $TE.")

# ----------------------------------------------------------------------------------------------- #
using OnePiece

# ----------------------------------------------------------------------------------------------- #
println(OnePiece.constant.ALPHABET)

# ----------------------------------------------------------------------------------------------- #
println(OnePiece.constant.CARD)

# ----------------------------------------------------------------------------------------------- #
println("Done.")
