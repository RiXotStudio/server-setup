.PHONY: all clean vendor build list

# Define directory to cache vendors
cacheDir = $$HOME/.cache/

all:
	@ $(error Target 'all' is not allowed, to build this source code use 'make build' or use 'make list' to list available targets or read the 'Makefile' file)
	@ exit 2

#@ List all targets
list:
	@ grep -o "^.*:$" Makefile

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

###! We are using '#@ APPEND something' in the code that is being replaced with a code from a vendor using ed

# FIXME: This creates additional 3 lines in between comment and '#% APPEND ...'
#@ Build the script
build: vendor
	$(info Building..)
	@ [ -d build ] || mkdir build
	@ [ -f build/server-setup.sh ] || cp src/bin/server-setup.sh build/server-setup.sh
	@ grep "^#% APPEND.*" src/bin/server-setup.sh | while IFS= read -r string; do cp "${string##\#& APPEND}" "vendor/${string##*/}" && printf "g/^#.*/d\nw\nq\n" | ed -s "vendor/${string##*/}" && printf "/^#& APPEND ${string##\#& APPEND}/d\\n-1r ${string##\#& APPEND}\\nw\\nq\\n" | ed -s build/server-setup.sh; done # Replace '#& APPEND' flags with their specified path
	@ printf '/^#%% BUILD-CHECK/d\nd\nw\nq\n' | ed -s build/server-setup.sh # Remove the BUILD-CHECK
	@ printf 'g/###!.*/d\nw\nq\n' | ed -s build/server-setup.sh # Strip docummentation
	$(info Script has been successfully built)

#@ Format the built result to be more storage efficient
format-release: build
	@ printf 'g/# .*/d\nw\nq\n' | ed -s build/server-setup.sh # Strip lvl 1 comments
	@ printf 'g/## .*/d\nw\nq\n' | ed -s build/server-setup.sh # Strip lvl 2 comments
	@ printf 'g/### .*/d\nw\nq\n' | ed -s build/server-setup.sh # Strip lvl 3 comments
	@ printf 'g/^\n$/d\nw\nq\n' | ed -s build/server-setup.sh # Strip blank lines

#@ Build the script for release
release: build format-release

#@ Install the script (requires privileged access)
install: build
	$(info Installing..)
	@ [ -f /root/server-setup.sh ] || cp build/server-setup.sh /root/server-setup.sh
	@ [ -x /root/server-setup.sh ] || chmod +x /root/server-setup.sh
	$(info Script has been successfully installed)

#@ Uninstall the script
uninstall:
	$(info Uninstalling..)
	@ [ ! -f /root/server-setup.sh ] || rm /root/server-setup.sh
	$(info Script has been successfully uninstalled)
