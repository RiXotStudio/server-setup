#!/bin/sh
# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/sefunc/00-bootloader.sh
# shellcheck source=src/sefunc/00-certbot.sh
# shellcheck source=src/sefunc/00-kernel.sh
# shellcheck source=src/sefunc/00-dovecot.sh
# shellcheck source=src/sefunc/00-postfix.sh
# shellcheck source=src/sefunc/00-sshd.sh
# shellcheck source=src/sefunc/00-tor.sh
# shellcheck disable=SC2059 # Krey: Don't use variables in format stings -> NOt possible here since we are appending a format string in a variable
# shellcheck disable=SC2034 # FIXME: Shellcheck doesn't follow our source files, this is just to silence it

# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

#& BUILD-CHECK
printf 'NOT_BUILT: %s\n' "This script is not built, refusing to run - Use 'make build' and reinvoke the script from build directory"; exit 88

###! Administrative script to configure target system to RiXotStudio's standard and expected functionality
###! Requires:
###! - Anything to run posix shell scripts e.g busybox
###! - Command 'lsb_release' to identify distribution on linux
###! - Command 'uname' to identify used kernel
###! Exit codes:
###! - FIXME-DOCS(Krey): Defined in die()
###! Tested Platforms:
###! - [ ] Linux
###!  - [ ] Debian
###!  - [ ] Devuan
###!  - [ ] Gentoo
###!  - [ ] Ubuntu
###!  - [ ] Fedora
###!  - [ ] NixOS
###!  - [ ] Archlinux
###!  - [ ] Alpine
###! - [ ] FreeBSD
###! - [ ] Darwin
###! - [ ] Redox
###! - [ ] ReactOS
###! - [ ] Windows
###! - [ ] Windows/Cygwin
###! Resources:
###! - https://pkgs.org | To search Linux distros for files and package informations

# FIXME: Implement tor option for relevant commands
# FIXME: Implement parts of this code in separate files so that it's more readable
# FIXME-QA: Set up docker tests on expected platforms
# FIXME-QA: Set up vagrant tests on non-linux platform

# Upstream info
UPSTREAM="https://github.com/RiXotStudio/server-setup"
# shellcheck disable=SC2034 # not used, remove disable directive when used
UPSTREAM_NAME="RiXotStudio"
# shellcheck disable=SC2034 # not used, remove disable directive when used
UPSTREAM_EMAIL="info@rixotstudio.cz"

# Maintainer info
# shellcheck disable=SC2034 # not used, remove disable directive when used
MAINTAINER_EMAIL="kreyren@rixotstudio.cz"
MAINTAINER_REPOSITORY="https://github.com/RiXotStudio/server-setup"
MAINTAINER_NICKNAME="kreyren"
# shellcheck disable=SC2034 # Used in src/sefunc/00-tor.sh
MAINTAINER_NAME="Jacob"
# shellcheck disable=SC2034 # Used in src/sefunc/00-tor.sh
MAINTAINER_SURNAME="Hrbek"
# shellcheck disable=SC2034 # Used in src/sefunc/00-tor.sh
MAINTAINER_PUBKEY="765AED304211C28410D5C478FCBA0482B0AB9F10"

# NOTICE(Krey): By default busybox outputs a full path in '$0' this is used to strip it
if [ "$0" != "$SHELL" ]; then
	myName="${0##*/}"
elif [ "$0" = "$SHELL" ]; then
	# FIXME: Implement logic for myName
	myName="server-setup.sh"
else
	# DNM
	echo "boop"
	exit 255
fi

# Used to prefix logs with timestemps, uses ISO 8601 by default
genTime() {	date -u +"%Y-%m-%dT%H:%M:%SZ" ;}
logPrefix="[ $(genTime) ] "
# Path to which we will save logs
# NOTICE(Krey): To avoid storing file '$HOME/.some-name.sh.log' we are stripping the '.sh' here
logPath="${XDG_DATA_HOME:-$HOME/}/${myName%%.sh}.log"

