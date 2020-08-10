#!/bin/false
# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/00-server-setup.sh

# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

###! Workflow made to configure SSH Daemon on RiXotStudio's systems
###! Relevants
###! - https://kuttler.eu/en/post/ssh-over-tor/

setup_sshd() { funcname="setup_sshd"
	edebug 1 "Started $funcname setup function"
	case "$KERNEL" in
		"linux")
			case "$DISTRO/$RELEASE" in
				"devuan/chimaera")
					invoke_privileged "$APT_GET" install -y openssh-server || die false "Unable to install package 'openssh-server'"

					# Relevant: US standard for security of government systems https://csrc.nist.gov/publications/detail/sp/800-53/rev-4/final
					# Relevant: RedHat reference to SSH https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/s2-ssh-configuration-keypairs
					# Relevant: Manpage for ssh (https://www.man7.org/linux/man-pages/man1/ssh.1.html)
					# Relevant: Manpage for sshd_config (https://www.man7.org/linux/man-pages/man5/ssh_config.5.html)
					# Relevant: DigitalOcean community reference (https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)
					# FIXME-Suggestion: You might also want to tweak and play with ClientAliveCountMax if it's a tor hidden service, that way you can prevent disconnects with lag spikes, Same with ClientAliveInterval MaxStartups,
					# NOTICE(Krey): Changes in sshd_config are immediate and so there is no need to restart the service
					cat <<-EOF > /etc/ssh/sshd_config
						### SECURITY CHECKLIST
						## - [X] Use standard port 22 for SSH
						Port 22

						## - [X] Require pubkey and then password authentication
						AuthenticationMethods publickey,password

						## - [ ] Disable root login
						# FIXME-SECURITY(Krey): Brainstorm since we are using $UPSTREAM_REPOSITORY for deployment
						PermitRootLogin yes

						## - [X] Require publickey authentification
						PubkeyAuthentication yes
						# SECURITY-WARNING: Do not use 'ssh-rsa' since that is using md5sum to verify the signature which is insecure!
						PubkeyAcceptedKeyTypes rsa-sha2-512
						# FIXME-SECURITY: There are methods that may require multiple layers of authentification -> Investigate
						# FIXME: Invalid
						#AuthentificationMethods publickey
						# Just to ensure that ssh is usinc publickey at all cost
						# FIXME: Invalid
						#PreferredAuthentications publickey

						## - [ ] Do not allow empty passwords
						# FIXME: Invalid
						#PermitEmptyPassowrds no

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

						## - [ ] Disable X11
						# FIXME: Invalid
						#ForwardX11 no

						## - [ ] Capture failed login attemps and implement remote logging to capture security issues
						# FIXME: Help-wanted

						## - [ ] Check integrity of critical files using checksum
						# FIXME: Needs to be implemented

						# Logging
						# FIXME
					EOF

					# Create SSH dir
					emkdir "/home/$MAINTAINER_NICKNAME/.ssh"

					# Allow privileged people to have access in the server
					# FIXME-SECURITY: Ensure that their private key is encrypted with password
					# FIXME: Allow configuration on demand
					invoke_privileged cat <<-EOF > "/home/$MAINTAINER_NICKNAME/.ssh/authorized_keys"
						ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClDp9OKjyYJnrmxBbHST20P5Yko9/1w3rz/haco23K5KcSSxaJ/hY/NDwoydtSqB/JoYDY0nSQd4qtxuuEhMshqmUHhHacTgvXmWApI/Rp
un8ap5KFZjvbIuX/J7Mgpou5CLDQodG/93HWp8Bq6+DDsEfiUapyxDullnCr//SNUv7eHgiSmkbpRQetG+RvE7IHGP6QCYF5MBVwVkBjnzN+Xt+iWQ+JL+ZhuLh0WC3W7uNxMLzzAr5fKVUJ
cpzwPSd8PmaEko83pQAUXFcI4BJL3IXpvAbJhAPpPaZcbHYxsj+1ypLBBJaLHDiSlmbFw0qCOW937nT/7p1HYw7ImXMKwjC7DxgKz8rfAQoCKkDTu1fkOe15ZtrCZCJL2IjXBryuFh4A9DTo
nU+bFplX1J6hW9WZQS8oQGQ1p1kM6WYy5b1CpMrJTKAJkJQXczrzJRf3ivVevyO4EDNXILVZ4SYWmaQsD6t8vYagTQVkzZyrx3ZznCjYITGMXGAIRj+NAl8JvOcs8LrxcJzRni38iqVM+Iht
St5UWYl5jhUv+FVhUFnzCsidI5HePA2LpjJ7GQ1H3gEqoQCuKifOLfEj7IU0UXelXXhkeNB38/mvyl97W0yHEItLJNi5Fle26jB3BVJd5s1Rbm5DBqwHKTI9A5Ul6DEahJm8g9NWWjfhslhv
xw== kreyren@rixotstudio.cz
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
