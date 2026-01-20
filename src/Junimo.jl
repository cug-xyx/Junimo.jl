module Junimo

  using Random

  include("./Utils/Print.jl")


  function __init__()
    fortunes = [
      ("✨ The spirits are very happy today! They will do their best to shower everyone with good fortune.", :magenta),

      ("😊 The spirits are in good humor today. I think you'll have a little extra luck.", :yellow),

      ("😐 The spirits feel neutral today. The day is in your hands.", :white),

      ("🦇 The spirits are somewhat annoyed today. Luck will not be on your side.", :cyan),

      ("💀 The spirits are very displeased today. They will do their best to make your life difficult.", :red)
    ]

    (text_en, color) = rand(fortunes)

    printstyled("\n🍎 Junimo is ready to help!", color=:green, bold=true)

    printstyled("\n📺 [Fortune Teller]: \n", color=color)
    println(text_en)
    println("-"^50)
  end
end # module Junimo
