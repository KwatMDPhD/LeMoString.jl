module Gene

using BioLab

function _read(na)

    BioLab.Table.read(joinpath(BioLab._DA, "Gene", na))

end

function map_ensembl()

    fr_to = Dict{String, String}()

    da = _read("ensembl.tsv.gz")

    co_ = [
        "Transcript stable ID version",
        "Transcript stable ID",
        "Transcript name",
        "Gene stable ID version",
        "Gene stable ID",
        "Gene name",
    ]

    n = length(co_)

    for an_ in eachrow(Matrix(da[!, co_]))

        fr_ = view(an_, 1:(n - 1))

        to = an_[n]

        if BioLab.Bad.is(to)

            continue

        end

        for fr in fr_

            if BioLab.Bad.is(fr)

                continue

            end

            for fr in eachsplit(fr, '|')

                BioLab.Dict.set!(fr_to, fr, to)

            end

        end

    end

    fr_to

end

function map_uniprot()

    pr_co_an = Dict{String, Dict{String, Any}}()

    da = _read("uniprot.tsv.gz")

    co_ = names(da)

    for an_ in eachrow(Matrix(da))

        co_an = Dict{String, Any}()

        for (co, an) in zip(co_, an_)

            if BioLab.Bad.is(an)

                continue

            end

            if co == "Entry Name"

                BioLab.Dict.set!(pr_co_an, chop(an; tail = 6), co_an)

            else

                if co == "Gene Names"

                    an = split(an)

                elseif co == "Interacts with"

                    an = split(an, "; ")

                end

                co_an[co] = an

            end

        end

    end

    pr_co_an

end

end
