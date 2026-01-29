export
  OptModel,
  fraction_of_photosynthetically_active_radiation,
  soil_moisture_constraint_factor,
  surface_pressure,
  photorespiratory_compensation_point,
  effective_michaelis_menten_coefficient_of_rubisco,
  marginal_water_use_efficiency


const PA0 = 101325       # [Pa]
const T2K = 273.15
const TAOPTK = 298.15      # [K]

const kR = 8.3145        # The universal gas constant [J mol-1 K-1] (Allen, 1973)
const Γ_STAR_25 = 4.332  # The photorespiration compensation point, assuming 25 °C and sea level [Pa]
const ΔH_Γ_STAR = 37830  # The activation energy of Γ* [J mol-1]


# TODO:
# 1. 土壤水分限制AI存在不足
# 2. PAR是基于Rs计算的，有待考虑用Rs作为输入
# 3. 用于计算植被吸收PAR（fPAR）的消光系数默认0.5，也是简化的
# 4. 可以扔两种函数，一个需要elv，一个是Pa
# 5. 部分过程只适用于C4植物
# 6. dimensionaless VPD (from kPa to dimentioless) refer to which paper?


"""
    OptModel(Ta, Precip, PET, PAR, LAI, VPD, elv, Ca, b)

`OptModel` is built on eco-evolutionary optimality principles 
to simulate how vegetation gross primary productivity (GPP) 
responds to climate and atmospheric CO₂. It integrates optimal 
stomatal conductance theory, optimal Ci/Ca theory, and the coordination 
theory, treating stomatal conductance (gs), intercellular CO₂ ratio, 
and maximum rate of Ribulose-1,5-bisphosphate carboxylase/ oxygenase 
(Rubisco) carboxylation (Vcmax) as outcomes of a carbon gain versus 
water cost trade-off, which enables analytical solutions for key 
variables. Driven by LAI and climate forcings (temperature, 
precipitation, potential evapotranspiration, VPD, radiation, elevation, 
and CO₂), the model requires only a small number of parameters (i.e., b). 
It can compute GPP, gs, Vcmax, and marginal water-use efficiency, among 
others. Compared with empirical formulations, `OptModel` is parsimonious 
and physically interpretable, better capturing responses to climate variability 
and elevated CO₂, and it scales well across sites and regions (Hu et al., 2025).

# Inputs
  - Ta: air temperature \\[°C\\]
  - Precip: precipitation \\[mm\\]
  - PET: potential evapotranspiration \\[mm\\]
  - PAR: photosynthetically active radiation \\[umol m-2 s-1\\]
  - LAI: leaf area index \\[m2 m-2\\]
  - VPD: vapor pressure deficit \\[kPa\\]
  - elv: elevation \\[m\\]
  - Ca: ambient CO2 concentration \\[umol mol-1 or ppm\\]
  - b: calibrated scalar parameter \\[-\\]

# Outputs
  - GPP: gross primary production \\[gC m-2 day-1\\]
  - Gc: canopy conductance \\[mol m-2 s-1\\]
  - Vcmax: maximum carboxylation capacity \\[umol m-2 s-1\\]

# Parameters

- b: calibrated scalar parameter \\[-\\]
- LightExtCoef: 0.5

# Formula

```math
GPP = f_c = \\frac{
V_{cmax} \\times (C_a - \\sqrt{1.6 \\times \\lambda \\times VPD \\times C_a})
}{
K + \\chi \\times C_a
}
\\\\
Gc_{water} = 1.6 \\times Gc_{carbon} = 1.6 \\times \\frac{
V_{cmax}
}{
K + \\chi \\times C_a
} \\times (-1 + (\\frac{
C_a
}{
1.6 \\times \\lambda \\times VPD
}) ^ \\frac{1}{2})
\\\\
V_{cmax} = \\phi_0 \\times I_{abs} \\times \\frac{m'}{m_c}
```

# Notes
  - fPAR is computed from LAI using a Beer-Lambert canopy extinction model.
  - Soil moisture limitation uses the aridity index (AI = Precip / PET).

# References
  - **Zhongmin Hu et al. (2025) Simulating climatic responses of vegetation
    production with ecological optimality theories. The Innovation Geoscience. 3, 100153–11.**
  - Stocker et al. (2020, GMD)
  - Wang et al. (2017, Nature Plants)
  - Prentice et al. (2014, Ecology Letters)
  - Katul et al. (2010)
"""
function OptModel(Ta, Precip, PET, PAR, LAI, VPD, elv, Ca, b)
  LightExtCoef = 0.5


  Tak = Ta + T2K # [°C] -> [K]

  # FPAR [-]
  @show FPAR = fraction_of_photosynthetically_active_radiation(LAI; LightExtCoef = LightExtCoef)

  Pa = surface_pressure(elv) # Pa [Pa]

  # marginal water use efficiency (Γ_star) [?]
  Γ_star, K, ξ, lambd, Dvpr = marginal_water_use_efficiency(Ta, Precip, PET, VPD, Pa, Ca)

  χ = ξ / (ξ + sqrt(Dvpr)) # optimal Ci/Ca (Prentice et al. 2014, EL)

  # Vcmax [umol m-2 s-1]
  Iabs = FPAR * PAR # PAR is represented by photon flux density [umol m-2 s-1]
  ci = χ * Ca
  mc = (ci - Γ_star) / (ci + K) # the Ac term
  mj = (ci - Γ_star) / (ci + 2 * Γ_star) # the Aj term

  # Nicholas G. Smith, 2019, Ecology letters
  θ = 0.85 # θ is related to the distribution of light intensity relative to the distribution of photosynthetic capacity
  c = 0.053 # the proportion A change with Jmax,
  phi = (0.352 + 0.022 * Ta - 0.00034 * Ta ^ 2) * 0.257 * b # ! The param b

  # Complex number
  # w = -(1 - 2 * θ) + sqrt((1 - θ) * (mj ^ 2 / (4 * c * mj - 16 * c ^ 2 * θ) - 4 * θ))
  term = (1 - θ) * (mj ^ 2 / (4 * c * mj - 16 * c ^ 2 * θ) - 4 * θ)
  if term < 0
      w = -(1 - 2 * θ) + sqrt(Complex{Float64}(term))
      @show real(w)
  else
      w = -(1 - 2 * θ) + sqrt(term)
  end
  w = real(w)

  wstar = 1 + w - sqrt((1 + w) ^ 2 - 4 * θ * w)
  Vcmax = phi .* Iabs .* (mj ./ mc) .* (wstar ./ θ / 8) # same as (Stocker et al., 2020, GMD, Eq. F25)

  # fc, i.e., GPP (Katul et al., 2010)

  fc = Vcmax ./ (K + χ .* Ca) .* (Ca - sqrt(1.6 * lambd .* Dvpr .* Ca)) # (umol m-2 s-1)
  GPP = fc * 0.0864 * 12 # [umol m-2 s-1] to [gC m-2 day-1]

  # canopy conductance (Katul, 2010, [mol m-2 s-1])
  Gc = (Vcmax ./ (K + χ * Ca)) .* (-1 + (Ca ./ (1.6 .* lambd .* Dvpr)) .^ 0.5) * 1.6

  return GPP, Gc, Vcmax
