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
UPSTREAM="https://github.com/RiXotStudio/server-setup"
MAINTAINER_EMAIL="kreyren@rixotstudio.cz"
MAINTAINER_REPOSITORY="https://github.com/RiXotStudio/server-setup"
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
[ -z "$GREP" ] && GREP="grep"
[ -z "$SUDO" ] && SUDO="sudo"
[ -z "$SU" ] && SU="su"
[ -z "$APT" ] && APT="apt"
[ -z "$APT_GET" ] && APT_GET="apt-get"
[ -z "$ID" ] && ID="id"

# Customization of the output
## efixme
[ -z "$EFIXME_FORMAT_STRING" ] && EFIXME_FORMAT_STRING="FIXME: %s\n"
[ -z "$EFIXME_FORMAT_STRING_LOG" ] && EFIXME_FORMAT_STRING_LOG="${logPrefix}FIXME: %s\n"
[ -z "$EFIXME_FORMAT_STRING_DEBUG" ] && EFIXME_FORMAT_STRING_DEBUG="FIXME($myName:$LINENO): %s\n"
[ -z "$EFIXME_FORMAT_STRING_DEBUG_LOG" ] && EFIXME_FORMAT_STRING_DEBUG_LOG="${logPrefix}FIXME($myName:$LINENO): %s\n"
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
### Generic
[ -z "$DIE_FORMAT_STRING" ] && DIE_FORMAT_STRING="FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="FATAL($myName:$1): %s\n"
[ -z "$DIE_FORMAT_STRING_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}FATAL($myName:$1): %s\\n"
### Success trap
# FIXME: Implement logic
[ -z "$DIE_FORMAT_STRING_SUCCESS" ] && DIE_FORMAT_STRING_SUCCESS="FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="FATAL($myName:$1): %s\n"
[ -z "$DIE_FORMAT_STRING_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}FATAL($myName:$1): %s\\n"
### Fixme trap
[ -z "$DIE_FORMAT_STRING_FIXME" ] && DIE_FORMAT_STRING_FIXME="FATAL: %s in script '$myName' located at '$0', fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_LOG" ] && DIE_FORMAT_STRING_FIXME_LOG="${logPrefix}FATAL: %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG" ] && DIE_FORMAT_STRING_FIXME_DEBUG="FATAL($myName:$1): %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" ] && DIE_FORMAT_STRING_FIXME_DEBUG_LOG="${logPrefix}FATAL($myName:$1): %s, fixme?\\n"
### Bug Trap
[ -z "$DIE_FORMAT_STRING_BUG" ] && DIE_FORMAT_STRING_BUG="BUG: Unexpected happend while processing %s in script '$myName' located at '$0'\\n\\nIf you think that this is a bug, the report it to $UPSTREAM to @$MAINTAINER_NICKNAME with output from $logPath for relevant runtime or through e-mail on $MAINTAINER_EMAIL"
[ -z "$DIE_FORMAT_STRING_BUG_LOG" ] && DIE_FORMAT_STRING_BUG_LOG="${logPrefix}$DIE_FORMAT_STRING_BUG"
[ -z "$DIE_FORMAT_STRING_BUG_DEBUG" ] && DIE_FORMAT_STRING_BUG_DEBUG="BUG:($myName:$1): ${DIE_FORMAT_STRING_BUG%%BUG:}"
[ -z "$DIE_FORMAT_STRING_BUG_DEBUG_LOG" ] && DIE_FORMAT_STRING_BUG_DEBUG_LOG="${logPrefix}$DIE_FORMAT_STRING_BUG_DEBUG"
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
# elog
[ -z "$ELOG_FORMAT_STRING_DEBUG_LOG" ] && ELOG_FORMAT_STRING_DEBUG_LOG="${logPrefix}LOG: %s\\n"

# Exit on anything unexpected
set -e

# FIXME: Implement sanitization for used shell

# inicialize the script in logs
"$PRINTF" '%s\n' "Started $myName on $("$UNAME" -s) at $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$logPath"

