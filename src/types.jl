const InnerDict = LittleDict{String,Any}

"""
    CFProjection{T<:AbstractDict} <: GeoFormatTypes.CoordinateReferenceSystemFormat

A wrapper for CF (Climate and Forecast) convention grid mapping attributes.

CF grid mappings define coordinate reference systems using a dictionary of parameters
as specified in the CF-1.8 conventions. This type wraps those parameters and provides
conversion to other CRS formats via the Proj.jl extension.

# Constructors

    CFProjection(params::AbstractDict)
    CFProjection(pairs...)

# Examples

```julia
# From a dictionary
cf = CFProjection(Dict(
    "grid_mapping_name" => "transverse_mercator",
    "latitude_of_projection_origin" => 0.0,
    "longitude_of_central_meridian" => 15.0,
    "scale_factor_at_central_meridian" => 0.9996,
    "false_easting" => 500000.0,
    "false_northing" => 0.0,
))

# From key-value pairs
cf = CFProjection(
    "grid_mapping_name" => "lambert_conformal_conic",
    "standard_parallel" => [25.0, 30.0],
    "longitude_of_central_meridian" => 265.0,
)

# Convert to other formats (requires Proj.jl)
using GeoFormatTypes, Proj
projjson = convert(ProjJSON, cf)
wkt = convert(WellKnownText, cf)
```

See also: [CF Conventions Grid Mappings](http://cfconventions.org/cf-conventions/cf-conventions.html#appendix-grid-mappings)
"""
struct CFProjection{T<:AbstractDict{<:AbstractString,<:Any}} <: GFT.CoordinateReferenceSystemFormat
    params::T
end
CFProjection(params::T) where T<:AbstractDict = CFProjection{T}(params)
CFProjection(params...) = CFProjection(InnerDict(params...))

Base.getindex(cf::CFProjection, key::String) = Base.parent(cf)[key]
Base.setindex!(cf::CFProjection, value, key::String) = Base.parent(cf)[key] = value
Base.haskey(cf::CFProjection, key) = haskey(Base.parent(cf), key)
Base.parent(cf::CFProjection) = cf.params
Base.get(cf::CFProjection, args...) = Base.get(Base.parent(cf), args...)

function Base.show(io::IO, cf::CFProjection)
    print(io, "CFProjection(")
    print(io, parent(cf))
    print(io, ")")
end
function Base.show(io::IO, mime::MIME"text/plain", cf::CFProjection)
    println(io, "CFProjection(")
    show(io, mime, parent(cf))
    println(io, ")")
end