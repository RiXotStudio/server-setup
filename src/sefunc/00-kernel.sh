#!/bin/false
# - Used only for sourcing
# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/server-setup.sh

###! Workflow made to configure kernel on RiXotStudio's systems

setup_kernel() { funcname="setup_kernel"
	# NOTICE(Krey): Currently we need a kernel optimized for our workload, using Liquorix as fast fix
	einfo "Configuring kernel"
	case "$KERNEL" in
		"linux")
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					ewarn "Usage of liquorix kernel is a fast fix, custom compilation of linux kernel is preferrable"
					einfo "Installing liquorix kernel"
					efixme "Sanitize liquorix pubkey configuration"
					curl 'https://liquorix.net/linux-liquorix.pub' | invoke_privileged apt-key add -

					elog "Installing liquorix kernel dependencies"
					efixme "Sanitize installation of liquorix dependencies"
					elog "$(invoke_privileged "$APT_GET" install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64 grub2)"

					unset funcname
					return 0
				;;
				*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented to handle kernel configuration"
			esac
		;;
		*) die fixme "System with kernel '$KERNEL' is not implemented to configure kernel through $myName script"
	esac
}
