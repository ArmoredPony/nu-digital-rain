# Nu Digital Rain

A simple implementation of the iconic [digital rain] effect for [Nushell].

Download the script, import it with `use digital-rain.nu` and run with `digital-rain`.

Tinker with animation speed, spawn rate of droplets, lengths and colors of parts
of the droplets, the background color and displayed characters to your heart's
content. Call with `-h` or `--help` for more info about animation parameters.

Here's an example you can paste into your Nushell session after importing the script
```nushell
(digital-rain
--drop-len 6
--tip-len 2
--tail-len 2
--drop-clr (ansi -e {fg: '#828998'})
--tip-clr (ansi -e {fg: '#acb0b8'})
--tail-clr (ansi -e {fg: '#68707c'})
--bg-clr (ansi -e {bg: '#4d5665'})
--speed 400
--period 5
)
```

Or just enjoy sensible defaults

For this script to be ran your terminal must support [ANSI escape codes] which
it most likely does.

[digital rain]: https://en.wikipedia.org/wiki/Matrix_digital_rain
[Nushell]: https://www.nushell.sh
[ANSI escape codes]: https://en.wikipedia.org/wiki/ANSI_escape_code
