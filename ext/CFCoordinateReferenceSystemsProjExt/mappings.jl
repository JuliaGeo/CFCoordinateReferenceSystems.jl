# Dictionary to map grid mapping names to their conversion functions
const GRID_MAPPING_NAME_MAP = Dict{String,Function}(
    "albers_conical_equal_area" => _albers_conical_equal_area,
    "azimuthal_equidistant" => _azimuthal_equidistant,
    "geostationary" => _geostationary,
    "lambert_azimuthal_equal_area" => _lambert_azimuthal_equal_area,
    "lambert_conformal_conic" => _lambert_conformal_conic,
    "lambert_cylindrical_equal_area" => _lambert_cylindrical_equal_area,
    "mercator" => _mercator,
    "oblique_mercator" => _oblique_mercator,
    "orthographic" => _orthographic,
    "polar_stereographic" => _polar_stereographic,
    "sinusoidal" => _sinusoidal,
    "stereographic" => _stereographic,
    "transverse_mercator" => _transverse_mercator,
    "vertical_perspective" => _vertical_perspective,
)

const GEOGRAPHIC_GRID_MAPPING_NAME_MAP = Dict{String,Function}(
    "rotated_latitude_longitude" => _rotated_latitude_longitude
)

const PROJJSON_METHOD_NAME_MAP = Dict{String,Function}(
    "Albers Equal Area" => _albers_conical_equal_area__to_cf,
    "Modified Azimuthal Equidistant" => _azimuthal_equidistant__to_cf,
    "Satellite height" => _geostationary__to_cf,
    "Satellite height (sweep_x)" => _geostationary__to_cf,
    "Satellite height (sweep_y)" => _geostationary__to_cf,
    "Lambert Azimuthal Equal Area" => _lambert_azimuthal_equal_area__to_cf,
    "Lambert Conformal Conic (1SP)" => _lambert_conformal_conic__to_cf,
    "Lambert Conformal Conic (2SP)" => _lambert_conformal_conic__to_cf,
    "Lambert Cylindrical Equal Area" => _lambert_cylindrical_equal_area__to_cf,
    "Mercator (variant A)" => _mercator__to_cf,
    "Mercator (variant B)" => _mercator__to_cf,
    "Hotine Oblique Mercator (variant B)" => _oblique_mercator__to_cf,
    "Orthographic" => _orthographic__to_cf,
    "Polar Stereographic (variant A)" => _polar_stereographic__to_cf,
    "Polar Stereographic (variant B)" => _polar_stereographic__to_cf,
    "Sinusoidal" => _sinusoidal__to_cf,
    "Stereographic" => _stereographic__to_cf,
    "Transverse Mercator" => _transverse_mercator__to_cf,
    "Vertical Perspective" => _vertical_perspective__to_cf,
)

# TODO: Geographic to CF

# Copied from PROJ so we dont have to call it for something so trivial
const PRIME_MERIDIAN_LONGITUDE = LittleDict(
    "Copenhagen" => 12.34399,
    "Greenwich" => 0.0,
    "Lisbon" => -9.0754862,
    "Paris" => 2.5969213,
    "Bogota" => -74.04513,
    "Madrid" => -3.411455,
    "Rome" => 12.27084,
    "Bern" => 7.26225,
    "Jakarta" => 106.482779,
    "Ferro" => -17.4,
    "Brussels" => 4.220471,
    "Stockholm" => 18.03298,
    "Athens" => 23.4258815,
    "Oslo" => 10.43225,
    "Paris RGS" => 2.201395,
)

const UNIT_DEGREE = "degree" 

const DEFAULT_ELLIPSOIDAL_2D_AXIS_MAP = [
    LittleDict(
        "name" => "Longitude",
        "abbreviation" => "lon",
        "direction" => "east",
        "unit" => UNIT_DEGREE,
    ),
    LittleDict(
        "name" => "Latitude",
        "abbreviation" => "lat",
        "direction" => "north",
        "unit" => UNIT_DEGREE,
    ),
]

