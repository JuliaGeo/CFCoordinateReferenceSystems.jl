using Documenter
using CFCoordinateReferenceSystems

# Load extension for docstrings
using Proj

makedocs(;
    modules=[CFCoordinateReferenceSystems],
    authors="Rafael Schouten, Anshul Singhvi, and contributors",
    sitename="CFCoordinateReferenceSystems.jl",
    format=Documenter.HTML(;
        canonical="https://JuliaGeo.github.io/CFCoordinateReferenceSystems.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API Reference" => "api.md",
    ],
    warnonly=[:missing_docs],
)

deploydocs(;
    repo="github.com/JuliaGeo/CFCoordinateReferenceSystems.jl",
    devbranch="main",
)
