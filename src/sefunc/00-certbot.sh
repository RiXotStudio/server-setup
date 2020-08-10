#!/bin/false
# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/00-server-setup.sh

# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

###! Workflow used to set up certificated on target system

setup_certbot() { funcname="setup_certbot"
	edebug 1 "Started $funcname setup function"

	case "$KERNEL" in
		"linux")
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					efixme "Sanitize certbot"
					# -n == Run non-interactively
					# FIXME: Using nginx as a hotfix, because we don't have HTML frontend
					certbot \
						certonly \
						-n \
						--nginx \
						--force-renewal \
						--domain "$HOSTNAME.$DOMAIN" \
						--domain "imap.$DOMAIN" \
						--domain "pop3.$DOMAIN" \
						--domain "smtp.$DOMAIN" \
					|| die false "Command 'certbot' returned false"
				;;
				*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented in function $funcname"
			esac
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented in function $funcname"
	esac

	edebug 1 "Finished $funcname"

	unset funcname
	return 0
}
