# Opt model

```@meta
CurrentModule = Junimo
```

## Description

`OptModel` is built on eco-evolutionary optimality principles to simulate how vegetation gross primary productivity (GPP) responds to climate and atmospheric CO₂. It integrates optimal stomatal conductance theory, optimal Ci/Ca theory, and the coordination theory, treating stomatal conductance (gs), intercellular CO₂ ratio, and maximum rate of Ribulose-1,5-bisphosphate carboxylase/ oxygenase (Rubisco) carboxylation (Vcmax) as outcomes of a carbon gain versus water cost trade-off, which enables analytical solutions for key variables. Driven by LAI and climate forcings (temperature, precipitation, potential evapotranspiration, VPD, radiation, elevation, and CO₂), the model requires only a small number of parameters (i.e., b). It can compute GPP, gs, Vcmax, and marginal water-use efficiency, among others. Compared with empirical formulations, `OptModel` is parsimonious and physically interpretable, better capturing responses to climate variability and elevated CO₂, and it scales well across sites and regions (Hu et al., 2025).

## Examples

```@example
using Junimo
using CairoMakie
using CSV, DataFrames

root_dir = joinpath(@__DIR__, "..", "..", "..", "..") # hide
# root_dir = "."
data_path = joinpath(root_dir, "data", "BE-Vie_8day")
df = CSV.read(data_path, DataFrame)

begin
  Ta = df.Tavg              # [°C]
  Precip = df.Prcp          # [mm]
  PET = df.PET              # [mm]
  PAR = (df.Rs * 0.4) * 4.6 # [W m-2] -> [umol m-2 s-1]
  LAI = df.LAI              # [m2 m-2]
  VPD = df.VPD              # [kPa]
  elv = df.elv              # [m]
  Ca = df.co2               # [ppm]
  b = df.b                  # [-]

  res = OptModel.(Ta, Precip, PET, PAR, LAI, VPD, elv, Ca, b)
  GPP_Opt = getindex.(res, 1)
end

begin
  yobs, ysim = df.GPP_obs, GPP_Opt
  fig = Figure(; size=(300, 300))
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
  fig
end
```

## APIs

```@docs
OptModel
fraction_of_photosynthetically_active_radiation
soil_moisture_constraint_factor
surface_pressure
photorespiratory_compensation_point
effective_michaelis_menten_coefficient_of_rubisco
marginal_water_use_efficiency
```
