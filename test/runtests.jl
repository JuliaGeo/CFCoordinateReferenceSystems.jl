using CFCoordinateReferenceSystems
using Test
using Aqua
using JET
using GeoFormatTypes
using Proj
using JSON3

import CFCoordinateReferenceSystems as CFCRS
import GeoFormatTypes as GFT

# Helper to get ProjJSON dict from CFProjection
function get_projjson_dict(cf)
    projjson = convert(GFT.ProjJSON, cf)
    return JSON3.read(GFT.val(projjson), Dict{String,Any})
end

# Helper to get conversion parameters as a dict
# The Julia implementation outputs "Conversion" type directly for projections
function get_conversion_params(cf)
    d = get_projjson_dict(cf)
    params = Dict{String,Any}()
    param_list = if haskey(d, "parameters")
        d["parameters"]
    elseif haskey(d, "conversion") && haskey(d["conversion"], "parameters")
        d["conversion"]["parameters"]
    else
        []
    end
    for p in param_list
        params[p["name"]] = p["value"]
    end
    return params
end

# Helper to get method name
function get_method_name(cf)
    d = get_projjson_dict(cf)
    if haskey(d, "method")
        return d["method"]["name"]
    elseif haskey(d, "conversion") && haskey(d["conversion"], "method")
        return d["conversion"]["method"]["name"]
    else
        return nothing
    end
end

