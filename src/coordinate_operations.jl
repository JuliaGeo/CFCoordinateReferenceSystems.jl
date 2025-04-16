"""
This module defines coordinate operations for building CRS transformations.
"""
module CoordinateOperations

include("parameters.jl")

using GeoFormatTypes

import GeoFormatTypes as GFT, JSON3

export ProjJSONDict,
    _albers_equal_area__to_projjson_dict,
    _azimuthal_equidistant__to_projjson_dict,
    _geostationary_satellite__to_projjson_dict,
    _lambert_azimuthal_equal_area__to_projjson_dict,
    _lambert_conformal_conic_2sp__to_projjson_dict,
    _lambert_conformal_conic_1sp__to_projjson_dict,
    _lambert_cylindrical_equal_area__to_projjson_dict,
    _lambert_cylindrical_equal_area_scale__to_projjson_dict,
    _mercator_a__to_projjson_dict,
    _mercator_b__to_projjson_dict,
    _hotine_oblique_mercator_b__to_projjson_dict,
    _orthographic__to_projjson_dict,
    _polar_stereographic_a__to_projjson_dict,
    _polar_stereographic_b__to_projjson_dict,
    _sinusoidal__to_projjson_dict,
    _stereographic__to_projjson_dict,
    _utm__to_projjson_dict,
    _transverse_mercator__to_projjson_dict,
    _vertical_perspective__to_projjson_dict,
    _web_mercator__to_projjson_dict

struct ProjJSONDict{D<:AbstractDict{<:String,<:Any}} <: GFT.CoordinateReferenceSystemFormat
    params::D
end

# We write the operation Dict to JSON to convert it to ProjJSON
GFT.ProjJSON(operation::ProjJSONDict) = 
    GFT.ProjJSON(JSON3.write(operation.params))

# We can convert directly to ProjJSON here
Base.convert(::Type{<:GFT.ProjJSON}, operation::ProjJSONDict) = 
    GFT.ProjJSON(operation)
# Or to String via ProjJSON
Base.convert(::Type{<:String}, operation::ProjJSONDict) = 
    convert(String, convert(GFT.ProjJSON, operation))
# We need external help to convert to other formats, 
# so we convert to ProjJSON first and call convert again
Base.convert(T::Type{<:GFT.GeoFormat}, operation::ProjJSONDict) = 
    convert(T, convert(GFT.ProjJSON, operation))

function Base.show(io::IO, ::MIME"text/plain", operation::T) where T <: ProjJSONDict
    println(io, "ProjJSON Coordinate Operation $(typeof(operation)):")
    for (key, value) in operation.params
        println(io, "$key: $value")
    end
end
function Base.show(io::IO, operation::T) where T <: ProjJSONDict
    println(io, "ProjJSON Coordinate Operation $(typeof(operation)):")
end

# Begin conversion definitions

function _albers_equal_area__to_projjson_dict(
    latitude_first_parallel::Real,
    latitude_second_parallel::Real;
    latitude_false_origin::Real = 0.0,
    longitude_false_origin::Real = 0.0,
    easting_false_origin::Real = 0.0,
    northing_false_origin::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Albers Equal Area",
            "id" => Dict("authority" => "EPSG", "code" => 9822)
        ),
        "parameters" => [
            _latitude_false_origin(latitude_false_origin),
            _longitude_false_origin(longitude_false_origin),
            _latitude_1st_standard_parallel(latitude_first_parallel),
            _latitude_2nd_standard_parallel(latitude_second_parallel),
            # TODO: why do these have Dict units? above its just "metre"
            Dict(
                "name" => "Easting at false origin",
                "value" => easting_false_origin,
                "unit" => Dict(
                    "type" => "LinearUnit",
                    "name" => "Metre",
                    "conversion_factor" => 1
                ),
                "id" => Dict("authority" => "EPSG", "code" => 8826)
            ),
            Dict(
                "name" => "Northing at false origin",
                "value" => northing_false_origin,
                "unit" => Dict(
                    "type" => "LinearUnit",
                    "name" => "Metre",
                    "conversion_factor" => 1
                ),
                "id" => Dict("authority" => "EPSG", "code" => 8827)
            ),
            _easting_false_origin(easting_false_origin),
            _northing_false_origin(northing_false_origin),
        ]
    )
    return ProjJSONDict(params)
end

