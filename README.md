# CFCoordinateReferenceSystems

[![Build Status](https://github.com/JuliaGeo/CFCoordinateReferenceSystems.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGeo/CFCoordinateReferenceSystems.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaGeo/CFCoordinateReferenceSystems.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaGeo/CFCoordinateReferenceSystems.jl)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaGeo.github.io/CFCoordinateReferenceSystems.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaGeo.github.io/CFCoordinateReferenceSystems.jl/dev/)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A library to convert between CF (Climate and Forecast) convention grid mappings and other coordinate reference system formats via [Proj.jl](https://github.com/JuliaGeo/Proj.jl).

## Features

- Convert CF grid mapping attributes to ProjJSON, WKT, ProjString, and other CRS formats
- Convert from other CRS formats back to CF grid mappings
- Supports 15+ projection types including Transverse Mercator, Lambert Conformal Conic, Polar Stereographic, and more

## Quick start

Convert CF grid mapping attributes from a NetCDF file to ProjJSON:
```julia
using CFCoordinateReferenceSystems, NCDatasets, GeoFormatTypes

# Read grid mapping attributes from NetCDF
attrs = NCDatasets.attribs(dataset["crs"])
cf = CFProjection(attrs)

# Convert to ProjJSON
projjson = convert(ProjJSON, cf)

# Or convert to other formats via Proj.jl
wkt = convert(WellKnownText, cf)
projstring = convert(ProjString, cf)
```

Convert from other CRS formats to CF:
```julia
using Proj

# From an existing CRS
crs = Proj.CRS("EPSG:32615")
cf = convert(CFProjection, WellKnownText(crs))
```