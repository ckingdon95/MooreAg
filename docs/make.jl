makedocs(
    modules=[MimiMooreEtAlAgricultureImpacts],
    sitename="Moore Agriculture Documentation",
    pages=[
        "Home" => "index.md",
        "Reference" => "reference.md"
    ],
    format=Documenter.HTML(prettyurls=get(ENV, "JULIA_NO_LOCAL_PRETTY_URLS", nothing) === nothing)
)

deploydocs(
    repo="https://github.com/ckingdon95/MimiMooreEtAlAgricultureImpacts.jl.git",
)
