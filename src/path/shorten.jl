function shorten(pa, n_ba::Real)

    joinpath(splitpath(pa)[(end - n_ba):end]...)

end

function shorten(pa, di::AbstractString)

    sp_ = splitpath(pa)

    id = findfirst(sp_ .== basename(di))

    if isnothing(id)

        error(di, " is not part of ", pa)

    end

    shorten(pa, length(sp_) - id)

end