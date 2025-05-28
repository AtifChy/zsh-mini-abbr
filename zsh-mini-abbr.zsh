(( ${+_ZSH_MINI_ABBR_VERSION} )) || typeset -gr _ZSH_MINI_ABBR_VERSION="v0.2.5"
typeset -gA _zsh_mini_abbrs
typeset -gi _ZSH_MINI_ABBR_STATUS

function _zsh_mini_abbr::register() {
  local kind=$1 key=${2%%=*} value=${2#*=} is_eval=$3
  case $kind in
    g) alias -g $key=$value ;;
    c) alias $key=$value ;;
    *) return 1 ;;
  esac
  _zsh_mini_abbrs[$key]="$kind\0$value\0$is_eval"
}

function mini-abbr-expand() {
  emulate -L zsh -o noaliases -o noglob

  local -a words
  local -i is_eval
  local lastword abbr prefix inserted

  # Extract the last word from the command line left buffer
  words=( ${(s. .)LBUFFER} )
  lastword=${words[-1]#(\"|)(\$\(|\`)}

  abbr=${_zsh_mini_abbrs[$lastword]}
  [[ -n $abbr ]] || return 0
  is_eval=${${(s.\0.)abbr}[3]}

  # Extract the prefix of the last word
  prefix=${LBUFFER%$lastword}

  # Try to expand the alias for the last word; if not possible, exit the function
  zle _expand_alias || return 0

  # Get the inserted text after prefix
  inserted=${LBUFFER#$prefix}

  if (( is_eval )) && [[ -n $inserted ]]; then
    LBUFFER=$prefix${(e)inserted}
  else
    LBUFFER=$prefix$inserted
  fi

  LBUFFER=${LBUFFER%% }
  _ZSH_MINI_ABBR_STATUS=1
}

function mini-abbr-expand-and-insert() {
  zle mini-abbr-expand
  zle self-insert
}

function mini-abbr-expand-and-accept-line() {
  zle mini-abbr-expand
  zle accept-line
}

function mini-abbr-expand-and-end-of-line() {
  zle mini-abbr-expand
  zle end-of-line
}

function mini-abbr-no-expand() {
  LBUFFER+=' '
}

function _zsh_mini_abbr::reset_status() {
  _ZSH_MINI_ABBR_STATUS=0
}

function _zsh_mini_abbr::init() {
  zle -N mini-abbr-expand
  zle -N mini-abbr-expand-and-insert
  zle -N mini-abbr-no-expand
  zle -N mini-abbr-expand-and-accept-line
  zle -N mini-abbr-expand-and-end-of-line
  bindkey ' '    mini-abbr-expand-and-insert
  bindkey '^ '   mini-abbr-no-expand
  bindkey '^M'   mini-abbr-expand-and-accept-line
  bindkey '^[[F' mini-abbr-expand-and-end-of-line

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _zsh_mini_abbr::reset_status
}

function _zsh_mini_abbr::show() {
  local kind_filter=$1
  local key=$2
  local abbr=${_zsh_mini_abbrs[$key]}
  [[ -n $abbr ]] || return 1
  local kind=${${(s.\0.)abbr}[1]}
  local value=${${(s.\0.)abbr}[2]}
  if [[ $kind_filter == $kind ]]; then
    print "${(q+)key}=${(q+)value}"
  fi
  return 0
}

function _zsh_mini_abbr::list() {
  local kind_filters=$1
  for kind_filter in ${(s::)kind_filters}; do
    for key in ${(ko)_zsh_mini_abbrs}; do
      _zsh_mini_abbr::show $kind_filter $key
    done
  done
}

function _zsh_mini_abbr::unregister() {
  local key=$1
  if [[ -n $_zsh_mini_abbrs[$key] ]]; then
    unalias $key
    unset "_zsh_mini_abbrs[$key]"
  else
    print "abbr: $key: not found" >&2
    return 1
  fi
}

function _zsh_mini_abbr::help() {
  print -P "%B%F{blue}abbr%f%b is a command to manage abbreviations.

%U%BUSAGE:%b%u
  abbr [options] {name=command ...}
  abbr -u {name ...}

%U%BOPTIONS:%b%u
  -c, --command       register alias as 'alias name=command' [default]
  -g, --global        register alias as 'alias -g name=command'
  -e, --eval          evaluate the command before expanding
  -u, --unset         unset abbreviation
  -h, --help          show this help"
}

function abbr() {
  local -i result=0

  # This zparseopts syntax is only compatible with zsh 5.8+
  zparseopts -D -F -- \
    {h,-help}=help \
    {u,-unset}=unset \
    {c,-command}=command \
    {g,-global}=global \
    {e,-eval}=eval

  if (( $#help )); then
    _zsh_mini_abbr::help
    return 0
  fi

  if (( $#unset )); then
    if (( ! $# )); then
      print "unabbr: not enough arguments" >&2
      return 1
    fi
    for key in $@; do
      _zsh_mini_abbr::unregister $key || result=1
    done
    return $result
  fi

  local kind
  if (( $#command )); then
    kind=c
  elif (( $#global )); then
    kind=g
  fi

  (( ! $#eval )); local -i is_eval=$?

  if (( ! $# )); then
    _zsh_mini_abbr::list ${kind:-gc}
    return 0
  fi

  while (( $# )); do
    if [[ $1 =~ "=" ]]; then
      _zsh_mini_abbr::register ${kind:-c} $1 $is_eval
    else
      _zsh_mini_abbr::show ${kind:-c} $1
      [[ $? -eq 1 ]] && result=1
    fi
    shift
  done
  return $result
}

function unabbr() {
  abbr -u $@
}

_zsh_mini_abbr::init
unfunction _zsh_mini_abbr::init
