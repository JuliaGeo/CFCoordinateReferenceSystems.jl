# Parameter helpers

_colatitude_cone_axis(colatitude_cone_axis) =
    Dict(
        "name" => "Co-latitude of cone axis",
        "value" => colatitude_cone_axis,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 1036)
    )

_latitude_natural_origin(value) =
    Dict(
        "name" => "Latitude of natural origin",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8801)
    )

_longitude_natural_origin(value) =
    Dict(
        "name" => "Longitude of natural origin",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8802)
    )
    
_scale_factor_natural_origin(value) =
    Dict(
        "name" => "Scale factor at natural origin",
        "value" => value,
        "unit" => "unity",
        "id" => Dict("authority" => "EPSG", "code" => 8805)
    )

_false_easting(value) =
    Dict(
        "name" => "False easting",
        "value" => value,
        "unit" => "metre",
        "id" => Dict("authority" => "EPSG", "code" => 8806)
    )

_false_northing(value) =
    Dict(
        "name" => "False northing",
        "value" => value,
        "unit" => "metre",
        "id" => Dict("authority" => "EPSG", "code" => 8807)
    )

_latitude_projection_centre(value) =
    Dict(
        "name" => "Latitude of projection centre",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8811)
    )

_longitude_projection_centre(value) =
    Dict(
        "name" => "Longitude of projection centre",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8812)
    )

_azimuth_projection_centre(value) =
    Dict(
        "name" => "Azimuth at projection centre",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8813)
    )

_angle_from_rectified_to_skew_grid(value) =
    Dict(
        "name" => "Angle from Rectified to Skew Grid",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8814)
    )

_scale_factor_projection_centre(value) =
    Dict(
        "name" => "Scale factor at projection centre",
        "value" => value,
        "unit" => "unity",
        "id" => Dict("authority" => "EPSG", "code" => 8815)
    )

_easting_projection_centre(value) =
    Dict(
        "name" => "Easting at projection centre",
        "value" => value,
        "unit" => "metre",
        "id" => Dict("authority" => "EPSG", "code" => 8816)
    )

_northing_projection_centre(value) =
    Dict(
        "name" => "Northing at projection centre",
        "value" => value,
        "unit" => "metre",
        "id" => Dict("authority" => "EPSG", "code" => 8817)
    )

_latitude_pseudo_standard_parallel(latitude_pseudo_standard_parallel) =
    Dict(
        "name" => "Latitude of pseudo standard parallel",
        "value" => latitude_pseudo_standard_parallel,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8818)
    )

_scale_factor_pseudo_standard_parallel(scale_factor_pseudo_standard_parallel) =
    Dict(
        "name" => "Scale factor on pseudo standard parallel",
        "value" => scale_factor_pseudo_standard_parallel,
        "unit" => "unity",
        "id" => Dict("authority" => "EPSG", "code" => 8819)
    )

_latitude_false_origin(value) =
    Dict(
        "name" => "Latitude of false origin",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8821)
    )

_longitude_false_origin(value) =
    Dict(
        "name" => "Longitude of false origin",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8822)
    )

_latitude_1st_standard_parallel(value) =
    Dict(
        "name" => "Latitude of 1st standard parallel",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8823)
    )

_latitude_2nd_standard_parallel(value) =
    Dict(
        "name" => "Latitude of 2nd standard parallel",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8824)
    )

_easting_false_origin(value) =
    Dict(
        "name" => "Easting at false origin",
        "value" => value,
        "unit" => "metre",
        "id" => Dict("authority" => "EPSG", "code" => 8826)
    )

_northing_false_origin(value) =
    Dict( "name" => "Northing at false origin",
        "value" => value,
        "unit" => "metre",
        "id" => Dict("authority" => "EPSG", "code" => 8827)
    )

_latitude_standard_paralel(value) =
    Dict(
        "name" => "Latitude of standard parallel",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8832)
    )

_longitude_origin(value) =
    Dict(
        "name" => "Longitude of origin",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8833)
    )

_latitude_topocentric_origin(value) =
    Dict(
        "name" => "Latitude of topocentric origin",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8834)
    )

_longitude_topocentric_origin(value) =
    Dict(
        "name" => "Longitude of topocentric origin",
        "value" => value,
        "unit" => "degree",
        "id" => Dict("authority" => "EPSG", "code" => 8835)
    )

_viewpoint_height(value) =
    Dict(
        "name" => "Viewpoint height",
        "value" => value,
        "unit" => "metre",
        "id" => Dict("authority" => "EPSG", "code" => 8840)
    )