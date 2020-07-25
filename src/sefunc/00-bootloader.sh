#!/bin/false
# - Used only for sourcing
# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/server-setup.sh

###! Workflow made to configure bootloader on RiXotStudio's systems

setup_bootloader() { funcname="setup_bootloader"
	edebug 1 "Started $funcname setup function"

	case "$KERNEL" in
		"linux")
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					case "$BOOTLOADER" in
						"grub2")
							efixme "Sanitize grub configuration"
							cat <<-EOF > /etc/default/grub
								GRUB_DEFAULT=0
								# NOTICE(Krey): GRUB UI is disabled to speed up the reboot
								GRUB_TIMEOUT=0
								GRUB_DISTRIBUTOR="\$(lsb_release -si 2>/dev/null || printf '%s\n' $DISTRO)"
								GRUB_CMDLINE_LINUX_DEFAULT="quiet"
								GRUB_CMDLINE_LINUX="selinux=0"
							EOF

							unset funcname
							return 0
						;;
						*) die fixme "Bootloader '$BOOTLOADER' is not implemented in Linux distribution '$DISTRO' using release '$RELEASE' logic for configuration"
					esac
				;;
				*) die fixme "Linux distribution '$DISTRO' with '$RELEASE' is not implemented to handle bootloader configuration"
			esac
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented in $myName to configure the bootloader"
	esac

	die security "Function '$funcname' escaped sanitization"
}
