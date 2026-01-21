using CairoMakie: text!

export show_gof!

"""
    show_gof!(ax, x, y, obs, sim; metrics=nothing, n=nothing, align=(:right, :bottom), color=:black)

Render GoF metrics at a given position on an existing axis.
The metrics are computed internally via `gof(obs, sim)` and then formatted as
multiline text.

# Arguments

- `ax`: Makie axis to draw on
- `x`, `y`: Text position coordinates
- `obs`, `sim`: Observed and simulated values (scalars or sequences)

# Keywords

- `metrics`: List of metric keys to display (e.g. `["R2", "NSE"]`).
  If `nothing`, defaults to `["R2", "NSE", "KGE", "RMSE", "bias"]`.
- `n`: Decimal digits to round to; forwarded to `gof(...; n_small=n)`.
- `align`: Text alignment tuple passed to `text!`.
- `color`: Text color passed to `text!`.

# Notes

- Unknown metric keys are shown as `NaN`.
"""
function show_gof!(
  ax,
  x,
  y,
  obs,
  sim;
  metrics::Union{Nothing, AbstractVector}=nothing,
  n::Union{Nothing, Int}=nothing,
  align=(:right, :bottom),
  color=:black
)
  gof_res = gof(obs, sim; n_small=n)
  metrics = metrics === nothing ? ["R2", "NSE", "KGE", "RMSE", "bias"] : metrics
  metrics_str = map(m -> m isa Symbol ? String(m) : String(m), metrics)

  lines = Vector{String}(undef, length(metrics_str))
  @inbounds for i in eachindex(metrics_str)
    key = metrics_str[i]
    val = get(gof_res, key, NaN)
    lines[i] = string(key, "=", val)
  end

  text!(
    ax,
    join(lines, "\n"),
    position = (x, y),
    align = align,
    color = color
  )
end
