#!/bin/bash

set -e

./partition.sh
./format_and_mount.sh
./install_base.sh
./chroot_setup.sh
./install_grub.sh