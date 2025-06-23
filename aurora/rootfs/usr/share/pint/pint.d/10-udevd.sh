#!/bin/bash

source /etc/profile
echo "Starting udevd..."
/sbin/udevd --daemon || echo "Failed..?"
udevadm trigger || echo "Failed 2..?"
udevadm settle || echo "Failed 3..?"
echo "Done."
