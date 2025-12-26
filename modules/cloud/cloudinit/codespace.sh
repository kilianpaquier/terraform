#!/bin/sh
# shellcheck disable=SC2154

# Must be run through terraform / opentofu to get the proper output

if [ "$(id -u)" -ne 0 ]; then exec sudo "$0" "$@"; fi

set -eu

USER_HOME=/home/nonroot

export DEBIAN_FRONTEND=noninteractive

# Timezone
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo "Europe/Paris" > /etc/timezone

# Hostname
hostnamectl set-hostname codespace

# Packages
apt-get update -y
apt-get upgrade -y
apt-get install -y fail2ban rsyslog ufw zsh

# User
if ! id nonroot >/dev/null 2>&1; then
  useradd \
    --comment "NonRoot" \
    --groups adm,docker,plugdev,sudo \
    --home $USER_HOME \
    --shell /bin/zsh \
    nonroot
fi

install -d -m 700 -o nonroot -g nonroot $USER_HOME/.ssh
cat > $USER_HOME/.ssh/authorized_keys <<EOF
%{ for public_key in public_keys ~}
${public_key}
%{ endfor ~}
EOF
chown nonroot:nonroot $USER_HOME/.ssh/authorized_keys
chmod 600 $USER_HOME/.ssh/authorized_keys

echo "nonroot ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/nonroot
chmod 440 /etc/sudoers.d/nonroot

# Fail2ban SSH jail
cat > /etc/fail2ban/jail.d/sshd.conf <<EOF
[sshd]
enabled  = true
port     = ${ssh_port}
filter   = sshd
maxretry = 3
findtime = 5m
bantime  = 30m
EOF

# SSH hardening
cat > /etc/ssh/sshd_config.d/cloud-init.conf <<EOF
AllowUsers nonroot
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
MaxAuthTries 3
PasswordAuthentication no
PermitRootLogin no
Port ${ssh_port}
PubkeyAuthentication yes
EOF

# UFW
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

ufw allow 80/tcp
ufw allow 443/tcp
ufw allow "${ssh_port}/tcp"
ufw limit "${ssh_port}/tcp"

# ufw allow in on docker0 to any port 80,443 proto tcp
# ufw allow out on docker0

ufw --force enable

# Services
systemctl enable rsyslog fail2ban ssh
systemctl restart rsyslog fail2ban ssh
