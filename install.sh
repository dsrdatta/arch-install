#!/bin/bash

set -e

./partition.sh
./format_and_mount.sh

echo "Partitioning and formatting complete."