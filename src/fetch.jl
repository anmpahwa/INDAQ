using CSV
using Dates
using DataFrames
using Git
using PlotlyJS
using PyCall
using TimeZones

dir = dirname(@__DIR__)

"""
    fetch_report(; date::Date)

Returns AQI bulletin report as `date.csv` file (in the data folder) for the given `date`.
`date` should follow the "yyyy-mm-dd" format.
"""
function fetch_report(; date::Date)
    println(date)
    # fetch table
    tabula = pyimport("tabula")
    url = "https://cpcb.nic.in//upload/Downloads/AQI_Bulletin_$(replace(string(date), "-" => "")).pdf"
    csv = "$dir/data/$date.csv"
    try df = tabula.convert_into(url, csv, lattice=true, output_format="csv", pages="all")
    catch
        if date > today(tz"UTC+0530")
            error("ArgumentError: AQI bulletin report for $date will be made available after 5pm $date IST (UTC+05:30).")
        elseif date < today(tz"UTC+0530")
            error("LoadError: Visit https://cpcb.nic.in for more details")
        elseif DateTime(now(tz"UTC+0530")) < DateTime(today(tz"UTC+0530")) + Hour(17)
            error("ArgumentError: AQI bulletin report for $date will be made available after 5pm $date IST (UTC+05:30).")
        else 
            error("LoadError: Visit https://cpcb.nic.in for more details")
        end
    end
    # scrub and save
    df = CSV.read(csv, DataFrame, silencewarnings=true)
    ## columns
    try select!(df, Not(Symbol("S.No"))) catch end
    headers = [:city, :level, :index, :pollutant, :stations]
    for (n, name) ∈ enumerate(names(df)) rename!(df, Symbol(name) => headers[n]) end
    ## rows
    deleteat!(df, findall(ismissing, df[:,3]))
    deleteat!(df, findall(isone, isnothing.(tryparse.(Int, string.(df[:,3])))))
    ## cells
    for r ∈ 1:nrow(df)
        df[r,1] = replace(df[r,1], "\r" => " ")
        df[r,1] = replace(df[r,1], "_" => " ")
        df[r,1] = titlecase(df[r,1])
        plt = ""
        if occursin("3", df[r,4]) plt *= "O3, " end
        if occursin("Z", df[r,4]) plt *= "O3, " end
        if occursin("CO", df[r,4]) plt *= "CO, " end
        if occursin("NO", df[r,4]) plt *= "NO2, " end
        if occursin("SO", df[r,4]) plt *= "SO2, " end
        if occursin("10", df[r,4]) plt *= "PM10, " end
        if occursin("2.5", df[r,4]) plt *= "PM2.5, " end
        df[r,4] = rstrip(plt, [',', ' '])
        try df[r,5] = replace(df[r,5], " #" => "") catch end
        try df[r,5] = split(df[r,5], "/")[begin] catch end
    end
    CSV.write(csv, df)
    run(`git -C $dir add $csv`)
    run(`git -C $dir commit -m "add $date AQI bulletin report"`)
    run(`git -C $dir push origin main`)
    # return
    return
end

"""
    fetch_data(; city::String, date::Date)

Returns air quality data from AQI bulletin report for the given `city` from the given `date`.
This data pertains to air quality level, air quality index, prominent pollutant, and number of active stations.
`city` should follow the title-case format and `date` should follow the "yyyy-mm-dd" format.
"""
function fetch_data(; city::String, date::Date)
    fold = readdir("$dir/data")
    file = "$date.csv"
    if file ∉ fold fetch_report(date=date) end
    csv = "$dir/data/$date.csv"
    df  = CSV.read(csv, DataFrame)
    r   = findfirst(isequal.(city), df[:,:city])
    cty = city
    lev = isnothing(r) ? nothing : df[r,:level]
    inx = isnothing(r) ? nothing : df[r,:index]
    plt = isnothing(r) ? nothing : df[r,:pollutant]
    stn = isnothing(r) ? nothing : df[r,:stations]
    res = (city=cty, level=lev, index=inx, pollutant=plt, stations=stn)
    return res
end