end


"""
    fraction_of_photosynthetically_active_radiation(LAI; LightExtCoef = 0.5)

Compute the fraction of absorbed PAR (fPAR) using a Beer-Lambert canopy
extinction model.

# Inputs
  - LAI: leaf area index \\[m2 m-2\\], scalar or array
  - LightExtCoef: canopy light extinction coefficient k \\[-\\]

# Outputs
  - fPAR: fraction of absorbed PAR \\[-\\], bounded in \\[0, 1\\]

# Rules for stability:
  - If `LAI` is `missing`, return `missing`.
  - If `LAI <= 0`, return 0.
  - Output is clamped to \\[0, 1\\].

# Formula

```math
fPAR = 1 - e^{-k \\times LAI}
```

# References
  - Beer-Lambert law for canopy radiation transfer.
  - Monsi, M., and Saeki, T. (1953). On the factor light in plant communities and its
    importance for matter production.
  - Sellers, P. J. (1985). Canopy reflectance, photosynthesis and transpiration.
"""
@inline function fraction_of_photosynthetically_active_radiation(LAI; LightExtCoef = 0.5)
  k = LightExtCoef
  return @. ismissing(LAI) ? missing : clamp(ifelse(LAI <= 0, 0, 1 - exp(-k * LAI)), 0, 1)
