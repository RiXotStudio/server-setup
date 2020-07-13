#!/bin/sh
# Created by Jacob Hrbek <kreyren@rixotstudio.cz> under GPLv3 license <https://www.gnu.org/licenses/gpl-3.0.en.html> in 13.07.2020 12:02:48 CEST

# shellcheck shell=sh # Written to be POSIX-comatible

###! Script to set up tor relay on target system
###! Requires:
###! - Anything to run posix shell scripts e.g busybox
###! - Command 'lsb_release' to identify distribution on linux
###! - Command 'uname' to identify used kernel
###! Exit codes:
###! - FIXME-DOCS(Krey): Defined in die()
###! Tested Platforms:
###! - [ ] Linux
###!  - [ ] Debian
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

# Maintainer info
UPSTREAM="https://github.com/RiXotStudio/tor-relay"
MAINTAINER_EMAIL="kreyren@rixotstudio.cz"
MAINTAINER_NICKNAME="kreyren"
MAINTAINER_NAME="Jacob"
MAINTAINER_SURNAME="Hrbek"

# NOTICE(Krey): By default busybox outputs a full path in '$0' this is used to strip it
myName="${0##*/}"

# Used to prefix logs with timestemps, uses ISO 8601 by default
logPrefix="[ $(date -u +"%Y-%m-%dT%H:%M:%SZ") ] "
# Path to which we will save logs
# NOTICE(Krey): To avoid storing file '$HOME/.some-name.sh.log' we are stripping the '.sh' here
logPath="${XDG_DATA_HOME:-$HOME/.local/share}/${myName%%.sh}.log"

# FIXME: _=${var:="some text"} is less verbose and less error prone than [ -z "$var" ] && var="some text"

# Command overrides
[ -z "$PRINTF" ] && PRINTF="printf"
[ -z "$WGET" ] && WGET="wget"
[ -z "$CURL" ] && CURL="curl"
[ -z "$ARIA2C" ] && ARIA2C="aria2c"
[ -z "$CHMOD" ] && CHMOD="chmod"
[ -z "$UNAME" ] && UNAME="uname"
[ -z "$TR" ] && TR="tr"
[ -z "$SED" ] && SED="sed"
[ -z "$GREP" ] && "$GREP"=""$GREP""

# Customization of the output
## efixme
[ -z "$EFIXME_FORMAT_STRING" ] && EFIXME_FORMAT_STRING="FIXME: %s\n"
[ -z "$EFIXME_FORMAT_STRING_LOG" ] && EFIXME_FORMAT_STRING="${logPrefix}FIXME: %s\n"
[ -z "$EFIXME_FORMAT_STRING_DEBUG" ] && EFIXME_FORMAT_STRING_DEBUG="FIXME($myName:$0): %s\n"
[ -z "$EFIXME_FORMAT_STRING_DEBUG_LOG" ] && EFIXME_FORMAT_STRING_DEBUG_LOG="${logPrefix}FIXME($myName:$0): %s\n"
## eerror
[ -z "$EERROR_FORMAT_STRING" ] && EERROR_FORMAT_STRING="ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_LOG" ] && EERROR_FORMAT_STRING_LOG="${logPrefix}ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG" ] && EERROR_FORMAT_STRING_DEBUG="ERROR($myName:$0): %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG_LOG" ] && EERROR_FORMAT_STRING_DEBUG_LOG="${logPrefix}ERROR($myName:$0): %s\n"
## edebug
[ -z "$EERROR_FORMAT_STRING" ] && EERROR_FORMAT_STRING="ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_LOG" ] && EERROR_FORMAT_STRING_LOG="${logPrefix}ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG" ] && EERROR_FORMAT_STRING_DEBUG="ERROR($myName:$0): %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG_LOG" ] && EERROR_FORMAT_STRING_DEBUG_LOG="${logPrefix}ERROR($myName:$0): %s\n"
## einfo
[ -z "$EINFO_FORMAT_STRING" ] && EINFO_FORMAT_STRING="INFO: %s\n"
[ -z "$EINFO_FORMAT_STRING_LOG" ] && EINFO_FORMAT_STRING_LOG="${logPrefix}INFO: %s\n"
[ -z "$EINFO_FORMAT_STRING_DEBUG" ] && EINFO_FORMAT_STRING_DEBUG="INFO($myName:$0): %s\n"
[ -z "$EINFO_FORMAT_STRING_DEBUG_LOG" ] && EINFO_FORMAT_STRING_DEBUG_LOG="${logPrefix}INFO($myName:$0): %s\n"
## die 
[ -z "$DIE_FORMAT_STRING" ] && DIE_FORMAT_STRING="FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="FATAL($myName:$1): %s\n"
[ -z "$DIE_FORMAT_STRING_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}FATAL($myName:$1): %s\\n"
### Fixme trap
[ -z "$DIE_FORMAT_STRING_FIXME" ] && DIE_FORMAT_STRING_FIXME="FATAL: %s in script '$myName' located at '$0', fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_LOG" ] && DIE_FORMAT_STRING_FIXME_LOG="${logPrefix}FATAL: %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG" ] && DIE_FORMAT_STRING_FIXME_DEBUG="FATAL($myName:$1): %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" ] && DIE_FORMAT_STRING_FIXME_DEBUG_LOG="${logPrefix}FATAL($myName:$1): %s, fixme?\\n"
### Unexpected trap
[ -z "$DIE_FORMAT_STRING_UNEXPECTED" ] && DIE_FORMAT_STRING_UNEXPECTED="FATAL: Unexpected happend while %s in $myName located at $0\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_LOG" ] && DIE_FORMAT_STRING_UNEXPECTED_LOG="${logPrefix}FATAL: Unexpected happend while %s\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG" ] && DIE_FORMAT_STRING_UNEXPECTED_DEBUG="FATAL($myName:$1): Unexpected happend while %s in $myName located at $0\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG_LOG" ] && DIE_FORMAT_STRING_UNEXPECTED_DEBUG="${logPrefix}FATAL($myName:$1): Unexpected happend while %s\\n"

