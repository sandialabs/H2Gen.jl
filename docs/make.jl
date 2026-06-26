import Pkg
Pkg.activate(@__DIR__)
Pkg.develop(Pkg.PackageSpec(path = joinpath(@__DIR__, "..")))
Pkg.instantiate()

using Documenter
using H2Gen

DocMeta.setdocmeta!(
    H2Gen,
    :DocTestSetup,
    :(using H2Gen);
    recursive = true,
)

makedocs(
    sitename = "H2Gen",
    modules = [H2Gen],
    checkdocs = :none,
    remotes = nothing,
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        edit_link = "main",
        repolink = "https://github.com/EnergyModelsX/H2gen.jl",
        assets = String[],
        ansicolor = true,
    ),
    pages = [
        "Home" => "index.md",
        "Quick Start" => "quickstart.md",
        "Theory" => "theory.md",
        "API" => "api.md",
    ],
)

if get(ENV, "CI", "false") == "true"
    deploydocs(;
        repo = "github.com/EnergyModelsX/H2gen.jl.git",
    )
end
