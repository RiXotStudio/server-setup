


die() { funcname="die"
	case "$3" in
		###! Generic true
		###! - Used to exit the shell successfully
		###! Compatibility: Returns Error code 0 on Unix and Error Code 1 on Windows
		"true")
			# In case no message is provided
			if [ -z "$3" ]; then
				if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
					case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*)
							"$PRINTF" "$DIE_FORMAT_STRING_TRUE" "Exitted successfully"
							"$PRINTF" "$DIE_FORMAT_STRING_TRUE" "Exitted successfully" >> "$logPath"
					esac
				elif [ "$DEBUG" = 1 ]; then
					case "$LANG" in
						en-*|*)
							# FIXME-TRANSLATE: Translate in your language
							"$PRINTF" "$DIE_FORMAT_STRING_TRUE_DEBUG" "Exitted successfully"
							"$PRINTF" "$DIE_FORMAT_STRING_TRUE_DEBUG" "Exitted successfully" >> "$logPath"
					esac
				else
					# NOTICE(Krey): Do not use die() in die for unexpected
					case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
					esac
				fi
			# Message on second argument is provided
			elif [ -n "$3" ]; then
				if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
					"$PRINTF" "$DIE_FORMAT_STRING_TRUE" "$3"
					"$PRINTF" "$DIE_FORMAT_STRING_TRUE" "$3" >> "$logPath"
				elif [ "$DEBUG" = 1 ]; then
					"$PRINTF" "$DIE_FORMAT_STRING_TRUE_DEBUG" "$3"
					"$PRINTF" "$DIE_FORMAT_STRING_TRUE_DEBUG" "$3" >> "$logPath"
				else
					# NOTICE(Krey): Do not use die() in die for unexpected
					case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
					esac
				fi
			fi

			# Assertion
			case "$KERNEL" in
				linux)
					unset funcname
					exit 0 ;;
				windows)
					unset funcname
					exit 1 ;;
				*)
					"$PRINTF" 'BUG: %s\n' "Invalid kernel has been provided in $myName for arguments '$*': $KERNEL"
					unset funcname
					exit 255
			esac
		;;
		###! Generic failure
		###! - Used to exit the shell with fatal error
		###! Compatibility: Returns Error code 1 on Unix and Error Code 0 on Windows
		"false")
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FALSE" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_FALSE_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FALSE_DEBUG" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_FALSE_DEBUG_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			else
				case "$LANG" in
					# FIXME-TRANSLATE: Translate in your language
					en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			# Assertion
			case "$KERNEL" in
				linux)
					unset funcname
					exit 1 ;;
				windows)
					unset funcname
					exit 0 ;;
				*)
					"$PRINTF" 'BUG: %s\n' "Invalid kernel has been provided in $myName: $KERNEL"
					unset funcname
					exit 223
			esac
		;;
		28|"security")
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_SECURITY" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_SECURITY_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_SECURITY_DEBUG" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_SECURITY_DEBUG_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			else
				case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 28 # In case 'fixme' argument is provided
		;;
		38|"fixme") # For features that needs to be implemented and prefents runtime from continuing
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_DEBUG" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			else
				case "$LANG" in
						# FIXME-TRANSLATE: Translate in your language
						en-*|*) "$PRINTF" 'BUG: %s\n' "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 38 # In case 'fixme' argument is provided
		;;
		111|"invalid-format")
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT_DEBUG" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT_DEBUG_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			else
				case "$LANG" in
					# FIXME-TRANSLATE: Translate to more languages
					en-*|*) "$PRINTF" "$DIE_FORMAT_STRING" "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 223 # In case 'bug' is used
		;;
		223|"bug") # Unexpected trap
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_BUG" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_BUG_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_BUG_DEBUG" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_BUG_DEBUG_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			else
				case "$LANG" in
					# FIXME-TRANSLATE: Translate to more languages
					en-*|*) "$PRINTF" "$DIE_FORMAT_STRING" "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 223 # In case 'bug' is used
		;;
		255|"unexpected") # Unexpected trap
			if [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			elif [ "$DEBUG" = 1 ]; then
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG" "$3" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
				"$PRINTF" "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG_LOG" "$3" >> "$logPath" || { "$PRINTF" "$DIE_FORMAT_STRING_INVALID_FORMAT" "Invalid format string was parsed in $funcname calling argument '$2' with message '$3'"; exit 111 ;}
			else
				case "$LANG" in
					# FIXME-TRANSLATE: Translate to more languages
					en-*|*) "$PRINTF" "$DIE_FORMAT_STRING" "Unexpected happend while processing variable DEBUG with value '$DEBUG' in $funcname"
				esac
			fi

			unset funcname
			exit 255 # In case 'unexpected' is used
		;;
		*)
			case "$LANG" in
				# FIXME-TRANSLATE: Translate to more languages
				en-*|*) "$PRINTF" 'BUG: %s\n' "Invalid argument '$3' has been provided in $myName"
			esac
			unset funcname
			exit 255
	esac
}; alias die='die "$LINENO"'
