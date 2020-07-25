#!/bin/false
# - Used only for sourcing
# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/server-setup.sh

###! Workflow used to set up tor on target system using RiXotStudio's configuration

# FIXME-SECURITY:
## Jul 25 15:38:04.297 [warn] Tor is currently configured as a relay and a hidden service. That's not very secure: you should probably run your hidden service in a separate Tor process, at least -- see https://trac.torproject.org/8742


setup_tor() { funcname="setup_tor"
	edebug 1 "Started $funcname setup function"

	### CONFIGURATION ###
	tor_SocksPort=9050
	tor_DNSPort=5400
	tor_ORPort=9001

	# Make sure that tor is installer else install it
	edebug 1 "Checking wether tor is installed"
	if cmd_check "$TOR"; then
		edebug 1 "Tor is already executable in this environment, skipping.."
	elif ! cmd_check "$TOR"; then
		ewarn "Command 'tor' is not executable on this environment, resolving.."

		# Install tor
		elog "Installing tor as instructed"
		case "$KERNEL" in
			"linux")
				case "$DISTRO/$RELEASE" in
					"devuan/chimaera")
						# FIXME-QA: Do not update repositories if it's not needed
						invoke_privileged "$APT_GET" update || die 1 "unable to update repositories"

						invoke_privileged "$APT_GET" install -y tor || die 1 "Unable to install package 'tor' using command 'apt-get'"
					;;
					*) die fixme "Installation of package 'tor' on kernel '$KERNEL' using distribution '$DISTRO' with release '$RELEASE' is not implemented"
				esac
			;;
			*) die fixme "Kernel '$KERNEL' is not implemented for function '$funcname' to check for tor in $myName script located at $0"
		esac
	else
		die bug "checking wether tor is executable"
	fi

	# Create the torrc.d
	emkdir "$torDir/torrc.d"


	# FIXME: Issue with permission - Could not open "/etc/tor/torrc.d/sshd": Permission denied
	# This is caused by apparmor

	# Configure torrc
	edebug 1 "configuring torrc"
	case "$KERNEL" in
		"linux")
			# shellcheck disable=SC2039 # HOSTNAME is undefined on posix, but defined by our script in src/bin/server-setup.sh
			cat <<-EOF > /etc/tor/torrc
				Nickname $UPSTREAM_NAME$HOSTNAME
				ContactInfo 0x$MAINTAINER_PUBKEY $MAINTAINER_NAME $MAINTAINER_SURNAME <$MAINTAINER_EMAIL>
				NumCPUs $(nproc || printf '%s\n' "8")
				SocksPort $tor_SocksPort
				ORPort $tor_ORPort

				# Set up SSH Daemon to run through Tor
				HiddenServiceDir /var/lib/tor/sshd/
				HiddenServicePort 22 127.0.0.1:22

				# Include configuration for hidden_mx
				# NOTICE(Krey): OnionMX requires more research and is currently disabled
				#%include /etc/tor/torrc.d/hidden_mx

				# FIXME: Verify that ISP doesn't log the traffic
				ExitRelay 0

				# FIXME(Krey): Value autodetected by tor -> requires logic
				maxMemInQueues 5960 MB

				# Setup Bandwidth limiters
				RelayBandwidthRate 125 KB # Throttle traffic to 125KB/s 1000Kbps)
				RelayBandwidthBurst 375 KB # But allow bursts up to 375KB/s (3000Kbps)

				# DNS
				DNSPort $tor_DNSPort

				# To provide informations about this relay to public
				# FIXME: Verify that we can use this as an exit node, then uncomment
				#DirPortFrontPage $torDir/tor-exit-notice.html
			EOF
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented for function '$funcname' to configure torrc in $myName script located at $0"
	esac

	# Set frontpage notice
	edebug 1 "Setting frontpage notice for tor"
	case "$KERNEL" in
		"linux")
			cat <<-EOF > "$torDir/tor-exit-notice.html"
				<html>
				  <h3>This is currently work im progress implementation of RiXotStudio's services on onion</h3>
				</html>
			EOF
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented for frontpage notice step in $myName script calling function '$funcname'"
	esac

	edebug 1 "Finished $funcname"

	unset funcname
	return 0
}
