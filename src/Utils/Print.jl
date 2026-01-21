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

Print `text` to standard output using the specified ANSI color `code`.

This is a low-level utility function for customized terminal output.

# Arguments
- `text`: The string to print.
- `code`: The integer ANSI color code (e.g., 31 for red, 32 for green).
- `io`: Optional `IO` stream to write to.

# Examples
```julia
cprint("System initialized", 33) # Prints yellow text
cprint(stderr, "Warning", 33)
```
"""
@inline function cprint(io::IO, text::AbstractString, code::Integer)::Nothing
    print(io, ANSI_PREFIX, code, "m", text, ANSI_RESET, '\n')
    return nothing
end
@inline cprint(text::AbstractString, code::Integer) = cprint(stdout, text, code)


"""

    red(text)
    red(io, text)

Print a line of text in Red (ANSI 31).

Typically used for errors, warnings, or to indicate "Bad Luck" (the Red Skull from the Fortune Teller).

# Examples
```julia
red("Error: Data mismatch detected!")
red(stderr, "Error: Data mismatch detected!")
```
"""
@inline red(io::IO, text::AbstractString) = cprint(io, text, ANSI_RED)
@inline red(text::AbstractString) = cprint(stdout, text, ANSI_RED)

"""
    @red text
    @red io text

Print a line of text in Red (ANSI 31).

This macro expands to `red(text)` or `red(io, text)`.

# Examples
```julia
@red "Error: Data mismatch detected!"
@red stderr "Error: Data mismatch detected!"
```
"""
macro red(args...)
    return Expr(:call, :red, map(esc, args)...)
end


"""
    green(text)
    green(io, text)

Print a line of text in Green (ANSI 32).

This is the color of the Junimos. Use this to indicate success, completed tasks, or stable model conditions.

# Examples
```julia
green("Processing complete. Junimos are happy.")
green(stderr, "Processing complete. Junimos are happy.")
```
"""
@inline green(io::IO, text::AbstractString) = cprint(io, text, ANSI_GREEN)
@inline green(text::AbstractString) = cprint(stdout, text, ANSI_GREEN)

"""
    @green text
    @green io text

Print a line of text in Green (ANSI 32).

This macro expands to `green(text)` or `green(io, text)`.

# Examples
```julia
@green "Processing complete. Junimos are happy."
@green stderr "Processing complete. Junimos are happy."
```
"""
macro green(args...)
    return Expr(:call, :green, map(esc, args)...)
end


"""
    blue(text)
    blue(io, text)

Print a line of text in Blue (ANSI 34).

Use this for general information, hydrological data outputs, or water-related metrics.

# Examples
```julia
blue("Lake level stabilized.")
blue(stderr, "Hydrology data missing.")
```
"""
@inline blue(io::IO, text::AbstractString) = cprint(io, text, ANSI_BLUE)
@inline blue(text::AbstractString) = cprint(stdout, text, ANSI_BLUE)

"""
    @blue text
    @blue io text

Print a line of text in Blue (ANSI 34).

This macro expands to `blue(text)` or `blue(io, text)`.

# Examples
```julia
@blue "Lake level stabilized."
@blue stderr "Hydrology data missing."
```
"""
macro blue(args...)
    return Expr(:call, :blue, map(esc, args)...)
end


"""
    purple(text)
    purple(io, text)

Print a line of text in Purple (ANSI 35).

This is the color of Iridium and Stardrops. Use this for high-priority messages, significant results, or "Great Luck" days.

# Examples
```julia
purple("Optimization finished! Results are Iridium quality.")
purple(stderr, "Optimization finished! Results are Iridium quality.")
```
"""
@inline purple(io::IO, text::AbstractString) = cprint(io, text, ANSI_PURPLE)
@inline purple(text::AbstractString) = cprint(stdout, text, ANSI_PURPLE)

"""
    @purple text
    @purple io text

Print a line of text in Purple (ANSI 35).

This macro expands to `purple(text)` or `purple(io, text)`.

# Examples
```julia
@purple "Optimization finished! Results are Iridium quality."
@purple stderr "Optimization finished! Results are Iridium quality."
```
"""
macro purple(args...)
    return Expr(:call, :purple, map(esc, args)...)
end
