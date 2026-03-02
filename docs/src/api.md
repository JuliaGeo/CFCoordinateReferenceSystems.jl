# API Reference

## Types

```@docs
CFProjection
```

## Conversion Methods

When Proj.jl is loaded, the following conversion methods become available:

### CF to Other Formats

```julia
convert(::Type{ProjJSON}, cf::CFProjection) -> ProjJSON
convert(::Type{WellKnownText}, cf::CFProjection) -> WellKnownText
convert(::Type{ProjString}, cf::CFProjection) -> ProjString
```

Convert a `CFProjection` to various CRS formats. The conversion first produces ProjJSON, then uses Proj.jl to convert to other formats as needed.

### Other Formats to CF

```julia
convert(::Type{CFProjection}, gf::GeoFormat) -> CFProjection
```

Convert from other CRS formats (WKT, ProjJSON, ProjString, etc.) to a CF grid mapping.

## Index

```@index
```
