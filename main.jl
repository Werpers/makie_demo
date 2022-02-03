using GLMakie

function main(;animate=true)
    # Setup grid
    N = 100
    xlim = (0,1)
    x, Δx = periodic_grid(xlim,N)
    Δt = Δx

    # Initial conditions
    v₀  = map(x->sin(2π*x), x)
    vₜ₀ = map(x->0,         x)

    # First step with euler forward
    v₁ = v₀ + Δt * vₜ₀

    # Simulation state
    vₙ₋₁ = copy(v₀)
    vₙ   = copy(v₁)
    w    = similar(v₀) # Extra buffer needed to perform a step

    # Observables for plotting
    v = Observable(vₙ)
    vₜ = Observable(copy(vₙ))


    """
        step!()

    Take simulation step and update plot state.
    """
    function step!()
        leap_frog!(w, vₙ, vₙ₋₁, (v,i)->D2(v,i,Δx), Δt)

        # Calculate vₜ for visualization
        map!((vₙ₊₁,vₙ₋₁)-> (vₙ₊₁-vₙ₋₁)/2Δt, vₜ.val, w, vₙ₋₁) # vₜ = (vₙ₊₁-vₙ₋₁)/2Δt = (w-vₙ₋₁)/2Δt

        vₙ, vₙ₋₁, w = w, vₙ, vₙ₋₁

        # Notify observables to cause an update of the plot
        v[] = vₙ # Automatically notifies `v`.
        notify(vₜ) # Needed because changing vₜ.val bypasses the automatic notification of `vₜ`.
    end

    # Setup figure
    fig = Figure()
    ax = Axis(fig[1,1])

    arrows!(ax, x, v, 0, @lift 0.1*$vₜ;
        label="vₜ",
    )

    scatter!(ax, x, v;
        label="v",
    )

    # Since `arrows!` and `scatter!` are called with Observables `v` and `vₜ`
    # the plots will automatically update whenever they are changed, e.g by
    # the `step!` function above.

    if animate
        display(fig)

        while true
            step!()
            sleep(1/24)
        end
    else
        record(frame->step!(), fig, "movie.mp4", 1:(5*24))
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

function prompt(msg = "Press [enter] to continue")
    print(msg, " ")
    return readline()
end
