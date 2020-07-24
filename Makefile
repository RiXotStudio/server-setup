.PHONY: all clean vendor build list

# FIXME-QA(Krey): Do we need some sanitization for the environment used? i.e correct 'ed' used?

# Define directory to cache vendors
cacheDir = $$HOME/.cache/

#@ Default target invoked on 'make' (outputs syntax error on this project)
all:
	@ $(error Target 'all' is not allowed, use 'make list' to list available targets or read the 'Makefile' file)
	@ exit 2

#@ List all targets
list:
	@ true \
		&& grep -A 1 "^#@.*" Makefile | sed s/--//gm | sed s/:.*//gm | sed "s/#@/#/gm" | while IFS= read -r line; do \
			case "$$line" in \
				"#"*|"") printf '%s\n' "$$line" ;; \
				*) printf '%s\n' "make $$line"; \
			esac; \
		done

#@ Clean temporary directories
clean:
	$(info Cleaning..)
	@ [ ! -d vendor ] || rm -rf vendor
	@ [ ! -d build ] || rm -rf build
	$(info Finished cleaning)

#@ Clear cache
clean-cache:
	$(info Clearning cache directory at '$(cacheDir)')
	@ [ ! -d "$(cacheDir)/Zernit" ] || rm -r "$(cacheDir)/Zernit"
	$(info Cleared '$(cacheDir)/Zernit')
	$(info Cache directory at '$(cacheDir)' has been cleared of vendors fetched using this project)

#@ Fetch 3rd party source code
vendor: clean
	$(info Fetching vendors..)
	@ [ -d vendor ] || mkdir vendor
	$(info Caching step requires cache directory)
	@ [ -d "$(cacheDir)/Zernit" ] || git clone https://github.com/RXT0112/Zernit.git "$(cacheDir)/Zernit" && printf '%s\n' "Vendor 'Zernit' has been cached in '$$HOME/.cache/Zernit'"
	@ [ -d vendor/Zernit ] || cp -r "$(cacheDir)/Zernit" vendor/Zernit
	$(info All vendors were fetched)

###! We are using '#& APPEND something' in the code that is being replaced with a code from a vendor using ed

# FIXME-SUGGESTION: btw that tr command is pointless; also consider using «cmd | while read -r var» instead of «for var in $(cmd)»
# FIXME-SUGGESTION: @ while IFS= read -r line; do case "$$line" in '#& APPEND '*) cat "$${line##'#& APPEND '}" ;; *) printf '%s\n' "$$line" ;; esac; done < src/bin/server-setup.sh > build/server-setup.sh
# FIXME-QA: This creates additional 3 lines in between comment and '#% APPEND ...'
# FIXME: Implement these in a way that doesn't mess with EOF
	# && : "Remove comments" \
	# && printf "g/#.*/d\nw\nq\n" | ed -s "vendor/$${string##*/}" \
	# && : "Remove blank lines" \
	# && printf "s/^$/d\nw\nq\n" | ed -s "vendor/$${string##*/}" \
#@ Build the script
build: vendor
	$(info Building..)
	@ [ -d build ] || mkdir build
	@ [ -f build/server-setup.sh ] || cp src/bin/server-setup.sh build/server-setup.sh
	@ true \
		&& printf 'INFO: %s\n' "Replacing '#& APPEND path' with requested code" \
		&& grep "^#& APPEND.*" src/bin/server-setup.sh | while IFS= read -r string; do \
			true \
			&& printf '%s\n' "Processing $${string##*/} from appended" \
			&& cp "$${string##\#& APPEND }" "vendor/$${string##*/}" \
			&& : "Replace '#& APPEND ...' with content from the file" \
			&& printf "/^#& APPEND $$(printf '%s\n' "$${string##\#& APPEND }" | sed "s#\/#\\\/#gm")/d\n-1r vendor/$${string##*/}\\nw\\nq\\n" | ed -s build/server-setup.sh\;\
			done \
		&& printf 'INFO: %s\n' "Replaced all mensioning of '#& APPEND path' with requested code"
	@ true \
		&& printf 'INFO: %s\n' "Removing tag 'BUILD-CHECK' allowing the script to run" \
		&& printf '/^#& BUILD-CHECK/d\nd\nw\nq\n' | ed -s build/server-setup.sh \
		&& printf 'INFO: %s\n' "tag 'BUILD-CHECK' and it's relevant code has been removed"
	$(info Build phase finished)

#@ Format the built result to be more storage efficient
format-release: build
	$(info Stripping level 1 comments)
	@ printf 'g/# .*/d\nw\nq\n' | ed -s build/server-setup.sh # Strip lvl 1 comments
	$(info Stripping level 2 comments)
	@ printf 'g/## .*/d\nw\nq\n' | ed -s build/server-setup.sh # Strip lvl 2 comments
	$(info Stripping level 3 comments)
	@ printf 'g/### .*/d\nw\nq\n' | ed -s build/server-setup.sh # Strip lvl 3 comments
	$(info Stripping documentation comments)
	@ printf 'g/###! .*/d\nw\nq\n' | ed -s build/server-setup.sh # Strip documentation comments
	$(info Stripping blank lines comments)
	@ printf 'g/^\n$/d\nw\nq\n' | ed -s build/server-setup.sh # Strip blank lines
	$(info formatting for release finished)

#@ Build the script for release
release: build format-release

#@ Install the script (requires privileged access)
install: build
	# NOTICE(Krey): Comment out this line if your privileged user doesn't have user id '0' and let me know at kreyren@rixotstudio.cz
	@ [ "$$(id -u)" = 0 ] || printf 'FATAL: %s\n' "This script has to be installed in /root/server-setup.sh and run in clean environment separated from the live system and so privileged access is required (re-invoke as root)"
	$(info Installing..)
	@ true \
		&& [ -f /root/server-setup.sh ] || cp build/server-setup.sh /root/server-setup.sh
		&& [ -x /root/server-setup.sh ] || chmod +x /root/server-setup.sh
	$(info Script has been successfully installed)

#@ Uninstall the script
uninstall:
	$(info Uninstalling..)
	@ [ ! -f /root/server-setup.sh ] || rm /root/server-setup.sh
	$(info Script has been successfully uninstalled)
