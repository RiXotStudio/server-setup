#!/bin/false
# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/00-server-setup.sh

# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

setup_torsocks() { funcname="setup_torsocks"
	edebug 1 "Started $funcname setup function"

	case "$KERNEL" in
		"linux")
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					cmd_check torsocks || die false "Command 'torsocks' is not installed"

					cat <<-EOF > /etc/tor/torsocks.conf
						# This is the configuration for libtorsocks (transparent socks) for use
						# with tor, which is providing a socks server on port 9050 by default.
						#
						# Lines beginning with # and blank lines are ignored
						# Much more documentation than provided in these comments can be found in
						#
						# torsocks.conf(5), torsocks(1) and torsocks(8) manpages.

						# Default Tor address and port. By default, Tor will listen on localhost for
						# any SOCKS connection and relay the traffic on the Tor network.
						TorAddress 127.0.0.1
						TorPort 9050

						# Tor hidden sites do not have real IP addresses. This specifies what range of
						# IP addresses will be handed to the application as "cookies" for .onion names.
						# Of course, you should pick a block of addresses which you aren't going to
						# ever need to actually connect to. This is similar to the MapAddress feature
						# of the main tor daemon.
						OnionAddrRange 127.42.42.0/24

						# SOCKS5 Username and Password. This is used to isolate the torsocks connection
						# circuit from other streams in Tor. Use with option IsolateSOCKSAuth (on by
						# default) in tor(1). TORSOCKS_USERNAME and TORSOCKS_PASSWORD environment
						# variable overrides these options.
						#SOCKS5Username <username>
						#SOCKS5Password <password>

						# Set Torsocks to accept inbound connections. If set to 1, listen() and
						# accept() will be allowed to be used with non localhost address. (Default: 0)
						# NOTICE(Krey): Required for onionMX, see sefunc/00-smtp.sh
						# NOTICE(Krey): OnionMX needs more research and is currently disabled
						#AllowInbound 1

						# Set Torsocks to allow outbound connections to the loopback interface.
						# If set to 1, connect() will be allowed to be used to the loopback interface
						# bypassing Tor. If set to 2, in addition to TCP connect(), UDP operations to
						# the loopback interface will also be allowed, bypassing Tor. This option
						# should not be used by most users. (Default: 0)
						#AllowOutboundLocalhost 1

						# Set Torsocks to use an automatically generated SOCKS5 username/password based
						# on the process ID and current time, that makes the connections to Tor use a
						# different circuit from other existing streams in Tor on a per-process basis.
						# If set, the SOCKS5Username and SOCKS5Password options must not be set.
						IsolatePID 0
					EOF

					unset funcname
					return 0
				;;
			esac
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented in function '$funcname'"
	esac
}
