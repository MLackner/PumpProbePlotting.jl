module PumpProbePlotting

using PyPlot
using PumpProbeModels
using PumpProbeFitting

export plot

"""
Plots the fit result
"""
function PyPlot.plot(r::PumpProbeFit, m::PumpProbeModel, dls, wns)
    x = r.m.wavenumbers
    y = r.m.delaytimes
    zfit = model2data(r.m)
    zdata = fit2data(r)
    resid = reshape(r.f.resid, size(zdata))

    pump = r.m.pumpfunction.(r.m.pumptimes)
    t0 = r.m.parameters.t0

    plotmodel = false
    local zmodel
    if m !== r.m
        zmodel = model2data(m)
        plotmodel = true
    end

    # Get extrema of the data
    vmin = min(zdata..., zfit...)
    vmax = max(zdata..., zfit...)
    rmax = maximum(abs.(resid))     # Limits for residual plot

    # Selected delay times and wavenumbers of slices
    dlt = y[dls]
    wn  = x[wns]

    fh = figure(figsize=(12,12))

    subplot(331)
    pcolormesh(x,y,z, vmin=vmin, vmax=vmax)
    colorbar()
    title("Input Data")

    subplot(334)
    pcolormesh(x,y,zfit, vmin=vmin, vmax=vmax)
    colorbar()
    title("Fit")
    hlines(dlt, xlim()..., alpha=0.4)
    vlines(wn , ylim()..., alpha=0.4)

    subplot(337)
    title("Residuals")
    pcolormesh(x,y,resid, cmap=ColorMap("RdBu"), vmin=-rmax, vmax=rmax)
    colorbar()

    ND = length(dls)
    for (i,k) in dls |> enumerate
        subplot(ND,3,3i-1)
        plot(x, z[k,:], ".", color="k", alpha=0.3)
        plot(x, zfit[k,:], "-", color="k", label="$(round(dlt[i], digits=1)) ps")
        plot(x, zmodel[k,:], "-", color="k", alpha=0.3)
        legend()
        # Also plot
        # Remove Ticks
        i != length(dls) && gca().set_xticklabels([])
    end

    NW = length(wns)
    for (i,k) in wns |> enumerate
        subplot(NW+1,3,3i)
        plot(y, z[:,k], ".", color="k", alpha=0.3)
        plot(y, zfit[:,k], "-", color="k", label="$(round(wn[i], digits=1)) 1/cm")
        plot(y, zmodel[:,k], "-", color="k", alpha=0.3)
        vlines(t0, ylim()..., linestyle="--", alpha=0.3)
        legend()
        # Remove Ticks
        i != length(wns) && gca().set_xticklabels([])
    end


    # Also plot pumpfunction
    xlims = xlim()
    subplot(NW+1,3,3*(NW+1))
    plot(r.m.pumptimes .+ t0, pump, ".-", color="k", alpha=0.2, label="Pump Pulse")
    xlim(xlims...)
    legend()

    plt.tight_layout()
    fh
end

end
