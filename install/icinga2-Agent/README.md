# Script for automatically installing Icinga2 according to the official documentation on DEBIAN, UBUNTU, RHEL, FEDORA, and ALPINE

# Initial installation script; still in the testing/development phase

# Functions:

Installs the Icinga2 agent and monitoring plugins

# How to run?

```bash
apt install -y curl wget

wget https://github.com/HenryyXVIII/scripts/raw/refs/heads/main/install/icinga2-Agent/install.sh
chmod +x ./install.sh
sudo ./install.sh

```

#Adding Features:

automatic configuration (enpoint/parent)
