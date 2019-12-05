makedocs(
    modules = [MooreAg],
    sitename = "Moore Agriculture Documentation",
    pages = [
        "Home" => "index.md",
        "Reference" => "reference.md"
    ],
    format = Documenter.HTML(prettyurls = get(ENV, "JULIA_NO_LOCAL_PRETTY_URLS", nothing) === nothing)
)