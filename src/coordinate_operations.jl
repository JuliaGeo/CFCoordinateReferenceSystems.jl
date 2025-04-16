"""
This module defines coordinate operations for building CRS transformations.
"""
module CoordinateOperations

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
            Dict(
                "name" => "Latitude of false origin",
                "value" => latitude_false_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8821)
            ),
            Dict(
                "name" => "Longitude of false origin",
                "value" => longitude_false_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8822)
            ),
            Dict(
                "name" => "Latitude of 1st standard parallel",
                "value" => latitude_first_parallel,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8823)
            ),
            Dict(
                "name" => "Latitude of 2nd standard parallel",
                "value" => latitude_second_parallel,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8824)
            ),
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
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of 1st standard parallel",
                "value" => latitude_first_parallel,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8823)
            ),
            Dict(
                "name" => "Latitude of 2nd standard parallel",
                "value" => latitude_second_parallel,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8824)
            ),
            Dict(
                "name" => "Latitude of false origin",
                "value" => latitude_false_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8821)
            ),
            Dict(
                "name" => "Longitude of false origin",
                "value" => longitude_false_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8822)
            ),
            Dict(
                "name" => "Easting at false origin",
                "value" => easting_false_origin,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8826)
            ),
            Dict(
                "name" => "Northing at false origin",
                "value" => northing_false_origin,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8827)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "Scale factor at natural origin",
                "value" => scale_factor_natural_origin,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8805)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of 1st standard parallel",
                "value" => latitude_first_parallel,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8823)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            ),
            Dict(
                "name" => "Scale factor at natural origin",
                "value" => scale_factor_natural_origin,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8805)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "Scale factor at natural origin",
                "value" => scale_factor_natural_origin,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8805)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of 1st standard parallel",
                "value" => latitude_first_parallel,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8823)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of projection centre",
                "value" => latitude_projection_centre,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8811)
            ),
            Dict(
                "name" => "Longitude of projection centre",
                "value" => longitude_projection_centre,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8812)
            ),
            Dict(
                "name" => "Azimuth at projection centre",
                "value" => azimuth_projection_centre,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8813)
            ),
            Dict(
                "name" => "Angle from Rectified to Skew Grid",
                "value" => angle_from_rectified_to_skew_grid,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8814)
            ),
            Dict(
                "name" => "Scale factor at projection centre",
                "value" => scale_factor_projection_centre,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8815)
            ),
            Dict(
                "name" => "Easting at projection centre",
                "value" => easting_projection_centre,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8816)
            ),
            Dict(
                "name" => "Northing at projection centre",
                "value" => northing_projection_centre,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8817)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "Scale factor at natural origin",
                "value" => scale_factor_natural_origin,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8805)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of standard parallel",
                "value" => latitude_standard_parallel,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8832)
            ),
            Dict(
                "name" => "Longitude of origin",
                "value" => longitude_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8833)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "Scale factor at natural origin",
                "value" => scale_factor_natural_origin,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8805)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => 0.0,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => (zone * 6 - 183),
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "Scale factor at natural origin",
                "value" => 0.9996,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8805)
            ),
            Dict(
                "name" => "False easting",
                "value" => 500000.0,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => hemisphere == "N" ? 0.0 : 10000000.0,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "Scale factor at natural origin",
                "value" => scale_factor_natural_origin,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8805)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Viewpoint height",
                "value" => viewpoint_height,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8840)
            ),
            Dict(
                "name" => "Latitude of topocentric origin",
                "value" => latitude_topocentric_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8834)
            ),
            Dict(
                "name" => "Longitude of topocentric origin",
                "value" => longitude_topocentric_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8835)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
        ]
    )
    return ProjJSONDict(params)
end

#=
"""
    CassiniSoldnerConversion

Cassini-Soldner Conversion coordinate operation.

# Fields
- `params::AbstractDict`: Dictionary of parameters for the conversion
"""
struct CassiniSoldnerConversion <: ProjJSONCoordinateOperation
    params::AbstractDict
end

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
            Dict(
                "name" => "Latitude of natural origin",
                "value" => latitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8801)
            ),
            Dict(
                "name" => "Longitude of natural origin",
                "value" => longitude_natural_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8802)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
        ]
    )
    return CassiniSoldnerConversion(params)
end

"""
    KrovakConversion

Krovak Conversion coordinate operation.

# Fields
- `params::AbstractDict`: Dictionary of parameters for the conversion
"""
struct KrovakConversion <: ProjJSONCoordinateOperation
    params::AbstractDict
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
            Dict(
                "name" => "Latitude of projection centre",
                "value" => latitude_projection_centre,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8811)
            ),
            Dict(
                "name" => "Longitude of origin",
                "value" => longitude_origin,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8833)
            ),
            Dict(
                "name" => "Co-latitude of cone axis",
                "value" => colatitude_cone_axis,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 1036)
            ),
            Dict(
                "name" => "Latitude of pseudo standard parallel",
                "value" => latitude_pseudo_standard_parallel,
                "unit" => "degree",
                "id" => Dict("authority" => "EPSG", "code" => 8818)
            ),
            Dict(
                "name" => "Scale factor on pseudo standard parallel",
                "value" => scale_factor_pseudo_standard_parallel,
                "unit" => "unity",
                "id" => Dict("authority" => "EPSG", "code" => 8819)
            ),
            Dict(
                "name" => "False easting",
                "value" => false_easting,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8806)
            ),
            Dict(
                "name" => "False northing",
                "value" => false_northing,
                "unit" => "metre",
                "id" => Dict("authority" => "EPSG", "code" => 8807)
            )
        ]
    )
    return KrovakConversion(params)
end
=#
end # module
