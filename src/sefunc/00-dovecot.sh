#!/bin/false
# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/00-server-setup.sh

# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

###! Administrative script used to get and manage dovecot on target system according to RiXotStudio's standard
###! CHECKLIST
###! - [X] Bare minimum
###! - [X] SSL
###! - [X] TLS (Handled in postfix)
###! - [ ] Do not allow unencypted traffic
###! - [ ] Disable STARTTLS
###! - [ ] Force SSL/TLS
###! - [ ] Set up virtual users
###!   - https://wiki.dovecot.org/VirtualUsers
###! - [ ] Force usage of OpenPGP encrypted messages
###! - [X] Provide POP3
###! - [ ] Disable IMAP
###!   - [ ] Allow usage on demand
###! - [ ] Reachable only from tor
###! - [ ] Allow address extension i.e user+folder@example.tls would deliver the email in 'folder' instead of an inbox
###! - [ ] Authentication Databases
###! Security concerns:
###! - [ ] It is not acceptable for ISP and 3rd party scanning the network to know that encrypted POP3 is sent from server A to server B
###! SECURITY-CHECKLIST:
###! - [ ] Localhost doesn't have admin privileges (We are using tor so that could make it exposed)
###! Relevants
###! - Research: https://github.com/Kreyren/kreyren/issues/24

# FIXME-SECURITY: Peer-review required
# FIXME-SECURITY: Do not allow localhost to have admin privileges because we are using tor

# FIXME: on devuan we need dovecot-{pop3,imap}d packages
# FIXME: Use official dovecot repo on apt-based? https://repo.dovecot.org
# FIXME: |
# you are using mbox storage
# which is one file with all your mails
# it's slow
# Use maildir
# FIXME: Generate certificates through certbot
# FIXME: Set certificates in /etc/dovecot/conf.d/10-ssl.conf
# FIXME: Secure /etc/letsencrypt
# Your account credentials have been saved in your Certbotconfiguration directory at /etc/letsencrypt. You should make a secure backup of this folder now. This configuration directory will also contain certificates and private keys obtained by Certbot so making regular backups of this folder is ideal.


# FIXME-SECURITY: Note https://doc.dovecot.org/configuration_manual/protocols/lmtp_server/yesu u r
# FIXME: Process https://doc.dovecot.org/configuration_manual/howto/simple_virtual_install/
# FIXME: Process https://doc.dovecot.org/admin_manual/ssl/#ssl
# FIXME: Process https://doc.dovecot.org/admin_manual/ssl/dovecot_configuration/
# FIXME: Process https://codahale.com/how-to-safely-store-a-password/

# FIXME: Create vmail user and group
## https://wiki.dovecot.org/VirtualUsers

setup_dovecot() { funcname="setup_dovecot"
	edebug 1 "Started $funcname setup function"

	case "$KERNEL" in
		"linux")

			# Install Dovecot
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					invoke_privileged "$APT_GET" install dovecot-core dovecot-pop3d -y || die false "Unable to install dovecot on Linux distro $DISTRO with release $RELEASE"
				;;
				"gentoo/*")
					die fixme "Implement logic to install dovecot on $DISTRO"
				;;
				*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented to install dovecot"
			esac

			efixme "Implement sanitycheck of the SSL certificate"
			efixme "Implement sanitycheck for option 'ssl_client_ca_dir' in our dovecot.conf"

			# Configure dovecot
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					# NOTICE(Krey): This is a JSON syntax file
					# May be relevant: https://wiki.dovecot.org/DomainLost [Domain (%d) is empty]
					# See variables https://doc.dovecot.org/configuration_manual/config_file/config_variables/
					cat <<-EOF > /etc/dovecot/dovecot.conf
						# FIXME: Implement IMAP to be used on demand
						protocols = pop3 imap

						# SECURITY-FIXME: Investigate (https://doc.dovecot.org/configuration_manual/authentication/authentication_mechanisms/)
						# FIXME: Quotting(https://doc.dovecot.org/configuration_manual/authentication/auth_settings/) - "The LOGIN mechanism is obsolete, but still used by old Outlooks and some Microsoft phones."
						# NOTICE(Krey): Quotting "Encrypted mechanisms require access to the plaintext password in your passdb.  This can be considered a potential security weakness also.  So encrypted mechanisms are a tradeoff, not a gain."
						# INVESTIGATE: Use s-cram-sha256 ?
							# FIXME-CONTRIB: Contribute s-cram-sha512 in dovecot
						auth_mechanisms = plain

						# FIXME-DOCS
						# NOTICE(Krey): This will convert everything into domainless username before passdb
						auth_username_format=%Ln@%Ld

						# SECURITY-WARNING: Used only for debugging, outputs passwords in the logs!
						# SECURITY-NOTICE: Purge logs once you are done with debugging!
						#auth_verbose_passwords=yes

						# SSL
						ssl = required
						ssl_key = </etc/letsencrypt/live/rixotstudio.cz/privkey.pem
						ssl_cert = </etc/letsencrypt/live/rixotstudio.cz/fullchain.pem
						# FIXME: Make sure that expected certs are available
						ssl_client_ca_dir = /etc/ssl/certs

						mail_location = mbox:/var/vmail/%Ld/%Ln:INDEX=/var/indexes/%Ld/%Ln
						mail_uid=vmail
						mail_gid=vmail

						userdb {
						  driver = static
						  args = uid=vmail gid=vmail home=/var/mail/virtual/%Ld/%Ln
						}

						# SECURITY-IMPROVEMENT: Investigate ARGON2
						# database arguments https://doc.dovecot.org/configuration_manual/authentication/password_databases_passdb/
						# Password schemes: https://doc.dovecot.org/configuration_manual/authentication/password_schemes/
						passdb {
						  driver = passwd-file
						  # Each domain has a separate passwd-file:
						  args = /etc/auth/%Ld/passwd

						  deny = no
						  master = no
						  pass = no
						  skip = never
						  #username_filter =

						  result_failure = return-fail
							# SECURITY-WARNING: If multiple passdbs are required (results are merged), it’s important to set result_internalfail=return-fail to them, otherwise the authentication could still succeed but not all the intended extra fields are set.
						  result_internalfail = return-fail
						  result_success = return-ok

						  # v2.2.24+
						  auth_verbose = default
						}

						service auth {
						  unix_listener /var/spool/postfix/private/auth {
						    mode = 0666
						  }
						  unix_listener auth-userdb {
						    user = postfix
						    group = postfix
						    mode = 0666
						  }
						  user = \$default_internal_user
						}

						service pop3-login {
						  inet_listener pop3s {
						    port = 995
						    ssl = yes
						  }
						}

						service imap-login {
						  inet_listener imaps {
						    port = 993
						    ssl = yes
						  }
						}
					EOF

					# Ensure that auth file has the correct permission
					# FIXME-QA: Define the file into an env var
					# SECURITY-WARNING: Keep this at 0660 so that regular users doesn't have read access to passwd files
					"$CHMOD" 0660 "/etc/auth/$DOMAIN/passwd" || die false "Unable to set the expected permission to file '/etc/auth/$DOMAIN/passwd'"
					"$CHOWN" dovecot:dovecot "/etc/auth/$DOMAIN/passwd" || die false "Unable to set the expected ownership to file '/etc/auth/$DOMAIN/passwd'"

					# FIXME-QA: Sanitize
					efixme "Implement timeout for service restart"
					efixme "This hangs for some reason?"
					#service dovecot restart || die false "Unable to restart service 'dovecot'"

					funcname="$myName"
					return 0
				;;
				*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented to configure dovecot"
			esac
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented in $funcname"
	esac
}
