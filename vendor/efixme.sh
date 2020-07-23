



efixme() { funcname="efixme"
	if [ "$IGNORE_FIXME" = 1 ]; then
		# FIXME: Implement 'fixme' debug channel
		edebug fixme "Fixme message for '$2' disabled"
		exit 0
	elif [ "$IGNORE_FIXME" = 0 ] || [ -z "$IGNORE_FIXME" ]; then
		if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
			"$PRINTF" "$EFIXME_FORMAT_STRING" "$2" || die invalid-format
			"$PRINTF" "$EFIXME_FORMAT_STRING" "$2" >> "$logPath" || die invalid-format
			unset funcname
			exit 0
		elif [ "$DEBUG" = 1 ]; then
			"$PRINTF" "$EFIXME_FORMAT_STRING_DEBUG" "$2" || die invalid-format
			"$PRINTF" "$EFIXME_FORMAT_STRING_DEBUG_LOG" "$2" >> "$logPath" || die invalid-format
			unset funcname
			exit 0
		else
			case "$LANG" in
				# FIXME-TRANSLATE: Translate to more languages
				en-*|*) die 255 "processing DEBUG variable with value '$DEBUG' in $funcname"
			esac
		fi
	else
		case "$LANG" in
			# FIXME-TRANSLATE: Translate to more languages
			en-*|*) die 255 "processing variable IGNORE_FIXME with value '$IGNORE_FIXME' in $0"
		esac
	fi
}; alias efixme='efixme "$LINENO"'
