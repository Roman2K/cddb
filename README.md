# cddb

Simple directory switcher written in Ruby with no dependencies, backed by a JSON database.

* Switch directories typing fuzzy [CtrlP][ctrlp]-like patterns
* Learns about new directories as you go or in batch
* Prioritizes most recently accessed ones when resolving names
* Autocomplete for Bash
* Lean code base

Alternatives:

* [autojump][autojump]
* [z][z]

## Installation

0. Requirement:
  * Ruby (>= 2.0)
  * Bash
1. Clone to `~/opt/cddb` for example.
2. Add to `~/.bash_profile`:

    ```bash
    source ~/opt/cddb/bashcomp.sh
    ``` 

## Usage

Given the following dir structure:

```
code
├── bin
├── cddb
├── chrome-new-window
├── comedies
├── ddl
├── dotfiles
├── node-mkfiletree
├── parallel
├── sabnzbd-cleanup
├── series-cleanup
└── series-trakt
map
├── MAP
├── MAP-editor
├── MAP-mo
├── MAP-workers
└── services
```

Initially, cddb doesn't know of any directories. Tell it about `code` and all of
its subdirectories:

```bash
$ j -- add code code/*
```

You can now jump to `code/node-mkfiletree` with:

```bash
$ j mkf
```

Jump to `MAP-editor` for the first time:

```bash
$ j map/MAP-editor
```

Next time:

```bash
$ j maped
```

Autocomplete works as expected:

```bash
$ j maped<TAB>   # => j ~/map/MAP-editor
```

## Commands

The db is stored at `~/.cddb`. It can be inspected and manipuled with `j --
action arg ...`:

* `j -- find pattern` print the first match, as used by `j pattern`
* `j -- complete pattern` print matches, as used by the autocompletion
* `j -- list` print all entries stored in the db
* `j -- add path ...` manually add paths
* `j -- delete pattern` delete matches
* `j -- prune` clean up deleted directories and duplicates
* `j -- gc max` keep at most `max` most recent entries
* `j -- rebuild` reset the db by deleting and re-adding existing paths
* `j -- clear` empty the db

[autojump]: https://github.com/joelthelion/autojump
[z]: https://github.com/rupa/z
[ctrlp]: https://github.com/kien/ctrlp.vim