# Exit on anything unexpected
set -e

# FIXME: Implement sanitization for used shell

# inicialize the script in logs
"$PRINTF" '%s\n' "Started $myName on $("$UNAME" -s) at $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$logPath"

# NOTICE(Krey): Aliases are required for posix-compatible line output (https://gist.github.com/Kreyren/4fc76d929efbea1bc874760e7f78c810)
die() { funcname="die"
	case "$2" in
		38|fixme) # FIXME
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_LOG" "$3" >> "$logPath"
				unset funcname
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_DEBUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" "$3" >> "$logPath"
				unset funcname
			else
				# NOTICE(Krey): Do not use die() here
				"$PRINTF" 'FATAL: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
			fi

			exit 38
		;;
		255) # Unexpected trap
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_LOG" "$3" >> "$logPath"
				unset funcname
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG_LOG" "$3" >> "$logPath"
				unset funcname
			else
				# NOTICE(Krey): Do not use die() here
				"$PRINTF" "$DIE_FORMAT_STRING" "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
			fi
		;;
		*)
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_LOG" "$3" >> "$logPath"
				unset funcname
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_DEBUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_DEBUG_LOG" "$3" >> "$logPath"
				unset funcname
			else
				# NOTICE(Krey): Do not use die() here
				"$PRINTF" 'FATAL: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
			fi
	esac

	exit "$2"

	# In case invalid argument has been parsed in $2
	exit 255
}; alias die='die "$LINENO"'

einfo() { funcname="einfo"
	if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
		"$PRINTF" "$EINFO_FORMAT_STRING" "$2"
		"$PRINTF" "$EINFO_FORMAT_STRING_LOG" "$2" >> "$logPath"
		unset funcname
		return 0
	elif [ "$DEBUG" = 1 ]; then
		"$PRINTF" "$EINFO_FORMAT_STRING_DEBUG" "$2"
		"$PRINTF" "$EINFO_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath"
		unset funcname
		return 0
	else
		die unexpected "processing variable DEBUG with value '$DEBUG' in $funcname"
	fi
}; alias einfo='einfo "$LINENO"'

ewarn() { funcname="ewarn"
	if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
		"$PRINTF" "$EWARN_FORMAT_STRING" "$2"
		"$PRINTF" "$EWARN_FORMAT_STRING_LOG" "$2" >> "$logPath"
		unset funcname
		return 0
	elif [ "$DEBUG" = 1 ]; then
		"$PRINTF" "$EWARN_FORMAT_STRING_DEBUG" "$2"
		"$PRINTF" "$EWARN_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath"
		unset funcname
		return 0
	else
		die unexpected "processing variable DEBUG with value '$DEBUG' in $funcname"
	fi
}; alias ewarn='ewarn "$LINENO"'

eerror() { funcname="eerror"
	if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
		"$PRINTF" "$EERROR_FORMAT_STRING" "$2"
		"$PRINTF" "$EERROR_FORMAT_STRING_LOG" "$2" >> "$logPath"
		unset funcname
		return 0
	elif [ "$DEBUG" = 1 ]; then
		"$PRINTF" "$EERROR_FORMAT_STRING_DEBUG" "$2"
		"$PRINTF" "$EERROR_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath"
		unset funcname
		return 0
	else
		die unexpected "processing variable DEBUG with value '$DEBUG' in $funcname"
	fi
}; alias eerror='eerror "$LINENO"'

