module CFCoordinateReferenceSystems

import GeoFormatTypes as GFT

include("coordinate_operations.jl")
include("cf1x8.jl")

import .CoordinateOperations
import .CF1x8

# Dictionary to map grid mapping names to their conversion functions
const GRID_MAPPING_NAME_MAP = Dict{String, Function}(
    "albers_conical_equal_area" => CF1x8._albers_conical_equal_area,
    "azimuthal_equidistant" => CF1x8._azimuthal_equidistant,
    "geostationary" => CF1x8._geostationary,
    "lambert_azimuthal_equal_area" => CF1x8._lambert_azimuthal_equal_area,
    "lambert_conformal_conic" => CF1x8._lambert_conformal_conic,
    "lambert_cylindrical_equal_area" => CF1x8._lambert_cylindrical_equal_area,
    "mercator" => CF1x8._mercator,
    "oblique_mercator" => CF1x8._oblique_mercator,
    "orthographic" => CF1x8._orthographic,
    "polar_stereographic" => CF1x8._polar_stereographic,
    "sinusoidal" => CF1x8._sinusoidal,
    "stereographic" => CF1x8._stereographic,
    "transverse_mercator" => CF1x8._transverse_mercator,
    "vertical_perspective" => CF1x8._vertical_perspective,
)

const GEOGRAPHIC_GRID_MAPPING_NAME_MAP = Dict{String, Function}(
    "rotated_latitude_longitude" => CF1x8._rotated_latitude_longitude
)

include("types.jl")


end
