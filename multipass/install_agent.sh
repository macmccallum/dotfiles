#!/usr/bin/env bash

is_vm() {
    systemd-detect-virt --quiet 2>/dev/null && return 0

    grep -qE "hypervisor|qemu|kvm|vmware|virtualbox" /proc/cpuinfo 2>/dev/null && return 0

    [[ -d /var/lib/cloud ]] && return 0

    return 1
}

if is_vm; then
    echo "VM detected — running VM-only setup"
    # your script here
    if [ ! -d "/workspace" ]; then
        echo "/workspace dir does not exist"
        echo "make sure to mount working dir to /workspace"
        echo "multipass mount /example/dir envname:/workspace"
    fi

    set -e
    echo "Installing Pi agent..."

    curl -fsSL https://pi.dev/install.sh | sh

    echo "Done."
else
    echo "Bare metal — skipping"
fi