@testset "CFCoordinateReferenceSystems.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        # stale_deps=false because JSON3 is used in the extension, not in src/,
        # and Aqua doesn't scan extensions
        Aqua.test_all(CFCoordinateReferenceSystems; stale_deps=false)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(CFCoordinateReferenceSystems; target_defined_modules=true)
    end

    @testset "latitude_longitude" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "latitude_longitude",
            "semi_major_axis" => 6378137.0,
            "inverse_flattening" => 298.257223,
        )
        d = get_projjson_dict(cf)
        @test d["type"] == "GeographicCRS"
        @test haskey(d, "datum") || haskey(d, "datum_ensemble")
    end

    @testset "transverse_mercator" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "transverse_mercator",
            "latitude_of_projection_origin" => 0.0,
            "longitude_of_central_meridian" => 15.0,
            "false_easting" => 2520000.0,
            "false_northing" => 0.0,
            "scale_factor_at_central_meridian" => 0.9996,
        )
        @test get_method_name(cf) == "Transverse Mercator"

        params = get_conversion_params(cf)
        @test params["Latitude of natural origin"] == 0.0
        @test params["Longitude of natural origin"] == 15.0
        @test params["False easting"] == 2520000.0
        @test params["False northing"] == 0.0
        @test params["Scale factor at natural origin"] == 0.9996
    end

    @testset "albers_conical_equal_area" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "albers_conical_equal_area",
            "standard_parallel" => [20.0, 60.0],
            "latitude_of_projection_origin" => 40.0,
            "longitude_of_central_meridian" => -96.0,
            "false_easting" => 0.0,
            "false_northing" => 0.0,
        )
        @test get_method_name(cf) == "Albers Equal Area"

        params = get_conversion_params(cf)
        @test params["Latitude of false origin"] == 40.0
        @test params["Longitude of false origin"] == -96.0
        @test params["Latitude of 1st standard parallel"] == 20.0
        @test params["Latitude of 2nd standard parallel"] == 60.0
        @test params["Easting at false origin"] == 0.0
        @test params["Northing at false origin"] == 0.0
    end

    @testset "azimuthal_equidistant" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "azimuthal_equidistant",
            "latitude_of_projection_origin" => 45.0,
            "longitude_of_projection_origin" => -100.0,
            "false_easting" => 0.0,
            "false_northing" => 0.0,
        )
        @test get_method_name(cf) == "Modified Azimuthal Equidistant"

        params = get_conversion_params(cf)
        @test params["Latitude of natural origin"] == 45.0
        @test params["Longitude of natural origin"] == -100.0
    end

    @testset "geostationary" begin
        @testset "sweep_x" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "geostationary",
                "perspective_point_height" => 35785831.0,
                "sweep_angle_axis" => "x",
                "longitude_of_projection_origin" => -75.0,
            )
            @test get_method_name(cf) == "Geostationary Satellite (Sweep X)"

            params = get_conversion_params(cf)
            @test params["Satellite height"] == 35785831.0
            @test params["Longitude of natural origin"] == -75.0
        end

        @testset "sweep_y" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "geostationary",
                "perspective_point_height" => 35785831.0,
                "sweep_angle_axis" => "y",
            )
            @test get_method_name(cf) == "Geostationary Satellite (Sweep Y)"

            params = get_conversion_params(cf)
            @test params["Satellite height"] == 35785831.0
        end

        @testset "fixed_angle_axis converts to sweep" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "geostationary",
                "perspective_point_height" => 35785831.0,
                "fixed_angle_axis" => "y",  # fixed_angle_axis=y means sweep_angle_axis=x
            )
            @test get_method_name(cf) == "Geostationary Satellite (Sweep X)"
        end
    end

    @testset "lambert_azimuthal_equal_area" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "lambert_azimuthal_equal_area",
            "latitude_of_projection_origin" => 52.0,
            "longitude_of_projection_origin" => 10.0,
            "false_easting" => 4321000.0,
            "false_northing" => 3210000.0,
        )
        @test get_method_name(cf) == "Lambert Azimuthal Equal Area"

        params = get_conversion_params(cf)
        @test params["Latitude of natural origin"] == 52.0
        @test params["Longitude of natural origin"] == 10.0
        @test params["False easting"] == 4321000.0
        @test params["False northing"] == 3210000.0
    end

    @testset "lambert_conformal_conic" begin
        @testset "1SP" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "lambert_conformal_conic",
                "standard_parallel" => 25.0,
                "longitude_of_central_meridian" => 265.0,
                "latitude_of_projection_origin" => 25.0,
            )
            @test get_method_name(cf) == "Lambert Conic Conformal (1SP)"

            params = get_conversion_params(cf)
            @test params["Latitude of natural origin"] == 25.0
            @test params["Longitude of natural origin"] == 265.0
            @test params["Scale factor at natural origin"] == 1.0
        end

        @testset "2SP" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "lambert_conformal_conic",
                "standard_parallel" => [25.0, 30.0],
                "longitude_of_central_meridian" => 265.0,
                "latitude_of_projection_origin" => 25.0,
            )
            @test get_method_name(cf) == "Lambert Conic Conformal (2SP)"

            params = get_conversion_params(cf)
            @test params["Latitude of 1st standard parallel"] == 25.0
            @test params["Latitude of 2nd standard parallel"] == 30.0
            @test params["Latitude of false origin"] == 25.0
            @test params["Longitude of false origin"] == 265.0
        end

        @testset "standard_parallel as string" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "lambert_conformal_conic",
                "standard_parallel" => "25.0, 30.0",
                "longitude_of_central_meridian" => 265.0,
                "latitude_of_projection_origin" => 25.0,
            )
            @test get_method_name(cf) == "Lambert Conic Conformal (2SP)"

            params = get_conversion_params(cf)
            @test params["Latitude of 1st standard parallel"] == 25.0
            @test params["Latitude of 2nd standard parallel"] == 30.0
        end
    end

    @testset "lambert_cylindrical_equal_area" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "lambert_cylindrical_equal_area",
            "standard_parallel" => 30.0,
            "longitude_of_central_meridian" => 0.0,
            "false_easting" => 0.0,
            "false_northing" => 0.0,
        )
        @test get_method_name(cf) == "Lambert Cylindrical Equal Area"

        params = get_conversion_params(cf)
        @test params["Latitude of 1st standard parallel"] == 30.0
        @test params["Longitude of natural origin"] == 0.0
    end

    @testset "mercator" begin
        @testset "variant B (with standard_parallel)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "mercator",
                "longitude_of_projection_origin" => 10.0,
                "standard_parallel" => 21.354,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            @test get_method_name(cf) == "Mercator (variant B)"

            params = get_conversion_params(cf)
            @test params["Latitude of 1st standard parallel"] == 21.354
            @test params["Longitude of natural origin"] == 10.0
        end

        @testset "variant A (with scale_factor)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "mercator",
                "longitude_of_projection_origin" => 10.0,
                "scale_factor_at_projection_origin" => 0.9996,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            @test get_method_name(cf) == "Mercator (variant A)"

            params = get_conversion_params(cf)
            @test params["Scale factor at natural origin"] == 0.9996
            @test params["Longitude of natural origin"] == 10.0
        end
    end

    @testset "oblique_mercator" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "oblique_mercator",
            "azimuth_of_central_line" => 0.35,
            "latitude_of_projection_origin" => 10.0,
            "longitude_of_projection_origin" => 15.0,
            "scale_factor_at_projection_origin" => 1.0,
            "false_easting" => 0.0,
            "false_northing" => 0.0,
        )
        @test get_method_name(cf) == "Hotine Oblique Mercator (variant B)"

        params = get_conversion_params(cf)
        @test params["Latitude of projection centre"] == 10.0
        @test params["Longitude of projection centre"] == 15.0
        @test params["Azimuth at projection centre"] == 0.35
        @test params["Angle from Rectified to Skew Grid"] == 90.0  # pyproj uses 90.0
        @test params["Scale factor at projection centre"] == 1.0
    end

    @testset "orthographic" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "orthographic",
            "latitude_of_projection_origin" => 45.0,
            "longitude_of_projection_origin" => -100.0,
            "false_easting" => 0.0,
            "false_northing" => 0.0,
        )
        @test get_method_name(cf) == "Orthographic"

        params = get_conversion_params(cf)
        @test params["Latitude of natural origin"] == 45.0
        @test params["Longitude of natural origin"] == -100.0
    end

    @testset "polar_stereographic" begin
        @testset "variant A (with scale_factor)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "polar_stereographic",
                "latitude_of_projection_origin" => 90.0,
                "straight_vertical_longitude_from_pole" => -45.0,
                "scale_factor_at_projection_origin" => 0.994,
                "false_easting" => 2000000.0,
                "false_northing" => 2000000.0,
            )
            @test get_method_name(cf) == "Polar Stereographic (variant A)"

            params = get_conversion_params(cf)
            @test params["Latitude of natural origin"] == 90.0
            @test params["Longitude of natural origin"] == -45.0
            @test params["Scale factor at natural origin"] == 0.994
            @test params["False easting"] == 2000000.0
            @test params["False northing"] == 2000000.0
        end

        @testset "variant B (with standard_parallel)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "polar_stereographic",
                "standard_parallel" => 71.0,
                "straight_vertical_longitude_from_pole" => -45.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            @test get_method_name(cf) == "Polar Stereographic (variant B)"

            params = get_conversion_params(cf)
            @test params["Latitude of standard parallel"] == 71.0
            @test params["Longitude of origin"] == -45.0
        end
    end

    @testset "sinusoidal" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "sinusoidal",
            "longitude_of_projection_origin" => 0.0,
            "false_easting" => 0.0,
            "false_northing" => 0.0,
        )
        @test get_method_name(cf) == "Sinusoidal"

        params = get_conversion_params(cf)
        @test params["Longitude of natural origin"] == 0.0
        @test params["False easting"] == 0.0
        @test params["False northing"] == 0.0
    end

    @testset "stereographic" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "stereographic",
            "latitude_of_projection_origin" => 46.0,
            "longitude_of_projection_origin" => 25.0,
            "scale_factor_at_projection_origin" => 0.99975,
            "false_easting" => 500000.0,
            "false_northing" => 500000.0,
        )
        @test get_method_name(cf) == "Stereographic"

        params = get_conversion_params(cf)
        @test params["Latitude of natural origin"] == 46.0
        @test params["Longitude of natural origin"] == 25.0
        @test params["Scale factor at natural origin"] == 0.99975
    end

    @testset "vertical_perspective" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "vertical_perspective",
            "perspective_point_height" => 5500000.0,
            "latitude_of_projection_origin" => 0.0,
            "longitude_of_projection_origin" => 0.0,
            "false_easting" => 0.0,
            "false_northing" => 0.0,
        )
        @test get_method_name(cf) == "Vertical Perspective"

        params = get_conversion_params(cf)
        @test params["Viewpoint height"] == 5500000.0
        @test params["Latitude of topocentric origin"] == 0.0
        @test params["Longitude of topocentric origin"] == 0.0
    end

    @testset "rotated_latitude_longitude" begin
        cf = CFCRS.CFProjection(
            "grid_mapping_name" => "rotated_latitude_longitude",
            "grid_north_pole_latitude" => 32.5,
            "grid_north_pole_longitude" => 170.0,
            "north_pole_grid_longitude" => 0.0,
        )
        # Returns Conversion type (like other projections) wrapped as DerivedGeographicCRS
        @test get_method_name(cf) == "Pole rotation (netCDF CF convention)"

        params = get_conversion_params(cf)
        @test params["Grid north pole latitude (netCDF CF convention)"] == 32.5
        @test params["Grid north pole longitude (netCDF CF convention)"] == 170.0
        @test params["North pole grid longitude (netCDF CF convention)"] == 0.0
    end

    @testset "Error handling" begin
        @testset "missing grid_mapping_name" begin
            cf = CFCRS.CFProjection(
                "latitude_of_projection_origin" => 25.0,
            )
            @test_throws ArgumentError convert(GFT.ProjJSON, cf)
        end

        @testset "invalid grid_mapping_name" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "invalid_projection",
            )
            @test_throws ArgumentError convert(GFT.ProjJSON, cf)
        end
    end

    @testset "Edge cases" begin
        @testset "custom spherical earth (earth_radius)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "transverse_mercator",
                "earth_radius" => 6371000.0,
                "latitude_of_projection_origin" => 0.0,
                "longitude_of_central_meridian" => 0.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            # Should not error
            d = get_projjson_dict(cf)
            @test get_method_name(cf) == "Transverse Mercator"
        end

        @testset "custom ellipsoid (semi_major + inverse_flattening)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "transverse_mercator",
                "semi_major_axis" => 6378388.0,
                "inverse_flattening" => 297.0,
                "latitude_of_projection_origin" => 0.0,
                "longitude_of_central_meridian" => 0.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            d = get_projjson_dict(cf)
            @test get_method_name(cf) == "Transverse Mercator"
        end

        @testset "custom ellipsoid (semi_major + semi_minor)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "transverse_mercator",
                "semi_major_axis" => 6370997.0,
                "semi_minor_axis" => 6370997.0,
                "latitude_of_projection_origin" => 0.0,
                "longitude_of_central_meridian" => 0.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            d = get_projjson_dict(cf)
            @test get_method_name(cf) == "Transverse Mercator"
        end

        @testset "custom prime meridian by longitude" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "transverse_mercator",
                "longitude_of_prime_meridian" => 2.5969213,
                "latitude_of_projection_origin" => 0.0,
                "longitude_of_central_meridian" => 0.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            d = get_projjson_dict(cf)
            @test get_method_name(cf) == "Transverse Mercator"
        end

        @testset "named prime meridian (Paris)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "transverse_mercator",
                "prime_meridian_name" => "Paris",
                "latitude_of_projection_origin" => 0.0,
                "longitude_of_central_meridian" => 0.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            d = get_projjson_dict(cf)
            @test get_method_name(cf) == "Transverse Mercator"
        end

        @testset "default false_easting/northing when not specified" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "transverse_mercator",
                "latitude_of_projection_origin" => 0.0,
                "longitude_of_central_meridian" => 15.0,
                "scale_factor_at_central_meridian" => 0.9996,
            )
            params = get_conversion_params(cf)
            @test params["False easting"] == 0.0
            @test params["False northing"] == 0.0
        end

        @testset "default scale_factor when not specified" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "transverse_mercator",
                "latitude_of_projection_origin" => 0.0,
                "longitude_of_central_meridian" => 15.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            params = get_conversion_params(cf)
            @test params["Scale factor at natural origin"] == 1.0
        end

        @testset "crs_wkt shortcut" begin
            cf = CFCRS.CFProjection(
                "crs_wkt" => "EPSG:4326",
            )
            d = get_projjson_dict(cf)
            @test d["type"] == "GeographicCRS"
        end

        @testset "spatial_ref shortcut" begin
            cf = CFCRS.CFProjection(
                "spatial_ref" => "EPSG:32615",
            )
            d = get_projjson_dict(cf)
            @test d["type"] == "ProjectedCRS"
        end

        @testset "geographic_crs_name for latitude_longitude" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "latitude_longitude",
                "geographic_crs_name" => "WGS 84",
            )
            d = get_projjson_dict(cf)
            @test d["type"] == "GeographicCRS"
        end

        @testset "single standard_parallel in polar_stereographic" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "polar_stereographic",
                "standard_parallel" => -71.0,
                "straight_vertical_longitude_from_pole" => 0.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            @test get_method_name(cf) == "Polar Stereographic (variant B)"
            params = get_conversion_params(cf)
            @test params["Latitude of standard parallel"] == -71.0
        end
    end

    @testset "ProjString output" begin
        @testset "transverse_mercator to ProjString" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "transverse_mercator",
                "latitude_of_projection_origin" => 49.0,
                "longitude_of_central_meridian" => -2.0,
                "false_easting" => 400000.0,
                "false_northing" => -100000.0,
                "scale_factor_at_central_meridian" => 0.9996012717,
            )
            ps = convert(ProjString, cf)
            @test occursin("+proj=tmerc", GFT.val(ps))
            @test occursin("+lat_0=49", GFT.val(ps))
            @test occursin("+lon_0=-2", GFT.val(ps))
        end

        @testset "albers to ProjString" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "albers_conical_equal_area",
                "standard_parallel" => [29.5, 45.5],
                "latitude_of_projection_origin" => 23.0,
                "longitude_of_central_meridian" => -96.0,
                "false_easting" => 0.0,
                "false_northing" => 0.0,
            )
            ps = convert(ProjString, cf)
            @test occursin("+proj=aea", GFT.val(ps))
        end
    end

    @testset "Reverse conversion (other formats to CF)" begin
        @testset "WKT to CF - transverse_mercator (UTM)" begin
            crs = Proj.CRS("EPSG:32615")  # UTM zone 15N
            wkt = GFT.WellKnownText(crs)
            cf = convert(CFCRS.CFProjection, wkt)
            @test cf["grid_mapping_name"] == "transverse_mercator"
            @test cf["latitude_of_projection_origin"] == 0.0
            @test cf["longitude_of_central_meridian"] == -93.0  # UTM zone 15
            @test cf["scale_factor_at_central_meridian"] == 0.9996
            @test cf["false_easting"] == 500000.0
            @test cf["false_northing"] == 0.0
        end

        @testset "WKT to CF - lambert_conformal_conic" begin
            crs = Proj.CRS("EPSG:2154")  # RGF93 / Lambert-93
            wkt = GFT.WellKnownText(crs)
            cf = convert(CFCRS.CFProjection, wkt)
            @test cf["grid_mapping_name"] == "lambert_conformal_conic"
            @test haskey(cf, "standard_parallel")
        end

        @testset "WKT to CF - polar_stereographic" begin
            crs = Proj.CRS("EPSG:3031")  # Antarctic Polar Stereographic
            wkt = GFT.WellKnownText(crs)
            cf = convert(CFCRS.CFProjection, wkt)
            @test cf["grid_mapping_name"] == "polar_stereographic"
        end

        @testset "WKT to CF - albers_conical_equal_area" begin
            crs = Proj.CRS("EPSG:5070")  # NAD83 / Conus Albers
            wkt = GFT.WellKnownText(crs)
            cf = convert(CFCRS.CFProjection, wkt)
            @test cf["grid_mapping_name"] == "albers_conical_equal_area"
            @test haskey(cf, "standard_parallel")
        end

        @testset "WKT to CF - geographic (latitude_longitude)" begin
            crs = Proj.CRS("EPSG:4326")  # WGS 84
            wkt = GFT.WellKnownText(crs)
            cf = convert(CFCRS.CFProjection, wkt)
            @test cf["grid_mapping_name"] == "latitude_longitude"
        end

        @testset "ProjJSON to CF" begin
            crs = Proj.CRS("EPSG:32615")
            projjson = GFT.ProjJSON(crs)
            cf = convert(CFCRS.CFProjection, projjson)
            @test cf["grid_mapping_name"] == "transverse_mercator"
        end

        @testset "ProjString to CF (via CRS)" begin
            # ProjString alone may not have enough info for a full CRS,
            # so we go through Proj.CRS which can expand it properly
            crs = Proj.CRS("+proj=tmerc +lat_0=0 +lon_0=15 +k=0.9996 +x_0=500000 +y_0=0 +datum=WGS84 +type=crs")
            wkt = GFT.WellKnownText(crs)
            cf = convert(CFCRS.CFProjection, wkt)
            @test cf["grid_mapping_name"] == "transverse_mercator"
            @test cf["longitude_of_central_meridian"] == 15.0
            @test cf["scale_factor_at_central_meridian"] == 0.9996
        end
    end

    # Roundtrip tests: EPSG → CF → ProjJSON → CF
    # Verifies that converting to CF and back preserves all parameters.
    # Test cases derived from pyproj test suite.
    @testset "Roundtrip conversion (EPSG → CF → CF)" begin
        @testset "UTM zone 15N (transverse_mercator)" begin
            crs = Proj.CRS("EPSG:32615")
            wkt_str = GFT.val(GFT.WellKnownText(crs))
            cf = CFCRS.CFProjection("crs_wkt" => wkt_str)
            projjson = convert(GFT.ProjJSON, cf)
            cf2 = convert(CFCRS.CFProjection, projjson)

            @test cf2["grid_mapping_name"] == "transverse_mercator"
            @test cf2["latitude_of_projection_origin"] == 0.0
            @test cf2["longitude_of_central_meridian"] == -93.0
            @test cf2["scale_factor_at_central_meridian"] == 0.9996
            @test cf2["false_easting"] == 500000.0
            @test cf2["false_northing"] == 0.0
        end

        @testset "Lambert-93 (lambert_conformal_conic 2SP)" begin
            crs = Proj.CRS("EPSG:2154")
            wkt_str = GFT.val(GFT.WellKnownText(crs))
            cf = CFCRS.CFProjection("crs_wkt" => wkt_str)
            projjson = convert(GFT.ProjJSON, cf)
            cf2 = convert(CFCRS.CFProjection, projjson)

            @test cf2["grid_mapping_name"] == "lambert_conformal_conic"
            @test cf2["standard_parallel"] == (49, 44)  # PROJ returns in this order
            @test cf2["latitude_of_projection_origin"] == 46.5
            @test cf2["longitude_of_central_meridian"] == 3.0
            @test cf2["false_easting"] == 700000.0
            @test cf2["false_northing"] == 6600000.0
        end

        @testset "Antarctic Polar Stereographic (polar_stereographic)" begin
            crs = Proj.CRS("EPSG:3031")
            wkt_str = GFT.val(GFT.WellKnownText(crs))
            cf = CFCRS.CFProjection("crs_wkt" => wkt_str)
            projjson = convert(GFT.ProjJSON, cf)
            cf2 = convert(CFCRS.CFProjection, projjson)

            # EPSG:3031 uses variant A (scale factor), converted to CF as variant A
            @test cf2["grid_mapping_name"] == "polar_stereographic"
            @test cf2["straight_vertical_longitude_from_pole"] == 0.0
            @test cf2["false_easting"] == 0.0
            @test cf2["false_northing"] == 0.0
            # Variant A uses scale_factor, variant B uses standard_parallel
            @test haskey(cf2, "scale_factor_at_projection_origin") || haskey(cf2, "standard_parallel")
        end

        @testset "Conus Albers (albers_conical_equal_area)" begin
            crs = Proj.CRS("EPSG:5070")
            wkt_str = GFT.val(GFT.WellKnownText(crs))
            cf = CFCRS.CFProjection("crs_wkt" => wkt_str)
            projjson = convert(GFT.ProjJSON, cf)
            cf2 = convert(CFCRS.CFProjection, projjson)

            @test cf2["grid_mapping_name"] == "albers_conical_equal_area"
            @test cf2["standard_parallel"] == (29.5, 45.5)
            @test cf2["latitude_of_projection_origin"] == 23.0
            @test cf2["longitude_of_central_meridian"] == -96.0
            @test cf2["false_easting"] == 0.0
            @test cf2["false_northing"] == 0.0
        end

        @testset "LAEA Europe (lambert_azimuthal_equal_area)" begin
            crs = Proj.CRS("EPSG:3035")
            wkt_str = GFT.val(GFT.WellKnownText(crs))
            cf = CFCRS.CFProjection("crs_wkt" => wkt_str)
            projjson = convert(GFT.ProjJSON, cf)
            cf2 = convert(CFCRS.CFProjection, projjson)

            @test cf2["grid_mapping_name"] == "lambert_azimuthal_equal_area"
            @test cf2["latitude_of_projection_origin"] == 52.0
            @test cf2["longitude_of_projection_origin"] == 10.0
            @test cf2["false_easting"] == 4321000.0
            @test cf2["false_northing"] == 3210000.0
        end

        @testset "WGS 84 (latitude_longitude)" begin
            cf = CFCRS.CFProjection(
                "grid_mapping_name" => "latitude_longitude",
                "geographic_crs_name" => "WGS 84",
            )
            wkt = convert(GFT.WellKnownText, cf)
            cf2 = convert(CFCRS.CFProjection, wkt)

            @test cf2["grid_mapping_name"] == "latitude_longitude"
        end
    end
end
