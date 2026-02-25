const InnerDict = LittleDict{String,Any}
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