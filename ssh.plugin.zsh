#!/usr/bin/env zsh

ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${TMPDIR:-/tmp}/zsh-${UID:-user}}"
CACHE_FILE="${ZSH_CACHE_DIR}/ssh-hosts.zsh"

hosts=()
if [[ -f ~/.ssh/config ]]; then
  if [[ "$CACHE_FILE" -nt "$HOME/.ssh/config" ]]; then
    source "$CACHE_FILE"
  else
    mkdir -p "${CACHE_FILE:h}"
    # Parse Host entries, ignoring wildcards and Ignore entries, support case-insensitive and indented Host
    hosts=( $(awk '/^[ \t]*[Hh][Oo][Ss][Tt] / {
      for (i=2; i<=NF; i++) {
        if ($i !~ /[*?]/ && $i !~ /[Ii]gnore/) print $i
      }
    }' ~/.ssh/config | sort -u) )

    typeset -p hosts >! "$CACHE_FILE" 2> /dev/null
    zcompile "$CACHE_FILE"
  fi
fi

zstyle ':completion:*:hosts' hosts $hosts

zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' sort false
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' format ' %F{yellow}-- %d --%f'

zstyle ':completion:*:(ssh|scp|rsync|sshfs|mosh):*' group-name ''
zstyle ':completion:*:(ssh|scp|rsync|sshfs|mosh):*' verbose yes

zstyle ':completion:*:(ssh|mosh):*' group-order users hosts-host users

zstyle ':completion:*:(scp|rsync|sshfs):*' group-order files all-files hosts-domain hosts-host hosts-ipaddr users
