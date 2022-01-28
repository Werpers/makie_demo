using GLMakie

function main()
    N = 100
    xlim = (0,1)
    x, Δx = periodic_grid(xlim,N)

    v₀  = map(x->sin(2π*x), x)
    vₜ₀ = map(x->0,         x)

    Δt = Δx

    # First step with euler forward
    v₁ = v₀ + Δt * vₜ₀


    # Simulation state
    vₙ₋₁ = copy(v₀)
    vₙ   = copy(v₁)
    w    = similar(v₀) # Extra buffer needed to perform a step

    # Observables for plotting
    v = Observable(vₙ)
    vₜ = Observable(copy(vₙ))

    "Take simulation step and update plot state"
    function step!()
        leap_frog!(w, vₙ, vₙ₋₁, (v,i)->D2(v,i,Δx), Δt)
        map!((vₙ₊₁,vₙ₋₁)-> (vₙ₊₁-vₙ₋₁)/2Δt, vₜ.val, w, vₙ₋₁)

        vₙ, vₙ₋₁, w = w, vₙ, vₙ₋₁

        v[] = vₙ
        notify(vₜ)
    end


    # Setup figure
    fig = Figure()

    ax = Axis(fig[1,1])

    scatter!(ax, x, v;
        label="v",
    )
    scatter!(ax, x, vₜ;
        label="vₜ",
    )

    display(fig)

    while true
        step!()
        sleep(1/24)
    end
end

function periodic_grid(xlim, N)
    Δx = (xlim[2]-xlim[1])/N
    return range(0, step=Δx, length=N), Δx
end

function leap_frog!(vₙ₊₁, vₙ, vₙ₋₁, f, Δt)
    for i ∈ eachindex(vₙ)
        vₙ₊₁[i] = 2vₙ[i] - vₙ₋₁[i] + Δt^2*f(vₙ, i)
    end
end

function D2(v, i, Δx)
    if i != 1
        vᵢ₋₁ = v[i-1]
    else
        vᵢ₋₁ = v[end]
    end

    if i != length(v)
        vᵢ₊₁ = v[i+1]
    else
        vᵢ₊₁ = v[1]
    end

    return (vᵢ₋₁ - 2v[i] + vᵢ₊₁)/Δx^2
end

function D1(v, i, Δx)
    if i != 1
        vᵢ₋₁ = v[i-1]
    else
        vᵢ₋₁ = v[end]
    end

    if i != length(v)
        vᵢ₊₁ = v[i+1]
    else
        vᵢ₊₁ = v[1]
    end

    return (vᵢ₊₁ - vᵢ₋₁)/2Δx
end

function D1!(vₓ, v, Δx)
    for i ∈ eachindex(v)
        vₓ[i] = D1(v,i,Δx)
    end
end

function prompt(msg = "Press [enter] to continue")
    print(msg, " ")
    return readline()
end
