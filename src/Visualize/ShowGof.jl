using CairoMakie: text!

export show_gof!

"""
    show_gof!(ax, x, y, obs, sim; metrics=nothing, n=nothing, align=(:right, :bottom), color=:black)

Render GoF metrics as multiline text at a given position on an existing axis.

# Inputs
  - ax: Makie axis to draw on
  - x, y: text position coordinates
  - obs: observed values
  - sim: simulated values
  - metrics: list of metric keys to display; if `nothing`, defaults to
    `["R2", "NSE", "KGE", "RMSE", "bias"]`
  - n: decimal digits to round to; forwarded to `gof(...; n_small=n)`
  - align: text alignment tuple passed to `text!`
  - color: text color passed to `text!`

# Notes
  - Metrics are computed via `gof(obs, sim)` and formatted as multiline text.
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
    label = key == "R2" ? "R²" : key
    val_str = key == "PBIAS" ? string(val, "%") : string(val)
    lines[i] = string(label, "=", val_str)
  end

  text!(
    ax,
    join(lines, "\n"),
    position = (x, y),
    align = align,
    color = color
  )
end
