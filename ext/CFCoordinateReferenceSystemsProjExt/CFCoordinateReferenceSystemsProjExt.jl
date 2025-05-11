module CFCoordinateReferenceSystemsProjExt

import Proj
import JSON3
import GeoFormatTypes as GFT

using OrderedCollections: OrderedDict
using CFCoordinateReferenceSystems: CFProjection, InnerDict

# This extension does most of the work

include("convert.jl")
include("conversions.jl")
include("cf.jl")
include("parameters.jl")
include("mappings.jl")
include("utils.jl")

end