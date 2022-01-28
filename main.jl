using GLMakie

function periodic_grid(xlim, N)
    Δx = (xlim[2]-xlim[1])/(N+1)
    return range(0, step=Δx, length=N), Δx
end

function leap_frog!(vₙ₊₁, vₙ, vₙ₋₁, f, k)
    for i ∈ eachindex(vₙ)
        vₙ₊₁[i] = 2vₙ[i] - vₙ₋₁[i] + k^2*f(vₙ, i)
    end
end

function D2(v, i, h)
    vᵢ₋₁ = v[mod1(i-1,N)]
    vᵢ   = v[i]
    vᵢ₊₁ = v[mod1(i+1,N)]

    return (vᵢ₋₁ - 2vᵢ + vᵢ₊₁)/h^2
end

N = 100
xlim = (0,1)
x, Δx = periodic_grid(xlim,N)

v₀  = map(x->sin(x/2π), x)
vₜ₀ = map(x->0,         x)

k = h/2

# First step with euler forward
v₁ = v₀ + k * vₜ₀


function step!(vₙ, vₙ₋₁, w)
    leap_frog!(w, vₙ, vₙ₋₁, (v,i)->D2(v,i,h), k)
    vₙ, vₙ₋₁, w = w, vₙ, vₙ₋₁
end