# NOTICE(Krey): Aliases are required for posix-compatible line output (https://gist.github.com/Kreyren/4fc76d929efbea1bc874760e7f78c810)
# FIXME-DUP_CODE: Fix duplicate code for easier maintainance
die() { funcname="die"
	case "$2" in
		###! Generic true
		###! - Used to exit the shell successfully
		###! Compatibility: Returns Error code 0 on Unix and Error Code 1 on Windows
		"true")
			# In case no message is provided
			if [ -z "$3" ]; then
				if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
					case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*)
							"$PRINTF" "$DIE_FORMAT_STRING_TRUE" "Exitted successfully"
							"$PRINTF" "$DIE_FORMAT_STRING_TRUE" "Exitted successfully" >> "$logPath"
					esac
				elif [ "$DEBUG" = 1 ]; then
					case "$LANG" in
						en-*|*)
							# FIXME-TRANSLATE: Translate in your language
							"$PRINTF" "$DIE_FORMAT_STRING_TRUE_DEBUG" "Exitted successfully"
							"$PRINTF" "$DIE_FORMAT_STRING_TRUE_DEBUG" "Exitted successfully" >> "$logPath"
					esac
				else
					# NOTICE(Krey): Do not use die() in die for unexpected
					case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
					esac
				fi
			# Message on second argument is provided
			elif [ -n "$3" ]; then
				if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
					"$PRINTF" "$DIE_FORMAT_STRING_TRUE" "$3"
					"$PRINTF" "$DIE_FORMAT_STRING_TRUE" "$3" >> "$logPath"
				elif [ "$DEBUG" = 1 ]; then
					"$PRINTF" "$DIE_FORMAT_STRING_TRUE_DEBUG" "$3"
					"$PRINTF" "$DIE_FORMAT_STRING_TRUE_DEBUG" "$3" >> "$logPath"
				else
					# NOTICE(Krey): Do not use die() in die for unexpected
					case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
					esac
				fi
			fi

			# Assertion
			case "$KERNEL" in
				"linux")
					unset funcname
					exit 0 ;;
				"windows")
					unset funcname
					exit 1 ;;
				*)
					"$PRINTF" 'BUG: %s\n' "Invalid kernel has been provided in $myName for arguments '$*': $KERNEL"
					unset funcname
					exit 255
			esac
		;;
		###! Generic failure
		###! - Used to exit the shell with fatal error
		###! Compatibility: Returns Error code 1 on Unix and Error Code 0 on Windows
		"false")
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FALSE" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_FALSE" "$3" >> "$logPath"
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FALSE_DEBUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_FALSE_DEBUG" "$3" >> "$logPath"
			else
				case "$LANG" in
					# FIXME-TRANSLATE: Translate in your language
					en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			# Assertion
			case "$KERNEL" in
				linux)
					unset funcname
					exit 1 ;;
				windows)
					unset funcname
					exit 0 ;;
				*)
					"$PRINTF" 'BUG: %s\n' "Invalid kernel has been provided in $myName: $KERNEL"
					unset funcname
					exit 223
			esac
		;;
		28|security)
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_SECURITY" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_SECURITY_LOG" "$3" >> "$logPath"
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_SECURITY_DEBUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_SECURITY_DEBUG_LOG" "$3" >> "$logPath"
			else
				case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 28 # In case 'fixme' argument is provided
		;;
		38|fixme) # For features that needs to be implemented and prefents runtime from continuing
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_LOG" "$3" >> "$logPath"
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_DEBUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" "$3" >> "$logPath"
			else
				case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 38 # In case 'fixme' argument is provided
		;;
		223|bug) # Unexpected trap
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_BUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_BUG_LOG" "$3" >> "$logPath"
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_BUG_DEBUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_BUG_DEBUG_LOG" "$3" >> "$logPath"
			else
				case "$LANG" in
					# FIXME-TRANSLATE: Translate to more languages
					en-*|*) "$PRINTF" "$DIE_FORMAT_STRING" "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 223 # In case 'bug' is used
		;;
		255|unexpected) # Unexpected trap
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_LOG" "$3" >> "$logPath"
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG" "$3"
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG_LOG" "$3" >> "$logPath"
			else
				case "$LANG" in
					# FIXME-TRANSLATE: Translate to more languages
					en-*|*) "$PRINTF" "$DIE_FORMAT_STRING" "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 255 # In case 'unexpected' is used
		;;
		*)
			case "$LANG" in
				# FIXME-TRANSLATE: Translate to more languages
				en-*|*) "$PRINTF" 'BUG: %s\n' "Invalid argument '$2' has been provided in $funcname located for script $myName located in $0"
			esac
			unset funcname
			exit 255
	esac
}; alias die='die "$LINENO"'

