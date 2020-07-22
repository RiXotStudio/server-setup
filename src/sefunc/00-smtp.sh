#!/bin/false
# - Used only for sourcing
# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/server-setup.sh

###! Workflow made to configure SMTP handler on RiXotStudio's systems
###! We are using 'postfix' for reasons stated in https://github.com/Kreyren/kreyren/issues/24

setup_smtp() { funcname="setup_smtp"
	case "$KERNEL" in
		"linux")
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					einfo "Installing SMTP handler 'postfix'"
					elog "$(invoke_privileged "$APT_GET" install -y postfix || die false "Unable to install package 'postfix'")"

					# Configure
					cat <<-EOF > /etc/postfix/main.cf
						FIXME
					EOF
				;;
				*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented in function '$funcname'"
			esac
		;;
		*) die fixme "Kernel '$KERNEL' is not implement in function $funcname"
	esac
}
