module CFCoordinateReferenceSystems

import GeoFormatTypes as GFT

include("coordinate_operations.jl")
include("cf1x8.jl")

import .CoordinateOperations
import .CF1x8

include("types.jl")

end
