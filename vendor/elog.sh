


elog() { funcname="elog"
	case "$2" in
		"debug")
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				unset funcname
				exit 0
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$ELOG_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath" || die invalid-format
				unset funcname
				exit 0
			else
				case "$LANG" in
					# FIXME-TRANSLATE: Translate to more languages
					en-*|*) die bug "processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi ;;
		*) die bug "Invalid argument '$2' has been parsed to $funcname"
	esac
}; alias einfo='einfo "$LINENO"'
