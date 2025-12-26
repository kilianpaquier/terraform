#!/bin/sh
# shellcheck disable=SC2154

# Must be run through terraform / opentofu to get the proper output

if [ "$(id -u)" -ne 0 ]; then exec sudo "$0" "$@"; fi

set -eu

export DEBIAN_FRONTEND=noninteractive

# Timezone
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo "Europe/Paris" > /etc/timezone

# Hostname
hostnamectl set-hostname coolify

# Packages
apt-get update -y
apt-get upgrade -y
apt-get install -y fail2ban rsyslog ufw curl ca-certificates

# SSH authorized keys
install -d -m 700 /root/.ssh
cat > /root/.ssh/authorized_keys <<EOF
%{ for public_key in public_keys ~}
${public_key}
%{ endfor ~}
EOF
chmod 600 /root/.ssh/authorized_keys

# SSH hardening
cat > /etc/ssh/sshd_config.d/cloud-init.conf <<EOF
AllowUsers root
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
MaxAuthTries 3
PasswordAuthentication no
PermitRootLogin prohibit-password
Port ${ssh_port}
PubkeyAuthentication yes
EOF

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

# Fail2ban Traefik filters
cat > /etc/fail2ban/filter.d/traefik-auth.conf <<'EOF'
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*HTTP.*" (401|403)
EOF

cat > /etc/fail2ban/filter.d/traefik-404.conf <<'EOF'
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*HTTP.*" 404
EOF

cat > /etc/fail2ban/jail.d/traefik.conf <<'EOF'
[traefik-auth]
enabled  = true
port     = 80,443
filter   = traefik-auth
logpath  = /data/coolify/proxy/access.log
maxretry = 5
findtime = 5m
bantime  = 30m

[traefik-404]
enabled  = true
port     = 80,443
filter   = traefik-404
logpath  = /data/coolify/proxy/access.log
maxretry = 10
findtime = 5m
bantime  = 30m
EOF

# UFW
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 6001/tcp
ufw allow 6002/tcp
ufw allow 8000/tcp
ufw allow "${ssh_port}/tcp"

# ufw allow in on docker0 to any port 80,443 proto tcp
# ufw allow out on docker0

ufw --force enable

# Services
systemctl enable rsyslog fail2ban ssh
systemctl restart rsyslog fail2ban ssh

env ROOT_USERNAME="${coolify_username}" \
  ROOT_USER_EMAIL="${coolify_email}" \
  ROOT_USER_PASSWORD="${coolify_password}" \
  bash -c 'curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash'
