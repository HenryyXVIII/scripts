# Script for automatically installing Icinga2 according to the official documentation on DEBIAN, UBUNTU, RHEL, FEDORA, and ALPINE

# Initial installation script; still in the testing/development phase

# Functions:

Installs the Icinga2 agent and monitoring plugins

testet on:
- debian 13
- alpine v3.23
- ubuntu 22.04.4 LTS

# How to run?
## Install on debian/ubuntu
```bash

sudo apt install -y curl wget

curl -fsSL https://github.com/HenryyXVIII/scripts/raw/refs/heads/main/install/icinga2-Agent/install.sh | sudo bash
```

## Install on Alpine

```bash
# ALPINE
apk update && apk add curl wget bash

wget -O - https://github.com/HenryyXVIII/scripts/raw/refs/heads/main/install/icinga2-Agent/install.sh | bash


```

# Adding Features:

automatic configuration (enpoint/parent)
