using GLMakie

function main()
    N = 100
    xlim = (0,1)
    x, Δx = periodic_grid(xlim,N)

    v₀  = map(x->sin(x/2π), x)
    vₜ₀ = map(x->0,         x)

    Δt = Δx/2

    # First step with euler forward
    v₁ = v₀ + k * vₜ₀
end



function periodic_grid(xlim, N)
    Δx = (xlim[2]-xlim[1])/(N+1)
    return range(0, step=Δx, length=N), Δx
end

function leap_frog!(vₙ₊₁, vₙ, vₙ₋₁, f, Δt)
    for i ∈ eachindex(vₙ)
        vₙ₊₁[i] = 2vₙ[i] - vₙ₋₁[i] + Δt^2*f(vₙ, i)
    end
end

function D2(v, i, Δx)
    if i == 1
        vᵢ₋₁ = v[end]
    elseif i == length(v)
        vᵢ₊₁ = v[1]
    end

    return (vᵢ₋₁ - 2v[i] + vᵢ₊₁)/Δx^2
end

function step!(vₙ, vₙ₋₁, w)
    leap_frog!(w, vₙ, vₙ₋₁, (v,i)->D2(v,i,Δx), Δt)
    vₙ, vₙ₋₁, w = w, vₙ, vₙ₋₁
end

function prompt(msg = "Press [enter] to continue")
    print(msg, " ")
    return readline()
end
