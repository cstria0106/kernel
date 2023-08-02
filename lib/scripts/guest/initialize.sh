# Setup fstab
cat <<EOF >> /etc/fstab
/dev/sda / ext4 defaults 1 1
EOF

# Setup ssh
if [ ! -z "$SSH_PUBLIC_KEY" ]; then
    mkdir -p ~/.ssh
    echo "$SSH_PUBLIC_KEY" >> ~/.ssh/authorized_keys
fi
pacman -S --noconfirm openssh
systemctl enable sshd

# Setup network manager
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

# Allow root login without password
passwd -d root
