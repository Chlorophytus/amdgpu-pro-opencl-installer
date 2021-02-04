#!/bin/bash
# This script is adapted from the 'opencl-amd' Arch Linux package: https://aur.archlinux.org/packages/opencl-amd/
# Install proprietary opencl components only!! - Run as root
# If amdgpu-pro stack is installed, completely purge it from system first by:
# 1) running 'amdgpu-pro-uninstall'
# 2) removing amdgpu-pro directory remnants 'rm -rf /opt/amdgpu*'
# 3) reboot

# Set packaging variables
pkgname='opencl-amd'
prefix='amdgpu-pro-'
major='20.45'
minor='1188099'
postfix='rhel-8.2'
arch='x86_64'
platform='el8'
amdver='2.4.100'

srcdir=~/${pkgname}

mkdir -vp $srcdir
cd ${srcdir}

# referer="http://support.amd.com/en-us/kb-articles/Pages/Radeon-Software-for-Linux-Release-Notes.aspx"
# download="https://www2.ati.com/drivers/linux/rhel7/${prefix}${major}-${minor}.tar.xz"

echo "Downloader disabled, provide your own AMDGPU Pro 20.45 with RHEL8 support"

# Remove previous downloads if they exist
# rm -rf ${prefix}${major}-${minor}.tar.xz
# rm -rf ${prefix}${major}-${minor}

# Download amdgpu-pro RHEL7 package from AMD's driver page
# wget ${download} --referer ${referer}

# Extract package
tar -xvf ${prefix}${major}-${minor}-${postfix}.tar.xz

# Change 'libdrm_amdgpu' references to 'libdrm_amdgpo' - Required workaround
mkdir -vp "${srcdir}/opencl"
cd "${srcdir}/opencl"
rpm2cpio "${srcdir}/${prefix}${major}-${minor}-${postfix}/RPMS/${arch}/opencl-orca-amdgpu-pro-icd-${major}-${minor}.${platform}.${arch}.rpm" | cpio -idmv
rpm2cpio "${srcdir}/${prefix}${major}-${minor}-${postfix}/RPMS/${arch}/comgr-amdgpu-pro-1.7.0-${minor}.${platform}.${arch}.rpm" | cpio -idmv
cd opt/amdgpu-pro/lib64
sed -i "s|libdrm_amdgpu|libdrm_amdgpo|g" libamdocl-orca64.so

# Rename libraries to reflect the 'amdgpo' rename
mkdir -p "${srcdir}/libdrm"
cd "${srcdir}/libdrm"
rpm2cpio "${srcdir}/${prefix}${major}-${minor}-${postfix}/RPMS/${arch}/libdrm-amdgpu-${amdver}-${minor}.${platform}.${arch}.rpm"  | cpio -idmv
cd opt/amdgpu/lib64/
rm -vf "libdrm_amdgpu.so.1"
mv -vf "libdrm_amdgpu.so.1.0.0" "libdrm_amdgpo.so.1.0.0"
ln -vs "libdrm_amdgpo.so.1.0.0" "libdrm_amdgpo.so.1"

# Copy OpenCL icd file
mkdir -vp /etc/OpenCL/vendors/
mv -vf "${srcdir}/opencl/etc/OpenCL/vendors/amdocl-orca64.icd" /etc/OpenCL/vendors/

# Copy libraries
/bin/cp -vf "${srcdir}/opencl/opt/amdgpu-pro/lib64/libamd_comgr.so.1" "/usr/lib64/"
/bin/cp -vf "${srcdir}/opencl/opt/amdgpu-pro/lib64/libamd_comgr.so.1.7.0" "/usr/lib64/"
/bin/cp -vf "${srcdir}/opencl/opt/amdgpu-pro/lib64/libamdocl-orca64.so" "/usr/lib64/"
/bin/cp -vf "${srcdir}/opencl/opt/amdgpu-pro/lib64/libamdocl-orca64.so" "/usr/lib64/"
/bin/cp -vf "${srcdir}/opencl/opt/amdgpu-pro/lib64/libamdocl12cl64.so" "/usr/lib64/"
/bin/cp -vf "${srcdir}/libdrm/opt/amdgpu/lib64/libdrm_amdgpo.so.1.0.0" "/usr/lib64/"
/bin/cp -vf "${srcdir}/libdrm/opt/amdgpu/lib64/libdrm_amdgpo.so.1" "/usr/lib64/"

# link .ids file
mkdir -vp "/opt/amdgpu/share/libdrm"
cd "/opt/amdgpu/share/libdrm"
rm -vf amdgpu.ids
ln -vs /usr/share/libdrm/amdgpu.ids amdgpu.ids

# Cleanup
rm -vrf "${srcdir}/opencl"
rm -vrf "${srcdir}/libdrm"

# rm -rf ${srcdir} # optional - clean up entire download
