set -ex

zcat /proc/config.gz > .config
./scripts/config --enable-after KVM KVM_NYX
yes "" | make oldconfig
make modules_prepare

if [ -z "${KERNEL_DIR}" ]; then
  if [ -f /etc/NIXOS ]; then
    KERNEL_DIR="$(nix-build -E '(import <nixpkgs> {}).linux.dev' --no-out-link)/lib/modules/*/build"
  else
    KERNEL_DIR=/lib/modules/`uname -r`/build
  fi
fi

cp $KERNEL_DIR/scripts/module.lds scripts/
cp $KERNEL_DIR/Module.symvers .
cp $KERNEL_DIR/include/config/kernel.release include/config/kernel.release
cp $KERNEL_DIR/include/generated/utsrelease.h include/generated/utsrelease.h

make  M=arch/x86/kvm/ -j
echo "[!] kvm-nyx successfully compiled"
