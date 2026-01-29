using Statistics

export gof
export GofResult

function _paired_nonmissing(obs, sim)
  # Pairwise filter missing to avoid misalignment.
  if obs isa Number || obs === missing
    obs = (obs,)
  end
  if sim isa Number || sim === missing
    sim = (sim,)
  end
  obs_vec = Float64[]
  sim_vec = Float64[]
  if Base.IteratorSize(obs) isa Base.HasLength && Base.IteratorSize(sim) isa Base.HasLength
    n_hint = min(length(obs), length(sim))
    sizehint!(obs_vec, n_hint)
    sizehint!(sim_vec, n_hint)
  end
  for (o, s) in zip(obs, sim)
    if !(ismissing(o) || ismissing(s))
      push!(obs_vec, float(o))
      push!(sim_vec, float(s))
    end
  end
  return obs_vec, sim_vec
end

function _maybe_round!(res::AbstractDict{String, V}, n_small::Union{Nothing, Int}) where {V}
  if n_small !== nothing
    for (k, v) in res
      if v isa Real
        res[k] = round(v, digits=n_small)
      end
    end
  end
  return res
end

"""
    GofResult(data; colorize=true)

Dictionary-like GoF result with colored printing.
Positive values print in red and negative values in blue when `colorize=true`.
It supports standard `Dict` access patterns such as `res["KGE"]` and `pairs(res)`.
"""
struct GofResult{V, D<:AbstractDict{String, V}} <: AbstractDict{String, V}
  data::D
  colorize::Bool
end

function GofResult(data::D; colorize::Bool=true) where {V, D<:AbstractDict{String, V}}
  return GofResult{V, D}(data, colorize)
end

Base.length(res::GofResult) = length(res.data)
Base.iterate(res::GofResult, state...) = iterate(res.data, state...)
Base.haskey(res::GofResult, key) = haskey(res.data, key)
Base.getindex(res::GofResult, key) = getindex(res.data, key)
Base.setindex!(res::GofResult, value, key) = setindex!(res.data, value, key)
Base.get(res::GofResult, key, default) = get(res.data, key, default)
Base.keys(res::GofResult) = keys(res.data)
Base.values(res::GofResult) = values(res.data)
Base.pairs(res::GofResult) = pairs(res.data)

function _show_gof_value(io::IO, value, colorize::Bool)
  if colorize && value isa Real && isfinite(value) && !iszero(value) && get(io, :color, false)
    color = value > 0 ? :red : :blue
    return printstyled(io, value; color=color)
  end
  return show(io, value)
end

function _show_gof_result_inline(io::IO, res::GofResult)
  print(io, "Dict(")
  first = true
  for (k, v) in pairs(res.data)
    if first
      first = false
    else
      print(io, ", ")
    end
    show(io, k)
    print(io, "=>")
    _show_gof_value(io, v, res.colorize)
  end
  return print(io, ")")
end

function _show_gof_result_pretty(io::IO, res::GofResult)
  show(io, typeof(res.data))
  n = length(res.data)
  print(io, " with ", n, " entries:")
  if n == 0
    return nothing
  end
  print(io, "\n")
  i = 0
  for (k, v) in pairs(res.data)
    i += 1
    print(io, "  ")
    show(io, k)
    print(io, " => ")
    _show_gof_value(io, v, res.colorize)
    if i < n
      print(io, "\n")
    end
  end
  return nothing
end

Base.show(io::IO, res::GofResult) = _show_gof_result_inline(io, res)
Base.show(io::IO, ::MIME"text/plain", res::GofResult) = _show_gof_result_pretty(io, res)

function _finish_gof_result(
  res::AbstractDict{String, V},
  n_small::Union{Nothing, Int},
  colorize::Bool
) where {V}
  res = _maybe_round!(res, n_small)
  return colorize ? GofResult(res; colorize=true) : res
end

