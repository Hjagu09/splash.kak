# This script fills Kakoune scratch buffers with a logo and help messages.
# Author: Francois Tonneau

declare-option -docstring 'Splash screen: frame color' str splash_frame rgb:dfdedb

declare-option -docstring 'Splash screen: K body color' str splash_k_body rgb:637486
declare-option -docstring 'Splash screen: K leg color' str splash_k_leg rgb:435a6c

declare-option -docstring 'Splash screen: phonetics foreground' str splash_phon_fg rgb:ffffff
declare-option -docstring 'Splash screen: phonetics background' str splash_phon_bg rgb:b38059

declare-option -docstring 'Splash screen: faded font color' str splash_faded rgb:8a8986

hook -group splash global WinCreate '\*scratch\*' %{
	evaluate-commands -save-regs S %{

		# Fill register with content
		set-register S \
"┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│   ███ ██                                                            │
│   █████                                                             │
│   █████                                                             │
│   █████ A K O U N E                          /kə'kuːn/             │
│                                                                       │
│                                                                       │
│                                                                       │
│                                                                       │
│                                                                       │
│   Edit empty buffer                             i                     │
│   Open a file                                   :e <space>            │
│   Read help                                     :doc <space>          │
│   Quit                                          :q <enter>            │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘"
		# Paste content into buffer
		execute-keys <esc><esc> <percent> <">S R

		# Colorize frame
		add-highlighter window/borders regex "[─│┌┐└┘├┤┬┴┼]" \
			"0:%opt(splash_frame)"

		# Colorize logo
		add-highlighter window/logo_1 regex "███ ██" \
			"0:%opt(splash_k_body)"
		add-highlighter window/logo_2 regex "█████" \
			"0:%opt(splash_k_body)"
		add-highlighter window/logo_3 regex "(█████)()" \
			"1:%opt(splash_k_body),%opt(splash_k_leg)+g" "2:%opt(splash_k_leg)"
		add-highlighter window/logo_4 regex "(████)(█)" \
			"1:%opt(splash_k_body)" "2:%opt(splash_k_leg)"
		add-highlighter window/logo_5 regex "A K O U N E" \
			0:default,+b

		# Colorize phonetic string
		add-highlighter window/phon regex "/kə'kuːn/" \
			"0:%opt(splash_phon_fg),%opt(splash_phon_bg)+b"

		# Colorize text elements
		add-highlighter window/edit regex '^ *│ *(Edit empty buffer) + (i)' \
			"1:%opt(splash_faded)" 2:default,+b "3:%opt(splash_faded)"
		add-highlighter window/open regex '^ *│ *(Open a file) + (:e) (<space>)' \
			"1:%opt(splash_faded)" 2:default,+b "3:%opt(splash_faded)"
		add-highlighter window/help regex '^ *│ *(Read help) + (:doc) (<space>)' \
			"1:%opt(splash_faded)" 2:default,+b "3:%opt(splash_faded)"
		add-highlighter window/quit regex '^ *│ *(Quit) + (:q) (<enter>)' \
			"1:%opt(splash_faded)" 2:default,+b "3:%opt(splash_faded)"
	}

	# remove the uggly cursor. We'll add it back later
	face buffer PrimaryCursorEol Default

	# center the thingy hook
	hook -group splash-center buffer WinResize .* %{
		evaluate-commands %sh{
			# clear previous indent
			# this may fail if their is no previous indent so its in a
			# try block
			printf "%s\n" "try %{execute-keys %{%s^ +<ret>d}}"
			# clear previous empty lines. just like the other one this can fail
			printf "%s\n" "try %{execute-keys %{%s^$<ret>d}}"
			# 71 is the width of the splash (i believe)
			# four is the width of gutter + line numbers (most of the time)
			printf "%s\n" "execute-keys %{%<a-s>i$(
				printf %$((
					(kak_window_width - 71 - 4) / 2
				))s
			)<esc>}"
			# 16 is the heigth of the splash
			# one is for the status line
			printf "%s\n" "execute-keys %{ggi$(
				printf %$((
					(kak_window_height - 16 - 1) / 2
				))s | tr ' ' '\n';
				printf %s '<esc>'
			)}"
			# put a few lines at the end to make sure that
			# the line numbers continue in a pretty way
			# this doesn't really mather so we add a few extra
			# to comensate for any integer roundings
			printf "%s\n" "execute-keys %{gei$(
				printf %$((
					(kak_window_height - 17 + 10) / 2
				))s | tr ' ' '\n';
				printf %s '<esc>gg'
			)}"
		}
	}

	# don't place the cursor on the splash
	# this can't be done in the hook above as
	# win resize is executed in a draft context
	hook -group splash-center buffer NormalIdle .* %{
		execute-keys "gg"
	}

	# if the user pressed a key we shouldn't mess with it
	# But if the user is typing a command we may as well
	# display the splash a litle longer
	hook -group splash-center buffer NormalKey [^:]* %{
		remove-hooks buffer splash-center
		# show the cursor again
		face buffer PrimaryCursorEol PrimaryCursorEol
		# clear the buffer
		execute-keys -draft %{%d}
	}
}

