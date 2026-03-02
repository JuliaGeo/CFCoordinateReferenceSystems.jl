const UNKNOWN_NAMES = ("undefined", "unknown")

"""
    convert(::Type{ProjJSON}, cf::CFProjection) -> ProjJSON

Convert a CF grid mapping to ProjJSON format.

This is the primary conversion method. The CF grid mapping must contain a
`grid_mapping_name` key specifying the projection type (e.g., "transverse_mercator",
"lambert_conformal_conic"), unless it contains a `crs_wkt` or `spatial_ref` key
with a WKT string.

# Supported grid mapping names

- `latitude_longitude` - Geographic CRS
- `transverse_mercator` - Transverse Mercator
- `albers_conical_equal_area` - Albers Equal Area
- `azimuthal_equidistant` - Azimuthal Equidistant
- `geostationary` - Geostationary Satellite
- `lambert_azimuthal_equal_area` - Lambert Azimuthal Equal Area
- `lambert_conformal_conic` - Lambert Conformal Conic (1SP or 2SP)
- `lambert_cylindrical_equal_area` - Lambert Cylindrical Equal Area
- `mercator` - Mercator (variant A or B)
- `oblique_mercator` - Oblique Mercator
- `orthographic` - Orthographic
- `polar_stereographic` - Polar Stereographic (variant A or B)
- `sinusoidal` - Sinusoidal
- `stereographic` - Stereographic
- `vertical_perspective` - Vertical Perspective
- `rotated_latitude_longitude` - Rotated Pole

# Examples

```julia
cf = CFProjection(
    "grid_mapping_name" => "transverse_mercator",
    "latitude_of_projection_origin" => 0.0,
    "longitude_of_central_meridian" => 15.0,
    "scale_factor_at_central_meridian" => 0.9996,
)
projjson = convert(ProjJSON, cf)
```

See also: [`convert(::Type{CFProjection}, gf)`](@ref)
"""
function Base.convert(::Type{GFT.ProjJSON}, cf::CFProjection)
    # Short circuit if we already have WKT etc
    if haskey(cf, "crs_wkt")
        return convert(GFT.ProjJSON, Proj.CRS(cf["crs_wkt"]))
    elseif haskey(cf, "spatial_ref")  # for previous supported WKT key
        return convert(GFT.ProjJSON, Proj.CRS(cf["spatial_ref"]))
    end

    if !haskey(cf.params, "grid_mapping_name")
        throw(ArgumentError("grid_mapping_name is required in `CFProjection` but was not found. Found keys: $(keys(cf.params))"))
    end
    grid_mapping_name = cf.params["grid_mapping_name"]
    datum = _horizontal_datum_from_params(cf)

    if grid_mapping_name == "latitude_longitude"
        geographic_crs_name = get(cf, "geographic_crs_name", nothing)
        if !isnothing(datum)
            geographic_crs = _geographic_crs(;
                name = isnothing(geographic_crs_name) ? "undefined" : geographic_crs_name,
                datum,
            )
            return GFT.ProjJSON(JSON3.write(geographic_crs))
        elseif isnothing(geographic_crs_name) || geographic_crs_name in UNKNOWN_NAMES
            geographic_crs = _geographic_crs()
            return GFT.ProjJSON(JSON3.write(geographic_crs))
        else
            # Named CRS like "WGS 84" - convert via Proj
            crs = Proj.CRS(geographic_crs_name)
            return convert(GFT.ProjJSON, crs)
        end
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
    return GFT.ProjJSON(JSON3.write(crs))
end
# convert to other GeoFormat or String via Proj.CRS
function Base.convert(T::Type{<:GFT.GeoFormat}, cf::CFProjection)
    projjson = convert(GFT.ProjJSON, cf)
    crs = Proj.CRS(projjson)
    return convert(T, crs)
end
Base.convert(::Type{String}, cf::CFProjection) =
    GFT.val(convert(GFT.ProjJSON, cf))

GFT.ProjJSON(cf::CFProjection) = convert(GFT.ProjJSON, cf)

"""
    convert(::Type{CFProjection}, gf::GeoFormat) -> CFProjection

Convert a CRS from another format (WKT, ProjJSON, ProjString, etc.) to CF grid mapping.

# Supported input types

Any `GeoFormatTypes.CoordinateReferenceSystemFormat` or `GeoFormatTypes.MixedFormat`,
including:
- `WellKnownText` / `WellKnownText2`
- `ProjJSON`
- `ProjString`
- `ESRIWellKnownText`

# Examples

```julia
using Proj, GeoFormatTypes

# From WKT
wkt = WellKnownText(Proj.CRS("EPSG:32615"))
cf = convert(CFProjection, wkt)

# From ProjString
ps = ProjString("+proj=tmerc +lat_0=0 +lon_0=15 +k=0.9996 +x_0=500000 +y_0=0")
cf = convert(CFProjection, ps)
```

See also: [`convert(::Type{ProjJSON}, cf::CFProjection)`](@ref)
"""
function Base.convert(T::Type{<:CFProjection}, gf::Union{GFT.CoordinateReferenceSystemFormat,GFT.MixedFormat})
    crs = Proj.CRS(gf)
    projjson_str = convert(String, GFT.ProjJSON(crs))
    jsondict = JSON3.read(projjson_str, Dict{String,Any})

    # Handle different CRS types
    crs_type = get(jsondict, "type", "")
    if crs_type == "ProjectedCRS"
        conversion = jsondict["conversion"]
        method_name = conversion["method"]["name"]
        if !haskey(PROJJSON_METHOD_NAME_MAP, method_name)
            throw(ArgumentError("Unsupported projection method: $method_name"))
        end
        to_cf_func = PROJJSON_METHOD_NAME_MAP[method_name]
        return T(to_cf_func(conversion))
    elseif crs_type == "GeographicCRS"
        # Geographic CRS - return latitude_longitude grid mapping
        return T(InnerDict("grid_mapping_name" => "latitude_longitude"))
    else
        throw(ArgumentError("Unsupported CRS type: $crs_type"))
    end
end