module Collection

using StatsBase: countmap

function error_duplicate(an_)

    if isempty(an_)

        @warn "Collection is empty."

        return

    end

    if !allunique(an_)

        st = join(("$n $an" for (an, n) in countmap(an_) if 1 < n), ". ")

        error("Collection has a duplicate. $st.")

    end

end

function error_no_change(an_)

    if isempty(an_)

        @warn "Collection is empty."

        return

    end

    if allequal(an_)

        an = an_[1]

        error("Collection has only $an.")

    end

end

function index(an_)

    ty = eltype(an_)

    an_id = Dict{ty, Int}()

    id_an = Dict{Int, ty}()

    for (id, an) in enumerate(an_)

        an_id[an] = id

        id_an[id] = an

    end

    an_id, id_an

end

function get_extreme(n::Int, n_ex)

    if n / 2 < n_ex

        collect(1:n)

    else

        vcat(collect(1:n_ex), collect((n - n_ex + 1):n))

    end

end

function get_extreme(an_::AbstractVector, n_ex)

    sortperm(an_)[get_extreme(length(an_), n_ex)]

end

function get_extreme(fl_::AbstractVector{Float64}, n_ex)

    sortperm(fl_)[get_extreme(length(fl_) - sum(isnan, fl_), n_ex)]

end

function get_extreme(an_, n_ex)

    get_extreme([an_...], n_ex)

end

# TODO: Benchmark against list comprehension.
function is_in(an_, an1_)

    n = length(an_)

    bo_ = Vector{Bool}(undef, n)

    for id in 1:n

        bo_[id] = an_[id] in an1_

    end

    bo_

end

function is_in(an_id::AbstractDict, an1_)

    bo_ = fill(false, length(an_id))

    for an1 in an1_

        id = get(an_id, an1, 0)

        if !iszero(id)

            bo_[id] = true

        end

    end

    bo_

end

function sort_like(an___; rev = false)

    id_ = sortperm(an___[1]; rev)

    (an_[id_] for an_ in an___)

end

end
