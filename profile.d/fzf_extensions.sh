#!/bin/sh
#
# fzf-extensions: A collection of useful, POSIX-compliant shell functions
# extending fzf's capabilities, including an advanced file previewer.
# To use these, source this file in your shell's configuration file (e.g., .bashrc, .zshrc):
# > . /path/to/fzf-extensions.sh
# Ensure you have fzf installed and available in your PATH.


# -----------------------------------------------------------------------------
# fzf_find_files (zff)
#
# Find files using 'fd' or 'find' with the advanced previewer.
# -----------------------------------------------------------------------------
fzf_find_files() (
	find_cmd=""
	if > /dev/null 2>&1 command -v fd
	then
		find_cmd="fd --type f --hidden --follow --exclude .git"
	else
		find_cmd="find . -type f -not -path '*/.git/*'"
	fi

	if command -v _fzf_previewer.sh > /dev/null; then
		preview_cmdstr='_fzf_previewer.sh {}'
	elif command -v fzf-preview.sh > /dev/null; then
		preview_cmdstr='fzf-preview.sh {}'
	else
		preview_cmdstr='flie -- {}'
	fi
	eval "$find_cmd" | fzf --multi --height=80% --layout=reverse \
		--preview="${preview_cmdstr}" \
		--bind "enter:execute(${EDITOR:-vi} {})" \
		--prompt "Files > " \
		--header "Press ENTER to edit."
	)

	alias fz-find=fzf_find_files
	alias zff=fzf_find_files

# -----------------------------------------------------------------------------
# fzf_search_content (zfg)
#
# Interactively search for content within files using 'ripgrep' (rg).
# -----------------------------------------------------------------------------
# shellcheck disable=SC2016
fzf_search_files() (
	if ! command -v rg > /dev/null 2>&1
	then
		printf '%s: missing required dependency: `ripgrep`\n' "$0" >&2
		return 1
	fi
	rg_cmdstr="$(shellquote rg --color=always --line-number --no-heading --files-with-matches | tr '\n' ' ')"
	rg_argstr="$(shellquote "$@" | tr '\n' ' ')"

	if command -v _fzf_previewer.sh > /dev/null; then
		preview_cmdstr='_fzf_previewer.sh {}'
	elif command -v fzf-preview.sh > /dev/null; then
		preview_cmdstr='fzf-preview.sh {}'
	elif command -v bat > /dev/null; then
		preview_cmdstr='bat --style=numbers,changes --color=always --highlight-line "$(echo {} | cut -d: -f1)" "$(echo {} | cut -d: -f2)"'
else
	preview_cmdstr="file -- {}"
	fi

	# rg output format is "file:line:col:content".
	export FZF_DEFAULT_COMMAND="${rg_cmdstr} -- '.*' ${rg_argstr}"
	fzf \
		--disabled \
		--bind="change:reload:${rg_cmdstr} -- {q} ${rg_argstr}" \
		--query="" \
		--preview="${preview_cmdstr}" \
		--ansi \
		--delimiter ':' \
		--height=80% --layout=reverse \
		--bind="enter:execute(${EDITOR:-vi} +{2} {1})" \
		--prompt="Search > " \
		--header="Press ENTER to open file."
	)
	alias fz-grep=fzf_search_files
	alias zfg=fzf_search_files

# -----------------------------------------------------------------------------
# fzf_kill_process (zfk)
#
# Interactively find and kill processes.
# -----------------------------------------------------------------------------
fzf_kill_process() (
	processes=$(ps -ef | tail -n +2)
	if [ -z "$processes" ]; then echo "No processes found." >&2; return 1; fi

	selected_pids=$(echo "$processes" | fzf --multi --height=50% --layout=reverse \
		--prompt "Kill > " \
		--header "Press TAB to select, ENTER to kill." \
		--preview 'printf "%s\\n" {2..} | xargs ps -o user,pid,ppid,pcpu,pmem,stat,time,command -p' \
		--bind "enter:become(echo {} | awk '{print \$2}')")

	if [ -n "$selected_pids" ]
	then
		echo "You are about to kill the following process(es):"
		echo "$selected_pids" | xargs ps -p
		printf "Are you sure? (y/N) "
		read -r response
		if [ "$response" = "y" ] || [ "$response" = "Y" ]
		then
			echo "$selected_pids" | xargs kill -9
			echo "Process(es) terminated."
		else
			echo "Operation cancelled."
		fi
	else
		echo "No process selected."
	fi
)
alias fz-kill=fzf_kill_process
alias zfk=fzf_kill_process

# -----------------------------------------------------------------------------
# fzf_find_executable (zfx)
#
# Find executables in your $PATH.
# -----------------------------------------------------------------------------
# shellcheck disable=SC2016
fzf_find_executable() (
	executables=$(
		echo "$PATH" | tr ':' '\n' | while read -r dir
	do
		[ -d "$dir" ] && find "$dir" -maxdepth 1 -type f -perm -u+x,g+x,o+x -printf "%f\n" 2>/dev/null
	done | sort -u
)

if command -v _fzf_previewer.sh > /dev/null; then
	preview_cmdstr='_fzf_previewer.sh {}'
elif command -v fzf-preview.sh > /dev/null; then
	preview_cmdstr='fzf-preview.sh {}'
else
	preview_cmdstr='flie -- {}'
fi
selected_cmd=$(echo "$executables" | fzf --height=50% --layout=reverse \
	--preview="${preview_cmdstr}" \
	--prompt "Exec > " \
	--header "Select an executable.")

exec "$selected_cmd" "$@"
)
alias fz-find-x=fzf_find_executable
alias zfx=fzf_find_executable

