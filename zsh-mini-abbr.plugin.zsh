typeset -gr _ZSH_MINI_ABBR_VERSION="v0.1.0"
typeset -gA _zsh_mini_abbrs
typeset -gi _ZSH_MINI_ABBR_STATUS

function zma::register {
  local kind=$1 key=${2%%=*} value=${2#*=}
  case $kind in
    g) alias -g $key=$value ;;
    c) alias $key=$value ;;
    *) return 1 ;;
  esac
  _zsh_mini_abbrs[$key]="$kind\0$value"
}

function zma::expand {
  local word=${${(Az)LBUFFER}[-1]}
  local abbr=${_zsh_mini_abbrs[$word]}
  if [[ -n $abbr ]]; then
    zle _expand_alias
    _ZSH_MINI_ABBR_STATUS=1
  fi
}

function zma::expand_and_insert {
  zle zma::expand
  zle self-insert
}

function zma::expand_and_accept_line {
  zle zma::expand
  zle accept-line
}

function zma::expand_and_end_of_line {
  zle zma::expand
  zle end-of-line
}

function zma::no_expand {
  LBUFFER+=' '
}

function zma::reset_tips_status {
  _ZSH_MINI_ABBR_STATUS=0
}

function zma::init {
  zle -N zma::expand
  zle -N zma::expand_and_insert
  zle -N zma::no_expand
  zle -N zma::expand_and_accept_line
  zle -N zma::expand_and_end_of_line
  bindkey ' '    zma::expand_and_insert
  bindkey '^ '   zma::no_expand
  bindkey '^M'   zma::expand_and_accept_line
  bindkey '^[[F' zma::expand_and_end_of_line

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd zma::reset_tips_status
}

function zma::show {
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

function zma::list {
  local kind_filters=$1
  for kind_filter in ${(s::)kind_filters}; do
    for key in ${(ko)_zsh_mini_abbrs}; do
      zma::show $kind_filter $key
    done
  done
}

function zma::unregister {
  local key=$1
  if [[ -n $_zsh_mini_abbrs[$key] ]]; then
    unalias $key
    unset "_zsh_mini_abbrs[$key]"
  else
    print "abbr: $key: not found" >&2
    return 1
  fi
}

function zma::help {
  print -P "%B%F{blue}abbr%f%b is a command to manage abbreviations.

%U%BUSAGE:%b%u
  abbr [options] {name=value ...}
  abbr -u {name ...}

%U%BOPTIONS:%b%u
  -c, --command       register alias as 'alias name=value' [default]
  -g, --global        register alias as 'alias -g name=value'
  -u, --unset         unset abbreviation
  -h, --help          show this help"
}

function abbr {
  zparseopts -D -F -- \
    {h,-help}=help \
    {u,-unset}=unset \
    {c,-command}=command \
    {g,-global}=global

  if (( $#help )); then
    zma::help
    return 0
  fi

  if (( $#unset )); then
    for key in $@; do
      zma::unregister $key
    done
    return 0
  fi

  local kind
  if (( $#command )); then
    kind=c
  elif (( $#global )); then
    kind=g
  fi

  if (( ! $# )); then
    zma::list ${kind:-gc}
    return 0
  fi

  local result=0
  while (( $# )); do
    if [[ $1 =~ "=" ]]; then
      zma::register ${kind:-c} $1
    else
      zma::show ${kind:-c} $1
      if [[ $? != 0 ]]; then
        result=1
      fi
    fi
    shift
  done
  return $result
}

zma::init
unfunction zma::init