end


"""
    soil_moisture_constraint_factor(Precip, PET; f_AI_min = 0.01)

Soil moisture constraint factor based on aridity index (AI).

# Inputs
  - Precip: precipitation \\[mm\\], scalar or array
  - PET: potential evapotranspiration \\[mm\\], scalar or array
  - f_AI_min: lower bound for AI, default is 0.01 \\[-\\]

# Outputs
  - f_AI: soil moisture constraint factor \\[-\\], bounded in \\[f_AI_min, 1\\]

# Rules for stability:
  - If `Precip` or `PET` is `missing`, return 1 (no soil moisture constraint).
  - If `PET <= 0`, return `f_AI_min` to avoid division by zero or negative PET.

# Formula

```math
f_{AI} = \\mathrm{clamp}(\\frac{P}{PET}, 0.01, 1)
```

# References
  - Budyko (1974)
"""
@inline function soil_moisture_constraint_factor(Precip, PET; f_AI_min = 0.01)
  return ifelse(ismissing(Precip), 1, clamp(Precip / PET, f_AI_min, 1))
end


"""
    surface_pressure(elv)

Surface pressure estimated from elevation using a standard atmosphere
formulation.

# Inputs
  - elv: elevation \\[m\\]

# Outputs
  - Pa: surface pressure \\[Pa\\]

# Formula

```math
Pa = P_0 \\left(1 - \\frac{k_L z}{T_0}\\right)^{\\frac{g M_a}{R k_L}}
```

# Notes
  - Uses constants `PA0` \\[Pa\\], `TAOPTK` \\[K\\], and `kR` \\[J mol-1 K-1\\].

# References
  - Stocker et al. (2020, GMD)
  - Allen (1973)
  - Tsilingiris (2008)
"""
function surface_pressure(elv)
  kL = 0.0065 # adiabiatic temperature lapse rate, K/m (Allen, 1973)
  kG = 9.80665 # gravitational acceleration, m/s^2 (Allen, 1973)
  kMa = 0.028963 # molecular weight of dry air, kg/mol (Tsilingiris, 2008)

  return PA0 * (1.0 - kL * elv / TAOPTK) .^ (kG * kMa / (kR * kL)) # Convert elevation to pressure, Pa
end


"""
    photorespiratory_compensation_point(Ta, Pa)

Photorespiratory compensation point (Γ*).

# Inputs
  - Ta: air temperature \\[°C\\], scalar or array
  - Pa: air pressure \\[Pa\\], scalar or array

# Outputs
  - Γ*: photorespiratory compensation point \\[umol mol-1\\]

# Rules for stability:
  - Units follow the constant definitions in this file; use `Ta` in °C and `Pa` in Pa.

# Notes
  - Uses constants `?*_25` and `?H_{?*}` defined above, and scales by `Pa/PA0`.
  - The factor 10 converts from Pa to umol mol-1.

# References
  - Stocker et al. (2020, GMD)
"""
function photorespiratory_compensation_point(Ta, Pa)
  Tak = Ta + T2K

  Gstar = Γ_STAR_25 .* exp(ΔH_Γ_STAR * (Ta - 25) ./ (TAOPTK * kR * Tak)) .* Pa / PA0 # Pa
  Γ_star = Gstar * 10 # from Pa to umol mol-1, should be lower than 80 ppm

  return Γ_star
end


