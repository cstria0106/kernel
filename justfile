alias umount := unmount

image-name := ".image"
ssh-port := "3822"

default:
    just --list

_success message:
    @green=$(tput setaf 2) &&\
    bold=$(tput bold) &&\
    reset=$(tput sgr0) &&\
    echo "${bold}${green}success:${reset}${bold} {{message}}${reset}"

_error message:
    @red=$(tput setaf 1) &&\
    bold=$(tput bold) &&\
    reset=$(tput sgr0) &&\
    echo "${bold}${red}error:${reset}${bold} {{message}}${reset}"

_test_file file:
    @test -e {{file}} || (just _error "File \\\"{{file}}\\\" does not exists." && false)

_test_image:
    @test -e {{image-name}} || (just _error "Image does not exists." && false)

mount:
    @test ! -x mount || (just _error "Already mounted. (if not, just delete .mount file)" && false)
    @just _test_image
    @mkdir -p mount &&\
    sudo mount {{image-name}} mount
    @just _success "Successfully mounted. \\\"cd mount\\\" to go to directory."

unmount:
    @test -x mount || (just _error "Not mounted yet." && false)
    @sudo umount mount
    @rm -r mount
    @just _success "Successfully unmounted."

create-img size:
    @[ -x "$(command -v qemu-img)" ] || (just _error "Please install qemu." && false)
    @[ ! -e {{image-name}} ] || (just _error "Image already exists." && false)
    @qemu-img create -f raw {{image-name}} "{{size}}" > /dev/null
    @mkfs.ext4 {{image-name}} &> /dev/null
    @(just unmount || true) &> /dev/null
    @just mount &> /dev/null
    @sudo pacstrap mount
    @ssh-keygen -ted25519 -f .ssh_identity -N ""
    @SSH_PUBLIC_KEY=$(printf "%q" | cat .ssh_identity.pub) &&\
    echo -e -n \
        "\rcat <<EOF >> /etc/fstab\n\
         \r/dev/sda / ext4 defaults 1 1\n\
         \rEOF\n\
         \rif [[ ! -z \"${SSH_PUBLIC_KEY}\" ]]; then\n\
         \r  mkdir -p ~/.ssh\n\
         \r  echo \"$SSH_PUBLIC_KEY\" >> ~/.ssh/authorized_keys\n\
         \rfi\n\
         \rpacman -S --noconfirm openssh networkmanager\n\
         \rsystemctl enable sshd\n\
         \rsystemctl enable NetworkManager\n\
         \rpasswd -d root" | envsubst | sudo arch-chroot mount
    @just unmount &> /dev/null

start:
    @just _test_file "linux/arch/x86_64/boot/bzImage"
    @just _test_image
    @qemu-system-x86_64 \
        -s \
        -kernel linux/arch/x86_64/boot/bzImage -drive format=raw,file={{image-name}} \
        -enable-kvm -nographic -m 16G -cpu host -smp `nproc` \
        -nic user,hostfwd=tcp::{{ssh-port}}-:22	\
        -append "quiet root=/dev/sda earlyprintk=serial,ttyS0,9600 console=ttyS0,9600n8"

install-modules:
    @just mount &> /dev/null
    @cd linux && sudo INSTALL_MOD_PATH=../mount make -j`nproc` modules_install
    @just unmount &> /dev/null
    @just _success "Successfully installed kernel modules"

build:
    cd linux && make -j`nproc`

ssh:
    ssh -p {{ssh-port}} root@localhost -i .ssh_identity