einfo() { funcname="einfo"
	if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
		"$PRINTF" "$EINFO_FORMAT_STRING" "$1"
		"$PRINTF" "$EINFO_FORMAT_STRING_LOG" "$1" >> "$logPath"
		unset funcname
		return 0
	elif [ "$DEBUG" = 1 ]; then
		"$PRINTF" "$EINFO_FORMAT_STRING_DEBUG" "$1"
		"$PRINTF" "$EINFO_FORMAT_STRING_DEBUG_LOG" "$1" >> "$logPath"
		unset funcname
		return 0
	else
		case "$LANG" in
			# FIXME-TRANSLATE: Translate to more languages
			en-*|*) die bug "processing variable DEBUG with value '$DEBUG' in $funcname"
		esac
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
		case "$LANG" in
			# FIXME-TRANSLATE: Translate to more languages
			en-*|*) die bug "processing variable DEBUG with value '$DEBUG' in $funcname"
		esac
	fi
}; alias ewarn='ewarn "$LINENO"'

# NOTICE(Krey): Aliases are required for posix-compatible line output (https://gist.github.com/Kreyren/4fc76d929efbea1bc874760e7f78c810)
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
		case "$LANG" in
			# FIXME-TRANSLATE: Translate to more languages
			en-*|*) die bug "processing variable DEBUG with value '$DEBUG' in $funcname"
		esac
	fi
}; alias eerror='eerror "$LINENO"'

# NOTICE(Krey): Aliases are required for posix-compatible line output (https://gist.github.com/Kreyren/4fc76d929efbea1bc874760e7f78c810)
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
		case "$LANG" in
			# FIXME-TRANSLATE: Translate to more languages
			en-*|*) die 255 "processing variable DEBUG with value '$DEBUG' in $funcname"
		esac
	fi
}; alias die='die "$LINENO"'

# NOTICE(Krey): Aliases are required for posix-compatible line output (https://gist.github.com/Kreyren/4fc76d929efbea1bc874760e7f78c810)
efixme() { funcname="efixme"
	if [ "$IGNORE_FIXME" = 1 ]; then
		# FIXME: Implement 'fixme' debug channel
		edebug fixme "Fixme message for '$2' disabled"
		return 0
	elif [ "$IGNORE_FIXME" = 0 ] || [ -z "$IGNORE_FIXME" ]; then
		if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
			"$PRINTF" "$EFIXME_FORMAT_STRING" "$2"
			"$PRINTF" "$EFIXME_FORMAT_STRING_LOG" "$2" >> "$logPath"
			unset funcname
			return 0
		elif [ "$DEBUG" = 1 ]; then
			"$PRINTF" "$EFIXME_FORMAT_STRING_DEBUG" "$2"
			"$PRINTF" "$EFIXME_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath"
			unset funcname
			return 0
		else
			case "$LANG" in
				# FIXME-TRANSLATE: Translate to more languages
				en-*|*) die 255 "processing DEBUG variable with value '$DEBUG' in $funcname"
			esac
		fi
	else
		case "$LANG" in
			# FIXME-TRANSLATE: Translate to more languages
			en-*|*) die 255 "processing variable IGNORE_FIXME with value '$IGNORE_FIXME' in $0"
		esac
	fi
}; alias efixme='efixme "$LINENO"'

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

