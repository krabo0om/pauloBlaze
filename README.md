# pauloBlaze
A plain VHDL implementation of a small microprocessor fully compatible with the ISA of the well known PicoBlaze by Ken Chapman.

The focus is on portability and easy extendability. This costs some performance (as little as 4% on a Virtex 7) and more resources (up to 2.5X on a Virtex 7). Details can be found in the [PauloBlaze documentation](/documentation.pdf).

# Getting Started

The PauloBlaze is a simple collection of VHDL files, with the top level module described in `sources/pauloBlaze.vhd`.

If you are using Xilinx ISE or Vivado, two projects are already set up. The ISE project includes a simple testbench running some program. The Vivado project includes the original KCPSM6 and a testbench running both processors in parallel and comparing their outputs. This is good for testing and debugging. Both testbenches can be easily added to ISE or Vivado.

## With ISE
1. Clone this repository (`git clone https://github.com/krabo0om/pauloBlaze.git`)
1. Start ISE 14.7
2. Open the project (`projects/ise14_7/`)

## With Vivado

```bash
git clone https://github.com/krabo0om/pauloBlaze.git
cd pauloBlaze/projects/vivado
vivado -mode batch -source create_project.tcl
vivado PauloBlaze.xpr
```

# Known Issues and Bugs

Please refer to the [issue tracker](https://github.com/krabo0om/pauloBlaze/issues).
