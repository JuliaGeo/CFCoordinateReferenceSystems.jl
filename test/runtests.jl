using CFCoordinateReferenceSystems
using Test
using Aqua
using JET
using GeoFormatTypes
using Proj

import CFCoordinateReferenceSystems as CFCRS
import GeoFormatTypes as GFT

@testset "CFCoordinateReferenceSystems.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(CFCoordinateReferenceSystems; stale_deps=false)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(CFCoordinateReferenceSystems; target_defined_modules=true)
    end
    
    @testset "latitude_longitude" begin
        cfcrs = CFCRS.CFProjection(
            "grid_mapping_name" => "latitude_longitude",
            "semi_major_axis" => 6371000.0,
            "inverse_flattening" => 0,
        )
        @test convert(ProjString, cfcrs) == 
            ProjString("+proj=longlat +datum=WGS84 +no_defs +type=crs")
    end

    @testset "transverse_mercator" begin
        british = CFCRS.CFProjection(
            "grid_mapping_name" => "transverse_mercator",
            "semi_major_axis" => 6377563.396,
            "inverse_flattening" => 299.3249646,
            "longitude_of_prime_meridian" => 0.0,
            "latitude_of_projection_origin" => 49.0,
            "longitude_of_central_meridian" => -2.0,
            "scale_factor_at_central_meridian" => 0.9996012717,
            "false_easting" => 400000.0,
            "false_northing" => -100000.0,
            "unit" => "metre",
        )
        @test convert(ProjString, british) ==
            ProjString("+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000")
    end
end