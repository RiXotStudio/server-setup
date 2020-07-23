


edebug() { funcname="edebug"
	efixme "Implement debug channels in $funcname"
	if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
		"$PRINTF" "$EDEBUG_FORMAT_STRING" "$2" || die invalid-format
		"$PRINTF" "$EDEBUG_FORMAT_STRING_LOG" "$2" >> "$logPath" || die invalid-format
		unset funcname
		exit 0
	elif [ "$DEBUG" = 1 ]; then
		"$PRINTF" "$EDEBUG_FORMAT_STRING_DEBUG" "$2" || die invalid-format
		"$PRINTF" "$EDEBUG_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath" || die invalid-format
		unset funcname
		exit 0
	else
		case "$LANG" in
			# FIXME-TRANSLATE: Translate to more languages
			en-*|*) die 255 "processing variable DEBUG with value '$DEBUG' in $funcname"
		esac
	fi
}; alias die='die "$LINENO"'
