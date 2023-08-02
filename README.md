# Kernel

My Linux kernel study repository with build/debug scripts!

## How to start
```sh
# Clone repository
git clone --recurse-submodules https://github.com/cstria0106/kernel

# Configure kernel
cd kernel/linux
make menuconfig
cd ..

# Generate file system image (only available on Arch Linux)
./lib/scripts/generate-image.sh rootfs

# Build and run!
make kernel
make kernel-modules
make run

# Now you are in guest Linux VM
# You can login as root without password
# To terminate VM, type ^A and X
```

### Debug
- Enable debugging features of kernel
- Enable GDB scripts(GDB_SCRIPTS)
- Disable KASLR(CONFIG_RANDOMIZE_BASE) feature of kernel
- Install Cgdb
- Add "add-auto-load-safe-path [directory]" in ~/.gdbinit

```sh
make debug
```