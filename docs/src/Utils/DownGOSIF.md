# DownGOSIF

```@meta
CurrentModule = Junimo
```

Download GOSIF v2 8-day dataset.

## Examples

```julia
using Junimo

date_start = "2020-01-01"
date_end = "2021-01-01"
dir_output = "E:/var_SIF/GOSIF/8day"

DownGOSIF(date_start, date_end, dir_output)
```

## APIs

```@docs
DownGOSIF
```