edebug() { funcname="edebug"
	if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
		"$PRINTF" "$EDEBUG_FORMAT_STRING" "$2"
		"$PRINTF" "$EDEBUG_FORMAT_STRING_LOG" "$2" >> "$logPath"
		unset funcname
		return 0
	elif [ "$DEBUG" = 1 ]; then
		"$PRINTF" "$EDEBUG_FORMAT_STRING_DEBUG" "$2"
		"$PRINTF" "$EDEBUG_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath"
		unset funcname
		return 0
	else
		die unexpected "processing variable DEBUG with value '$DEBUG' in $funcname"
	fi
}; alias eerror='eerror "$LINENO"'

efixme() { funcname="efixme"
	if [ "$IGNORE_FIXME" = 1 ]; then
		true
	elif [ "$IGNORE_FIXME" = 0 ] || [ -z "$IGNORE_FIXME" ]; then
		if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
			"$PRINTF" "$EFIXME_FORMAT_STRING" "$2"
			"$PRINTF" "$EFIXME_FORMAT_STRING" "$2" >> "$logPath"
			unset funcname
			return 0
		elif [ "$DEBUG" = 1 ]; then
			"$PRINTF" "$EFIXME_FORMAT_STRING_DEBUG" "$2"
			"$PRINTF" "$EFIXME_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath"
			unset funcname
			return 0
		else
			die unexpected "processing DEBUG variable with value '$DEBUG' in $funcname"
		fi
	else
		die unexpected "processing variable IGNORE_FIXME with value '$IGNORE_FIXME' in $0"
	fi
}; alias efixme='efixme "$LINENO"'

# Identify system
if command -v "$UNAME" 1>/dev/null; then
	unameKernel="$("$UNAME" -s)"
	edebug "Identified the kernel as '$unameKernel"
	case "$unameKernel" in
		Linux)
			KERNEL="$unameKernel"

			# Assume Linux Distro and release
			# NOTICE(Krey): We are expecting this to return a lowercase value
			if command -v "$LSB_RELEASE" 1>/dev/null; then
				assumedDistro="$("$LSB_RELEASE" -si | "$TR" :[upper]: :[lower]:)"
				assumedRelease="$("$LSB_RELEASE" -cs | "$TR" :[upper]: :[lower]:)"
			elif ! command -v "$LSB_RELEASE" 1>/dev/null && [ -f /etc/os-release ]; then
				assumedDistro="$("$"$GREP"" -o "^ID\=.*" /etc/os-release | "$SED" s/ID=//gm)"
				assumedRelease="$("$"$GREP"" -o"^VERSION_CODENAME\=.*" /etc/os-release | "$SED" s/VERSION_CODENAME=//gm)"
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
				ubuntu | debian | fedora | nixos | opensuse | gentoo | exherbo)
					DISTRO="$assumedDistro"
				;;
				*) die fixme "Unexpected Linux distribution '$assumedDistro' has been detected."
			esac

			# Verify Linux Distro Release
			efixme "Sanitize verification of linux distro release"
			assumedRelease="$RELEASE"
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
		edebug "According to command 'id' user's ID is not 0 (user id is "$ID" -u), assuming non-root"
		privileged="false"
	else
		die unexpected "Command '${ID:-id}' returned unexpected value '$($ID -u)'"
	fi
elif ! command -v "$ID" 1>/dev/null; then
	die fixme "Unable to deduce wether this script has been executed with privileged permission, implement other methods in case command 'id' is not executable on this environment"
else
	die bug "Logic failure happend while identifying privileged user"
fi

[ -z "$INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION" ] && INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION="### PRIVILEGED ACCESS REQUEST ###\n\n\s\n"