"""
    effective_michaelis_menten_coefficient_of_rubisco(Ta, Pa)

Effective Michaelis-Menten coefficient of Rubisco.

# Inputs
  - Ta: air temperature \\[°C\\]
  - Pa: air pressure \\[Pa\\]

# Outputs
  - K: effective Michaelis-Menten coefficient \\[Pa\\]

# Rules for stability:
  - Units follow the constant definitions in this file; use `Ta` in °C and `Pa` in Pa.

# Notes
  - `kco` uses the US Standard Atmosphere for O2.

# References
  - Stocker et al. (2020, GMD)
"""
function effective_michaelis_menten_coefficient_of_rubisco(Ta, Pa)
  Kc25 = 39.97 # The Michaelis-Menten coefficient of Rubisco for carboxylation assuming 25 °C & 98.716 kPa [Pa]
  Ko25 = 27480 # The Michaelis-Menten coefficient of Rubisco for oxygenation assuming 25 °C & 98.716 kPa [Pa]
  ΔH_Kc = 79430 # J/mol
  ΔH_Ko = 36380 # J/mol
  kco = 2.09476e5 # ppm, US Standard Atmosphere

  Tak = Ta + T2K

  Kc = Kc25 * exp(ΔH_Kc * (Ta - 25) ./ (TAOPTK * kR * Tak))
  Ko = Ko25 * exp(ΔH_Ko * (Ta - 25) ./ (TAOPTK * kR * Tak))
  K = Kc .* (1 + kco * (1e-6) * Pa ./ Ko)

  return K
end

"""
    marginal_water_use_efficiency(Ta, Precip, PET, VPD, Pa, Ca)

Compute marginal water use efficiency and related intermediate terms.

# Inputs
  - Ta: air temperature \\[°C\\]
  - Precip: precipitation \\[mm\\]
  - PET: potential evapotranspiration \\[mm\\]
  - VPD: vapor pressure deficit \\[kPa\\]
  - Pa: air pressure \\[Pa\\]
  - Ca: ambient CO2 concentration \\[umol mol-1\\]

# Outputs
  - Γ_star: photorespiratory compensation point \\[umol mol-1\\]
  - K: effective Michaelis-Menten coefficient \\[Pa\\]
  - ξ: intermediate term (Prentice et al., 2014)
  - λ: marginal water use efficiency \\[-\\]
  - Dvpr: dimensionless VPD \\[Pa Pa-1\\]

# Rules for stability:
  - Units follow the constant definitions in this file; use `Ta` in °C, `VPD` in kPa, `Pa` in Pa.

# Notes
  - Uses the Prentice et al. (2014) formulation with viscosity correction (Wang et al., 2017).

# References
  - Prentice et al. (2014, Ecology Letters)
  - Katul et al. (2010)
  - Wang et al. (2017, Nature Plants)
"""
function marginal_water_use_efficiency(Ta, Precip, PET, VPD, Pa, Ca)
  Tak = Ta + T2K

  Γ_star = photorespiratory_compensation_point(Ta, Pa)

  f_AI = soil_moisture_constraint_factor(Precip, PET)
  K = effective_michaelis_menten_coefficient_of_rubisco(Ta, Pa)

  # ξ (Prentice et al., 2014, EL)
  A = -3.719
  B = 580
  C = -138
  # η = 1e-3 * exp(A + (B / (C + Tak))) # water viscosity, refer to Wang et al. (2017, Nature Plants) supp Eq.26
  # η* correction coefficient, higher value in η* if water is more viscosity
  η_star = exp((-B * (Tak - TAOPTK)) / ((Tak + C) * (TAOPTK + C)))
  η_star = η_star ./ f_AI

  β = 146 * 1e-6 # composite parameter, which is the unit cost ratio for C3. (Wang et al., 2017， NP) [mol umol-1]
  
  ξ = sqrt(β * ((K + Γ_star) / (1.6 * η_star))) # ξ: Prentice 2014, EL, more accurate form.

  # λ, combined equation (15) of Katul et al. (2010) and equation (2) of Prentice et al. (2014) inferred
  Dvpr = VPD * 1000 / Pa
  a = 1.6 # a is 1.6 is the relative diffusivity of water vapour with respect to carbon dioxide
  λ = Ca / (ξ + sqrt(Dvpr)) .^ 2 / a # lambd: marginal water use efficiency

  return Γ_star, K, ξ, λ, Dvpr
end
