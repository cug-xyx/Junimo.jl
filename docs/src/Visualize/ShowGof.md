# Gof

```@meta
CurrentModule = Junimo
```

Render a compact multiline block of GoF metrics at a chosen position on an axis.
Metrics are computed internally via `gof` and can be filtered via the `metrics` keyword.

## Examples

```@example
using Junimo # hide
using CairoMakie # hide

CairoMakie.activate!() # hide

yobs = [1, 2, 3, 4, 5]
ysim = [1, 2, 3, 4, 6]


fig = Figure(; size=(700, 350))

ax = Axis(
  fig[1, 1], titlefont = :regular,
  xlabel = "Yobs (-)", ylabel = "Ysim (-)"
)
scatter!(ax, yobs, ysim; markersize=10, color=:lightblue)
lines!(ax, [0, 6], [0, 6]; color=:red, linestyle=:dash, linewidth=2)
show_gof!(
  ax, 5.3, 0.1,
  yobs, ysim;
  metrics = ["R2", "RMSE"],
  n=2,
  align=(:right, :bottom),
  color=:black
)
fig
```

## APIs

```@docs
show_gof!
```
