module CFCoordinateReferenceSystems

import GeoFormatTypes as GFT

using OrderedCollections: LittleDict

export CFProjection

# We only need the wrapper type for normal use
# the rest is loaded when Proj is loaded
include("types.jl")

end
