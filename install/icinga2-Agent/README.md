# Script for automatically installing Icinga2 according to the official documentation on DEBIAN, UBUNTU, RHEL, FEDORA, and ALPINE

# Initial installation script; still in the testing/development phase

# Functions:

Installs the Icinga2 agent and monitoring plugins

testet on:
- debian 13
- alpine v3.23

# How to run?

```bash
# DEBAIN/UBUNTU
apt install -y curl wget

wget -O - https://github.com/HenryyXVIII/scripts/raw/refs/heads/main/install/icinga2-Agent/install.sh | bash

# ALPINE
apk update && apk add curl wget bash

wget -O - https://github.com/HenryyXVIII/scripts/raw/refs/heads/main/install/icinga2-Agent/install.sh | bash


```

#Adding Features:

automatic configuration (enpoint/parent)