# FIXME: _=${var:="some text"} is less verbose and less error prone than [ -z "$var" ] && var="some text"

# Command overrides
[ -z "$PRINTF" ] && PRINTF="printf"
[ -z "$WGET" ] && WGET="wget"
[ -z "$CURL" ] && CURL="curl"
[ -z "$CAT" ] && CAT="cat"
[ -z "$ARIA2C" ] && ARIA2C="aria2c"
[ -z "$CHMOD" ] && CHMOD="chmod"
[ -z "$CHOWN" ] && CHOWN="chown"
[ -z "$UNAME" ] && UNAME="uname"
[ -z "$TR" ] && TR="tr"
[ -z "$SED" ] && SED="sed"
[ -z "$GREP" ] && GREP="grep"
[ -z "$SUDO" ] && SUDO="sudo"
[ -z "$SU" ] && SU="su"
[ -z "$APT" ] && APT="apt"
[ -z "$APT_GET" ] && APT_GET="apt-get"
[ -z "$ID" ] && ID="id"
[ -z "$MKDIR" ] && MKDIR="mkdir"
[ -z "$LSB_RELEASE" ] && LSB_RELEASE="lsb_release"
[ -z "$EMERGE" ] && EMERGE="emerge"

# Customization of the output
## efixme
[ -z "$EFIXME_FORMAT_STRING" ] && EFIXME_FORMAT_STRING="FIXME: %s\n"
[ -z "$EFIXME_FORMAT_STRING_LOG" ] && EFIXME_FORMAT_STRING_LOG="${logPrefix}FIXME: %s\n"
[ -z "$EFIXME_FORMAT_STRING_DEBUG" ] && EFIXME_FORMAT_STRING_DEBUG="FIXME($myName:$LINENO): %s\n"
[ -z "$EFIXME_FORMAT_STRING_DEBUG_LOG" ] && EFIXME_FORMAT_STRING_DEBUG_LOG="${logPrefix}FIXME($myName:$LINENO): %s\n"
## eerror
[ -z "$EERROR_FORMAT_STRING" ] && EERROR_FORMAT_STRING="ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_LOG" ] && EERROR_FORMAT_STRING_LOG="${logPrefix}ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG" ] && EERROR_FORMAT_STRING_DEBUG="ERROR($myName:$LINENO): %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG_LOG" ] && EERROR_FORMAT_STRING_DEBUG_LOG="${logPrefix}ERROR($myName:$LINENO): %s\n"
## edebug
[ -z "$EERROR_FORMAT_STRING" ] && EERROR_FORMAT_STRING="ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_LOG" ] && EERROR_FORMAT_STRING_LOG="${logPrefix}ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG" ] && EERROR_FORMAT_STRING_DEBUG="ERROR($myName:$LINENO): %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG_LOG" ] && EERROR_FORMAT_STRING_DEBUG_LOG="${logPrefix}ERROR($myName:$LINENO): %s\n"
## einfo
[ -z "$EINFO_FORMAT_STRING" ] && EINFO_FORMAT_STRING="INFO: %s\n"
[ -z "$EINFO_FORMAT_STRING_LOG" ] && EINFO_FORMAT_STRING_LOG="${logPrefix}INFO: %s\n"
[ -z "$EINFO_FORMAT_STRING_DEBUG" ] && EINFO_FORMAT_STRING_DEBUG="INFO($myName:$LINENO): %s\n"
[ -z "$EINFO_FORMAT_STRING_DEBUG_LOG" ] && EINFO_FORMAT_STRING_DEBUG_LOG="${logPrefix}INFO($myName:$LINENO): %s\n"
## die
### Generic
[ -z "$DIE_FORMAT_STRING" ] && DIE_FORMAT_STRING="FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="FATAL($myName:$LINENO): %s\n"
[ -z "$DIE_FORMAT_STRING_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}FATAL($myName:$LINENO): %s\\n"
### Success trap
[ -z "$DIE_FORMAT_STRING_SUCCESS" ] && DIE_FORMAT_STRING_SUCCESS="SUCCESS: Script '$myName' located at '$0' finished successfully\\n"
[ -z "$DIE_FORMAT_STRING_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}$DIE_FORMAT_STRING_SUCCESS"
[ -z "$DIE_FORMAT_STRING_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="SUCCESS($myName:$LINENO): Script '$myName' located at '$0' finished successfully\\n"
[ -z "$DIE_FORMAT_STRING_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}$DIE_FORMAT_STRING_DEBUG_LOG"
### Syntax error (syntaxerr) trap
[ -z "$DIE_FORMAT_STRING_SYNTAXERR" ] && DIE_FORMAT_STRING_SYNTAXERR="SyntaxErr: Invalid argument(s) '$0' '$1' '$2' '$3' '$4' has been provided to $myName\\n"
[ -z "$DIE_FORMAT_STRING_SYNTAXERR_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}$DIE_FORMAT_STRING_SUCCESS"
[ -z "$DIE_FORMAT_STRING_SYNTAXERR_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="SyntaxErr($myName:$LINENO): Invalid argument(s) '$0' '$1' '$2' '$3' '$4' has been provided to $myName\\n"
[ -z "$DIE_FORMAT_STRING_SYNTAXERR_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}$DIE_FORMAT_STRING_DEBUG_LOG"
### Fixme trap
[ -z "$DIE_FORMAT_STRING_FIXME" ] && DIE_FORMAT_STRING_FIXME="FATAL: %s in script '$myName' located at '$0', fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_LOG" ] && DIE_FORMAT_STRING_FIXME_LOG="${logPrefix}FATAL: %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG" ] && DIE_FORMAT_STRING_FIXME_DEBUG="FATAL($myName:$LINENO): %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" ] && DIE_FORMAT_STRING_FIXME_DEBUG_LOG="${logPrefix}FATAL($myName:$LINENO): %s, fixme?\\n"
### Bug Trap
[ -z "$DIE_FORMAT_STRING_BUG" ] && DIE_FORMAT_STRING_BUG="BUG: Unexpected happend while processing %s in script '$myName' located at '$0'\\n\\nIf you think that this is a bug, the report it to $UPSTREAM to @$MAINTAINER_NICKNAME with output from $logPath for relevant runtime"
[ -z "$DIE_FORMAT_STRING_BUG_LOG" ] && DIE_FORMAT_STRING_BUG_LOG="${logPrefix}$DIE_FORMAT_STRING_BUG"
[ -z "$DIE_FORMAT_STRING_BUG_DEBUG" ] && DIE_FORMAT_STRING_BUG_DEBUG="BUG:($myName:$LINENO): ${DIE_FORMAT_STRING_BUG%%BUG:}"
[ -z "$DIE_FORMAT_STRING_BUG_DEBUG_LOG" ] && DIE_FORMAT_STRING_BUG_DEBUG_LOG="${logPrefix}$DIE_FORMAT_STRING_BUG_DEBUG"
### Fixme trap
[ -z "$DIE_FORMAT_STRING_FIXME" ] && DIE_FORMAT_STRING_FIXME="FATAL: %s in script '$myName' located at '$0', fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_LOG" ] && DIE_FORMAT_STRING_FIXME_LOG="${logPrefix}FATAL: %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG" ] && DIE_FORMAT_STRING_FIXME_DEBUG="FATAL($myName:$LINENO): %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" ] && DIE_FORMAT_STRING_FIXME_DEBUG_LOG="${logPrefix}FATAL($myName:$LINENO): %s, fixme?\\n"
### Unexpected trap
[ -z "$DIE_FORMAT_STRING_UNEXPECTED" ] && DIE_FORMAT_STRING_UNEXPECTED="FATAL: Unexpected happend while %s in $myName located at $0\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_LOG" ] && DIE_FORMAT_STRING_UNEXPECTED_LOG="${logPrefix}FATAL: Unexpected happend while %s\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG" ] && DIE_FORMAT_STRING_UNEXPECTED_DEBUG="FATAL($myName:$LINENO): Unexpected happend while %s in $myName located at $0\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG_LOG" ] && DIE_FORMAT_STRING_UNEXPECTED_DEBUG="${logPrefix}FATAL($myName:$LINENO): Unexpected happend while %s\\n"
# elog
[ -z "$ELOG_FORMAT_STRING_DEBUG_LOG" ] && ELOG_FORMAT_STRING_DEBUG_LOG="${logPrefix}LOG: %s\\n"
# ebench
[ -z "$EBENCH_FORMAT_STRING_START" ] && EBENCH_FORMAT_STRING_START="BENCHMARK: Starting benchmark for action %s\n"
[ -z "$EBENCH_FORMAT_STRING_RESULT" ] && EBENCH_FORMAT_STRING_RESULT="BENCHMARK: Action %s took $SECONDS seconds\n"
# invoke_privileged
[ -z "$INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION" ] && INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION="### PRIVILEGED ACCESS REQUEST ###\n\n\s\n"

