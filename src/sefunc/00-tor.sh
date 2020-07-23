#!/bin/false
# - Used only for sourcing
# Created by Jacob Hrbek under All Rights Reserved in 19/07/2020 (prepared for four freedom respecting license)

# shellcheck shell=sh # Written to be POSIX-compatible
# shellcheck source=src/bin/server-setup.sh

###! Workflow used to set up tor on target system using RiXotStudio's configuration

setup_tor() { funcname="setup_tor"
	### CONFIGURATION ###
	tor_SocksPort=9050
	tor_DNSPort=5400
	tor_ORPort=9001

	# Make sure that tor is installer else install it
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
						invoke_privileged "$APT_GET" update -q || die 1 "unable to update repositories"

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

	# Configure torrc
	case "$KERNEL" in
		"linux")
			# shellcheck disable=SC2039 # HOSTNAME is undefined on posix, but defined by our script in src/bin/server-setup.sh
			cat <<-EOF > /etc/tor/torrc
				Nickname $UPSTREAM_NAME/$HOSTNAME
				ContactInfo 0x$MAINTAINER_PUBKEY $MAINTAINER_NAME $MAINTAINER_SURNAME <$MAINTAINER_EMAIL>
				NumCPUs $(nproc || printf '%s\n' "8")
				SocksPort $tor_SocksPort
				ORPort $tor_ORPort

				# Setup Bandwidth limiters
				RelayBandwidthRate 125 KB # Throttle traffic to 125KB/s 1000Kbps)
				RelayBandwidthBurst 375 KB # But allow bursts up to 375KB/s (3000Kbps)

				# DNS
				DNSPort $tor_DNSPort

				# Use onion websites over clearnet when sane (fast enough connection and availability)
				## Generated using: curl https://onion.debian.org/ 2>/dev/null | grep '<li id=.*\.onion.*' | sed -E "s#^<li id=\"(.*)\"><strong>.*<\/strong>: <a href=\"(http:\/\/.*\.onion)\/\">http:\/\/.*\.onion\/<\/a><\/li>#MapAddress \1 \2#gm"
				MapAddress 10years.debconf.org b5tearqs4v4nvbup.onion
				## FIXME: Some websites alike debian.org doesn't work on https://debian.org, but work on http://debian.org where web-browsers might redirect on https
				MapAddress appstream.debian.org 5j7saze5byfqccf3.onion
				MapAddress apt.buildd.debian.org ito4xpoj3re4wctm.onion
				MapAddress backports.debian.org 6f6ejaiiixypfqaf.onion
				MapAddress bits.debian.org 4ypuji3wwrg5zoxm.onion
				MapAddress blends.debian.org bcwpy5wca456u7tz.onion
				MapAddress bootstrap.debian.net ihdhoeoovbtgutfm.onion
				MapAddress cdbuilder-logs.debian.org uqxc5rgqum7ihsey.onion
				MapAddress cdimage-search.debian.org 4zhlmuhqvjkvspwb.onion
				MapAddress d-i.debian.org f6syxyjdgzbeacry.onion
				MapAddress ddtp.debian.org gkcjzacpobmneucx.onion
				MapAddress debaday.debian.net ammd7ytxcpeavif2.onion
				MapAddress debconf0.debconf.org ynr7muu3263jikep.onion
				MapAddress debconf1.debconf.org 4do6yq4iwstidagh.onion
				MapAddress debconf16.debconf.org 6nhxqcogfcwqzgnm.onion
				MapAddress debconf17.debconf.org hdfcrogj3fayr7wl.onion
				MapAddress debconf18.debconf.org 6zwq6bghdyviqf7r.onion
				MapAddress debconf2.debconf.org ugw3zjsayleoamaz.onion
				MapAddress debconf3.debconf.org zdfsyv3rubuhpql3.onion
				MapAddress debconf4.debconf.org eeblrw5eh2is36az.onion
				MapAddress debconf5.debconf.org 3m2tlhjsoxws2akz.onion
				MapAddress debconf6.debconf.org gmi5gld3uk5ozvrv.onion
				MapAddress debconf7.debconf.org 465rf3c2oskkqc24.onion
				MapAddress debdeltas.debian.net vral2uljb3ndhhxr.onion
				MapAddress debug.mirrors.debian.org ktqxbqrhg5ai2c7f.onion
				MapAddress dpl.debian.org j73wbfpplklpixbh.onion
				MapAddress dsa.debian.org f7bphdxlqca3sevt.onion
				MapAddress es.debconf.org nwvk3svshonwqfjs.onion
				MapAddress fr.debconf.org ythg247lqkx2gpgx.onion
				MapAddress ftp.debian.org vwakviie2ienjx6t.onion
				MapAddress ftp.ports.debian.org nbybwh4atabu6xq3.onion
				MapAddress incoming.debian.org oscbw3h7wrfxqi4m.onion
				MapAddress incoming.ports.debian.org vyrxto4jsgoxvilf.onion
				MapAddress lintian.debian.org ohusanrieoxsxlmh.onion
				MapAddress manpages.debian.org pugljpwjhbiagkrn.onion
				MapAddress media.debconf.org ls5v3tzpothur4mv.onion
				MapAddress metadata.ftp-master.debian.org cmgvqnxjoiqthvrc.onion
				MapAddress micronews.debian.org n7jzk5wpel4tdog2.onion
				MapAddress miniconf10.debconf.org tpez4zz5a4civ6ew.onion
				MapAddress mirror-master.debian.org kyk55bof3hzdiwrm.onion
				MapAddress mozilla.debian.net fkbjngvraoici6k7.onion
				MapAddress news.debian.net tz4732fxpkehod36.onion
				MapAddress onion.debian.org 5nca3wxl33tzlzj5.onion
				MapAddress openpgpkey.debian.org habaivdfcyamjhkk.onion
				MapAddress people.debian.org hd37oiauf5uoz7gg.onion
				MapAddress planet.debian.org gnvweaoe2xzjqldu.onion
				MapAddress release.debian.org 6nvqpgx7bih375fx.onion
				MapAddress rtc.debian.org ex4gh7cig5ssn2xm.onion
				MapAddress security-team.debian.org ynvs3km32u33agwq.onion
				MapAddress security.debian.org sgvtcaew4bxjd7ln.onion
				MapAddress timeline.debian.net qqvyib4j3fz66nuc.onion
				MapAddress tracker.debian.org 2qlvvvnhqyda2ahd.onion
				MapAddress wnpp-by-tags.debian.net gl3n4wtekbfaubye.onion
				MapAddress www.debian.org sejnfjrq6szgca7v.onion
				MapAddress www.ports.debian.org lljrzrimek6if67j.onion

				# To provide informations about this relay to public
				# FIXME: Verify that we can use this as an exit node, then uncomment
				#DirPortFrontPage $torDir/tor-exit-notice.html
			EOF
		;;
		*) die fixme "Kernel '$KERNEL' is not implemented for function '$funcname' to configure torrc in $myName script located at $0"
	esac

	# Set frontpage notice
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
}