[ -z "$INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION" ] && INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION="### PRIVILEGED ACCESS REQUEST ###\n\n\s\n"

# Root elevation on-demand
# SYNOPSIS: rootme [reason for privileged access] [command]
# FIXME-QA: Needs better implementation
invoke_privileged() { funcname="invoke_privileged"

	if [ "$privileged" = "false" ]; then
		die fixme "Implement $funcname to execute '$2' as privileged user, invoke this script as root as a workaround"

		edebug "Script '$myName' has been executed from an unprivileged user, deducing possible elevation"

		# Ask for permission to execute the command
		"$PRINTF" "$INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION" "$1"

		while true; do
			"$PRINTF" '%s\n' "Requesting permission to invoke '$2' as privileged user (y/n)"
			read -r privilege_granted

			case "$privilege_granted" in
				"Y"|"y"|"YES"|"yes")
					edebug "User granted permission to invoke '$2' as privileged user"
					unset privilege_granted
					break
				;;
				"N"|"n"|"NO"|"no")
					die 3 "Unable to execute '$2' as privileged user"
				;;
				*) "$PRINTF" '%s\n' "Input '$privilege_granted' is not recognized, try again.."
			esac
		done

		# Check what we can use for executing command as privileged user
		unset privilege_commands

		# FIXME-QA: Fix duplicate code

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

		case "$("$PRINTF" '%s\n' "$privilege_commands" | tr ' ' '\n' | wc -l)" in
			0) die 3 "Neither of supported commands used to invoke command as privileged user '$privilege_commands' are available on this system, unable to invoke '$2'" ;;
			1)
				cmd_count="$("$PRINTF" '%s\n' "$privilege_commands" | sed "s/ //gm")"
				case "$cmd_count" in
					"sudo")
						while true; do
							printf '%s\n' "Requesting permission to use '${SUDO:-sudo}' for invokation of '$2' (y/n)"
							read -r allowed_to_use_sudo

							case "$allowed_to_use_sudo" in
								"Y"|"y"|"YES"|"yes")
									sudo "$2" | die 3 "Unable to execute '$2' with privileged permission"
									break
								;;
								"N"|"n"|"NO"|"no")
									die 3 "Unable to execute '$2' with privileged permission using sudo, because we were not allowed to proceed"
								;;
								*)
									"$PRINTF" '%s\n' "Input '$allowed_to_use_sudo' is not recognized, retrying.."
									unset allowed_to_use_sudo
							esac
						done
					;;
					"su")
						while true; do
							printf '%s\n' "Requesting permission to use '${SUDO:-sudo}' for invokation of '$2' (y/n)"
							read -r allowed_to_use_sudo

							case "$allowed_to_use_sudo" in
								"Y"|"y"|"YES"|"yes")
									su root -c "$2" | die 3 "Unable to execute '$2' with privileged permission"
									break
								;;
								"N"|"n"|"NO"|"no")
									die 3 "Unable to execute '$2' with privileged permission using sudo, because we were not allowed to proceed"
								;;
								*)
									"$PRINTF" '%s\n' "Input '$allowed_to_use_sudo' is not recognized, retrying.."
									unset allowed_to_use_sudo
							esac
						done
					;;
				esac ;;
			2)
				# NOTICE: This is adapted to allow more commands in the future
				while true; do
					printf '%s\n\n' \
						"We found following commands that we can use to execute the command as privileged user:"

						# FIXME: seq might not be available on the system
						# - yes | head -n 3| nl | cut -f1 | while read i; do echo $i; done
						# - awk 'BEGIN{for(i=0;i<10;i++)print i}
						for num in $(seq 1 "$cmd_count" | tr '\n' ' '); do
							for cmd in $privilege_commands; do
									printf "%s\n" "$num. $cmd"
							done

							printf '%s\n' ""

							printf '%s\n' "Which command do you want to use?"
						done

						read -r privilege_choice

						case "$privilege_choice" in
							[1-2])
								die fixme "Choose the appropriate choice, invoke this script as privileged user as a workaround"
								break
							;;
							*)
								printf '%s\n' "Invalid choice '$privilege_choice', retrying.."
								unset privilege_choice
 						esac
				done

				# DNM: Implement proper logic
				efixme "Implement better logic here, invoking 'sudo' for testing.."

				sudo "$2" || die 3 "unable to use privileged permission" ;;
			*)
				# FIXME-QA: Implement better output
				die bug "Unexpected value has been returned for variable 'privilege_commands'"
		esac

	elif [ "$privileged" = "true" ]; then
		edebug "Executing '$1' as privileged user"
		return 0

	fi
}

