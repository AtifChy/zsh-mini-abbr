# zsh-mini-abbr

A minimal Zsh plugin for managing command and global abbreviations,
inspired by fish shell's abbr.
Easily register, expand, list, and remove abbreviations for faster command-line workflows.

## Features

- Register command (`alias name=value`) and global (`alias -g name=value`) abbreviations
- Automatic expansion as you type
- Simple commands to list, show, and remove abbreviations
- Lightweight and dependency-free

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
echo 'source /path/to/zsh-mini-abbr/zsh-mini-abbr.plugin.zsh' >> ~/.zshrc
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
  abbr [options] {name=value ...}
  abbr -u {name ...}

OPTIONS:
  -c, --command       register alias as 'alias name=value' [default]
  -g, --global        register alias as 'alias -g name=value'
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
