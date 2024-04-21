# Linux No MMU Environment Running on NEMU

This repository contains the necessary environment for running a Linux No MMU on a RISC-V simulator. The environment includes the bootloader and the device tree for Linux userspace.

# Usage

## Compiling the linux kernel

clone mini-rv32ima project

```bash
$ git clone https://github.com/cnlohr/mini-rv32ima.git
```

compile it 

```bash 
make everything
```

Now, we can obtain the linux no mmu image in the `mini-rv32ima/buildroot` directory


## Running on NEMU

```bash
make run BUILDROOT_DIR=<PATH-TO-BUILDROOT>
```