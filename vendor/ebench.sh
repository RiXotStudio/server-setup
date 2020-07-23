



ebench() { funcname="ebench"
	case "$SKIP_BENCHMARK" in
		1)
		 	unset funcname
			exit 0 ;;
		0|"") edebug 3 "Benchmark was not skipped" ;;
		*) die 23 "Variable SKIP_BENCHMARK has unexpected value '$SKIP_BENCHMARK', expecting only '1' or blank"
	esac

	case "$2" in
		start)
			printf "$EBENCH_FORMAT_STRING_START" "$2" || die invalid-format
			# POSIX: We might be able to use /proc/uptime on Unix
			efixme "Variable 'SECONDS' is not POSIX compatible, implement logic"
			SECONDS=0
			unset funcname
			exit 0 ;;
		result)
			printf "$EBENCH_FORMAT_STRING_RESULT" "$2" || die invalid-format
			unset funcname
			exit 0 ;;
		*) die 2 "Invalid argument '$2' has been parsed in $funcname"
	esac
}; alias ebench='ebench "$LINENO"'
