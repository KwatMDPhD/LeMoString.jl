module Clustering

using Clustering: cutree, hclust

using Distances: Euclidean, pairwise

using ..Nucleus

const _FU = Euclidean()

const _LI = :ward

function hierarchize(ma, fu = _FU, linkage = _LI)

    hclust(pairwise(fu, ma); linkage)

end

function cluster(hc, k)

    cutree(hc; k)

end

function order(co_, ma, fu = _FU, linkage = _LI)

    id_ = Int[]

    for co in sort!(unique(co_))

        idc_ = findall(==(co), co_)

        append!(id_, view(idc_, hierarchize(ma[:, idc_], fu, linkage).order))

    end

    id_

end

function _mean(nu)

    sum(nu) / lastindex(nu)

end

# TODO: Test.
function compare_grouping(
    ht,
    id_::AbstractVector{<:Integer},
    fe_x_sa_x_nu,
    ng_ = eachindex(unique(id_));
    fu = _FU,
    title_text = "",
)

    n_gr = lastindex(ng_)

    hi = hierarchize(fe_x_sa_x_nu, fu)

    mu_ = [
        Nucleus.Information.get_mutual_information(id_, cluster(hi, n_gr); no = true) for
        n_gr in ng_
    ]

    Nucleus.Plot.plot_scatter(
        ht,
        (mu_,),
        (ng_,);
        layout = Dict(
            "title" => Dict("text" => "$title_text<br>$(Nucleus.Number.format4(_mean(mu_)))"),
            "yaxis" => Dict("title" => Dict("text" => "Mutual Information")),
            "xaxis" => Dict("title" => Dict("text" => "Number of Group")),
        ),
    )

    mu_

end

# TODO: Test.
function compare_grouping(
    ht,
    la_,
    fe_x_sa_x_nu,
    ng_ = eachindex(unique(la_));
    fu = _FU,
    title_text = "",
)

    n_gr = lastindex(ng_)

    hi = hierarchize(fe_x_sa_x_nu, fu)

    un_ = unique(la_)

    la_x_ng_x_ti = Matrix{Int}(undef, lastindex(un_), n_gr)

    la_gr_ = Dict(la => Int[] for la in un_)

    for (idg, n_gr) in enumerate(ng_)

        for (la, gr) in zip(la_, cluster(hi, n_gr))

            push!(la_gr_[la], gr)

        end

        for (idl, la) in enumerate(un_)

            gr_ = la_gr_[la]

            la_x_ng_x_ti[idl, idg] = convert(Int, isone(lastindex(unique!(gr_))))

            empty!(gr_)

        end

    end

    id_ = sortperm(sum.(eachrow(la_x_ng_x_ti)))

    Nucleus.Plot.plot_heat_map(
        ht,
        la_x_ng_x_ti[id_, :];
        y = un_[id_],
        x = ng_,
        nar = "Label",
        nac = "Number of Group",
        layout = Dict(
            "title" => Dict(
                Dict(
                    "text" => "$title_text<br>$(Nucleus.Number.format4(_mean(la_x_ng_x_ti) * 100))%",
                ),
            ),
            "yaxis" => Dict("dtick" => 1),
        ),
    )

    la_x_ng_x_ti

end

end
