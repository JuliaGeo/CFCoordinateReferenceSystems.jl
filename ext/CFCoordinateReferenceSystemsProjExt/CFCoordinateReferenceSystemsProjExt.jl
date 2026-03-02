module CFCoordinateReferenceSystemsProjExt

# This extension provides conversion between CF grid mappings and other CRS formats.
#
# The conversion logic and parameter mappings are derived from:
# - pyproj (https://github.com/pyproj4/pyproj) - MIT License
#   Specifically pyproj/crs/cf1x8.py for CF-1.8 convention support
# - EPSG Geodetic Parameter Registry (https://epsg.org/)
#   EPSG codes identify projection methods and parameters
# - CF Conventions (http://cfconventions.org/cf-conventions/cf-conventions.html)
#   Appendix F: Grid Mappings defines the CF parameter names

import Proj
import JSON3
import GeoFormatTypes as GFT

using OrderedCollections: LittleDict
using CFCoordinateReferenceSystems: CFProjection, InnerDict

include("convert.jl")
include("conversions.jl")
include("cf.jl")
include("parameters.jl")
include("mappings.jl")
include("utils.jl")

end