# Root elevation on-demand
# SYNOPSIS: rootme [reason for privileged access] [command]
invoke_privileged() { funcname="invoke_privileged"

	die fixme "Implement $funcname to execute '$2'"

	if [ "$privileged" = "false" ]; then
		edebug "Script '$myName' has been executed from an unprivileged user, deducing possible elevation"

		# Ask for permission to execute the command
		printf "$INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION" "$1"

		while true; do
			read -p "Requesting permission to invoke '$2' as privileged user (y/n)" privilege_granted

			case "$privilege_granted" in
				"Y"|"y"|"YES"|"yes")
					edebug "User granted permission to invoke '$2' as privileged user"
					unset privilege_granted
					break
				;;
				"N"|"n"|"NO"|"no")
					die 3 "Unable to execute '$2' as privileged user"
				;;
				*) printf '%s\n' "Input '$privilege_granted' is not recognized, try again.."
			esac
		done

		# Check what we can use for executing command as privileged user
		unset privilege_commands

		## Check for sudo
		if command -v "$SUDO" 1>/dev/null; then
			privilege_commands="$privilege_commands sudo"
		elif ! command -v "$SUDO" 1>/dev/null; then
			edebug "Command '$SUDO' is not executable in $funcname, unable to use it"
		else
			die bug "checking wether command sudo is executable in $funcname"
		fi

		## Check for su
		if command -v "$SU" 1>/dev/null; then
			privilege_commands="$privilege_commands su"
		elif ! command -v "$SU" 1>/dev/null; then
			edebug "Command '$SU' is not executable in $funcname, unable to use it"
		else
			die bug "checking wether command su is executable in $funcname"
		fi

		case "$(printf '%s\n' "$privilege_commands" | tr ' ' '\n' | wc -l)" in
			0) die 3 "Neither of supported commands used to invoke command as privileged user '$privilege_commands' are available on this system, unable to invoke '$2'" ;;
			1) 
				case "$(printf '%s\n' "$privilege_commands" | sed "s/ //gm")" in
					"sudo")
						while true; do
							read -p "Requesting permission to use '${SUDO:-sudo}' for invokation of '$2' (y/n)" allowed_to_use_sudo

							case "$allowed_to_use_sudo" in
								"Y"|"y"|"YES"|"yes")
									sudo "$2" | die 3 "Unable to execute '$2' with privileged permission"
									break
								;;
								"N"|"n"|"NO"|"no")
									die 3 "Unable to execute '$2' with privileged permission using sudo, because we were not allowed to proceed"
								;;
								*)
									printf '%s\n' "Input '$allowed_to_use_sudo' is not recognized, retrying.."
									unset allowed_to_use_sudo
							esac
						done
					;;
					"su")
						while true; do
							read -p "Requesting permission to use '${SUDO:-sudo}' for invokation of '$2' (y/n)" allowed_to_use_sudo

							case "$allowed_to_use_sudo" in
								"Y"|"y"|"YES"|"yes")
									su root -c "$2" | die 3 "Unable to execute '$2' with privileged permission"
									break
								;;
								"N"|"n"|"NO"|"no")
									die 3 "Unable to execute '$2' with privileged permission using sudo, because we were not allowed to proceed"
								;;
								*)
									printf '%s\n' "Input '$allowed_to_use_sudo' is not recognized, retrying.."
									unset allowed_to_use_sudo
							esac
						done
					;;
				esac
			2)
				# DNM: Implement proper logic
				efixme "Implement better logic here, invoking 'sudo' for testing.."

				sudo "$2" || die 3 "unable to use privileged permission"
			;;
			*)
				# FIXME-QA: Implement better output
				die bug "Unexpected value has been returned for variable 'privilege_commands'"
		esac

	elif [ "$privileged" = "true" ]; then
		edebug "Executing '$1' as privileged user"
		return 0

	fi
}

# Argument management
while [ "$#" -gt 0 ]; do case "$1" in
	# Install dependencies on supported system
	# Start configured tor relay
	start-tor-relay)
		case "$KERNEL"
			linux)
				case "$DISTRO/$RELEASE" in
					devuan/chimaera)
						einfo "Checking wether tor is executable on this system"
						if command -v "$TOR" 1>/dev/null; then
							einfo "Package 'tor' is already installed"
						elif ! command -v "$TOR" 1>/dev/null; then
							einfo "Command 'tor' is not executable in this environment, resolving.."
							if command -v "$APT" 1>/dev/null; then
								if "$APT" list --installed tor |& "$GREP" -o "^tor/.*"; then
									einfo "Package 'tor' is already installed on this environment"
								elif ! "$APT" list --installed tor |& "$GREP" -o "^tor/.*"; then
									edebug "Concluded that package 'tor' is not installed, resolving.."
									elog "Installing package '$TOR' using '$APT_GET':"
									invoke_privileged "\"$APT_GET\" install --yes tor >> "$logPath" || die false \"Unable to install package 'tor' on $DISTRO/$RELEASE environment\"" "installing tor"
								else
									die bug "insufficient logic found while trying to check wether package 'tor' is installed"
								fi
							elif ! command -v "$APT" 1>/dev/null; then
								die false "Command '$APT' is not executable from this $DISTRO environment"
							else
								die unexpected "processing apt availability on $KERNEL/$RELEASE"
							fi
						fi
						die fixme "run tor in background"
					;;
				esac
			;;
			*) die fixme "Kernel '$KERNEL' has not been implemented"
		esac
	;;
	--help|help)
		efixme "HELP_MESSAGE"
	;;
	*)
		die 2 "FIXME_MESSAGE"
	;;
esac; done