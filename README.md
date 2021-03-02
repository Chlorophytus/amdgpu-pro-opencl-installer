# amdgpu-pro-opencl-installer
_Disclaimer_: **Here be dragons, this is unsupported and will make your install UNSUPPORTED.**

AMD OpenCL installer scripts for Linux. These scripts install AMD's "headless" OpenCL components alongside the open source amdgpu stack. These scripts are adapted for OpenSUSE and Fedora from the ['opencl-amd' Arch Linux package](https://aur.archlinux.org/packages/opencl-amd/), and are also adapted from the repo I forked from.

## Assumptions

A recent AMD GPU is required. 

[amdgpu_opencl_install.sh](/amdgpu_opencl_install.sh) has been tested against the following 64 bit rpm based distributions: 

 * OpenSUSE Tumbleweed (as of February 3, 2021)
 
## Prerequisites 

The clinfo package is required to verify successful installation and run other OpenCL programs and utilities such as xmr-stak. You may need more packages depending on your base installation (minimal install, etc).

### OpenSUSE 
```shell
sudo zypper in -y clinfo
```

### Fedora
```shell
sudo dnf install -y clinfo
```
### Pre-Polars (RX 460, RX 470, RX 480) GPUs

The 'amdgpu' kernel module is required to run the OpenCL components! If you're using the 'radeon' kernel module (default for 7900 series, 200 series, 300 series GPUs), you will need to blacklist the radeon module and add the following kernel parameters to your grub defaults in /etc/defaults/grub: 
```
modprobe.blacklist=radeon radeon.si_support=0 radeon.cik_support=0 amdgpu.exp_hw_support=1 amdgpu.si_support=1 amdgpu.cik_support=1
```
For example, if you're using an HD 7870, R9 290X, or R9 390 you will need the above kernel parameters. Please see [Fedora's documentation on adding kernel parameters to grub](https://docs-old.fedoraproject.org/en-US/Fedora/23/html/Multiboot_Guide/GRUB-configuration.html).

Please note that you do not actually need _all_ of the above parameters depending on your actual hardware setup. 
 
Kernel version 4.15 or greater recommended. 

## Post Installation

Setting the OCL_ICD_VENDORS environment variable allows running clinfo and other utilities under a non-root context.
```shell
export OCL_ICD_VENDORS=/etc/OpenCL/vendors/
```
Setting the OCL_ICD_VENDORS environment variable to AMD specific devices will prevent Intel iGPU OpenCL devices from enumerating. This is usually desired, but it depends on your intentions. 
```shell
export OCL_ICD_VENDORS=/etc/OpenCL/vendors/amdocl64.icd
```
