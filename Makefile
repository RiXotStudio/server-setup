.PHONY all vendor build

all:
	@ printf '%s\n' "This is a posix sh script, why are you trying make?"
	@ exit 2

vendor:
	@ [ -d vendor ] || mkdir vendor
	@ git clone https://github.com/RXT0112/Zernit.git vendor/Zernit

build: vendor
	@ [ -d build ] || mkdir build
	@ for vendor_func in cat src/bin/server-setup.sh | grep "^#% APPEND .*"; do