"""
    gof(obs, sim; n_small=nothing, colorize=true)

Compute goodness-of-fit (GOF) metrics comparing simulated `sim` with observed `obs`.

# Inputs
  - obs: observed values, scalar or array, may include `missing`
  - sim: simulated values, scalar or array, may include `missing`
  - n_small: number of decimal digits to round to; `nothing` keeps full precision
  - colorize: whether to return a colored `GofResult` for pretty printing

# Outputs
  - result: `GofResult` (when `colorize=true`) or `Dict{String, Float64}` (when `colorize=false`)
    with keys: `KGE`, `NSE`, `R`, `R2`, `RMSE`, `MAE`, `bias`, `PBIAS`, `n`

# Rules for stability:
  - Missing values are removed pairwise via `zip(obs, sim)`.
  - If `n <= 2`, `KGE`, `NSE`, `R`, and `R2` return `NaN`.
  - If `mean(obs) == 0` or `std(obs) == 0`, ratio-based terms return `NaN`.

# Formula
  - ``RMSE = \\sqrt{\\frac{1}{n} \\sum (s_i - o_i)^2}``
  - ``MAE = \\frac{1}{n} \\sum |s_i - o_i|``
  - ``bias = \\bar{s} - \\bar{o}``
  - ``bias\\_perc = 100 \\cdot bias / \\bar{o}``
  - ``NSE = 1 - \\frac{\\sum (s_i - o_i)^2}{\\sum (o_i - \\bar{o})^2}``
  - ``KGE = 1 - \\sqrt{(r-1)^2 + (\\alpha-1)^2 + (\\beta-1)^2}``
    where ``r = cor(o, s)``, ``\\alpha = \\sigma_s / \\sigma_o``,
    ``\\beta = \\bar{s}/\\bar{o}``

# References
  - Nash, J. E., and Sutcliffe, J. V. (1970). River flow forecasting through conceptual models.
    Journal of Hydrology, 10(3), 282-290. doi:10.1016/0022-1694(70)90255-6
  - Gupta, H. V., Kling, H., Yilmaz, K. K., and Martinez, G. F. (2009). Decomposition of the mean
    squared error and NSE: Toward improved diagnostic evaluation. Water Resources Research, 45,
    W09417. doi:10.1029/2009WR007200
  - Willmott, C. J., and Matsuura, K. (2005). Advantages of the mean absolute error (MAE).
    Climate Research, 30, 79-82. doi:10.3354/cr030079
"""
function gof(obs, sim; n_small::Union{Nothing, Int}=nothing, colorize::Bool=true)
  obs, sim = _paired_nonmissing(obs, sim)

  n = length(obs)
  if n == 0
    res = Dict(
      "KGE"=>NaN, "NSE"=>NaN, "R2"=>NaN, "R"=>NaN,
      "RMSE"=>NaN, "MAE"=>NaN, "bias"=>NaN, "PBIAS"=>NaN,
      "slp"=>NaN, "pvalue"=>NaN, "intercept"=>NaN,
      "n"=>n
    )
    return _finish_gof_result(res, n_small, colorize)
  end

  # Single pass: mean, variance, covariance, and error totals.
  mean_obs = 0.0
  mean_sim = 0.0
  m2_obs = 0.0
  m2_sim = 0.0
  cov_os = 0.0
  sum_sq = 0.0
  sum_abs = 0.0

  i = 0
  @inbounds for idx in eachindex(obs)
    i += 1
    o = obs[idx]
    s = sim[idx]
    diff = s - o
    sum_sq += diff * diff
    sum_abs += abs(diff)

    # Welford update: numerically stable and avoids extra passes.
    delta_o = o - mean_obs
    mean_obs += delta_o / i
    delta_s = s - mean_sim
    mean_sim += delta_s / i
    m2_obs += delta_o * (o - mean_obs)
    m2_sim += delta_s * (s - mean_sim)
    cov_os += delta_o * (s - mean_sim)
  end

  RMSE = sqrt(sum_sq / n)
  MAE = sum_abs / n
  bias = mean_sim - mean_obs
  PBIAS = iszero(mean_obs) ? NaN : bias / mean_obs * 100

  # sample too small
  if n <= 2
    res = Dict(
      "KGE"=>NaN, "NSE"=>NaN, "R2"=>NaN, "R"=>NaN,
      "RMSE"=>RMSE, "MAE"=>MAE, "bias"=>bias, "PBIAS"=>PBIAS,
      "slp"=>NaN, "pvalue"=>NaN, "intercept"=>NaN,
      "n"=>n
    )
    return _finish_gof_result(res, n_small, colorize)
  end

  ss_obs = m2_obs
  NSE = ss_obs > 0 ? 1 - sum_sq / ss_obs : NaN

  R = NaN
  R2 = NaN
  KGE = NaN
  if m2_obs > 0 && m2_sim > 0
    var_obs = m2_obs / (n - 1)
    var_sim = m2_sim / (n - 1)
    std_obs = sqrt(var_obs)
    std_sim = sqrt(var_sim)
    cov = cov_os / (n - 1)
    if std_obs > 0 && std_sim > 0
      R = cov / (std_obs * std_sim)
      if isfinite(R)
        R = clamp(R, -1.0, 1.0)
        R2 = R^2
      end
      alpha = std_sim / std_obs
      beta = iszero(mean_obs) ? NaN : mean_sim / mean_obs
      if isfinite(R) && isfinite(alpha) && isfinite(beta)
        KGE = 1 - sqrt((R - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)
      end
    end
  end

  res = Dict(
    "KGE"=>KGE, "NSE"=>NSE, "R2"=>R2, "R"=>R,
    "RMSE"=>RMSE, "MAE"=>MAE, "bias"=>bias, "PBIAS"=>PBIAS,
    "n"=>n
  )

  return _finish_gof_result(res, n_small, colorize)
end
