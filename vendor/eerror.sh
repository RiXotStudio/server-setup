


eerror() { funcname="eerror"
	if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
		"$PRINTF" "$EERROR_FORMAT_STRING" "$2" || die invalid-format
		"$PRINTF" "$EERROR_FORMAT_STRING_LOG" "$2" >> "$logPath" || die invalid-format
		unset funcname
		exit 0
	elif [ "$DEBUG" = 1 ]; then
		"$PRINTF" "$EERROR_FORMAT_STRING_DEBUG" "$2" || die invalid-format
		"$PRINTF" "$EERROR_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath" || die invalid-format
		unset funcname
		exit 0
	else
		case "$LANG" in
			# FIXME-TRANSLATE: Translate to more languages
			en-*|*) die bug "processing variable DEBUG with value '$DEBUG' in $funcname"
		esac
	fi
}; alias eerror='eerror "$LINENO"'