# Define hostname
# NOTICE: Variable 'HOSTNAME' is not defined on POSIX sh
if command -v hostname 1>/dev/null; then
	HOSTNAME="$(hostname)"
elif ! command -v hostname 1>/dev/null; then
	die false "Unable to determine the hostname"
else
	die unexpected "processing hostname"
fi

# Check executability of a program
cmd_check() { funcname="cmd_check"
	# FIXME-STUB: This is a stub implementation
	if command; then
		true
	elif ! command; then
		die fixme "Command 'command' is not executable on this system when runtime requested function '$funcname', we are unable to continue"
	else
		die unexpected "Unexpected happend while checking command 'command' in $funcname"
	fi

	if command -v "$1" 1>/dev/null; then
		edebug cmd_check "Command '$1' has been confirmed to be executable on this system"
		case "$KERNEL" in
			"linux")
				unset funcname
				return 0 ;;
			"windows")
				unset funcname
				return 1 ;;
			*) die fixme "Kernel '$KERNEL' is not implemented in function '$funcname'"
		esac
	elif ! command -v "$1" 1>/dev/null; then
		edebug cmd_check "Command '$1' is not executable on this system"
		case "$KERNEL" in
			"linux")
				unset funcname
				return 1 ;;
			"windows")
				unset funcname
				return 0 ;;
			*) die fixme "Kernel '$KERNEL' is not implemented in function '$funcname'"
		esac
	else
		die unexpected "Command 'command' returned an unexpected result in function '$funcname'"
	fi
}