# Exit on anything unexpected
set -e

# FIXME: Implement sanitization for used shell

# inicialize the script in logs
"$PRINTF" '%s\n' "Started $myName on $("$UNAME" -s) at $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$logPath"

# Function to output fixme messages for unimplemented/expected features that doesn't prevent runtime
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/efixme.sh

# These are appended from https://github.com/RXT0112/Zernit/tree/master/src/RXT0112-1/downstream-classes/zeres-0/bash/output
# Fatal output handling with method to specify exit code and show helpful message for the end-user and in logs
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/die.sh

# Function to output error message
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/einfo.sh

# Function to show warning message for the end-user and in logs
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/ewarn.sh

# Function to show debug messages in logs or for the end-user if variable DEBUG is set on value '1'
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/edebug.sh

# Function to output error message
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/eerror.sh

# Function to relay an output in logs
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/elog.sh

# Function to perform benchmarks in specified parts of the code
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/ebench.sh

# Function to invoke commands as privileged user with method to ensure that it's not abused
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/wrappers/invoke_privileged.sh

# Function to return executability of a command
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/wrappers/cmd_check.sh

# Function to sanitize creation of a directory
#& APPEND vendor/Zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/wrappers/emkdir.sh

# Identify system
if command -v "$UNAME" 1>/dev/null; then
	unameKernel="$("$UNAME" -s)"
	edebug "Identified the kernel as '$unameKernel"
	case "$unameKernel" in
		"Linux")
			KERNEL="$(printf '%s\n' "$unameKernel" | "$TR" [[:upper:]] [[:lower:]])"

			# Assume Linux Distro and release
			# NOTICE(Krey): We are expecting this to return a lowercase value
			if command -v "$LSB_RELEASE" 1>/dev/null; then
				assumedDistro="$("$LSB_RELEASE" -si | "$TR" [[:upper:]] [[:lower:]])"
				assumedRelease="$("$LSB_RELEASE" -cs | "$TR" [[:upper:]] [[:lower:]])"
			elif ! command -v "$LSB_RELEASE" 1>/dev/null && [ -f /etc/os-release ]; then
				assumedDistro="$("$GREP" -o "^ID\=.*" /etc/os-release | "$SED" s/ID=//gm)"
				assumedRelease="$("$GREP" -o "^VERSION_CODENAME\=.*" /etc/os-release | "$SED" s/VERSION_CODENAME=//gm)"
			elif ! command -v "$LSB_RELEASE" 1>/dev/null && [ ! -f /etc/os-release ]; then
				die false "Unable to identify linux distribution using  command 'lsb_release' nor file '/etc/os-release'"
			else
				die unexpected "attempting to assume linux distro and release"
			fi

			edebug "Identified distribution as '$assumedDistro'"
			edebug "Identified distribution release as '$assumedRelease'"

			# Verify Linux Distro
			efixme "Add sanitization logic for other linux distributions"
			case "$assumedDistro" in
				ubuntu | debian | devuan | fedora | nixos | opensuse | gentoo | exherbo)
					DISTRO="$assumedDistro"
				;;
				*) die fixme "Unexpected Linux distribution '$assumedDistro' has been detected."
			esac

			# Verify Linux Distro Release
			efixme "Sanitize verification of linux distro release"
			RELEASE="$assumedRelease"
		;;
		FreeBSD | Redox | Darwin | Windows)
			KERNEL="$unameKernel"
		;;
		*) die unexpected "Unexpected kernel '$unameKernel'"
	esac
