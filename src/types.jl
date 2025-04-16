import GeoFormatTypes as GFT

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
    ::Type{<:CoordinateOperations.ProjJSONCoordinateOperation}, cf::CFProjection
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
function Base.convert(T::Type{<:GFT.GeoFormat}, cf::CFProjection)
    return convert(T, convert(CoordinateOperations.ProjJSONCoordinateOperation, cf))
end
function Base.convert(::Type{String}, cf::CFProjection)
    return convert(String, convert(CoordinateOperations.ProjJSONCoordinateOperation, cf))
end # this is the only usable form

GFT.ProjJSON(cf::CFProjection) = convert(GFT.ProjJSON, cf)