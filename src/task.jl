include("fetch.jl")

# Task 1
"""
    store()

Fetch and save all AQI bulletin reports since last update.
"""
function store()
    # fetch last report
    f = readdir("$dir/data")[end]
    y = parse(Int, f[1:4])
    m = parse(Int, f[6:7])
    d = parse(Int, f[9:10])
    # fetch new report(s)
    tₒ = (today() - Date(y, m, d)).value
    t  = Date(y, m, d)
    for _ ∈ 1:tₒ 
        t += Day(1)
        fetch_report(date=t)
    end
    return
end

# Task 2
"""
    index(cities::Vector{String}, startdate::Date, enddate::Date)

Plots Air Quality Index (AQI) for given `cities` from `startdate` to `enddate`.
"""
function index(; cities::Vector{String}, startdate::Date, enddate::Date)
    C  = cities
    tₛ = startdate
    tₑ = enddate
    # plot attributes
    figure = "$dir/plots/index.html"
    trace  = GenericTrace{Dict{Symbol, Any}}[]
    layout = Layout(
            autosize=false,
            height=450,
            width=800,
            paper_bgcolor="#cddee6",
            plot_bgcolor="#cddee6",
            font=
                attr(
                    family="Milo", 
                    size=13,
                    color="#001428"
                ), 
            title="<b>Air Quality Index (AQI):</b>",
            xaxis=
                attr(
                    showline=true,
                    linecolor="#001428",
                    title="<b>month</b>",
                    range=[1, 365],
                    tickvals=[31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],
                    ticktext=["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                ),
            yaxis=
                attr(
                    showline=true,
                    linecolor="#001428",
                    title="<b>index</b>",
                    range=[0, 500],
                    tickvals=0:50:500
                ),
            legend=attr(title=attr(text="<b>Year</b>")),
            shapes=[
                attr(
                    type="rect",
                    xref="paper",
                    yref="paper",
                    x0=-0.1,
                    y0=1.25,
                    x1=-0.07,
                    y1=1.1,
                    fillcolor="crimson",
                    line_color="crimson"
                )
            ],
            annotations=[
                attr(
                    text="<i>Source: <a href=https://cpcb.nic.in/>Central Pollution Control Board, Government of India</a></i>",
                    x=0, 
                    y=-0.18,    
                    xref="paper",
                    yref="paper",
                    showarrow=false,
                    font=attr(size=11)
                )
            ]
        )
    # for each city, fetch and plot data 
    yₛ = Year(tₛ).value
    yₑ = Year(tₑ).value
    α  = reverse([99 - (i-1) * floor(Int, 79/max(yₑ-yₛ,1)) for i ∈ eachindex(yₛ:yₑ)])
    β  = [[isequal(i,k) for i ∈ C for j ∈ yₛ:yₑ] for k ∈ C]
    tₒ = (tₑ - tₛ).value + 1
    for (i, c) ∈ enumerate(C)
        X = [Int[] for _ ∈ yₛ:yₑ]
        Y = [Float64[] for _ ∈ yₛ:yₑ]
        t = tₛ
        # for a given city, fetch data
        for _ ∈ 1:tₒ
            y = Year(t).value
            j = findfirst(isequal(y), yₛ:yₑ)
            z = fetch_data(city=c, date=t)
            if !isnothing(z.index) && !ismissing(z.index)
                push!(X[j], dayofyear(t))
                push!(Y[j], z.index)
            end
            t += Day(1)
        end
        # for a given city, plot data
        for j ∈ eachindex(Y)
            plt = scatter(
                    x=X[j], 
                    y=Y[j], 
                    line=attr(color="#001428$(α[j])"), 
                    line_shape="vhv", 
                    name=[y for y ∈ yₛ:yₑ][j], 
                    visible=β[i][j]
                )
            push!(trace, plt)
        end
    end
    # consolidate each city-specific plot
    plt = plot(trace, layout)
    relayout!(
        plt,
        updatemenus=[
            attr(
                buttons=[attr(args=[attr(visible=β[i])],label=c,method="update") for (i, c) ∈ enumerate(C)],
                type="dropdown",
                bordercolor="#00142850",
                pad = attr(t=0, r=0, b=10, l=10),
                showactive=false,
                x=0.51,
                xanchor="right",
                y=1.17,
                yanchor="top"
            )
        ]
    )
    # save plot
    savefig(plt, figure)
    run(`git -C $dir add $figure`)
    run(`git -C $dir commit -m "update index.html"`)
    run(`git -C $dir push origin main`)
    return plt
end

# Task 3
"""
    level(cities::Vector{String}, startdate::Date, enddate::Date)

Plots Air Quality Level (AQL) for given `cities` from `startdate` to `enddate`.
"""
function level(; cities::Vector{String}, startdate::Date, enddate::Date)
    C  = cities
    tₛ = startdate
    tₑ = enddate
    # plot attributes
    figure = "$dir/plots/level.html"
    trace  = GenericTrace{Dict{Symbol, Any}}[]
    layout = Layout(
        barmode="stack",
        autosize=false,
        height=600,
        width=450,
        paper_bgcolor="#cddee6",
        plot_bgcolor="#cddee6",
        font=
            attr(
                family="Milo", 
                size=13,
                color="#001428"
            ), 
        title="<b>Air Quality Level (AQL):</b>",
        xaxis=
            attr(
                showline=true,
                linecolor="#001428",
                title="<b>year</b>",
                tickvals=(Year(tₛ).value:Year(tₑ).value).-2000,
            ),
        yaxis=
            attr(
                showline=true,
                linecolor="#001428",
                title="<b>percentage</b>",
                range=[0, 100],
                tickvals=0:10:100,
            ),
        legend=attr(title=attr(text="<b>Level</b>")),
        shapes=[
            attr(
                type="rect",
                xref="paper",
                yref="paper",
                x0=-0.3,
                y0=1.25,
                x1=-0.175,
                y1=1.075,
                fillcolor="crimson",
                line_color="crimson"
            )
        ],
        annotations=[
            attr(
                text="<i>Source: <a href=https://cpcb.nic.in/>CPCB, GoI</a></i>",
                x=0, 
                y=-0.123,    
                xref="paper",
                yref="paper",
                showarrow=false,
                font=attr(size=11)
            )
        ]
    )
    # for each city, fetch and plot data
    L  = ["Good", "Satisfactory", "Moderate", "Poor", "Very Poor", "Severe"]
    K  = ["#8eab5a", "#daf7a6", "#ffc300", "#ff5733", "#c70039", "#900c3f"]
    yₛ = Year(tₛ).value
    yₑ = Year(tₑ).value
    β  = [[isequal(i,k) for i ∈ C for j ∈ L] for k ∈ C]
    tₒ = (tₑ - tₛ).value + 1
    for (i, c) ∈ enumerate(C)
        X = [y for y ∈ yₛ:yₑ].-2000
        Y = [zeros(eachindex(X)) for _ ∈ eachindex(L)]
        t = tₛ
        # for a given city, fetch data
        for _ ∈ 1:tₒ
            y = Year(t).value
            j = findfirst(isequal(y), yₛ:yₑ)
            z = fetch_data(city=c, date=t)
            if !isnothing(z.level) && !ismissing(z.level)
                k = findfirst(isequal(z.level), L)
                Y[k][j] += 1
            end
            t += Day(1)
        end
        for j ∈ eachindex(X)
            s = 0.
            for k ∈ eachindex(Y) s += Y[k][j] end
            for k ∈ eachindex(Y) Y[k][j] *= 100/s end
        end
        for k ∈ eachindex(Y)
            plt = bar(
                    x=X, 
                    y=Y[k], 
                    name=L[k],
                    marker=attr(color=K[k]),
                    visible=β[i][k]
                )
            push!(trace, plt)
        end
    end   
    # consolidate each city-specific plot
    plt = plot(trace, layout)
    relayout!(
        plt,
        updatemenus=[
            attr(
                buttons=[attr(args=[attr(visible=β[i])],label=c,method="update") for (i, c) ∈ enumerate(C)],
                type="dropdown",
                bordercolor="#00142850",
                pad = attr(t=0, r=0, b=10, l=10),
                showactive=false,
                x=1.19,
                xanchor="right",
                y=1.12,
                yanchor="top"
            )
        ]
    )
    # save plot
    savefig(plt, "$dir/plots/level.html")
    run(`git -C $dir add $figure`)
    run(`git -C $dir commit -m "update level.html"`)
    run(`git -C $dir push origin main`)
    return plt
end

# Task 4
"""
    pollutant(cities::Vector{String}, startdate::Date, enddate::Date)

Plots Air Quality Level (AQL) for given `cities` from `startdate` to `enddate`.
"""
function pollutant(; cities::Vector{String}, startdate::Date, enddate::Date)
    C  = cities
    tₛ = startdate
    tₑ = enddate
    # plot attributes
    figure = "$dir/plots/pollutant.html"
    trace  = GenericTrace{Dict{Symbol, Any}}[]
    layout = Layout(
        barmode="stack",
        autosize=false,
        height=600,
        width=450,
        paper_bgcolor="#cddee6",
        plot_bgcolor="#cddee6",
        font=
            attr(
                family="Milo", 
                size=13,
                color="#001428"
            ), 
        title="<b>Prominent pollutant:</b>",
        xaxis=
            attr(
                showline=true,
                linecolor="#001428",
                title="<b>year</b>",
                tickvals=tickvals=(Year(tₛ).value:Year(tₑ).value).-2000,
            ),
        yaxis=
            attr(
                showline=true,
                linecolor="#001428",
                title="<b>percentage</b>",
                range=[0, 100],
                tickvals=0:10:100,
            ),
        legend=attr(title=attr(text="<b>Pollutant</b>")),
        shapes=[
            attr(
                type="rect",
                xref="paper",
                yref="paper",
                x0=-0.3,
                y0=1.25,
                x1=-0.16,
                y1=1.075,
                fillcolor="crimson",
                line_color="crimson"
            )
        ],
        annotations=[
            attr(
                text="<i>Source: <a href=https://cpcb.nic.in/>CPCB, GoI</a></i>",
                x=0, 
                y=-0.123,    
                xref="paper",
                yref="paper",
                showarrow=false,
                font=attr(size=11)
            )
        ]
    )
    # for each city, fetch and plot data
    L  = ["O3", "CO", "NO2", "SO2", "PM10", "PM2.5"]
    L′ = ["O₃", "CO", "NO₂", "SO₂", "PM₁₀", "PM₂.₅"]
    K  = ["#79b0c1", "#ffd580", "#ff7043", "#a76171", "#564138", "#6b7a8f"]
    yₛ = Year(tₛ).value
    yₑ = Year(tₑ).value
    β  = [[isequal(i,k) for i ∈ C for j ∈ L] for k ∈ C]
    tₒ = (tₑ - tₛ).value + 1
    for (i, c) ∈ enumerate(C)
        X = [y for y ∈ yₛ:yₑ].-2000
        Y = [zeros(eachindex(X)) for _ ∈ eachindex(L)]
        t = tₛ
        # for a given city, fetch data
        for _ ∈ 1:tₒ
            y = Year(t).value
            j = findfirst(isequal(y), yₛ:yₑ)
            z = fetch_data(city=c, date=t)
            if !isnothing(z.pollutant) && !ismissing(z.pollutant)
                for p ∈ split(z.pollutant, ", ")
                    k = findfirst(isequal(p), L)
                    Y[k][j] += 1
                end
            end
            t += Day(1)
        end
        for j ∈ eachindex(X)
            s = 0.
            for k ∈ eachindex(Y) s += Y[k][j] end
            for k ∈ eachindex(Y) Y[k][j] *= 100/s end
        end
        for k ∈ eachindex(Y)
            plt = bar(
                    x=X, 
                    y=Y[k], 
                    name=L′[k],
                    marker=attr(color=K[k]),
                    visible=β[i][k]
                )
            push!(trace, plt)
        end
    end   
    # consolidate each city-specific plot
    plt = plot(trace, layout)
    relayout!(
        plt,
        updatemenus=[
            attr(
                buttons=[attr(args=[attr(visible=β[i])],label=c,method="update") for (i, c) ∈ enumerate(C)],
                type="dropdown",
                bordercolor="#00142850",
                pad = attr(t=0, r=0, b=10, l=10),
                showactive=false,
                x=0.97,
                xanchor="right",
                y=1.12,
                yanchor="top"
            )
        ]
    )
    # save plot
    savefig(plt, "$dir/plots/pollutant.html")
    run(`git -C $dir add $figure`)
    run(`git -C $dir commit -m "update pollutant.html"`)
    run(`git -C $dir push origin main`)
    return plt
end

# NOTE: The following tasks have been automated to be performed at 5pm (IST) using Task Scheduler on a Windows machine
let 
    C  = [
        "Chennai",
        "Agartala",
        "Amaravati",
        "Bengaluru",
        "Bhopal",
        "Chandigarh",
        "Delhi",
        "Gandhinagar",
        "Hyderabad",
        "Jaipur",
        "Kohima",
        "Kolkata",
        "Lucknow",
        "Mumbai",
        "Patna",
        "Shillong",
        "Thiruvananthapuram",
        #= 
        #1. Data partly available
        "Bhubaneswar",
        "Dehradun",
        "Gangtok",
        "Imphal",
        "Srinagar",
        =#
        #=
        #2. Data not available
        "Daman",
        "Dispur",
        "Itanagar",
        "Kavaratti",
        "Leh",
        "Panaji",
        "Pondicherry",
        "Port Blair",
        "Raipur",
        "Ranchi",
        "Shimla",
        =#
    ]
    
    println("Task 1: storing new reports since last update")
    store()
    sleep(5)

    println("Task 2: developing a rolling 3-year multi-city air quality index plot")
    tₛ = Date(Year(today())-Year(2))
    tₑ = today()
    index(cities=C, startdate=tₛ, enddate=tₑ)
    sleep(5)

    println("Task 3: developing a multi-city air quality level plot")
    tₛ = Date(2016)
    tₑ = today()
    level(cities=C, startdate=tₛ, enddate=tₑ)
    sleep(5)

    println("Task 4: developing a multi-city prominent pollutant plot")
    tₛ = Date(2016)
    tₑ = today()
    pollutant(cities=C, startdate=tₛ, enddate=tₑ)
    sleep(5)
end
# TODO:
    #1. Add capital/ut cities once data is available
    #2. update task 3 and 4 to rolling 10-year on 2026-01-01
    