#
# Create admin user, copy SSH public key and disable root login
#

# Create user
useradd -m -d /home/${INIT_USER} -s /bin/bash ${INIT_USER}

# Enable sudo for the user
usermod -aG sudo ${INIT_USER}
echo "${INIT_USER}  ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${INIT_USER}

# Setup SSH public key authentication for the user
mkdir /home/${INIT_USER}/.ssh
echo "${INIT_PUBKEY}" > /home/${INIT_USER}/.ssh/authorized_keys
chown -R ${INIT_USER}:${INIT_USER} /home/${INIT_USER}/.ssh
chmod 700 /home/${INIT_USER}/.ssh
chmod 600 /home/${INIT_USER}/.ssh/authorized_keys

# Disable root login
sed -i 's/PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
# Disable SSH password authentication
sed -i 's/PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart sshd

# Make sure the user has the right permissions
chmod 755 /home/${INIT_USER}
chown ${INIT_USER}:${INIT_USER} /home/${INIT_USER}

echo "INIT Users done." >> ${INIT_LOG}

# EOF

