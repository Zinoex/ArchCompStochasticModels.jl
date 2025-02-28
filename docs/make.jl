using ArchCompStochasticModels
using Documenter

DocMeta.setdocmeta!(ArchCompStochasticModels, :DocTestSetup, :(using ArchCompStochasticModels); recursive=true)

makedocs(;
    modules=[ArchCompStochasticModels],
    authors="Frederik Baymler Mathiesen <frederik@baymler.com> and contributors",
    sitename="ArchCompStochasticModels.jl",
    format=Documenter.HTML(;
        canonical="https://Zinoex.github.io/ArchCompStochasticModels.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Zinoex/ArchCompStochasticModels.jl",
    devbranch="main",
)
