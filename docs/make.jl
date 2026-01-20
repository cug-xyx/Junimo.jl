push!(LOAD_PATH,"../src/")

using Documenter, Junimo

makedocs(
  sitename="Junimo.jl",
  pages = [
    "index.md",
    "Print" => "Utils/Print.md",
    #   "Subsection" => [
    #       ...
    # ]
  ]
)


# === 新增的部分 ===
deploydocs(
  repo = "github.com/cug-xyx/Junimo.jl.git",
  devbranch = "master"
)