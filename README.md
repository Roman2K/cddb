# cddb

Simple [autojump][autojump] alternative written in Ruby with no dependencies,
backed by a JSON database.

* Switch directories typing parts of their basenames
* Learns new directories as you go or in batch
* Prioritizes most recently accessed ones when resolving names
* Autocomplete for Bash
* Its code is easy to understand

## Installation

0. Requirement:
  * Ruby (>= 2.0)
  * Bash
1. Clone to `~/opt/cddb` for example.
2. Add to `~/.bash_profile`:

    ```
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
$ j ed
```

Autocomplete works as expected:

```
$ j ed<TAB>   # => j map/MAP-editor
```

## Commands

The db is stored at `~/.cddb`. It can be inspected and manipuled with `j --
action arg ...`:

* `j -- find pattern` print the first match, same mechanism as used behind `j
  pattern`
* `j -- complete pattern` print all matches, used by the shell autocompletion
* `j -- list` prints all entries stored in the db
* `j -- add path ...` manually add paths
* `j -- delete pattern` delete entries, pattern matches paths instead of
  basenames
* `j -- prune` clean up deleted directories and duplicates
* `j -- gc max` keep at most `max` most recent entries
* `j -- rebuild` resets the db by deleting and re-adding existing paths
* `j -- clear` empties the db

## Background

Why not use autojump? Well, when I discovered autojump, I was very much
delighted with the concept... At least my interpretation of the concept. My
enthusiasm didn't last long. Trying to use it, I couldn't figure out how it
saved visited directories, nor how it resolved directories from typed names.
Maybe I didn't fully grasp its concept after all, if at all, and my expectation
had nothing to do with autojump's purpose, as its behaviour wasn't intuitive to
me. Regardless, autojump gave me an idea for a tool and I wrote it.

[autojump]: https://github.com/joelthelion/autojump
