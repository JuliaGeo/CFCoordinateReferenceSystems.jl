# CFCoordinateReferenceSystems

[![Build Status](https://github.com/rafaqz/CFCoordinateReferenceSystems.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/rafaqz/CFCoordinateReferenceSystems.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/rafaqz/CFCoordinateReferenceSystems.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/rafaqz/CFCoordinateReferenceSystems.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A library to parse CF coordinate reference systems (as `Dict`s) to ProjJSON conversions, and utilities to take 
that to other coordinate systems via ArchGDAL.jl (or Proj.jl in future).

## Quick start

Let's say you have an `NCDataset` and your variable's `grid_mapping_name` is `mapping`.  Then,
```julia
NCDatasets.attr(dataset["mapping"]) |> CFProjection |> ProjJSON
```
will get you ProjJSON, from where you can convert to anything.

Going the other way is not yet supported but will be soon.  All the functionality is in place - we just 
need the ability to match arbitrary CRS'es with the CF compatible ones.