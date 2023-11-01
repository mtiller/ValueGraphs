using Documenter, ValueGraphs

push!(LOAD_PATH,"../src/")

makedocs(
    modules=[ValueGraphs], 
    warnonly = Documenter.except(),
    sitename="ValueGraphs Documentation")