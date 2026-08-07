# nice_export

Code to export numerical data to a result file, timestamp it and add the name of the program that generated the data.
The data is written in scientific notation and defaults to 15 digits.

> [!WARNING]
> Mandatory "Works on my PC" disclaimer

## How to use

### Python

Simply place `nice_export.py` in the same directory as the program that will generate the data and do the following:

```python
import nice_export

# Code that generates your data
# ...
# Let's say you get 3 arrays a1, a2 and a3
# and you want to export everything to the file out.dat

nice_export.do_the_export('out.dat','My data',['a1','a2','a3'],a1,a2,a3)
```

Refer to `nice_export.py` for more details on the arguments that can be passed to `do_the_export()`.

### Mathematica

Simply place `nice_export.wl` in the same directory as the program that will generate the data and do the following:

```mathematica
Import["nice_export.wl"];

(* Code that generates the data *)

DoTheExport["out.dat",{"The description"},cols,data];
```

Refer to `nice_export.wl` for more details on the arguments, or run `?DoTheExport`.
The code was tested in a script (`test.wl`) **and** in a notebook (`test.nb`).

## License

MIT

## Copyright

Copyright (c) 2026 Killian Bouzoud