# -----------------------------------------------------------------------------
# shellquote
#
# Quote each argument for safe evaluation
# -----------------------------------------------------------------------------
# shellcheck disable='SC3050'
if command -v printf > /dev/null && printf '%q' '' > /dev/null 2>&1; then
	shellquote() {
		while test "$#" -gt 0; do
			printf '%q\n' "$1"
			shift
		done
	}
elif command -v env && env printf '%q' '' > /dev/null 2>&1; then
	shellquote() {
		while test "$#" -gt 0; do
			env printf '%q\n' "$1"
			shift
		done
	}
elif command -v sed > /dev/null 2>&1; then
	shellquote () {
		while test "$#" -gt 0; do
			# shellcheck disable=SC2016
			printf '%s\n' "$1" | sed -E -n '
			:r
			$be
			N
			br
			:e
			s%'\''%'\'\\\\\'\''%g
			s%\`|'\\\''%'\''%g
			p'
			shift
		done
	}
else
	shellquote () (
		while test "$#" -gt 0; do
			orig="$1"
			quot=""
			span=""
			while test -n "${orig}"; do
				span="${orig%%\'*}"
				orig="${orig#"${span}"}"
				quot="${quot}${span}"
				case "${orig}" in
					(\'*)
						quot="${quot}'"'\'"''"
						orig="${orig#"'"}"
						;;
				esac
			done
			printf '%s\n' "'${quot}'"
			shift
		done
	)
fi

# -----------------------------------------------------------------------------
# shellunquote
#
# Remove a level of quoting from each argument
# -----------------------------------------------------------------------------
shellunquote() {
	while test "$#" -gt 0
	do
		eval 'printf' \''%s\n'\' "$1"
		shift
	done
}

# -----------------------------------------------------------------------------
# _fzf_previewer.sh
#
# We're going to write the remainder of this script to a file in ~/.local/bin
# -----------------------------------------------------------------------------
{
	rm -f "${HOME}/.local/bin/_fzf_previewer.sh" && cat > "${HOME}/.local/bin/_fzf_previewer.sh" && chmod +x "${HOME}/.local/bin/_fzf_previewer.sh"
} > /dev/null 2>&1 << \EOF
#!/usr/bin/env sh

filepath="$1"
mimetype=$(file --mime-type -b -- "$filepath")

case "$mimetype" in
	# --- Directories ---
	inode/directory)
	# Use `exa` for a tree view if available, otherwise `ls`
	if > /dev/null 2>&1 command -v exa
	then
		exa --tree --level=2 --icons --color=always -- "$filepath"
	else
		ls -lA -- "$filepath"
	fi
	;;

	# --- Archives ---
	application/zip) unzip -l -- "$filepath" ;;
	application/x-rar) unrar l -- "$filepath" ;;
	application/x-7z-compressed) 7z l -- "$filepath" ;;
	application/gzip | application/x-bzip2 | application/x-xz | application/x-tar)
		tar -tf -- "$filepath"
		;;
	application/vnd.debian.binary-package)
		> /dev/null 2>&1 command -v dpkg && dpkg -c -- "$filepath" || echo "dpkg not found"
		;;

	# --- Media Files ---
	image/*)
	# Display image previews with viu or show metadata
	if > /dev/null 2>&1 command -v viu
	then
		viu -b -- "$filepath"
	elif > /dev/null 2>&1 command -v exiftool
	then
		exiftool -- "$filepath"
	else
		file -- "$filepath"
	fi
	;;
video/* | audio/*)
	# Show media metadata
	if > /dev/null 2>&1 command -v mediainfo
	then
		mediainfo -- "$filepath"
	elif > /dev/null 2>&1 command -v exiftool
	then
		exiftool -- "$filepath"
	else
		file -- "$filepath"
	fi
	;;

	# --- Documents ---
	application/pdf)
	# Extract text from PDFs or show info
	if > /dev/null 2>&1 command -v pdftotext
	then
		pdftotext -l 5 -nopgbrk -q -- "$filepath" - | head -n 100
	elif > /dev/null 2>&1 command -v exiftool
	then
		exiftool -- "$filepath"
	else
		file -- "$filepath"
	fi
	;;

	# --- Text-based Files (and fallbacks) ---
	text/* | application/json | *)
	# Use `bat` for syntax-highlighted previews, with a fallback to `cat`.
	if > /dev/null 2>&1 command -v bat
	then
		bat --style=numbers,changes --color=always --line-range :500 -- "$filepath"
	else
		cat -- "$filepath"
	fi
	;;
esac
EOF

# vi:ts=8:sw=8:noet:sts=8:ft=sh
