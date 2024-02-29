# Kernel

Linux kernel study repository
Includes justfile script for build/run/debug kernel

## How to start
```sh
# Clone repository
git clone https://github.com/cstria0106/kernel

# Make config
cd linux && make nconfig

# Build
just build

# Generate os file system (only available in Arch Linux with pacstrap)
just create-img 64G

# Build
just build
just install-modules

# Run
just start

# Now guest will be booted
# You can login as root without password
# To terminate, type ^A and X

# SSH ingo guest
make ssh
```

### Debug
- Enable debugging features of kernel
- Enable GDB scripts(GDB_SCRIPTS) feature of kernel
- Disable KASLR(CONFIG_RANDOMIZE_BASE) feature of kernel
- Install Cgdb
- Add "add-auto-load-safe-path [directory]" in ~/.gdbinit

```sh
just debug
```