function _azimuthal_equidistant__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Modified Azimuthal Equidistant",
            "id" => Dict("authority" => "EPSG", "code" => 9832)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _geostationary_satellite__to_projjson_dict(
    sweep_angle_axis::String,
    satellite_height::Real;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    sweep_angle_axis = strip(uppercase(sweep_angle_axis))
    if !(sweep_angle_axis in ("X", "Y"))
        throw(ArgumentError("sweep_angle_axis only supports X and Y"))
    end

    if latitude_natural_origin != 0
        @warn "The latitude of natural origin (lat_0) is not used within PROJ. It is only supported for exporting to the WKT or PROJ JSON formats."
    end

    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict("name" => "Geostationary Satellite (Sweep $sweep_angle_axis)"),
        "parameters" => [
            Dict(
                "name" => "Satellite height",
                "value" => satellite_height,
                "unit" => "metre"
            ),
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _lambert_azimuthal_equal_area__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Lambert Azimuthal Equal Area",
            "id" => Dict("authority" => "EPSG", "code" => 9820)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _lambert_conformal_conic_2sp__to_projjson_dict(
    latitude_first_parallel::Real,
    latitude_second_parallel::Real;
    latitude_false_origin::Real = 0.0,
    longitude_false_origin::Real = 0.0,
    easting_false_origin::Real = 0.0,
    northing_false_origin::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Lambert Conic Conformal (2SP)",
            "id" => Dict("authority" => "EPSG", "code" => 9802)
        ),
        "parameters" => [
            _latitude_1st_standard_parallel(latitude_first_parallel),
            _latitude_2nd_standard_parallel(latitude_second_parallel),
            _latitude_false_origin(latitude_false_origin),
            _longitude_false_origin(longitude_false_origin),
            _easting_false_origin(easting_false_origin),
            _northing_false_origin(northing_false_origin),
        ]
    )
    return ProjJSONDict(params)
end

function _lambert_convermal_conic_1sp__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Lambert Conic Conformal (1SP)",
            "id" => Dict("authority" => "EPSG", "code" => 9801)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _lambert_cylindrical_equal_area__to_projjson_dict(;
    latitude_first_parallel::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Lambert Cylindrical Equal Area",
            "id" => Dict("authority" => "EPSG", "code" => 9835)
        ),
        "parameters" => [
            _latitude_1st_standard_parallel(latitude_first_parallel),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _lambert_cylindrical_equal_area_scale__to_projjson_dict(;
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Lambert Cylindrical Equal Area",
            "id" => Dict("authority" => "EPSG", "code" => 9835)
        ),
        "parameters" => [
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
            _scale_factor_natural_origin(scale_factor_natural_origin),
        ]
    )
    return ProjJSONDict(params)
end

function _mercator_a__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    if latitude_natural_origin != 0
        throw(ArgumentError("This conversion is defined for only latitude_natural_origin = 0."))
    end

    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Mercator (variant A)",
            "id" => Dict("authority" => "EPSG", "code" => 9804)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _mercator_b__to_projjson_dict(;
    latitude_first_parallel::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Mercator (variant B)",
            "id" => Dict("authority" => "EPSG", "code" => 9805)
        ),
        "parameters" => [
            _latitude_1st_standard_parallel(latitude_first_parallel),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _hotine_oblique_mercator_b__to_projjson_dict(
    latitude_projection_centre::Real,
    longitude_projection_centre::Real,
    angle_from_rectified_to_skew_grid::Real;
    easting_projection_centre::Real = 0.0,
    northing_projection_centre::Real = 0.0,
    azimuth_projection_centre::Union{Real,Nothing} = nothing,
    scale_factor_projection_centre::Union{Real,Nothing} = nothing,
    azimuth_initial_line::Union{Real,Nothing} = nothing,
    scale_factor_on_initial_line::Union{Real,Nothing} = nothing,
)
    if scale_factor_on_initial_line !== nothing
        if scale_factor_projection_centre !== nothing
            throw(ArgumentError("scale_factor_projection_centre and scale_factor_on_initial_line cannot be provided together."))
        end
        @warn "scale_factor_on_initial_line is deprecated. Use scale_factor_projection_centre instead."
        scale_factor_projection_centre = scale_factor_on_initial_line
    elseif scale_factor_projection_centre === nothing
        scale_factor_projection_centre = 1.0
    end

    if azimuth_projection_centre === nothing && azimuth_initial_line === nothing
        throw(ArgumentError("azimuth_projection_centre or azimuth_initial_line must be provided."))
    end
    if azimuth_initial_line !== nothing
        if azimuth_projection_centre !== nothing
            throw(ArgumentError("azimuth_projection_centre and azimuth_initial_line cannot be provided together."))
        end
        @warn "azimuth_initial_line is deprecated. Use azimuth_projection_centre instead."
        azimuth_projection_centre = azimuth_initial_line
    end

    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Hotine Oblique Mercator (variant B)",
            "id" => Dict("authority" => "EPSG", "code" => 9815)
        ),
        "parameters" => [
            _latitude_projection_centre(latitude_projection_centre),
            _longitude_projection_centre(longitude_projection_centre),
            _azimuth_projection_centre(azimuth_projection_centre),
            _angle_from_rectified_to_skew_grid(angle_from_rectified_to_skew_grid),
            _scale_factor_projection_centre(scale_factor_projection_centre),
            _easting_projection_centre(easting_projection_centre),
            _northing_projection_centre(northing_projection_centre),
        ]
    )
    return ProjJSONDict(params)
