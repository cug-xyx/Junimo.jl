push!(LOAD_PATH,"../src/")

using Documenter, Junimo

makedocs(
  sitename="Junimo.jl",
  pages = [
    "index.md",
    "Statistics" => [
        "Statistics/Gof.md"
    ],
    "Utils" => [
      "Utils/Print.md"
    ],
    "Visualize" => [
      "Visualize/ShowGof.md"
    ]
  ]
)


# === 新增的部分 ===
deploydocs(
  repo = "github.com/cug-xyx/Junimo.jl.git",
  devbranch = "master"
)