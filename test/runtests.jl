using Test
using Junimo

@testset "Print utilities" begin
    io = IOBuffer()
    @test cprint(io, "hi", 31) === nothing
    @test String(take!(io)) == "\e[31mhi\e[0m\n"

    io = IOBuffer()
    @test red(io, "x") === nothing
    @test String(take!(io)) == "\e[31mx\e[0m\n"

    io = IOBuffer()
    @test green(io, "x") === nothing
    @test String(take!(io)) == "\e[32mx\e[0m\n"

    io = IOBuffer()
    @test blue(io, "x") === nothing
    @test String(take!(io)) == "\e[34mx\e[0m\n"

    io = IOBuffer()
    @test purple(io, "x") === nothing
    @test String(take!(io)) == "\e[35mx\e[0m\n"
end
