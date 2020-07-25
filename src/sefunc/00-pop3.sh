#!/bin/false
# - Used only for sourcing
# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/server-setup.sh

# shellcheck disable=SC2039 # HOSTNAME is undefined in posix, but defined by our logic

###! Workflow made to configure POP3 handler on RiXotStudio's systems
###! Security concerns:
###! - [ ] It is not acceptable for ISP and 3rd party scanning the network to know that encrypted POP3 is sent from server A to server B
###! SECURITY-CHECKLIST:
###! - [ ] Localhost doesn't have admin privileges (We are using tor so that could make it exposed)
###! Relevants
###! - Research: https://github.com/Kreyren/kreyren/issues/24

# FIXME-SECURITY: Peer-review required
# FIXME-SECURITY: Do not allow localhost to have admin privileges because we are using tor

setup_pop3() { funcname="setup_pop3"
	edebug 1 "Started $funcname setup function"

	case "$KERNEL" in
		"linux")

			# Get Dovecot
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					invoke_privileged "$APT_GET" install dovecot-core -y || die false "Unable to install dovecot on Linux distro $DISTRO with release $RELEASE"
				;;
				*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented to install dovecot"
			esac

			# Configure dovecot
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					cat <<-EOF > /etc/dovecot/dovecot.conf
						## Dovecot configuration file

						# If you're in a hurry, see http://wiki2.dovecot.org/QuickConfiguration

						# "doveconf -n" command gives a clean output of the changed settings. Use it
						# instead of copy&pasting files when posting to the Dovecot mailing list.

						# '#' character and everything after it is treated as comments. Extra spaces
						# and tabs are ignored. If you want to use either of these explicitly, put the
						# value inside quotes, eg.: key = "# char and trailing whitespace  "

						# Most (but not all) settings can be overridden by different protocols and/or
						# source/destination IPs by placing the settings inside sections, for example:
						# protocol imap { }, local 127.0.0.1 { }, remote 10.0.0.0/8 { }

						# Default values are shown for each setting, it's not required to uncomment
						# those. These are exceptions to this though: No sections (e.g. namespace {})
						# or plugin settings are added by default, they're listed only as examples.
						# Paths are also just examples with the real defaults being based on configure
						# options. The paths listed here are for configure --prefix=/usr
						# --sysconfdir=/etc --localstatedir=/var

						# Enable installed protocols
						!include_try /usr/share/dovecot/protocols.d/*.protocol

						# A comma separated list of IPs or hosts where to listen in for connections.
						# "*" listens in all IPv4 interfaces, "::" listens in all IPv6 interfaces.
						# If you want to specify non-default ports or anything more complex,
						# edit conf.d/master.conf.
						#listen = *, ::

						# Base directory where to store runtime data.
						base_dir = /var/run/dovecot/

						# Name of this instance. In multi-instance setup doveadm and other commands
						# can use -i <instance_name> to select which instance is used (an alternative
						# to -c <config_path>). The instance name is also added to Dovecot processes
						# in ps output.
						#instance_name = dovecot

						# Greeting message for clients.
						#login_greeting = Dovecot ready.

						# Space separated list of trusted network ranges. Connections from these
						# IPs are allowed to override their IP addresses and ports (for logging and
						# for authentication checks). disable_plaintext_auth is also ignored for
						# these networks. Typically you'd specify your IMAP proxy servers here.
						#login_trusted_networks =

						# Space separated list of login access check sockets (e.g. tcpwrap)
						#login_access_sockets =

						# With proxy_maybe=yes if proxy destination matches any of these IPs, don't do
						# proxying. This isn't necessary normally, but may be useful if the destination
						# IP is e.g. a load balancer's IP.
						#auth_proxy_self =

						# Show more verbose process titles (in ps). Currently shows user name and
						# IP address. Useful for seeing who are actually using the IMAP processes
						# (eg. shared mailboxes or if same uid is used for multiple accounts).
						#verbose_proctitle = no

						# Should all processes be killed when Dovecot master process shuts down.
						# Setting this to "no" means that Dovecot can be upgraded without
						# forcing existing client connections to close (although that could also be
						# a problem if the upgrade is e.g. because of a security fix).
						#shutdown_clients = yes

						# If non-zero, run mail commands via this many connections to doveadm server,
						# instead of running them directly in the same process.
						#doveadm_worker_count = 0
						# UNIX socket or host:port used for connecting to doveadm server
						#doveadm_socket_path = doveadm-server

						# Space separated list of environment variables that are preserved on Dovecot
						# startup and passed down to all of its child processes. You can also give
						# key=value pairs to always set specific settings.
						#import_environment = TZ

						##
						## Dictionary server settings
						##

						# Dictionary can be used to store key=value lists. This is used by several
						# plugins. The dictionary can be accessed either directly or though a
						# dictionary server. The following dict block maps dictionary names to URIs
						# when the server is used. These can then be referenced using URIs in format
						# "proxy::<name>".

						dict {
						  #quota = mysql:/etc/dovecot/dovecot-dict-sql.conf.ext
						  #expire = sqlite:/etc/dovecot/dovecot-dict-sql.conf.ext
						}

						# Most of the actual configuration gets included below. The filenames are
						# first sorted by their ASCII value and parsed in that order. The 00-prefixes
						# in filenames are intended to make it easier to understand the ordering.
						# FIXME-SECURITY(Krey): What?
						!include conf.d/*.conf

						# A config file can also tried to be included without giving an error if
						# it's not found:
						# FIXME-SECURITY(Krey): What?
						!include_try local.conf
					EOF
				;;
				*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented to configure dovecot"
			esac
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented in $funcname"
	esac
}
