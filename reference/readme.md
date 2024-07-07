# Reference Implementation

Used to verify the FPGA implementation. Builds upon the implementation from [here](https://github.com/stbrumme/xxhash).

## Compilation and Execution 
```
meson setup build
cd build
meson compile
./xxhash32_reference
```