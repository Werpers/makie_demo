# Makie demo
A simple Makie animation demo. Solves the periodic one dimensional wave equation and animates the solution in real time. To run first activate the Julia environment,
```julia
pkg> activate makie_example
```
then include `main.jl` (possibly using Revise.jl's `includet`)
```julia
julia> include("main.jl")
```
and finally call the main function
```
julia> main()
```

`main` takes a key word argument `animate` which defaults to `true`. If set to `false` a movie file will be saved instead of showing a live animation.
