# Setup fstab
cat <<EOF >> /etc/fstab
/dev/sda / ext4 defaults 1 1
EOF

# Setup network manager
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

# Allow root login without password
passwd -d root