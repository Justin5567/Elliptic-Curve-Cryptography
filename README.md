# Elliptic Curve Cryptography
Implement ECC and ECDSA in Verilog

## How to run
ncverilog TESTBED_**ACTION**.v +access+r

ex
ncverilog TESTBED_add.v +access+r

## FSDB
If you want to see the waveform, you could uncomment the code written in TESTBED_**ACTION**.v

## Note
There are still some corner case in sign/verify I haven't finish, but most function provided in modular.v works.

## Reference
This code is reference from HLS code provided by Xilinx.

