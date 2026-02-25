const WGS84DATUM = InnerDict(
    "type" => "GeodeticReferenceFrame",
    "name" => "World Geodetic System 1984",
    "ellipsoid" => InnerDict(
        "name" => "WGS 84",
        "semi_major_axis" => 6378137,
        "inverse_flattening" => 298.257223563,
    )
)

function _geographic_crs(;
    name = "WSG 84",
    datum = WGS84DATUM,
)
    geographic_crs_dict = InnerDict(
        SCHEMA,
        "type" => "GeographicCRS",
        "name" => name,
        "coordinate_system" => InnerDict(
            "type" => "CoordinateSystem",
            "subtype" => "ellipsoidal",
            "axis" => DEFAULT_ELLIPSOIDAL_2D_AXIS_MAP,
        ),
    )
    isempty(datum) && return geographic_crs_dict

    if datum["type"] == "DatumEnsemble"
        geographic_crs_dict["datum_ensemble"] = datum
    else
        geographic_crs_dict["datum"] = datum
    end
    return geographic_crs_dict
end

function _custom_datum(;
    name::String = "undefined",
    ellipsoid = "WGS 84",
    prime_meridian = "Greenwich",
)
    return InnerDict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "GeodeticReferenceFrame",
        "name" => name,
        "ellipsoid" => ellipsoid,
        "prime_meridian" => prime_meridian isa String ? _prime_meridian(; name=prime_meridian) : prime_meridian
    )
end

function _prime_meridian(;
    name = nothing,
    longitude = nothing, 
)
    dict = InnerDict(
        "\$schema" => "https://proj.org/schemas/v0.2/projjson.schema.json",
        "type" => "PrimeMeridian",
    )
    if isnothing(longitude)
        if isnothing(name)
            throw(ArgumentError("No name or longitude for prime meridian"))
        else
            if haskey(PRIME_MERIDIAN_LONGITUDE, name)
                dict["longitude"] = PRIME_MERIDIAN_LONGITUDE[name]
            else
                throw(ArgumentError("Unrecognized prime meridian name: $name"))
            end
        end
    else
        dict["longitude"] = longitude
    end
    if !isnothing(name)
        dict["name"] = name
    end
    return dict
end

function _get_standard_parallels(standard_parallel::String)
    val_split = split(input_str, ",")
    if length(val_split) > 1
        return ntuple(2) do i
            parse(Float64, strip(val_split[i]))
        end
    else
        return parse(Float64, strip(standard_parallel))
    end
end
function _get_standard_parallels(standard_parallels::Vector{<:Real})
    p1, p2 = standard_parallels
    return Float64(p1), Float64(p2)
end
function _get_standard_parallels(standard_parallel::Real)
    return Float64(standard_parallel), 0.0
end

# Helper function to convert operation parameters to dictionary
function _to_dict(operation)
    param_dict = InnerDict()
    for param in operation.params
        param_dict[lowercase(replace(param.name, " " => "_"))] = param.value
    end
    return param_dict
end
