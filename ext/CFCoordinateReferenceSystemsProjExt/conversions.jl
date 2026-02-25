# Begin conversion definitions
const SCHEMA = "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json"

function _albers_equal_area__to_projjson_dict(;
    latitude_first_parallel::Real,
    latitude_second_parallel::Real,
    latitude_false_origin::Real = 0.0,
    longitude_false_origin::Real = 0.0,
    easting_false_origin::Real = 0.0,
    northing_false_origin::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Albers Equal Area",
            "id" => InnerDict("authority" => "EPSG", "code" => 9822),
        ),
        "parameters" => [
            _latitude_false_origin(latitude_false_origin),
            _longitude_false_origin(longitude_false_origin),
            _latitude_1st_standard_parallel(latitude_first_parallel),
            _latitude_2nd_standard_parallel(latitude_second_parallel),
            _easting_false_origin(easting_false_origin),
            _northing_false_origin(northing_false_origin),
            # Note: Units dicts were dropped from these entries, and "metre" 
            # used instead as thats what is used everywhere else.
            _easting_false_origin(easting_false_origin),
            _northing_false_origin(northing_false_origin),
        ]
    )
end

function _azimuthal_equidistant__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Modified Azimuthal Equidistant",
            "id" => InnerDict("authority" => "EPSG", "code" => 9832)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _geostationary_satellite__to_projjson_dict(;
    sweep_angle_axis::String,
    satellite_height::Real,
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

    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict("name" => "Geostationary Satellite (Sweep $sweep_angle_axis)"),
        "parameters" => [
            InnerDict(
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
end

function _lambert_azimuthal_equal_area__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Lambert Azimuthal Equal Area",
            "id" => InnerDict("authority" => "EPSG", "code" => 9820)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _lambert_conformal_conic_2sp__to_projjson_dict(;
    latitude_first_parallel::Real,
    latitude_second_parallel::Real,
    latitude_false_origin::Real = 0.0,
    longitude_false_origin::Real = 0.0,
    easting_false_origin::Real = 0.0,
    northing_false_origin::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Lambert Conic Conformal (2SP)",
            "id" => InnerDict("authority" => "EPSG", "code" => 9802)
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
end

function _lambert_convermal_conic_1sp__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Lambert Conic Conformal (1SP)",
            "id" => InnerDict("authority" => "EPSG", "code" => 9801)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _lambert_cylindrical_equal_area__to_projjson_dict(;
    latitude_first_parallel::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Lambert Cylindrical Equal Area",
            "id" => InnerDict("authority" => "EPSG", "code" => 9835)
        ),
        "parameters" => [
            _latitude_1st_standard_parallel(latitude_first_parallel),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _lambert_cylindrical_equal_area_scale__to_projjson_dict(;
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Lambert Cylindrical Equal Area",
            "id" => InnerDict("authority" => "EPSG", "code" => 9835)
        ),
        "parameters" => [
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
            _scale_factor_natural_origin(scale_factor_natural_origin),
        ]
    )
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

    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Mercator (variant A)",
            "id" => InnerDict("authority" => "EPSG", "code" => 9804)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _mercator_b__to_projjson_dict(;
    latitude_first_parallel::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Mercator (variant B)",
            "id" => InnerDict("authority" => "EPSG", "code" => 9805)
        ),
        "parameters" => [
            _latitude_1st_standard_parallel(latitude_first_parallel),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _hotine_oblique_mercator_b__to_projjson_dict(;
    latitude_projection_centre::Real,
    longitude_projection_centre::Real,
    angle_from_rectified_to_skew_grid::Real,
    easting_projection_centre::Real = 0.0,
    northing_projection_centre::Real = 0.0,
    azimuth_projection_centre::Real,
    scale_factor_projection_centre::Real = 1.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Hotine Oblique Mercator (variant B)",
            "id" => InnerDict("authority" => "EPSG", "code" => 9815),
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
end

function _orthographic__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Orthographic",
            "id" => InnerDict("authority" => "EPSG", "code" => 9840)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _polar_stereographic_a__to_projjson_dict(;
    latitude_natural_origin::Real,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    if !(latitude_natural_origin in (90, -90))
        throw(ArgumentError("latitude_natural_origin must be either +90 or -90"))
    end

    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Polar Stereographic (variant A)",
            "id" => InnerDict("authority" => "EPSG", "code" => 9810)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _polar_stereographic_b__to_projjson_dict(;
    latitude_standard_parallel::Real = 0.0,
    longitude_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Polar Stereographic (variant B)",
            "id" => InnerDict("authority" => "EPSG", "code" => 9829)
        ),
        "parameters" => [
            _latitude_standard_paralel(latitude_standard_parallel),
            _longitude_origin(longitude_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _sinosoidal__to_projjson_dict(;
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict("name" => "Sinusoidal"),
        "parameters" => [
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _stereographic__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict("name" => "Stereographic"),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _utm__to_projjson_dict(zone::Integer, hemisphere::String = "N")
    if !(1 <= zone <= 60)
        throw(ArgumentError("zone must be between 1 and 60"))
    end
    hemisphere = uppercase(hemisphere)
    if !(hemisphere in ("N", "S"))
        throw(ArgumentError("hemisphere must be either N or S"))
    end

    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "UTM zone $(zone)$(hemisphere)",
        "method" => InnerDict(
            "name" => "Transverse Mercator",
            "id" => InnerDict("authority" => "EPSG", "code" => 9807)
        ),
        "parameters" => [
            _latitude_natural_origin(0.0),
            _longitude_natural_origin((zone * 6 - 183)),
            _scale_factor_natural_origin(0.9996),
            _false_easting(500000.0),
            _false_northing(hemisphere == "N" ? 0.0 : 10000000.0),
        ]
    )
end

function _transverse_mercator__to_projjson_dict(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
    scale_factor_natural_origin::Real = 1.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Transverse Mercator",
            "id" => InnerDict("authority" => "EPSG", "code" => 9807)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _scale_factor_natural_origin(scale_factor_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _vertical_perspective__to_projjson_dict(;
    viewpoint_height::Real,
    latitude_topocentric_origin::Real = 0.0,
    longitude_topocentric_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Vertical Perspective",
            "id" => InnerDict("authority" => "EPSG", "code" => 9838)
        ),
        "parameters" => [
            _viewpoint_height(viewpoint_height),
            _latitude_topocentric_origin(latitude_topocentric_origin),
            _longitude_topocentric_origin(longitude_topocentric_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
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

    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Popular Visualisation Pseudo Mercator",
            "id" => InnerDict("authority" => "EPSG", "code" => 1024)
        ),
        "parameters" => [
            _latitude_natural_origin(latitude_natural_origin),
            _longitude_natural_origin(longitude_natural_origin),
            _false_easting(false_easting),
            _false_northing(false_northing),
        ]
    )
end

function _rotated_latitude_longitude__to_projjson_dict(;
    grid_north_pole_latitude,
    grid_north_pole_longitude,
    north_pole_grid_longitude,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "Pole rotation (netCDF CF convention)",
        "method" => InnerDict("name" => "Pole rotation (netCDF CF convention)"),
        "parameters" => [
            InnerDict(
                "name" => "Grid north pole latitude (netCDF CF convention)",
                "value" => grid_north_pole_latitude,
                "unit" => "degree",
            ),
            InnerDict(
                "name" => "Grid north pole longitude (netCDF CF convention)",
                "value" => grid_north_pole_longitude,
                "unit" => "degree",
            ),
            InnerDict(
                "name" => "North pole grid longitude (netCDF CF convention)",
                "value" => north_pole_grid_longitude,
                "unit" => "degree",
            ),
        ],
    )
end
#=

function CassiniSoldnerConversion(;
    latitude_natural_origin::Real = 0.0,
    longitude_natural_origin::Real = 0.0,
    false_easting::Real = 0.0,
    false_northing::Real = 0.0,
)
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Cassini-Soldner",
            "id" => InnerDict("authority" => "EPSG", "code" => 9806)
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
    InnerDict(
        SCHEMA,
        "type" => "Conversion",
        "name" => "unknown",
        "method" => InnerDict(
            "name" => "Krovak",
            "id" => InnerDict("authority" => "EPSG", "code" => 9819)
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