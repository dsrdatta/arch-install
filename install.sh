#!/bin/bash

set -e

./pre_install.sh
./partition.sh
./format_and_mount.sh
./install_base.sh
./chroot_setup.sh
./install_grub.sh
./install_cleanup.sh