elif ! command -v "$UNAME" 1>/dev/null; then
	die false "Standard command '$UNAME' is not available on this system, unable to identify kernel"
else
	die unexpected "identifying system"
fi

# Identify privileges of the end-user
if command -v "$ID" 1>/dev/null; then
	if [ "$("$ID" -u)" = 0 ]; then
		edebug "According to command 'id' user's ID is 0, assuming root"
		privileged="true"
	elif [ "$("$ID" -u)" != 0 ]; then
		edebug "According to command 'id' user's ID is not 0 (user id is $("$ID" -u), assuming non-root"
		privileged="false"
	else
		die unexpected "Command '${ID:-id}' returned unexpected value '$($ID -u)'"
	fi
elif ! command -v "$ID" 1>/dev/null; then
	die fixme "Unable to deduce wether this script has been executed with privileged permission, implement other methods in case command 'id' is not executable on this environment"
else
	die bug "Logic failure happend while identifying privileged user"
fi

# Define hostname
# NOTICE: Variable 'HOSTNAME' is not defined on POSIX sh
if command -v hostname 1>/dev/null; then
	HOSTNAME="$(hostname)"
elif [ -s /etc/hostname ]; then
	HOSTNAME="$(cat /etc/hostname)"
elif ! command -v hostname 1>/dev/null && [ ! -s /etc/hostname ]; then
	die false "Unable to determine the hostname from command 'hostname' (which doesn't exists) and from file /etc/hostname (that doesn't exists or is blank)"
