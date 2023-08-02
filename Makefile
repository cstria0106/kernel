MOUNT_DIR := $(CURDIR)/mount
LINUX_DIR := $(CURDIR)/linux
SSH_PORT  := 4200
ROOTFS    := $(CURDIR)/rootfs
BZIMAGE   := $(LINUX_DIR)/arch/x86_64/boot/bzImage

all: kernel run

mount: $(ROOTFS)
	sudo mkdir -p $(MOUNT_DIR)
	sudo mount $(ROOTFS) $(MOUNT_DIR)

umount: $(MOUNT_DIR)
	sudo umount $(MOUNT_DIR)
	sudo rm -r $(MOUNT_DIR)

kernel:
	cd $(LINUX_DIR) && make -j`nproc`

install-kernel-modules: kernel mount _install-kernel-modules umount

_install-kernel-modules:
	cd $(LINUX_DIR) && sudo INSTALL_MOD_PATH=$(MOUNT_DIR) make -j`nproc` modules_install

run: $(ROOTFS) $(BZIMAGE) 
	qemu-system-x86_64 \
		-s \
		-kernel $(BZIMAGE) -drive format=raw,file=$(ROOTFS),if=ide \
		-enable-kvm -nographic -m 16G -cpu host -smp `nproc` \
		-nic user,hostfwd=tcp::$(SSH_PORT)-:22	\
		-append "quiet root=/dev/sda earlyprintk=serial,ttyS0,9600 console=ttyS0,9600n8"

debug: $(LINUX_DIR)/vmlinux-gdb.py $(LINUX_DIR)/scripts/gdb
	cp $(LINUX_DIR)/vmlinux-gdb.py .
	mkdir -p scripts
	cp -r $(LINUX_DIR)/scripts/gdb scripts
	cp $(LINUX_DIR)/vmlinux .
	cgdb vmlinux

ssh: .ssh_identity
	ssh -p $(SSH_PORT) -i .ssh_identity root@localhost

clean:
	rm -rf scripts
	rm -f vmlinux
	rm -f vmlinux-gdb.py
