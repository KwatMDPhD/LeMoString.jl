module GPSMap

using DelaunayTriangulation: get_edges

using StatsBase: mean, std

using ..Nucleus

# TODO: Test.
function normalize_h!(h1, h2 = h1; lo = -3, hi = 3)

    if size(h1, 1) != size(h2, 1)

        error()

    end

    ra = hi - lo

    for (e1, e2) in zip(eachrow(h1), eachrow(h2))

        m1 = mean(e1)

        s1 = std(e1)

        if iszero(s1)

            error()

        end

        for (i2, n2) in enumerate(e2)

            e2[i2] = clamp((n2 - m1) / s1, lo, hi)

        end

        if allequal(e2)

            be = e2[1]

            af = (be - lo) / ra

            e2 .= af

            @warn "$be --> $af."

        else

            Nucleus.Normalization.normalize_with_01!(e2)

        end

        @assert !any(isnan, e2)

        @assert !any(Nucleus.Number.is_negative, e2)

    end

end

function distance(ea_)

    Nucleus.Distance.get_half(Nucleus.Information.get_information_coefficient_distance, ea_)

end

function plot(
    ht,
    no_,
    di_x_no_x_co,
    po_,
    no_x_po_x_pu;
    triangulation_line_color = "#171412",
    node_marker_size = 32,
    node_marker_opacity = 0.96,
    node_marker_color = triangulation_line_color,
    node_marker_line_width = 2,
    node_marker_line_color = Nucleus.Color.HEFA,
    node_annotation_font_size = 16,
    node_annotation_font_color = node_marker_color,
    node_annotation_bgcolor = "#ffffff",
    node_annotation_borderpad = 2,
    node_annotation_borderwidth = node_marker_line_width,
    node_annotation_bordercolor = node_marker_line_color,
    node_annotation_arrowwidth = 1.6,
    node_annotation_arrowcolor = node_marker_line_color,
    pu = 1,
    n_gr = 64,
    ncontours = 32,
    point_marker_size = 16,
    point_marker_opacity = 0.88,
    point_marker_color = Nucleus.Color.HEGE,
    point_marker_line_width = 0.8,
    point_marker_line_color = "#000000",
    sc_ = nothing,
    sc_na = Dict{Int, String}(),
    layout = Dict{String, Any}(),
)

    data = Dict{String, Any}[]

    tr = Nucleus.Coordinate.triangulate(eachcol(di_x_no_x_co))

    for id_ in get_edges(tr)

        if any(==(-1), id_)

            continue

        end

        ve = collect(id_)

        push!(
            data,
            Dict(
                "legendgroup" => "Node",
                "showlegend" => false,
                "y" => view(di_x_no_x_co, 1, ve),
                "x" => view(di_x_no_x_co, 2, ve),
                "mode" => "lines",
                "line" => Dict("color" => triangulation_line_color),
                "hoverinfo" => "skip",
            ),
        )

    end

    push!(
        data,
        Dict(
            "legendgroup" => "Node",
            "name" => "Node ($(lastindex(no_)))",
            "y" => view(di_x_no_x_co, 1, :),
            "x" => view(di_x_no_x_co, 2, :),
            "text" => no_,
            "mode" => "markers",
            "marker" => Dict(
                "size" => node_marker_size,
                "opacity" => node_marker_opacity,
                "color" => node_marker_color,
                "line" =>
                    Dict("width" => node_marker_line_width, "color" => node_marker_line_color),
            ),
            "hoverinfo" => "text",
        ),
    )

    annotations = [
        Dict(
            "y" => co1,
            "x" => co2,
            "text" => "<b>$no</b>",
            "font" => Dict(
                "family" => "Gravitas One, monospace",
                "size" => node_annotation_font_size,
                "color" => node_annotation_font_color,
            ),
            "bgcolor" => node_annotation_bgcolor,
            "borderpad" => node_annotation_borderpad,
            "borderwidth" => node_annotation_borderwidth,
            "bordercolor" => node_annotation_bordercolor,
            "arrowwidth" => node_annotation_arrowwidth,
            "arrowcolor" => node_annotation_arrowcolor,
        ) for (no, (co1, co2)) in zip(no_, eachcol(di_x_no_x_co))
    ]

    range1 = Nucleus.Collection.get_minimum_maximum(di_x_no_x_co[1, :])

    range2 = Nucleus.Collection.get_minimum_maximum(di_x_no_x_co[2, :])

    di_x_po_x_co = Nucleus.Coordinate.pull(di_x_no_x_co, no_x_po_x_pu, pu)

    fa = 1.39

    ke_ar = (
        boundary = (range1 .* fa, range2 .* fa),
        npoints = (n_gr, n_gr),
        bandwidth = (
            Nucleus.Density.get_bandwidth(di_x_po_x_co[1, :]),
            Nucleus.Density.get_bandwidth(di_x_po_x_co[2, :]),
        ),
    )

    ro_, co_, de = Nucleus.Density.estimate((di_x_po_x_co[1, :], di_x_po_x_co[2, :]); ke_ar...)

    vp = Nucleus.Coordinate.wall(tr)

    is = [!Nucleus.Coordinate.is_in([ro, co], vp) for ro in ro_, co in co_]

    de[is] .= NaN

    push!(
        data,
        Dict(
            "type" => "contour",
            "legendgroup" => "Point",
            "showlegend" => false,
            "y" => ro_,
            "x" => co_,
            "z" => de,
            "transpose" => true,
            "ncontours" => ncontours,
            "contours" => Dict("coloring" => "none"),
            "hoverinfo" => "skip",
        ),
    )

    point = Dict(
        "legendgroup" => "Point",
        "name" => "Point ($(lastindex(po_)))",
        "y" => view(di_x_po_x_co, 1, :),
        "x" => view(di_x_po_x_co, 2, :),
        "text" => po_,
        "mode" => "markers",
        "marker" => Dict(
            "size" => point_marker_size,
            "opacity" => point_marker_opacity,
            "color" => point_marker_color,
            "line" => Dict("width" => point_marker_line_width, "color" => point_marker_line_color),
        ),
        "hoverinfo" => "text",
    )

    if isnothing(sc_)

        push!(data, point)

    elseif sc_ isa AbstractVector{<:AbstractFloat}

        push!(
            data,
            Nucleus.Dict.merge(
                point,
                Dict("marker" => Dict("color" => Nucleus.Color.color(sc_, Nucleus.Color.COBW))),
            ),
        )

    elseif sc_ isa AbstractVector{<:Integer}

        un_ = sort!(unique(sc_))

        gr_x_gr_x_un_x_pr = Array{Float64, 3}(undef, n_gr, n_gr, lastindex(un_))

        for (id, un) in enumerate(un_)

            id_ = findall(==(un), sc_)

            _ro_, _co_, de =
                Nucleus.Density.estimate((di_x_po_x_co[1, id_], di_x_po_x_co[2, id_]); ke_ar...)

            de[is] .= NaN

            gr_x_gr_x_un_x_pr[:, :, id] = de

        end

        # TODO: Benchmark iteration order.
        for id2 in 1:n_gr, id1 in 1:n_gr

            pr_ = view(gr_x_gr_x_un_x_pr, id1, id2, :)

            if all(isnan, pr_)

                continue

            end

            ma = argmax(pr_)

            for id in eachindex(pr_)

                if id != ma

                    pr_[id] = NaN

                end

            end

        end

        for (i3, (un, he)) in enumerate(zip(un_, Nucleus.Color.color(un_)))

            i2_ = findall(==(un), sc_)

            push!(
                data,
                Dict(
                    "type" => "heatmap",
                    "y" => ro_,
                    "x" => co_,
                    "z" => view(gr_x_gr_x_un_x_pr, :, :, i3),
                    "transpose" => true,
                    "colorscale" => Nucleus.Color.fractionate(
                        Nucleus.Color._make_color_scheme(["#ffffff", he]),
                    ),
                    "showscale" => false,
                    "hoverinfo" => "skip",
                ),
            )

            na = get(sc_na, un, un)

            push!(
                data,
                Nucleus.Dict.merge(
                    point,
                    Dict(
                        "legendgroup" => na,
                        "name" => "$na ($(lastindex(i2_)))",
                        "y" => view(di_x_po_x_co, 1, i2_),
                        "x" => view(di_x_po_x_co, 2, i2_),
                        "text" => view(po_, i2_),
                        "marker" => Dict("color" => he),
                    ),
                ),
            )

        end

    end

    axis = Dict("showgrid" => false, "zeroline" => false, "ticks" => "", "showticklabels" => false)

    Nucleus.Plot.plot(
        ht,
        data,
        Nucleus.Dict.merge(
            Dict(
                "height" => 800,
                "width" => 800,
                "title" => Dict(
                    "x" => 0.02,
                    "text" => "GPS Map",
                    "font" =>
                        Dict("family" => "Gravitas One", "size" => 32, "color" => "#000000"),
                ),
                "yaxis" => merge(axis, Dict("range" => range1, "autorange" => "reversed")),
                "xaxis" => merge(axis, Dict("range" => range2 .* 1.08)),
                "annotations" => annotations,
            ),
            layout,
        ),
        Dict("editable" => true),
    )

end

end