else
	die unexpected "processing hostname"
fi

#& APPEND src/sefunc/00-bootloader.sh

#& APPEND src/sefunc/00-certbot.sh

#& APPEND src/sefunc/00-cron.sh

#& APPEND src/sefunc/00-sshd.sh

#& APPEND src/sefunc/00-tor.sh

#& APPEND src/sefunc/00-torsocks.sh

#& APPEND src/sefunc/00-postfix.sh

#& APPEND src/sefunc/00-secret.sh

#& APPEND src/sefunc/00-dovecot.sh

#& APPEND src/sefunc/00-kernel.sh

# This is a stub implementation
efixme "Implement logic to determine which bootloader is used" # FIXME
BOOTLOADER="grub2"

# Used a stub implementation in case we need to handle different tor directories
torDir="/etc/tor/"

# FIXME-QA(Krey): There should be a better implementation for this
DOMAIN="rixotstudio.cz"

### SECURITY-CHECKLIST
# - [X] Disable SELinux
# - [ ] Optimize firewall
# - [X] Bootloader security
#   - GRUB_TIMEOUT=0 is set to prevent someone from calling shell and changing boot records
# - [ ] BIOS security
#   - Needs to be configured to require a password to access BIOS
# - [ ] Do we care about portmap services?
#   - HELP_WANTED
# - [ ] Disable root login in /etc/securetty
#   - FIXME: Implement
# - [ ] Implement password policy
# - [ ] Implement snitching measure that checks integrity of files and performs counter-measures if someone alters them

