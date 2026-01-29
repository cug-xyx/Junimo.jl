export 
  cprint,
  red, green, blue, purple,
  @red, @green, @blue, @purple

const ANSI_PREFIX = "\x1b["
const ANSI_RESET = "\x1b[0m"
const ANSI_RED = 31
const ANSI_GREEN = 32
const ANSI_BLUE = 34
const ANSI_PURPLE = 35

"""
    cprint(text, code)
    cprint(io, text, code)

Print `text` using the specified ANSI color `code`.

# Inputs
  - text: string to print
  - code: ANSI color code integer (e.g., 31 for red, 32 for green)
  - io: optional `IO` stream to write to (default: `stdout`)
"""
@inline function cprint(io::IO, text::AbstractString, code::Integer)::Nothing
    print(io, ANSI_PREFIX, code, "m", text, ANSI_RESET, '\n')
    return nothing
end
@inline cprint(text::AbstractString, code::Integer) = cprint(stdout, text, code)


"""
    red(text)
    red(io, text)

Print a line of text in red (ANSI 31).

# Inputs
  - text: string to print
  - io: optional `IO` stream to write to (default: `stdout`)

# Notes
  - Convenience wrapper for `cprint(..., ANSI_RED)`.
"""
@inline red(io::IO, text::AbstractString) = cprint(io, text, ANSI_RED)
@inline red(text::AbstractString) = cprint(stdout, text, ANSI_RED)

"""
    @red text
    @red io text

Print a line of text in red (ANSI 31).

# Inputs
  - text: string to print
  - io: optional `IO` stream to write to
"""
macro red(args...)
    return Expr(:call, :red, map(esc, args)...)
end


"""
    green(text)
    green(io, text)

Print a line of text in green (ANSI 32).

# Inputs
  - text: string to print
  - io: optional `IO` stream to write to (default: `stdout`)

# Notes
  - Convenience wrapper for `cprint(..., ANSI_GREEN)`.
"""
@inline green(io::IO, text::AbstractString) = cprint(io, text, ANSI_GREEN)
@inline green(text::AbstractString) = cprint(stdout, text, ANSI_GREEN)

"""
    @green text
    @green io text

Print a line of text in green (ANSI 32).

# Inputs
  - text: string to print
  - io: optional `IO` stream to write to
"""
macro green(args...)
    return Expr(:call, :green, map(esc, args)...)
end


"""
    blue(text)
    blue(io, text)

Print a line of text in blue (ANSI 34).

# Inputs
  - text: string to print
  - io: optional `IO` stream to write to (default: `stdout`)

# Notes
  - Convenience wrapper for `cprint(..., ANSI_BLUE)`.
"""
@inline blue(io::IO, text::AbstractString) = cprint(io, text, ANSI_BLUE)
@inline blue(text::AbstractString) = cprint(stdout, text, ANSI_BLUE)

"""
    @blue text
    @blue io text

Print a line of text in blue (ANSI 34).

# Inputs
  - text: string to print
  - io: optional `IO` stream to write to
"""
macro blue(args...)
    return Expr(:call, :blue, map(esc, args)...)
end


"""
    purple(text)
    purple(io, text)

Print a line of text in purple (ANSI 35).

# Inputs
  - text: string to print
  - io: optional `IO` stream to write to (default: `stdout`)

# Notes
  - Convenience wrapper for `cprint(..., ANSI_PURPLE)`.
"""
@inline purple(io::IO, text::AbstractString) = cprint(io, text, ANSI_PURPLE)
@inline purple(text::AbstractString) = cprint(stdout, text, ANSI_PURPLE)

"""
    @purple text
    @purple io text

Print a line of text in purple (ANSI 35).

# Inputs
  - text: string to print
  - io: optional `IO` stream to write to
"""
macro purple(args...)
    return Expr(:call, :purple, map(esc, args)...)
end
