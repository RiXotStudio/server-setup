#!/bin/false
# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/00-server-setup.sh

# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

###! Workflow made to create/configure maintainer account

# FIXME(Krey): Implement King-Mode (sanitized backdoor to force access to the system when it's compromised)

# Function called to generate SSH access keys for the maintainer
maintainer_ssh_access() { funcname="funcname"
	if [ "$MAINTAINER_NICKNAME" = "kreyren" ]; then
		cat <<-EOF
			# Jacob Hrbek (kreyren)
			ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClDp9OKjyYJnrmxBbHST20P5Yko9/1w3rz/haco23K5KcSSxaJ/hY/NDwoydtSqB/JoYDY0nSQd4qtxuuEhMshqmUHhHacTgvXmWApI/Rpun8ap5KFZjvbIuX/J7Mgpou5CLDQodG/93HWp8Bq6+DDsEfiUapyxDullnCr//SNUv7eHgiSmkbpRQetG+RvE7IHGP6QCYF5MBVwVkBjnzN+Xt+iWQ+JL+ZhuLh0WC3W7uNxMLzzAr5fKVUJcpzwPSd8PmaEko83pQAUXFcI4BJL3IXpvAbJhAPpPaZcbHYxsj+1ypLBBJaLHDiSlmbFw0qCOW937nT/7p1HYw7ImXMKwjC7DxgKz8rfAQoCKkDTu1fkOe15ZtrCZCJL2IjXBryuFh4A9DTonU+bFplX1J6hW9WZQS8oQGQ1p1kM6WYy5b1CpMrJTKAJkJQXczrzJRf3ivVevyO4EDNXILVZ4SYWmaQsD6t8vYagTQVkzZyrx3ZznCjYITGMXGAIRj+NAl8JvOcs8LrxcJzRni38iqVM+IhtSt5UWYl5jhUv+FVhUFnzCsidI5HePA2LpjJ7GQ1H3gEqoQCuKifOLfEj7IU0UXelXXhkeNB38/mvyl97W0yHEItLJNi5Fle26jB3BVJd5s1Rbm5DBqwHKTI9A5Ul6DEahJm8g9NWWjfhslhvxw== kreyren@rixotstudio.cz
		EOF
		unset funcname
		return 0
	elif [ "$MAINTAINER_NICKNAME" != "kreyren" ]; then
		die false "Maintainer '$MAINTAINER_NICKNAME' is not implemented in logic, add your ssh configuration in function $funcname"
	else
		die unexpected "processing maintainer '$MAINTAINER_NICKNAME' in function '$funcname'"
	fi
}

setup_maintainer() { funcname="setup_maintainer"
	edebug 1 "Started $funcname setup function"

	case "$KERNEL" in
		"linux")
			# Maintainer account
			if [ -n "$MAINTAINER_NICKNAME" ]; then
				# Create a new homedir if needed
				if [ -d "/home/$MAINTAINER_NICKNAME" ]; then
					edebug 1 "Directory '/home/$MAINTAINER_NICKNAME' already exists, no need to create it"
				elif [ ! -d "/home/$MAINTAINER_NICKNAME" ]; then
					emkdir "/home/$MAINTAINER_NICKNAME"
				else
					die unexpected "Creating a new directory '/home/$MAINTAINER_NICKNAME' in function $funcname"
				fi

				# Create the maintainer account
				# FIXME
				efixme "Create maintainer account"

				# FIXME
				efixme "Configure SSH access for $MAINTAINER_NICKNAME"
			elif [ -z "$MAINTAINER_NICKNAME" ]; then
				einfo "Variable 'MAINTAINER_NICKNAME' is blank, skipping creation of the maintainer account"
			else
				die unexpected "processing variable MAINTAINER_NICKNAME in function $funcname"
			fi
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented in function $funcname"
	esac
}
