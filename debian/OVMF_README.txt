The OVMF images were built through the edk2 github repository.

git clone https://github.com/tianocore/edk2

set up the build environment

copy the Logo.bmp to ./edk2/MdeModulePkg/Logo/

call ./edk2/OvmfPkg/build.sh -a X64 -b RELEASE

The license is under ./edk2/OvmfPkg/License.txt
