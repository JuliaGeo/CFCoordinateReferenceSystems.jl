const UNKNOWN_NAMES = ("undefined", "unknown")

# convert is a multi-step process. 
function Base.convert(::Type{GFT.ProjJSON}, cf::CFProjection)
    # Short circuit if we already have WKT etc
    if haskey(cf, "crs_wkt")
        return convert(GFT.ProjJSON, Proj.CRS(cf["crs_wkt"]))
    elseif haskey(cf, "spatial_ref")  # for previous supported WKT key
        return convert(GFT.ProjJSON, Proj.CRS(cf["spatial_ref"]))
    end

    @boundscheck if !haskey(cf.params, "grid_mapping_name")
        throw(ArgumentError("grid_mapping_name is required in `CFProjection` but was not found. \n\n\n Found keys $(keys(cf.params))."))
    end
    grid_mapping_name = cf.params["grid_mapping_name"]
    datum = _horizontal_datum_from_params(cf)

    if grid_mapping_name == "latitude_longitude"
        geographic_crs_name = get(cf, "geographic_crs_name", nothing)
        geographic_crs = if !isnothing(datum)
            geographic_crs = _geographic_crs(;
                name = isnothing(geographic_crs_name) ? "undefined" : geographic_crs_name,
                datum,
            )
        elseif isnothing(geographic_crs_name) || geographic_crs_name in UNKNOWN_NAMES
            geographic_crs = _geographic_crs()
        else
            Proj.CRS(geographic_crs_name)
        end
        return GFT.ProjJSON(JSON3.write(parent(geographic_crs)))
    end

    grid_mapping_function = if haskey(GRID_MAPPING_NAME_MAP, grid_mapping_name)
        GRID_MAPPING_NAME_MAP[grid_mapping_name]
    elseif haskey(GEOGRAPHIC_GRID_MAPPING_NAME_MAP, grid_mapping_name)
        GEOGRAPHIC_GRID_MAPPING_NAME_MAP[grid_mapping_name]
    else
        throw(ArgumentError("Unsupported grid mapping name: $(grid_mapping_name)"))
    end
    crs = grid_mapping_function(cf) 
    if !isnothing(datum) 
        crs["datum"] = datum
    end
    return GFT.ProjJSON(JSON3.write(parent(crs)))
end
# convert to other GeoFormat or String via ProjJSON
Base.convert(T::Type{<:GFT.GeoFormat}, cf::CFProjection) =
    convert(T, convert(GFT.ProjJSON, cf))
Base.convert(::Type{String}, cf::CFProjection) =
    convert(String, convert(GFT.ProjJSON, cf))

GFT.ProjJSON(cf::CFProjection) = convert(GFT.ProjJSON, cf)
GFT.ProjJSON(pjd::ProjJSONDict) = GFT.ProjJSON(JSON3.write(parent(pjd)))