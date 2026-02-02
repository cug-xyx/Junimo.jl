using Dates
using Downloads

export DownGOSIF

const GOSIF_V2_8DAY_BASE_URL = "https://data.globalecology.unh.edu/data/GOSIF_v2/8day"

_as_date(x::Date) = x
_as_date(x::AbstractString) = Date(x)

"""
    DownGOSIF(start_date, end_date, out_dir)

Download GOSIF v2 8-day composites between `start_date` and `end_date` (inclusive)
into `out_dir`. File naming uses day-of-year (DOY) as `GOSIF_YYYYDDD.tif.gz`.

# Inputs
  - start_date: `Date` or date string (e.g. "2000-02-26")
  - end_date: `Date` or date string
  - out_dir: folder to store downloads

# Behavior
  - If a target file already exists, it is skipped.
  - Downloads are attempted in 8-day steps.

# Output
  - Named tuple with `downloaded`, `skipped`, `failed` file paths.

# Source
  - https://data.globalecology.unh.edu/data/GOSIF_v2/8day/
"""
function DownGOSIF(start_date, end_date, out_dir)
  s = _as_date(start_date)
  e = _as_date(end_date)
  s > e && throw(ArgumentError("start_date must be <= end_date"))

  mkpath(out_dir)

  downloaded = String[]
  skipped = String[]
  failed = String[]

  date = s
  while date <= e
    yr = year(date)
    doy = dayofyear(date)
    doy_str = lpad(string(doy), 3, '0')
    fname = "GOSIF_$(yr)$(doy_str).tif.gz"
    fpath = joinpath(out_dir, fname)

    if isfile(fpath)
      push!(skipped, fpath)
    else
      url = "$(GOSIF_V2_8DAY_BASE_URL)/$(fname)"
      try
        Downloads.download(url, fpath)
        push!(downloaded, fpath)
      catch err
        push!(failed, fpath)
        println(stderr, "Failed to download GOSIF file: ", url)
        println(stderr, "  -> ", fpath)
        println(stderr, "  -> error: ", err)
      end
    end

    date += Day(8)
  end

  return (downloaded=downloaded, skipped=skipped, failed=failed)
end