end

function _orthographic__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Orthographic",
            "id" => Dict("authority" => "EPSG", "code" => 9840)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _polar_stereographic_a__to_projjson_dict(
    latitude_natural_origin::Real;
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    if !(latitude_natural_origin in (90, -90))
        throw(ArgumentError("latitude_natural_origin must be either +90 or -90"))
    end

    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Polar Stereographic (variant A)",
            "id" => Dict("authority" => "EPSG", "code" => 9810)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _polar_stereographic_b__to_projjson_dict(;
    latitude_standard_parallel::Real = 0.0,
    longitude_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Polar Stereographic (variant B)",
            "id" => Dict("authority" => "EPSG", "code" => 9829)
        ),
        "parameters" => [
            _latitude_standard_paralel(latitude_standard_parallel),
            _longitude_origin(longitude_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _sinosoidal__to_projjson_dict(;
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict("name" => "Sinusoidal"),
        "parameters" => [
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _stereographic__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict("name" => "Stereographic"),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _utm__to_projjson_dict(zone::Integer, hemisphere::String = "N")
    if !(1 <= zone <= 60)
        throw(ArgumentError("zone must be between 1 and 60"))
    end
    hemisphere = uppercase(hemisphere)
    if !(hemisphere in ("N", "S"))
        throw(ArgumentError("hemisphere must be either N or S"))
    end

    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "UTM zone $(zone)$(hemisphere)",
        "method" => Dict(
            "name" => "Transverse Mercator",
            "id" => Dict("authority" => "EPSG", "code" => 9807)
        ),
        "parameters" => [
            _latitude_natural_origin(0.0),
            _longitude_natural_origin((zone * 6 - 183)),
            _scale_factor_natural_origin(0.9996),
            _false_easting(500000.0),
            _false_northing(hemisphere == "N" ? 0.0 : 10000000.0),
        ]
    )
    return ProjJSONDict(params)
end

function _transverse_mercator__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Transverse Mercator",
            "id" => Dict("authority" => "EPSG", "code" => 9807)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _vertical_perspective__to_projjson_dict(
    viewpoint_height::Real;
    latitude_topocentric_origin::Real = 0.0,
    longitude_topocentric_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Vertical Perspective",
            "id" => Dict("authority" => "EPSG", "code" => 9838)
        ),
        "parameters" => [
            _viewpoint_height(viewpoint_height),
            _latitude_topocentric_origin(latitude_topocentric_origin),
            _longitude_topocentric_origin(longitude_topocentric_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

function _web_mercator__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    if latitude_natural_origin != 0
        throw(ArgumentError("This conversion is defined for only latitude_natural_origin = 0."))
    end

    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Popular Visualisation Pseudo Mercator",
            "id" => Dict("authority" => "EPSG", "code" => 1024)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return ProjJSONDict(params)
end

#=

function CassiniSoldnerConversion(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Cassini-Soldner",
            "id" => Dict("authority" => "EPSG", "code" => 9806)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return CassiniSoldnerConversion(params)
end

function KrovakConversion(;
    latitude_projection_centre::Real = 0.0,
    longitude_origin::Real = 0.0,
    colatitude_cone_axis::Real = 0.0,
    latitude_pseudo_standard_parallel::Real = 0.0,
    scale_factor_pseudo_standard_parallel::Real = 1.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    params = Dict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "Conversion",
        "name" => "unknown",
        "method" => Dict(
            "name" => "Krovak",
            "id" => Dict("authority" => "EPSG", "code" => 9819)
        ),
        "parameters" => [
            _latitude_projection_centre(latitude_projection_centre),
            _longitude_oriding(longitude_oriding),
            _colatitude_cone_axis(colatitude_cone_axis), 
            _latitude_pseudo_standard_parallel(latitude_pseudo_standard_parallel),
            _scale_factor_pseudo_standard_parallel(scale_factor_pseudo_standard_parallel),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
    return KrovakConversion(params)
end
=#
end # module
