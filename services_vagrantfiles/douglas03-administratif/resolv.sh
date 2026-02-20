cat > /etc/resolv.conf << EOF
nameserver 192.168.1.98
EOF

if [ -L /etc/resolv.conf ]; then rm /etc/resolv.conf; fi

chattr +i /etc/resolv.conf

