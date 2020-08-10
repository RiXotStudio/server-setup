#!/bin/false
# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/00-server-setup.sh

# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

###! Workflow used to set up tor on target system using RiXotStudio's configuration

# FIXME-SECURITY:
## Jul 25 15:38:04.297 [warn] Tor is currently configured as a relay and a hidden service. That's not very secure: you should probably run your hidden service in a separate Tor process, at least -- see https://trac.torproject.org/8742


setup_cron() { funcname="setup_cron"
	edebug 1 "Started $funcname setup function"

	case "$KERNEL" in
		"linux")
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					# FIXME: Implement eapt
					#eapt install cron

					cat <<-EOF > /etc/crontab
						# /etc/crontab: system-wide crontab
						# Unlike any other crontab you don't have to run the 'crontab'
						# command to install the new version when you edit this file
						# and files in /etc/cron.d. These files also have username fields,
						# that none of the other crontabs do.

						# Helper: https://crontab.guru/

						SHELL=/bin/sh
						PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

						# Example of job definition:
						# .---------------- minute (0 - 59)
						# |  .------------- hour (0 - 23)
						# |  |  .---------- day of month (1 - 31)
						# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
						# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
						# |  |  |  |  |
						# *  *  *  *  * user-name command to be executed

						# Keep the system up-to-date at minute 0 past every 8th hour
						0 */8 * * * root DEBIAN_FRONTEND=noninteractive apt-get update -q && apt-get full-upgrade -qy
					EOF

					# Make sure that crontab has the appropriate permission
					"$CHMOD" 0660 /etc/crontab || die false "Unable to set the appropriate permission to file '/etc/crontab' in a function '$funcname'"
					"$CHOWN" root:root /etc/crontab || die false "Unable to set the appropriate ownership of file '/etc/crontab' in a function '$funcname'"
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