# Argument management
while [ "$#" -gt 0 ]; do case "$1" in
	# Configure target system to be up to standard for RiXotStudio's usage
	"configure-system")
		case "$KERNEL" in
			"linux")
				case "$DISTRO/$RELEASE" in
					"devuan/chimaera")
						# FIXME-DOCS
						if apt list --installed apt-transport-tor; then
							edebug 1 "Package 'apt-transport-tor' is already installed on $DISTRO/$RELEASE"
						elif ! apt list --installed apt-transport-tor; then
							einfo "Installing package 'apt-transport-tor' to allow piping the apt trafic though Tor"
							efixme "Do not perform changes to /etc/apt/sources.list if they are not needed"
							invoke_privileged cat <<-EOF > /etc/apt/sources.list
								deb [arch=amd64,i386] http://deb.devuan.org/merged chimaera main contrib non-free
							EOF

							efixme "Do not perform repository update if it's not needed"
							elog "Updating apt repositories"
							elog "$(invoke_privileged "$APT_GET" update -q || die false "Unable to update sources")"

							elog "Installing package apt-transport-tor"
							elog "$(invoke_privileged "$APT_GET" install apt-transport-tor -y || die false "Unable to install package 'apt-transport-tor'")"

							# Make sure that tor is really installed
							if cmd_check tor; then
								edebug "Command 'tor' has been confirmed to be executable on this system"
							elif ! cmd_check tor; then
								die bug "Command 'tor' is not executable on this system after logic that should implement it"
							else
								die unexpected "self-checking for tor command"
							fi

							efixme "Do not perform changes to /etc/apt/sources.list if they are not needed"
							cat <<-EOF > /etc/apt/sources.list
								# WARNING-DO_NOT_EDIT(Krey): This file is auto-maintained by $MAINTAINER_REPOSITORY
								# Main
								deb [arch=amd64,i386] tor+http://devuanfwojg73k6r.onion/merged chimaera main contrib non-free
								deb-src [arch=amd64,i386] tor+http://devuanfwojg73k6r.onion/merged chimaera main contrib non-free
								# Liquorix
								deb [arch=amd64,i386] tor+http://liquorix.net/debian buster main
								deb-src [arch=amd64,i386] tor+http://liquorix.net/debian buster main
							EOF

							elog "$(invoke_privileged "$APT_GET" update || die false "Unable to update repositories for tor usage")"

							# Configure Grub
							einfo "Configuring grub"
							efixme "Sanitize grub configuration"
							cat <<-EOF > /etc/default/grub
								GRUB_DEFAULT=0
								# NOTICE(Krey): GRUB UI is disabled to speed up the reboot
								GRUB_TIMEOUT=0
								GRUB_DISTRIBUTOR="\$(lsb_release -si 2>/dev/null || printf '%s\n' Devuan)"
								GRUB_CMDLINE_LINUX_DEFAULT="quiet"
								GRUB_CMDLINE_LINUX="selinux=0"
							EOF

							einfo "Installing liquorix kernel"
							efixme "Sanitize liquorix pubkey configuration"
							curl 'https://liquorix.net/linux-liquorix.pub' | invoke_privileged apt-key add -

							elog "Installing liquorix kernel dependencies"
							efixme "Sanitize installation of liquorix dependencies"
							elog "$(invoke_privileged "$APT_GET" install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64 grub2)"

							die success "Task '$1' in script $myName finished successfully"
						else
							die unexpected "Processing package 'apt-transport-tor' on $KERNEL/$DISTRO-$RELEASE"
						fi
					;;
					*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented"
				esac
			;;
			*) die fixme "Kernel '$KERNEL' is not implemented"
		esac
	;;
	"setup-ssh")
		die fixme "Configure, install and secure SSH"
		case "$KERNEL" in
			"linux")
				case "$DISTRO/$RELEASE" in
					devuan/chimaera)
						elog "Installing package 'openssh-server' on $DISTRO/$RELEASE"
						elog "$(invoke_privileged "$APT_GET" install -y openssh-server || die false "Unable to install package 'openssh-server'")"

						cat <<-EOF > /etc/ssh/sshd_config
							### SECURITY CHECKLIST
							# - [ ] Disable root login
							# - [ ] Disable password login
							# - [ ] Set up connection via gpg
							# - [ ] Appent timeout for multiple failed attemps to login
							# - [ ] Add various counter-measures for brute-force attacks
							# - [ ] Auto-update curl job
							# - [ ] Disable X11
							# - [ ] Capture failed login attemps and implement remote logging to capture security issues
							# - [ ] Remote logging
							# - [ ] Set up mailserver to inform administrators about vulnerabilities
							# - [ ] Set up sudo?
							# - [ ] Check integrity of critical files using checksum
							# - [ ] Disable SELinux
							# - [ ] Optimize firewall
							# - [ ] Allow only cherrypicked list of users
							# - [ ] Bootloader and BIOS Security?
							# - [ ] Do we care about portmap services?
							# - [ ] Disable root login in /etc/securetty
							# - [ ] Implement password policy
						EOF
					;;
					*) die fixme "Linux distribution '$DISTRO' using release '$RELEASE' is not implemented for argument '$1' in $myName script"
				esac
			;;
			*) die fixme "Kernel '$KERNEL' is not implemented for argument '$1' in script $myName"
		esac
	;;
	"setup-tor")
		die fixme "Configure and start tor-relay"
	;;
	"setup-mailserver")
		die fixme "Install, configure and run mailserver"
	;;
	"setup-socks")
		die fixme "Install, configure and run SOCKS5 proxy"
	;;
	"--help"|"help")
		efixme "HELP_MESSAGE"
		die true
	;;
	*)
		die 2 "FIXME_MESSAGE"
	;;
esac; done

die security "$myName escaped sanitization"
