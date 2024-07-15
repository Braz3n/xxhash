# xxhash
A SystemVerilog implementation of xxhash32 and xxhash64. The build system is tailored specifically to Xilinx/Vivado, however the code is entirely in platform agnostic C++/SystemVerilog, so it can be readily ported to other toolchains.

Functionaility is verified by comparing to the output of the [implementation written by Stephan Brumme](https://github.com/stbrumme/xxhash).

## Dependencies
- Vivado
- meson
- ninja

## Synthesis
Simply run `ninja` at the root of the repository. This will synthesise the modules, generate the test data, and run the testbenches.