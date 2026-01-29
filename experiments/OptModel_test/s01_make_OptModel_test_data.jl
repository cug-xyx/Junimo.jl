using Junimo
using CairoMakie
using MAT
using Rasters, ArchGDAL
using CSV, DataFrames
using HydroTools


# gridded parameter b
m_param_b = matopen("doc/Model/Plant_physiology/OptModel/B05degree.mat")
var_name = keys(m_param_b)
arr_param_b = read(m_param_b, "B05degree")

ras_param_b = Raster(arr_param_b, (Y(89.75:-0.5:-89.75), X(-179.75:0.5:179.75)))
# plot(ras_param_b)
# write("data/OptModel_param_b.tif", ras_param_b)

# FLUXNET
df_all = CSV.read("E:/Eddy_covariance_flux_towers/PML-V2.2-cali-final/input_output_qc_8d_pml_v22.csv", DataFrame)
df_all = df_all[.!ismissing.(df_all.GPP_obs), :]

df_nGPPobs = DataFrames.combine(groupby(df_all, "ID"), nrow => :Count)

site_most_GPPobs = sort!(df_nGPPobs, "Count", rev = true)[1, "ID"]

df_res = df_all[df_all.ID .== site_most_GPPobs, :]

# extract b
df_loc = CSV.read("E:/Eddy_covariance_flux_towers/PML-V2.2-cali-final/sites_qc_pml_v22.csv", DataFrame)
df_loc[df_loc.ID .== site_most_GPPobs, ["long", "lat"]]

param_b = ras_param_b[X(Near(5.9981)), Y(Near(50.305))]
df_res.b .= param_b
df_res.elv .= 152.9

# calculate PET
df_res.PET .= ET0_FAO98.(df_res.Rn, df_res.Tavg, df_res.VPD, df_res.U2, df_res.Pa; z_wind=2, tall_crop=false)

# write
cols = ["ID", "IGBP1", "Date", "elv", "GPP_obs", "GPP", "Prcp", "Rs", "Tavg", "VPD", "Pa", "co2", "LAI", "PET", "b"]
df_res = df_res[:, cols]
CSV.write("data/$(site_most_GPPobs)_8day", df_res)