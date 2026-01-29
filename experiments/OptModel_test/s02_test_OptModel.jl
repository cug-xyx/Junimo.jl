using Junimo
using CairoMakie
using CSV, DataFrames

df = CSV.read("data/BE-Vie_8day", DataFrame)

begin
  Ta = df.Tavg  # [°C]
  Precip = df.Prcp # [mm]
  PET = df.PET # [mm]
  PAR = (df.Rs * 0.4) * 4.6 # [W m-2] -> [umol m-2 s-1]
  LAI = df.LAI # [m2 m-2]
  VPD = df.VPD # [kPa]
  elv = df.elv # [m]
  Ca = df.co2 # [ppm]
  b = df.b # [-]

  res = OptModel.(Ta, Precip, PET, PAR, LAI, VPD, elv, Ca, b)
  GPP_Opt = getindex.(res, 1)
end

begin
  yobs, ysim = df.GPP_obs, GPP_Opt
  fig = Figure(; size=(400, 400))
  ax = Axis(
    fig[1, 1], titlefont = :regular,
    xlabel = "Observed GPP (gC/m2/day)", ylabel = "OptModel GPP (gC/m2/day)",
    rightspinevisible = false, topspinevisible = false,
     xgridvisible = false, ygridvisible = false
  )
  scatter!(ax, yobs, ysim; markersize=10, color=:lightblue)
  lines!(ax, [0, 15], [0, 15]; color=:red, linestyle=:dash, linewidth=2)
  show_gof!(
    ax, 0.1, 14.9, yobs, ysim; metrics=["R2", "RMSE", "PBIAS"],
    n=3, align=(:left, :top), color=:black
  )
  xlims!(ax, 0, 15)
  ylims!(ax, 0, 15)
  display(fig)
end
