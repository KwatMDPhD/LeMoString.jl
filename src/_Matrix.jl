module Matrix

using ..BioLab

function print(ro_x_co_x_an; n_ro = 3, n_co = 3)

    sir, sic = size(ro_x_co_x_an)

    println("📐 $sir x $sic")

    if sir <= n_ro

        idr___ = (1:sir,)

    else

        idr___ = (1:n_ro, (1 + sir - n_ro):sir)

    end

    if sic <= n_co

        idc___ = (1:sic,)

    else

        idc___ = (1:n_co, (1 + sic - n_co):sic)

    end

    for idr_ in idr___, idc_ in idc___

        println("🕯️ $idr_ x $idc_")

        display(view(ro_x_co_x_an, idr_, idc_))

    end

    return nothing

end

function make(an___)

    BioLab.Array.error_size(an___)

    n_ro = length(an___)

    n_co = length(an___[1])

    ro_x_co_x_an = Base.Matrix{BioLab.Collection.get_type(an___...)}(undef, (n_ro, n_co))

    for idr in 1:n_ro, idc in 1:n_co

        ro_x_co_x_an[idr, idc] = an___[idr][idc]

    end

    return ro_x_co_x_an

end

function apply_by_column!(fu!, ro_x_co_x_an)

    for ve in eachcol(ro_x_co_x_an)

        fu!(ve)

    end

    return nothing

end

function apply_by_row!(fu!, ro_x_co_x_an)

    for ve in eachrow(ro_x_co_x_an)

        fu!(ve)

    end

    return nothing

end

function simulate(n_ro, n_co, ho; re = 0)

    if ho == "1.0:"

        ro_x_co_x_nu = convert(Base.Matrix, reshape(1.0:(n_ro * n_co), (n_ro, n_co)))

    elseif ho == "rand"

        ro_x_co_x_nu = rand(n_ro, n_co)

    elseif ho == "randn"

        # TODO `@test`.

        ro_x_co_x_nu = randn(n_ro, n_co)

    else

        error()

    end

    # TODO: `@test`.

    if re == 1

        for id in 2:2:n_ro

            reverse!(view(ro_x_co_x_nu, id, :))

        end

    elseif re == 2

        for id in 2:2:n_co

            reverse!(view(ro_x_co_x_nu, :, id))

        end

    end

    return ro_x_co_x_nu

end

end