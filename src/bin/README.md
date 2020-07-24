# Server-setup

Script to run continuously (reinvoked every X time) on the target system to make sure the configuration is as specified and to inform the administrator in case it unexpectedly changes

Meant to run in a standalone `busybox sh` instance stored in `/root` directory on linux using one file script (converted into a one file using `make build`)

This is mostly a temporary implementation until https://github.com/RXT0112/Zernit is finished, may be implemented into a standlone product on demand using high-end programming language instead of posix shell
