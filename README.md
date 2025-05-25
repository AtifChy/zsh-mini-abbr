# zsh-mini-abbr

A minimal zsh plugin for creating regular and global abbreviations, inspired by fish shell's abbr.
Easily register, expand, list, and remove abbreviations for faster command-line workflows.

## Features

- Register command (`alias name=command`) and global (`alias -g name=command`) abbreviations
- Automatic expansion as you type
- Simple commands to list, show, and remove abbreviations
- Lightweight and dependency-free

**Required zsh version: 5.8 or higher**

## Installation

### Package Manager

#### Using [antidote](https://github.com/mattmc3/antidote.git)

```sh
antidote bundle AtifChy/zsh-mini-abbr
```

### Manual

Clone this repository and source the plugin in your `.zshrc`:

```sh
git clone https://github.com/AtifChy/zsh-mini-abbr.git
echo "source ${(q-)PWD}/zsh-mini-abbr/zsh-mini-abbr.plugin.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
```

Restart your shell or run `source ~/.zshrc`.

## Usage

### Register an abbreviation

- Command abbreviation (default):

  ```sh
  abbr gs='git status'
  ```

- Global abbreviation:

  ```sh
  abbr -g G='| grep'
  ```

### List abbreviations

```sh
abbr
```

### Show a specific abbreviation

```sh
abbr gs
```

### Remove an abbreviation

```sh
abbr -u gs
```

### Help

```
$ abbr -h

abbr is a command to manage abbreviations.

USAGE:
  abbr [options] {name=command ...}
  abbr -u {name ...}

OPTIONS:
  -c, --command       register alias as 'alias name=command' [default]
  -g, --global        register alias as 'alias -g name=command'
  -u, --unset         unset abbreviation
  -h, --help          show this help
```

## Key Bindings

- <kbd>Space</kbd>: Expand abbreviation and insert space
- <kbd>Ctrl+Space</kbd>: Insert space without expanding
- <kbd>Enter</kbd>: Expand abbreviation and accept line
- <kbd>End</kbd>: Expand abbreviation and move to end of line

## Special Thanks

[momo-lab/zsh-abbrev-alias](https://github.com/momo-lab/zsh-abbrev-alias.git)

## License

MIT License © 2025 Md. Iftakhar Awal Chowdhury