# Argument management
while [ "$#" -gt 0 ]; do case "$1" in
	# Configure target system to be up to standard for RiXotStudio's usage
	"configure-system")
		efixme "Implement a cron job to automatically update the system"
		efixme "Set up mailserver to inform administrators about vulnerabilities"

		# Configure the system to run tor in package manager if supported
		case "$KERNEL" in
			"linux")
				case "$DISTRO/$RELEASE" in
					"devuan/chimaera")
						# On apt-based distributions we need 'apt-transport-tor' package so that the package manager knows how to use tor
						if "$APT" list --installed apt-transport-tor >/dev/null 2>&1; then
							edebug 1 "Package 'apt-transport-tor' is already installed on $DISTRO/$RELEASE"
						elif ! "$APT" list --installed apt-transport-tor >/dev/null 2>&1; then
							einfo "Installing package 'apt-transport-tor' to allow piping the apt trafic though Tor"
							efixme "Do not perform changes to /etc/apt/sources.list if they are not needed"
							invoke_privileged cat <<-EOF > /etc/apt/sources.list
								deb [arch=amd64,i386] http://deb.devuan.org/merged chimaera main contrib non-free
							EOF

							efixme "Do not perform repository update if it's not needed"
							efixme "In case the command fails it doesn't show the output?"
							elog "Updating apt repositories"
							invoke_privileged "$APT_GET" update -q || die false "Unable to update sources"

							elog "Installing package apt-transport-tor"
							invoke_privileged "$APT_GET" install apt-transport-tor -y || die false "Unable to install package 'apt-transport-tor'"

							# Make sure that tor is really installed in case apt-transport-tor changed
							if cmd_check tor; then
								edebug "Command 'tor' has been confirmed to be executable on this system"
							elif ! cmd_check tor; then
								die bug "Command 'tor' is not executable on this system after logic that should implement it"
							else
								die unexpected "self-checking for tor command"
							fi
						else
							die bug "checking if package 'apt-transport-tor' is installed"
						fi
					;;
					*)
						die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented to install tor through script '$myName'"
				esac
			;;
			*) die fixme "Kernel '$KERNEL' is not implemented in $myName to process tor setup"
		esac

		# Make sure that the package manager is configured to use tor if it supports it
		case "$KERNEL" in
			"linux")
				case "$DISTRO/$RELEASE" in
					devuan/chimaera)
						efixme "Do not perform changes to /etc/apt/sources.list if they are not needed" # FIXME
						cat <<-EOF > /etc/apt/sources.list
							# WARNING-DO_NOT_EDIT(Krey): This file is auto-maintained by $MAINTAINER_REPOSITORY
							deb [arch=amd64,i386] tor+http://devuanfwojg73k6r.onion/merged chimaera main contrib non-free
							deb-src [arch=amd64,i386] tor+http://devuanfwojg73k6r.onion/merged chimaera main contrib non-free
						EOF

						invoke_privileged "$APT_GET" update || die false "Unable to update repositories for tor usage"
					;;
					*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented to configure the system to use tor"
				esac
			;;
			*) die fixme "Kernel '$KERNEL' is not implemented in $myName to configure the system to use tor"
		esac

		# Set up SLL certificate
		# FIXME: Sanitize so that we are not DoSing letsencrypt provider
		#setup_certbot

		# Set up tor
		setup_tor

		# Set up cron
		setup_cron

		# Configuration torsocks
		setup_torsocks

		# Configure bootloader
		setup_bootloader

		# Configure kernel
		setup_kernel

		# Configure SSH Daemon
		setup_sshd

		# Setup secrets
		#setup_secret

		# Configure SMTP provider
		setup_postfix

		# Configure POP3/IMAP provider
		# NOTICE(Krey): Currently we are using Dovecot which provides both POP3 and IMAP and so only setup_pop3 is called
		setup_dovecot

		die true "Step '$1' finished in $myName"
	;;
	"--help"|"help")
		efixme "HELP_MESSAGE"
		die true
	;;
	*)
		die syntaxerr "Invalid argument '$1' has been provided in script '$myName' located at '$0'"
	;;
esac; done

die security "$myName escaped sanitization"
