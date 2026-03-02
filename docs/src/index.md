# CFCoordinateReferenceSystems.jl

A Julia library to convert between CF (Climate and Forecast) convention grid mappings and other coordinate reference system formats.

## Overview

The CF conventions define a standard way to describe coordinate reference systems in NetCDF files using grid mapping attributes. This package provides bidirectional conversion between CF grid mappings and other CRS formats (ProjJSON, WKT, ProjString, etc.) via [Proj.jl](https://github.com/JuliaGeo/Proj.jl).

## Installation

```julia
using Pkg
Pkg.add("CFCoordinateReferenceSystems")
```

## Quick Start

### CF to Other Formats

Convert CF grid mapping attributes from a NetCDF file to other CRS formats:

```julia
using CFCoordinateReferenceSystems
using GeoFormatTypes
using Proj

# Create a CFProjection from grid mapping parameters
cf = CFProjection(
    "grid_mapping_name" => "transverse_mercator",
    "latitude_of_projection_origin" => 0.0,
    "longitude_of_central_meridian" => 15.0,
    "scale_factor_at_central_meridian" => 0.9996,
    "false_easting" => 500000.0,
    "false_northing" => 0.0,
)

# Convert to ProjJSON
projjson = convert(ProjJSON, cf)

# Convert to WKT
wkt = convert(WellKnownText, cf)

# Convert to ProjString
projstring = convert(ProjString, cf)
```

### Other Formats to CF

Convert from other CRS formats back to CF grid mappings:

```julia
using CFCoordinateReferenceSystems
using GeoFormatTypes
using Proj

# From an EPSG code via Proj
crs = Proj.CRS("EPSG:32615")
cf = convert(CFProjection, WellKnownText(crs))

# Access the grid mapping parameters
cf["grid_mapping_name"]  # "transverse_mercator"
```

### With NCDatasets

Read grid mapping from a NetCDF file:

```julia
using CFCoordinateReferenceSystems
using NCDatasets
using GeoFormatTypes

ds = NCDataset("file.nc")
# Get the grid mapping variable (often named "crs" or similar)
attrs = NCDatasets.attribs(ds["crs"])
cf = CFProjection(attrs)
projjson = convert(ProjJSON, cf)
```

## Supported Projections

The following CF grid mapping names are supported:

| CF Grid Mapping Name | Description |
|---------------------|-------------|
| `latitude_longitude` | Geographic CRS |
| `transverse_mercator` | Transverse Mercator |
| `albers_conical_equal_area` | Albers Equal Area |
| `azimuthal_equidistant` | Azimuthal Equidistant |
| `geostationary` | Geostationary Satellite |
| `lambert_azimuthal_equal_area` | Lambert Azimuthal Equal Area |
| `lambert_conformal_conic` | Lambert Conformal Conic (1SP or 2SP) |
| `lambert_cylindrical_equal_area` | Lambert Cylindrical Equal Area |
| `mercator` | Mercator (variant A or B) |
| `oblique_mercator` | Oblique Mercator |
| `orthographic` | Orthographic |
| `polar_stereographic` | Polar Stereographic (variant A or B) |
| `sinusoidal` | Sinusoidal |
| `stereographic` | Stereographic |
| `vertical_perspective` | Vertical Perspective |
| `rotated_latitude_longitude` | Rotated Pole |

## See Also

- [CF Conventions - Grid Mappings](http://cfconventions.org/cf-conventions/cf-conventions.html#appendix-grid-mappings)
- [Proj.jl](https://github.com/JuliaGeo/Proj.jl)
- [GeoFormatTypes.jl](https://github.com/JuliaGeo/GeoFormatTypes.jl)
