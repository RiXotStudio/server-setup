#!/bin/false
# - Used only for sourcing
# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/server-setup.sh

###! Workflow made to configure SSH Daemon on RiXotStudio's systems
###! Relevant

setup_sshd() { funcname="setup_sshd"
	einfo "Configuring SSH Daemon for remote access"
		case "$KERNEL" in
			"linux")
				case "$DISTRO/$RELEASE" in
					"devuan/chimaera")
						elog "$(invoke_privileged "$APT_GET" install -y openssh-server || die false "Unable to install package 'openssh-server'")"

						# Relevant: US standard for security of government systems https://csrc.nist.gov/publications/detail/sp/800-53/rev-4/final
						# Relevant: RedHat reference to SSH https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/s2-ssh-configuration-keypairs
						# Relevant: Manpage for ssh (https://www.man7.org/linux/man-pages/man1/ssh.1.html)
						# Relevant: Manpage for sshd_config (https://www.man7.org/linux/man-pages/man5/ssh_config.5.html)
						# Relevant: DigitalOcean community reference (https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)
						# FIXME-Suggestion: You might also want to tweak and play with ClientAliveCountMax if it's a tor hidden service, that way you can prevent disconnects with lag spikes, Same with ClientAliveInterval MaxStartups,
						cat <<-EOF > /etc/ssh/sshd_config
							### SECURITY CHECKLIST
							## - [X] Use standard port 22 for SSH
							Port 22

							## - [X] Disable root login
							PermitRootLogin no

							## - [X] Require publickey authentification
							PubkeyAuthentication yes
							# Allow only ssh-rsa since that's what privileged users are using
							PubkeyAcceptedKeyTypes ssh-rsa
							# FIXME-SECURITY: There are methods that may require multiple layers of authentification -> Investigate
							AuthentificationMethods publickey
							# Just to ensure that ssh is usinc publickey at all cost
							PreferredAuthentications publickey

							## - [X] Disable password authentification
							PasswordAuthentication no

							## - [X] Do not allow empty passwords
							PermitEmptyPassowrds no

							## - [X] Set Maximum connections attempts
							# FIXME: Investigate fail2ban
							# NOTICE(Krey): We are using publickey so this should be set to 1, if there is required a second attempt for pubkey authentication then there is something wrong going on
							MaxAuthTries 1

							## - [X] Set Maximum allowed sessions
							MaxSessions 5

							## - [ ] Disconnect the users after 5 minutes
							# FIXME: Help-wanted
							# ConnectTimeout ?
							# ForwardX11Timeout  ?

							## - [ ] Add various counter-measures for brute-force attacks
							# FIXME: Help-wanted

							## - [X] Disable X11
							ForwardX11 no

							## - [ ] Capture failed login attemps and implement remote logging to capture security issues
							# FIXME: Help-wanted

							## - [ ] Check integrity of critical files using checksum
							# FIXME: Needs to be implemented
						EOF

						# Allow privileged people to have access in the server
						# FIXME-SECURITY: Ensure that their private key is encrypted with password
						invoke_privileged cat <<-EOF > /root/ssh/authorized_keys
							# Jacob Hrbek
							ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClDp9OKjyYJnrmxBbHST20P5Yko9/1w3rz/haco23K5KcSSxaJ/hY/NDwoydtSqB/JoYDY0nSQd4qtxuuEhMshqmUHhHacTgvXmWApI/Rpun8ap5KFZjvbIuX/J7Mgpou5CLDQodG/93HWp8Bq6+DDsEfiUapyxDullnCr//SNUv7eHgiSmkbpRQetG+RvE7IHGP6QCYF5MBVwVkBjnzN+Xt+iWQ+JL+ZhuLh0WC3W7uNxMLzzAr5fKVUJcpzwPSd8PmaEko83pQAUXFcI4BJL3IXpvAbJhAPpPaZcbHYxsj+1ypLBBJaLHDiSlmbFw0qCOW937nT/7p1HYw7ImXMKwjC7DxgKz8rfAQoCKkDTu1fkOe15ZtrCZCJL2IjXBryuFh4A9DTonU+bFplX1J6hW9WZQS8oQGQ1p1kM6WYy5b1CpMrJTKAJkJQXczrzJRf3ivVevyO4EDNXILVZ4SYWmaQsD6t8vYagTQVkzZyrx3ZznCjYITGMXGAIRj+NAl8JvOcs8LrxcJzRni38iqVM+IhtSt5UWYl5jhUv+FVhUFnzCsidI5HePA2LpjJ7GQ1H3gEqoQCuKifOLfEj7IU0UXelXXhkeNB38/mvyl97W0yHEItLJNi5Fle26jB3BVJd5s1Rbm5DBqwHKTI9A5Ul6DEahJm8g9NWWjfhslhvxw== kreyren@rixotstudio.cz
						EOF

						# Set up tor
						invoke_privileged cat <<-EOF > /etc/tor/torrc.d/sshd
							# Set up SSH Daemon to run through Tor
							HiddenServiceDir /var/lib/tor/sshd/
							HiddenServicePort 22 127.0.0.1:22
						EOF

						# Make sure that tor is set up to read from torrc.d/sshd
						if grep -q "%include $torDir/torrc.d/sshd" "$torDir/torrc"; then
							edebug 1 "Confirmed that required configuration for torrc using sshd is present"
						elif ! grep -q "%include $torDir/torrc.d/sshd" "$torDir/torrc"; then
							edebug 1 "Expected configuration for torrc to use sshd is not present, appending.."
							printf '%s\n' "%include $torDir/torrc.d/sshd" >> "$torDir/torrc" || die false "Unable to append required changes in '$torDir/torrc'"
						else
							die bug "Command 'grep' returned exitcode that is not recognized by the script logic"
						fi

						unset funcname
						return 0
					;;
					*) die fixme "Linux distribution '$DISTRO' with release '$RELEASE' is not implemented to handle SSH Daemon configuration"
				esac
			;;
			*) die fixme "Kernel '$KERNEL' is not implemeted to configure SSH Daemon"
		esac
}
