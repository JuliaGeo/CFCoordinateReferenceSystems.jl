"""
This file contains mappings necessary to convert from
a CRS to a CF-1.8 compliant projection.

http://cfconventions.org/cf-conventions/cf-conventions.html#appendix-grid-mappings
"""

function _horizontal_datum_from_params(cf_params)
    datum_name = if haskey(cf_params, "horizontal_datum_name")
        datum_name = cf_params["horizontal_datum_name"]
        datum_name in UNKNOWN_NAMES || return datum_name
        datum_name
    end
    # Step 1: build ellipsoid
    ellipsoid_name = get(cf_params, "reference_ellipsoid_name", nothing)
    ellipsoid = if all(k -> haskey(cf_params, k), ("semi_major_axis", "inverse_flattening", "earth_radius"))
        InnerDict(
            "name" => isnothing(ellipsoid_name) ? "undefined" : ellipsoid_name,
            "semi_major_axis" => cf_params["semi_major_axis"],
            "semi_minor_axis" => get(cf_params, "semi_minor_axis", 0.0),
            "inverse_flattening" => cf_params["inverse_flattening"],
            "radius" => cf_params["earth_radius"],
        )
    else
        # TODO
        ellipsoid_name #elipsoid_from_name(ellipsoid_name)
    end

    # Step 2: build prime meridian
    prime_meridian_name = get(cf_params, "prime_meridian_name", nothing)
    prime_meridian = if haskey(cf_params, "longitude_of_prime_meridian")
        _prime_meridian(
            name=prime_meridian_name,
            longitude=cf_params["longitude_of_prime_meridian"]
        )
    else
        if isnothing(prime_meridian_name) || prime_meridian_name in ("undefined", "unknown")
            nothing
        else
            _prime_meridian(; name=prime_meridian_name)
        end
    end

    # Step 3: build datum
    if isnothing(ellipsoid) && isnothing(prime_meridian)
        return nothing
    else
        return _custom_datum(
            name=isnothing(datum_name) ? "undefined" : datum_name,
            ellipsoid=isnothing(ellipsoid) ? "WGS 84" : ellipsoid,
            prime_meridian=isnothing(prime_meridian) ? "Greenwich" : prime_meridian
        )
    end
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_albers_equal_area
function _albers_conical_equal_area(cf_params)
    first_parallel, second_parallel = _get_standard_parallels(cf_params["standard_parallel"])
    return _albers_equal_area__to_projjson_dict(
        latitude_first_parallel=first_parallel,
        latitude_second_parallel=isnothing(second_parallel) ? 0.0 : second_parallel,
        latitude_false_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
        longitude_false_origin=get(cf_params, "longitude_of_central_meridian", 0.0),
        easting_false_origin=get(cf_params, "false_easting", 0.0),
        northing_false_origin=get(cf_params, "false_northing", 0.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#azimuthal-equidistant
function _azimuthal_equidistant(cf_params)
    return _azimuthal_equidistant__to_projjson_dict(
        latitude_natural_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
        longitude_natural_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
        false_easting=get(cf_params, "false_easting", 0.0),
        false_northing=get(cf_params, "false_northing", 0.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_geostationary_projection
function _geostationary(cf_params)
    sweep_angle_axis = if haskey(cf_params, "sweep_angle_axis")
        cf_params["sweep_angle_axis"]
    else
        Dict("x" => "y", "y" => "x")[lowercase(cf_params["fixed_angle_axis"])]
    end
    return _geostationary_satellite__to_projjson_dict(
        sweep_angle_axis=sweep_angle_axis,
        satellite_height=cf_params["perspective_point_height"],
        latitude_natural_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
        longitude_natural_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
        false_easting=get(cf_params, "false_easting", 0.0),
        false_northing=get(cf_params, "false_northing", 0.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#lambert-azimuthal-equal-area
function _lambert_azimuthal_equal_area(cf_params)
    return _lambert_azimuthal_equal_area__to_projjson_dict(
        latitude_natural_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
        longitude_natural_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
        false_easting=get(cf_params, "false_easting", 0.0),
        false_northing=get(cf_params, "false_northing", 0.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_lambert_conformal
function _lambert_conformal_conic(cf_params)
    first_parallel, second_parallel = _get_standard_parallels(cf_params["standard_parallel"])
    if isnothing(second_parallel)
        return _lambert_conformal_conic_1sp__to_projjson_dict(
            latitude_natural_origin=first_parallel,
            longitude_natural_origin=get(cf_params, "longitude_of_central_meridian", 0.0),
            false_easting=get(cf_params, "false_easting", 0.0),
            false_northing=get(cf_params, "false_northing", 0.0)
        )
    else
        return _lambert_conformal_conic_2sp__to_projjson_dict(
            latitude_first_parallel=first_parallel,
            latitude_second_parallel=second_parallel,
            latitude_false_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
            longitude_false_origin=get(cf_params, "longitude_of_central_meridian", 0.0),
            easting_false_origin=get(cf_params, "false_easting", 0.0),
            northing_false_origin=get(cf_params, "false_northing", 0.0)
        )
    end
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_lambert_cylindrical_equal_area
function _lambert_cylindrical_equal_area(cf_params)
    if haskey(cf_params, "scale_factor_at_projection_origin")
        return _lambert_cylindrical_equal_area_scale__to_projjson_dict(
            scale_factor_natural_origin=cf_params["scale_factor_at_projection_origin"],
            longitude_natural_origin=get(cf_params, "longitude_of_central_meridian", 0.0),
            false_easting=get(cf_params, "false_easting", 0.0),
            false_northing=get(cf_params, "false_northing", 0.0)
        )
    else
        return _lambert_cylindrical_equal_area__to_projjson_dict(
            latitude_first_parallel=get(cf_params, "standard_parallel", 0.0),
            longitude_natural_origin=get(cf_params, "longitude_of_central_meridian", 0.0),
            false_easting=get(cf_params, "false_easting", 0.0),
            false_northing=get(cf_params, "false_northing", 0.0)
        )
    end
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_mercator
function _mercator(cf_params)
    if haskey(cf_params, "scale_factor_at_projection_origin")
        return _mercator_a__to_projjson_dict(
            latitude_natural_origin=get(cf_params, "standard_parallel", 0.0),
            longitude_natural_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
            false_easting=get(cf_params, "false_easting", 0.0),
            false_northing=get(cf_params, "false_northing", 0.0),
            scale_factor_natural_origin=cf_params["scale_factor_at_projection_origin"]
        )
    else
        return _mercator_b__to_projjson_dict(
            latitude_first_parallel=get(cf_params, "standard_parallel", 0.0),
            longitude_natural_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
            false_easting=get(cf_params, "false_easting", 0.0),
            false_northing=get(cf_params, "false_northing", 0.0)
        )
    end
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_oblique_mercator
function _oblique_mercator(cf_params)
    return _hotine_oblique_mercator_b__to_projjson_dict(
        latitude_projection_centre=cf_params["latitude_of_projection_origin"],
        longitude_projection_centre=cf_params["longitude_of_projection_origin"],
        azimuth_projection_centre=cf_params["azimuth_of_central_line"],
        angle_from_rectified_to_skew_grid=0.0,
        scale_factor_projection_centre=get(cf_params, "scale_factor_at_projection_origin", 1.0),
        easting_projection_centre=get(cf_params, "false_easting", 0.0),
        northing_projection_centre=get(cf_params, "false_northing", 0.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_orthographic
function _orthographic(cf_params)
    return _orthographic__to_projjson_dict(
        latitude_natural_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
        longitude_natural_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
        false_easting=get(cf_params, "false_easting", 0.0),
        false_northing=get(cf_params, "false_northing", 0.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#polar-stereographic
function _polar_stereographic(cf_params)
    if haskey(cf_params, "standard_parallel")
        return _polar_stereographic_b__to_projjson_dict(
            latitude_standard_parallel=cf_params["standard_parallel"],
            longitude_origin=cf_params["straight_vertical_longitude_from_pole"],
            false_easting=get(cf_params, "false_easting", 0.0),
            false_northing=get(cf_params, "false_northing", 0.0)
        )
    else
        return _polar_stereographic_a__to_projjson_dict(
            latitude_natural_origin=cf_params["latitude_of_projection_origin"],
            longitude_natural_origin=cf_params["straight_vertical_longitude_from_pole"],
            false_easting=get(cf_params, "false_easting", 0.0),
            false_northing=get(cf_params, "false_northing", 0.0),
            scale_factor_natural_origin=get(cf_params, "scale_factor_at_projection_origin", 1.0)
        )
    end
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_sinusoidal
function _sinusoidal(cf_params)
    return _sinusoidal__to_projjson_dict(
        longitude_natural_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
        false_easting=get(cf_params, "false_easting", 0.0),
        false_northing=get(cf_params, "false_northing", 0.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_stereographic
function _stereographic(cf_params)
    return _stereographic__to_projjson_dict(
        latitude_natural_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
        longitude_natural_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
        false_easting=get(cf_params, "false_easting", 0.0),
        false_northing=get(cf_params, "false_northing", 0.0),
        scale_factor_natural_origin=get(cf_params, "scale_factor_at_projection_origin", 1.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_transverse_mercator
function _transverse_mercator(cf_params)
    return _transverse_mercator__to_projjson_dict(
        latitude_natural_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
        longitude_natural_origin=get(cf_params, "longitude_of_central_meridian", 0.0),
        false_easting=get(cf_params, "false_easting", 0.0),
        false_northing=get(cf_params, "false_northing", 0.0),
        scale_factor_natural_origin=get(cf_params, "scale_factor_at_central_meridian", 1.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#vertical-perspective
function _vertical_perspective(cf_params)
    return _vertical_perspective__to_projjson_dict(;
        viewpoint_height=cf_params["perspective_point_height"],
        latitude_topocentric_origin=get(cf_params, "latitude_of_projection_origin", 0.0),
        longitude_topocentric_origin=get(cf_params, "longitude_of_projection_origin", 0.0),
        false_easting=get(cf_params, "false_easting", 0.0),
        false_northing=get(cf_params, "false_northing", 0.0)
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_rotated_pole
function _rotated_latitude_longitude(cf_params)
    grid_north_pole_latitude = cf_params["grid_north_pole_latitude"],
    grid_north_pole_longitude = cf_params["grid_north_pole_longitude"],
    north_pole_grid_longitude = get(cf_params, "north_pole_grid_longitude", 0.0)
    _rotated_latitude_longitude__to_projjson_dict(;
        grid_north_pole_latitude,
        grid_north_pole_longitude,
        north_pole_grid_longitude,
    )
end

# Inverse mapping functions
# http://cfconventions.org/cf-conventions/cf-conventions.html#_albers_equal_area
function _albers_conical_equal_area__to_cf(conversion::OrderedDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "albers_conical_equal_area",
        "standard_parallel" => (
            params["latitude_of_1st_standard_parallel"],
            params["latitude_of_2nd_standard_parallel"]
        ),
        "latitude_of_projection_origin" => params["latitude_of_false_origin"],
        "longitude_of_central_meridian" => params["longitude_of_false_origin"],
        "false_easting" => params["easting_at_false_origin"],
        "false_northing" => params["northing_at_false_origin"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#azimuthal-equidistant
function _azimuthal_equidistant__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "azimuthal_equidistant",
        "latitude_of_projection_origin" => params["latitude_of_natural_origin"],
        "longitude_of_projection_origin" => params["longitude_of_natural_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_geostationary_projection
function _geostationary__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    sweep_angle_axis = "y"
    if endswith(lowercase(conversion.method_name), "(sweep_x)")
        sweep_angle_axis = "x"
    end
    return InnerDict(
        "grid_mapping_name" => "geostationary",
        "sweep_angle_axis" => sweep_angle_axis,
        "perspective_point_height" => params["satellite_height"],
        "latitude_of_projection_origin" => get(params, "latitude_of_natural_origin", 0.0),
        "longitude_of_projection_origin" => params["longitude_of_natural_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#lambert-azimuthal-equal-area
function _lambert_azimuthal_equal_area__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "lambert_azimuthal_equal_area",
        "latitude_of_projection_origin" => params["latitude_of_natural_origin"],
        "longitude_of_projection_origin" => params["longitude_of_natural_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_lambert_conformal
function _lambert_conformal_conic__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    if endswith(lowercase(conversion.method_name), "(2sp)")
        return InnerDict(
            "grid_mapping_name" => "lambert_conformal_conic",
            "standard_parallel" => (
                params["latitude_of_1st_standard_parallel"],
                params["latitude_of_2nd_standard_parallel"]
            ),
            "latitude_of_projection_origin" => params["latitude_of_false_origin"],
            "longitude_of_central_meridian" => params["longitude_of_false_origin"],
            "false_easting" => params["easting_at_false_origin"],
            "false_northing" => params["northing_at_false_origin"]
        )
    else
        return InnerDict(
            "grid_mapping_name" => "lambert_conformal_conic",
            "standard_parallel" => params["latitude_of_natural_origin"],
            "longitude_of_central_meridian" => params["longitude_of_natural_origin"],
            "false_easting" => params["false_easting"],
            "false_northing" => params["false_northing"]
        )
    end
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_lambert_cylindrical_equal_area
function _lambert_cylindrical_equal_area__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "lambert_cylindrical_equal_area",
        "standard_parallel" => params["latitude_of_1st_standard_parallel"],
        "longitude_of_central_meridian" => params["longitude_of_natural_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_mercator
function _mercator__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    if endswith(lowercase(conversion.method_name), "(variant_a)")
        return InnerDict(
            "grid_mapping_name" => "mercator",
            "standard_parallel" => params["latitude_of_natural_origin"],
            "longitude_of_projection_origin" => params["longitude_of_natural_origin"],
            "false_easting" => params["false_easting"],
            "false_northing" => params["false_northing"],
            "scale_factor_at_projection_origin" => params["scale_factor_at_natural_origin"]
        )
    else
        return InnerDict(
            "grid_mapping_name" => "mercator",
            "standard_parallel" => params["latitude_of_1st_standard_parallel"],
            "longitude_of_projection_origin" => params["longitude_of_natural_origin"],
            "false_easting" => params["false_easting"],
            "false_northing" => params["false_northing"]
        )
    end
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_oblique_mercator
function _oblique_mercator__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    if params["angle_from_rectified_to_skew_grid"] != 0
        @warn "angle from rectified to skew grid parameter lost in conversion to CF"
    end
    # Handle some deprecated parameter names
    azimuth_of_central_line = if haskey(params, "azimuth_of_initial_line")
        params["azimuth_of_initial_line"]
    else
        params["azimuth_at_projection_centre"]
    end
    scale_factor_at_projection_origin = if haskey(params, "scale_factor_on_initial_line")
        params["scale_factor_on_initial_line"]
    else
        params["scale_factor_at_projection_centre"]
    end
    return InnerDict(
        "grid_mapping_name" => "oblique_mercator",
        "latitude_of_projection_origin" => params["latitude_of_projection_centre"],
        "longitude_of_projection_origin" => params["longitude_of_projection_centre"],
        "azimuth_of_central_line" => azimuth_of_central_line,
        "scale_factor_at_projection_origin" => scale_factor_at_projection_origin,
        "false_easting" => params["easting_at_projection_centre"],
        "false_northing" => params["northing_at_projection_centre"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_orthographic
function _orthographic__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "orthographic",
        "latitude_of_projection_origin" => params["latitude_of_natural_origin"],
        "longitude_of_projection_origin" => params["longitude_of_natural_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#polar-stereographic
function _polar_stereographic__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    if endswith(lowercase(conversion.method_name), "(variant b)")
        return InnerDict(
            "grid_mapping_name" => "polar_stereographic",
            "standard_parallel" => params["latitude_of_standard_parallel"],
            "straight_vertical_longitude_from_pole" => params["longitude_of_origin"],
            "false_easting" => params["false_easting"],
            "false_northing" => params["false_northing"]
        )
    else
        return InnerDict(
            "grid_mapping_name" => "polar_stereographic",
            "latitude_of_projection_origin" => params["latitude_of_natural_origin"],
            "straight_vertical_longitude_from_pole" => params["longitude_of_natural_origin"],
            "false_easting" => params["false_easting"],
            "false_northing" => params["false_northing"],
            "scale_factor_at_projection_origin" => params["scale_factor_at_natural_origin"]
        )
    end
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_sinusoidal
function _sinusoidal__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "sinusoidal",
        "longitude_of_projection_origin" => params["longitude_of_natural_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_stereographic
function _stereographic__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "stereographic",
        "latitude_of_projection_origin" => params["latitude_of_natural_origin"],
        "longitude_of_projection_origin" => params["longitude_of_natural_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"],
        "scale_factor_at_projection_origin" => params["scale_factor_at_natural_origin"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_transverse_mercator
function _transverse_mercator__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "transverse_mercator",
        "latitude_of_projection_origin" => params["latitude_of_natural_origin"],
        "longitude_of_central_meridian" => params["longitude_of_natural_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"],
        "scale_factor_at_central_meridian" => params["scale_factor_at_natural_origin"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#vertical-perspective
function _vertical_perspective__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "vertical_perspective",
        "perspective_point_height" => params["viewpoint_height"],
        "latitude_of_projection_origin" => params["latitude_of_topocentric_origin"],
        "longitude_of_projection_origin" => params["longitude_of_topocentric_origin"],
        "false_easting" => params["false_easting"],
        "false_northing" => params["false_northing"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_rotated_pole
function _rotated_latitude_longitude__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "rotated_latitude_longitude",
        "grid_north_pole_latitude" => params["o_lat_p"],
        "grid_north_pole_longitude" => params["lon_0"] - 180,
        "north_pole_grid_longitude" => params["o_lon_p"]
    )
end

# http://cfconventions.org/cf-conventions/cf-conventions.html#_rotated_pole
function _pole_rotation_netcdf__to_cf(conversion::AbstractDict)
    params = _to_dict(conversion)
    return InnerDict(
        "grid_mapping_name" => "rotated_latitude_longitude",
        "grid_north_pole_latitude" => params["grid_north_pole_latitude_(netcdf_cf_convention)"],
        "grid_north_pole_longitude" => params["grid_north_pole_longitude_(netcdf_cf_convention)"],
        "north_pole_grid_longitude" => params["north_pole_grid_longitude_(netcdf_cf_convention)"]
    )
end