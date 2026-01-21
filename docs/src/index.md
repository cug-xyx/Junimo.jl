# Junimo.jl

[![Tests](https://github.com/cug-xyx/Junimo.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/cug-xyx/Junimo.jl/actions/workflows/tests.yml)
[![Documentation](https://github.com/cug-xyx/Junimo.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/cug-xyx/Junimo.jl/actions/workflows/ci.yml)

`Junimo.jl` is a personal Julia utility library, aimed at automating and streamlining day-to-day workflows.

## Table of Contents

- [Junimo.jl](#junimojl)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Author](#author)
  - [Function Categories](#function-categories)
  - [Installation](#installation)
  - [Quick Start](#quick-start)
  - [Testing](#testing)
  - [Documentation](#documentation)
  - [Contributing](#contributing)
  - [License](#license)

## Overview

`Junimo.jl` gathers practical helpers and conventions into a single package.
It favors small, composable utilities that can be reused across projects and scripts.

## Author

YuxuanXie

## Function Categories

- Utils: colored console output helpers (`cprint`, `red`, `green`, `blue`, `purple` and macros)
- Statistics: goodness-of-fit metrics (`gof`, colorized `GofResult` output)
- Visualize: GoF annotation helpers for Makie (`show_gof!`)

## Installation

```julia
pkg> add https://github.com/cug-xyx/Junimo.jl
```

## Quick Start

```julia
using Junimo
```

## Testing

```julia
julia --project -e "using Pkg; Pkg.test()"
```

## Documentation

Documentation site: https://cug-xyx.github.io/Junimo.jl/index.html

## Contributing

Contributions are welcome. Please open an issue to discuss ideas before submitting a PR.

## License

GPL-3.0-only
