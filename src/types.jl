import GeoFormatTypes as GFT

# Dictionary to map grid mapping names to their conversion functions
const GRID_MAPPING_NAME_MAP = Dict{String,Function}(
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

const GEOGRAPHIC_GRID_MAPPING_NAME_MAP = Dict{String,Function}(
    "rotated_latitude_longitude" => CF1x8._rotated_latitude_longitude
)

struct CFProjection{T<:AbstractDict{<:AbstractString,<:Any}} <: GFT.CoordinateReferenceSystemFormat
    params::T
end

Base.getindex(cf::CFProjection, key::String) = cf.params[key]
Base.setindex!(cf::CFProjection, value, key::String) = cf.params[key] = value

function Base.show(io::IO, cf::CFProjection)
    print(io, "CFProjection(")
    print(io, cf.params)
    print(io, ")")
end
function Base.show(io::IO, ::MIME"text/plain", cf::CFProjection)
    println(io, "CFProjection with parameters:")
    show(io, MIME"text/plain"(), cf.params)
end

# convert is a multi-step process. 
Base.@propagate_inbounds function Base.convert(
    ::Type{<:ProjJSONDict}, cf::CFProjection
)
    @boundscheck if !haskey(cf.params, "grid_mapping_name")
        throw(ArgumentError("grid_mapping_name is required in `CFProjection` but was not found. \n\n\n Found keys $(keys(cf.params))."))
    end

    grid_mapping_name = cf.params["grid_mapping_name"]
    grid_mapping_function = if haskey(GRID_MAPPING_NAME_MAP, grid_mapping_function)
        GRID_MAPPING_NAME_MAP[grid_mapping_name]
    elseif haskey(GEOGRAPHIC_GRID_MAPPING_NAME_MAP, grid_mapping_name)
        GEOGRAPHIC_GRID_MAPPING_NAME_MAP[grid_mapping_name]
    else
        throw(ArgumentError("Unsupported grid mapping name: $(grid_mapping_name)"))
    end
    return grid_mapping_function(cf.params) 
end
# convert to other GeoFormat or String via ProjJSONDict
Base.convert(T::Type{<:GFT.GeoFormat}, cf::CFProjection) =
    convert(T, convert(ProjJSONDict, cf))
Base.convert(::Type{String}, cf::CFProjection) =
    convert(String, convert(ProjJSONDict, cf))

ProjJSONDict(cf::CFProjection) = convert(ProjJSONDict, cf)
GFT.ProjJSON(cf::CFProjection) = convert(GFT.ProjJSON, cf)