export 
  cprint,
  red, green, blue, purple


"""
    cprint(text, code)

Print `text` to standard output using the specified ANSI color `code`.

This is a low-level utility function for customized terminal output.

# Arguments
- `text`: The string to print.
- `code`: The integer ANSI color code (e.g., 31 for red, 32 for green).

# Examples
```julia
cprint("System initialized", 33) # Prints yellow text
```
"""
cprint(text, code) = println("\x1b[$(code)m$text\x1b[0m")


"""

    red(text)

Print a line of text in Red (ANSI 31).

Typically used for errors, warnings, or to indicate "Bad Luck" (the Red Skull from the Fortune Teller).

# Examples
```julia
red("Error: Data mismatch detected!")
```
"""
red(text) = println("\x1b[31m$text\x1b[0m")


"""
    green(text)

Print a line of text in Green (ANSI 32).

This is the color of the Junimos. Use this to indicate success, completed tasks, or stable model conditions.

# Examples
```julia
green("Processing complete. Junimos are happy.")
```
"""
green(text) = println("\x1b[32m$text\x1b[0m")


"""
    blue(text)

Print a line of text in Blue (ANSI 34).

Use this for general information, hydrological data outputs, or water-related metrics. 
"""
blue(text) = println("\x1b[34m$text\x1b[0m")


"""
    purple(text)

Print a line of text in Purple (ANSI 35).

This is the color of Iridium and Stardrops. Use this for high-priority messages, significant results, or "Great Luck" days.

# Examples
```julia
purple("Optimization finished! Results are Iridium quality.")
```
"""
purple(text) = println("\x1b[35m$text\x1b[0m")
