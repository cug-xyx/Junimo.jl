# Gof

```@meta
CurrentModule = Junimo
```

Compute a composite set of goodness-of-fit metrics between observed and simulated values.
Missing values are filtered pairwise, and optional rounding is supported via `n_small`.

## Examples

```@example
using Junimo # hide

yobs = [1, 2, 3, 4, 5]
ysim = [1, 2, 3, 4, 6]

gof(yobs, ysim)
```

```@example
using Junimo # hide

gof(1, 1)
```

```@example
using Junimo # hide

yobs = [1, missing, 3, 4, 5]
ysim = [1, 2, missing, 4, 6]

gof(yobs, ysim; n_small=3)
```

## APIs

```@docs
gof
```
